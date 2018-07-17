//
//  ImageDetailViewController.h
//  piwigo
//
//  Created by Spencer Baker on 1/15/15.
//  Copyright (c) 2015 bakercrew. All rights reserved.
//

#import <UIKit/UIKit.h>

FOUNDATION_EXPORT NSString * const kPiwigoNotificationPinchedImage;

@class PiwigoImageData;

@protocol ImageDetailDelegate <NSObject>

-(void)didDeleteImage:(PiwigoImageData*)image;
-(void)needToLoadMoreImages;

@end


@interface ImageDetailViewController : UIPageViewController

@property (nonatomic, weak) id<ImageDetailDelegate> imgDetailDelegate;
@property (nonatomic, strong) NSMutableArray *images;

-(instancetype)initWithCategoryId:(NSInteger)categoryId atImageIndex:(NSInteger)imageIndex withArray:(NSArray*)array;

@end
