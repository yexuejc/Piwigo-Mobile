//
//  ImagePreviewViewController.m
//  piwigo
//
//  Created by Spencer Baker on 2/21/15.
//  Copyright (c) 2015 bakercrew. All rights reserved.
//

#import "AppDelegate.h"
#import "ImagePreviewViewController.h"
#import "PiwigoImageData.h"
#import "ImageScrollView.h"
#import "ImageService.h"
#import "VideoView.h"
#import "Model.h"
#import "NetworkHandler.h"
#import "SAMKeychain.h"

@interface ImagePreviewViewController ()

@end

@implementation ImagePreviewViewController

-(instancetype)init
{
	self = [super init];
	if(self)
	{
        // Image
        self.scrollView = [ImageScrollView new];
        self.view = self.scrollView;

        // Video
        self.videoView = [VideoView new];

        // Register palette changes
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applyColorPalette) name:kPiwigoPaletteChangedNotification object:nil];
    }
	return self;
}

#pragma mark - View Lifecycle

-(void)applyColorPalette
{
    // Background color depends on the navigation bar visibility
    if (self.navigationController.navigationBarHidden)
        self.view.backgroundColor = [UIColor blackColor];
    else
        self.view.backgroundColor = [UIColor piwigoBackgroundColor];

    // Navigation bar
    NSDictionary *attributes = @{
                                 NSForegroundColorAttributeName: [UIColor piwigoWhiteCream],
                                 NSFontAttributeName: [UIFont piwigoFontNormal],
                                 };
    self.navigationController.navigationBar.titleTextAttributes = attributes;
    self.navigationController.navigationBar.barStyle = [Model sharedInstance].isDarkPaletteActive ? UIBarStyleBlack : UIBarStyleDefault;
    self.navigationController.navigationBar.tintColor = [UIColor piwigoOrange];
    self.navigationController.navigationBar.barTintColor = [UIColor piwigoBackgroundColor];
    self.navigationController.navigationBar.backgroundColor = [UIColor piwigoBackgroundColor];
    self.navigationBarHidden = YES;
}

-(void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];

    // Set colors, fonts, etc.
    [self applyColorPalette];    
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

-(void)setImageScrollViewWithImageData:(PiwigoImageData*)imageData
{
    // Display "play" button if video
    self.scrollView.playImage.hidden = !(imageData.isVideo);

    // Thumbnail image may be used as placeholder image
    NSString *thumbnailStr = [imageData getURLFromImageSizeType:(kPiwigoImageSize)[Model sharedInstance].defaultThumbnailSize];
    NSURL *thumbnailURL = [NSURL URLWithString:thumbnailStr];
    UIImageView *thumb = [UIImageView new];
    [thumb setImageWithURL:thumbnailURL placeholderImage:[UIImage imageNamed:@"placeholderImage"]];
    self.scrollView.imageView.image = thumb.image ? thumb.image : [UIImage imageNamed:@"placeholderImage"];

    // Previewed image
    NSString *previewStr = [imageData getURLFromImageSizeType:(kPiwigoImageSize)[Model sharedInstance].defaultImagePreviewSize];
    if (previewStr == nil) {
        // Image URL unknown => default to medium image size
        previewStr = [imageData getURLFromImageSizeType:kPiwigoImageSizeMedium];
    }
    NSURL *previewURL = [NSURL URLWithString:previewStr];
    __weak typeof(self) weakSelf = self;
    
//    NSLog(@"==> Start loading %@", previewURL.path);
    self.downloadTask = [[Model sharedInstance].imagesSessionManager GET:previewURL.absoluteString
                                                              parameters:nil
                progress:^(NSProgress *progress) {
                    dispatch_async(dispatch_get_main_queue(),
                       ^(void){
                           if([weakSelf.imagePreviewDelegate respondsToSelector:@selector(downloadProgress:)])
                       {
                           [weakSelf.imagePreviewDelegate downloadProgress:progress.fractionCompleted];
                       }
                                });
                }
                 success:^(NSURLSessionTask *task, UIImage *image) {
                     if (image != nil) {
                         weakSelf.scrollView.imageView.image = image;
                         if([weakSelf.imagePreviewDelegate respondsToSelector:@selector(downloadProgress:)])
                         {
                             [weakSelf.imagePreviewDelegate downloadProgress:1.0];
                         }
                         weakSelf.imageLoaded = YES;                      // Hide progress bar
                     }
                     else {     // Keep thumbnail or placeholder if image could not be loaded
        #if defined(DEBUG)
                         NSLog(@"setImageScrollViewWithImageData: loaded image is nil!");
        #endif
                     }
                 }
                 failure:^(NSURLSessionTask *task, NSError *error) {
        #if defined(DEBUG)
                     NSLog(@"setImageScrollViewWithImageData/GET Error: %@", error);
        #endif
                 }
             ];
    
    [self.downloadTask resume];
}

-(void)startVideoPlayerViewWithImageData:(PiwigoImageData*)imageData
{
    // Set URL
    NSURL *videoURL = [NSURL URLWithString:imageData.fullResPath];

    // Intialise video controller
    AVPlayer *videoPlayer = [AVPlayer playerWithURL:videoURL];
    AVPlayerViewController *playerController = [[AVPlayerViewController alloc] init];
    playerController.player = videoPlayer;
    playerController.videoGravity = AVLayerVideoGravityResizeAspect;
    
    // Playback controls
    playerController.showsPlaybackControls = YES;
//    [self.videoPlayer addObserver:self.imageView forKeyPath:@"rate" options:0 context:nil];
    
    // Start playing automatically…
    [playerController.player play];
    
    [self.videoView addSubview:playerController.view];
    playerController.view.frame = self.videoView.bounds;

    // Present the video
    UIViewController *currentViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
    while (currentViewController.presentedViewController)
    {
        currentViewController = currentViewController.presentedViewController;
    }
    [currentViewController presentViewController:playerController animated:YES completion:nil];
}

@end
