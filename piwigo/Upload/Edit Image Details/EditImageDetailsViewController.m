//
//  EditImageDetailsViewController.m
//  piwigo
//
//  Created by Spencer Baker on 2/8/15.
//  Copyright (c) 2015 bakercrew. All rights reserved.
//

#import "AppDelegate.h"
#import "EditImageDetailsViewController.h"
#import "EditImagePrivacyTableViewCell.h"
#import "EditImageTextFieldTableViewCell.h"
#import "EditImageTextViewTableViewCell.h"
#import "EditImageThumbnailTableViewCell.h"
#import "EditImageTagsTableViewCell.h"
#import "ImageUpload.h"
#import "ImageService.h"
#import "MBProgressHUD.h"
#import "SelectPrivacyViewController.h"
#import "TagsViewController.h"
#import "UploadService.h"

CGFloat const kEditImageDetailsWidth = 512.0;      // EditImageDetails view width

typedef enum {
    EditImageDetailsOrderThumbnail,
	EditImageDetailsOrderImageName,
	EditImageDetailsOrderAuthor,
	EditImageDetailsOrderPrivacy,
	EditImageDetailsOrderTags,
	EditImageDetailsOrderDescription,
	EditImageDetailsOrderCount
} EditImageDetailsOrder;

@interface EditImageDetailsViewController () <UITableViewDelegate, UITableViewDataSource, SelectPrivacyDelegate, TagsViewControllerDelegate>

@property (nonatomic, weak) IBOutlet UITableView *editImageDetailsTableView;

@end

@implementation EditImageDetailsViewController

-(void)awakeFromNib
{
	[super awakeFromNib];
	
    self.title = NSLocalizedString(@"imageDetailsView_title", @"Image Details");
	
    // Register palette changes
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applyColorPalette) name:kPiwigoNotificationPaletteChanged object:nil];
}

#pragma mark - View Lifecycle

-(void)applyColorPalette
{
    // Background color of the view
    self.view.backgroundColor = [UIColor piwigoBackgroundColor];

    // Navigation bar
    self.navigationController.navigationBar.backgroundColor = [UIColor piwigoBackgroundColor];
    self.navigationController.navigationBar.tintColor = [UIColor piwigoOrange];
    if (@available(iOS 11.0, *)) {
        self.navigationController.navigationBar.prefersLargeTitles = NO;
    }
    
    // Table view
    self.editImageDetailsTableView.backgroundColor = [UIColor piwigoBackgroundColor];
    [self.editImageDetailsTableView reloadData];
}

-(void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];

    // Navigation buttons in edition mode
    self.navigationController.navigationBarHidden = NO;
    if (self.isEdit)
    {
		UIBarButtonItem *cancel = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelEdit)];
        [cancel setAccessibilityIdentifier:@"Cancel"];
		UIBarButtonItem *done = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneEdit)];
        [done setAccessibilityIdentifier:@"Done"];

		self.navigationItem.leftBarButtonItem = cancel;
		self.navigationItem.rightBarButtonItem = done;
    }

    // Adjust content inset
    // See https://stackoverflow.com/questions/1983463/whats-the-uiscrollview-contentinset-property-for
    CGFloat navBarHeight = self.navigationController.navigationBar.bounds.size.height;
    CGFloat tableHeight = self.editImageDetailsTableView.bounds.size.height;
    CGFloat viewHeight = self.view.bounds.size.height;

    // On iPad, the form is presented in a popover view
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        [self.editImageDetailsTableView setContentInset:UIEdgeInsetsMake(0.0, 0.0, MAX(0.0, tableHeight + navBarHeight - viewHeight), 0.0)];
    } else {
        CGFloat statBarHeight = [UIApplication sharedApplication].statusBarFrame.size.height;
        [self.editImageDetailsTableView setContentInset:UIEdgeInsetsMake(0.0, 0.0, MAX(0.0, tableHeight + statBarHeight + navBarHeight - viewHeight), 0.0)];
    }
    
    // Set colors, fonts, etc.
    [self applyColorPalette];

    // Register for the keyboard notifications
    [self registerForKeyboardNotifications];
}

-(void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator{
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    
    // Reload the tableview on orientation change, to match the new width of the table.
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        
        // Store recent modification
        [self updateImageParameters];
        
        // Adjust content inset
        // See https://stackoverflow.com/questions/1983463/whats-the-uiscrollview-contentinset-property-for
        CGFloat navBarHeight = self.navigationController.navigationBar.bounds.size.height;
        CGFloat tableHeight = self.editImageDetailsTableView.bounds.size.height;

        // On iPad, the form is presented in a popover view
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
            CGRect mainScreenBounds = [UIScreen mainScreen].bounds;
            self.preferredContentSize = CGSizeMake(kEditImageDetailsWidth, ceil(CGRectGetHeight(mainScreenBounds)*2/3));
            [self.editImageDetailsTableView setContentInset:UIEdgeInsetsMake(0.0, 0.0, MAX(0.0, tableHeight + navBarHeight - size.height), 0.0)];
        } else {
            CGFloat statBarHeight = [UIApplication sharedApplication].statusBarFrame.size.height;
            [self.editImageDetailsTableView setContentInset:UIEdgeInsetsMake(0.0, 0.0, MAX(0.0, tableHeight + statBarHeight + navBarHeight - size.height), 0.0)];
        }

        // Reload table view
        [self.editImageDetailsTableView reloadData];
    } completion:nil];
}

-(void)viewWillDisappear:(BOOL)animated
{
    // Unregister for the keyboard notifications.
    [self unregisterKeyboardNotifications];

    // Return updated parameters or nil
    if ([self.delegate respondsToSelector:@selector(didFinishEditingDetails:)])
    {
        [self.delegate didFinishEditingDetails:self.imageDetails];
    }
}

#pragma mark - Edit methods

// NOTE: make sure that you set the image data before you set isEdit so it can download the appropriate data
-(void)setIsEdit:(BOOL)isEditChoice
{
    _isEdit = isEditChoice;
}

-(void)cancelEdit
{
    // No change
    self.imageDetails = nil;
    
    // Return to image preview
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)doneEdit
{
    // Store recent modification
    [self updateImageParameters];
	
    // Display HUD during the update
    dispatch_async(dispatch_get_main_queue(), ^{
        [self showUpdatingImageInfoHUD];
    });
    
    // Update image info on server and in cache
	[UploadService updateImageInfo:self.imageDetails
						onProgress:^(NSProgress *progress) {
							// Progress
						}
                      OnCompletion:^(NSURLSessionTask *task, NSDictionary *response) {
							
                            // Hide HUD
                            [self hideUpdatingImageInfoHUDwithSuccess:YES completion:^{
                                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 500 * NSEC_PER_MSEC), dispatch_get_main_queue(), ^{
                                    // Return to image preview
                                    [self dismissViewControllerAnimated:YES completion:nil];
                                });
                            }];
						}
                         onFailure:^(NSURLSessionTask *task, NSError *error) {
							// Failed
                            [self hideUpdatingImageInfoHUDwithSuccess:NO completion:^{
                                UIAlertController* alert = [UIAlertController
                                        alertControllerWithTitle:NSLocalizedString(@"editImageDetailsError_title", @"Failed to Update")
                                        message:NSLocalizedString(@"editImageDetailsError_message", @"Failed to update your changes with your server\nTry again?")
                                        preferredStyle:UIAlertControllerStyleAlert];
                                
                                UIAlertAction* dismissAction = [UIAlertAction
                                                actionWithTitle:NSLocalizedString(@"alertCancelButton", @"Cancel")
                                                style:UIAlertActionStyleCancel
                                                handler:^(UIAlertAction * action) {
                                                }];

                                UIAlertAction* retryAction = [UIAlertAction
                                                actionWithTitle:NSLocalizedString(@"alertRetryButton", @"Retry")
                                                style:UIAlertActionStyleDefault
                                                handler:^(UIAlertAction * action) {
                                                    [self doneEdit];
                                                }];

                                [alert addAction:dismissAction];
                                [alert addAction:retryAction];
                                if (@available(iOS 13.0, *)) {
                                    alert.overrideUserInterfaceStyle = [Model sharedInstance].isDarkPaletteActive ? UIUserInterfaceStyleDark : UIUserInterfaceStyleLight;
                                } else {
                                    // Fallback on earlier versions
                                }
                                [self presentViewController:alert animated:YES completion:nil];
                             }];
						}];
}


#pragma mark - HUD methods

-(void)showUpdatingImageInfoHUD
{
    // Create the loading HUD if needed
    MBProgressHUD *hud = [MBProgressHUD HUDForView:self.view];
    if (!hud) {
        hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    }
    
    // Change the background view shape, style and color.
    hud.square = NO;
    hud.animationType = MBProgressHUDAnimationFade;
    hud.backgroundView.style = MBProgressHUDBackgroundStyleSolidColor;
    hud.backgroundView.color = [UIColor colorWithWhite:0.f alpha:0.5f];
    hud.contentColor = [UIColor piwigoHudContentColor];
    hud.bezelView.color = [UIColor piwigoHudBezelViewColor];

    // Define the text
    hud.label.text = NSLocalizedString(@"editImageDetailsHUD_updating", @"Updating Image Info…");
    hud.label.font = [UIFont piwigoFontNormal];
}

-(void)hideUpdatingImageInfoHUDwithSuccess:(BOOL)success completion:(void (^)(void))completion
{
    dispatch_async(dispatch_get_main_queue(), ^{
        // Hide and remove the HUD
        MBProgressHUD *hud = [MBProgressHUD HUDForView:self.view];
        if (hud) {
            if (success) {
                UIImage *image = [[UIImage imageNamed:@"completed"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
                UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
                hud.customView = imageView;
                hud.mode = MBProgressHUDModeCustomView;
                hud.label.text = NSLocalizedString(@"completeHUD_label", @"Complete");
                [hud hideAnimated:YES afterDelay:2.f];
            } else {
                [hud hideAnimated:YES];
            }
        }
        if (completion) {
            completion();
        }
    });
}


#pragma mark - UITableView - Rows

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0.0;        // To hide the section header
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = 44.0;
    switch (indexPath.row)
    {
        case EditImageDetailsOrderThumbnail:
            height = 160.0;
            break;
            
        case EditImageDetailsOrderPrivacy:
        case EditImageDetailsOrderTags:
            height = 78.0;
            break;
            
        case EditImageDetailsOrderDescription:
            height = 506.0;
            break;

        default:
            break;
    }

    return height;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return EditImageDetailsOrderCount;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *tableViewCell = [UITableViewCell new];

	switch(indexPath.row)
	{
		case EditImageDetailsOrderThumbnail:
        {
            EditImageThumbnailTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"image"];
            [cell setupWithImage:self.imageDetails];
            tableViewCell = cell;
            break;
        }
        
        case EditImageDetailsOrderImageName:
		{
            EditImageTextFieldTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"title"];
            if(!cell)
            {
                cell = [EditImageTextFieldTableViewCell new];
            }

            cell.cellLabel.text = NSLocalizedString(@"editImageDetails_title", @"Title:");
            cell.cellLabel.textColor = [UIColor piwigoLeftLabelColor];
            cell.cellTextField.text = self.imageDetails.imageTitle;
            cell.cellTextField.textColor = [UIColor piwigoLeftLabelColor];
            cell.cellTextField.backgroundColor = [UIColor piwigoBackgroundColor];
            cell.cellTextField.placeholder = NSLocalizedString(@"editImageDetails_titlePlaceholder", @"Title");
            cell.cellTextField.tag = EditImageDetailsOrderImageName;

            tableViewCell = cell;
            break;
		}
		
        case EditImageDetailsOrderAuthor:
		{
            EditImageTextFieldTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"author"];
            if(!cell)
            {
                cell = [EditImageTextFieldTableViewCell new];
            }
            
            cell.cellLabel.text = NSLocalizedString(@"editImageDetails_author", @"Author:");
            cell.cellLabel.textColor = [UIColor piwigoLeftLabelColor];
            if ([self.imageDetails.author isEqualToString:@"NSNotFound"]) {
                cell.cellTextField.text = @"";
            } else {
                cell.cellTextField.text = self.imageDetails.author;
            }
            cell.cellTextField.textColor = [UIColor piwigoLeftLabelColor];
            cell.cellTextField.backgroundColor = [UIColor piwigoBackgroundColor];
            cell.cellTextField.placeholder = NSLocalizedString(@"settings_defaultAuthorPlaceholder", @"Author Name");
            cell.cellTextField.tag = EditImageDetailsOrderAuthor;
            tableViewCell = cell;
			break;
		}
		
        case EditImageDetailsOrderPrivacy:
		{
			EditImagePrivacyTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"privacy"];
			[cell setLeftLabelText:NSLocalizedString(@"editImageDetails_privacyLevel", @"Who can see this photo?")];
			[cell setPrivacyLevel:self.imageDetails.privacyLevel];
            tableViewCell = cell;
			break;
		}
		
        case EditImageDetailsOrderTags:
		{
			EditImageTagsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"tags"];
			[cell setTagList:self.imageDetails.tags];
            tableViewCell = cell;
			break;
		}
		
        case EditImageDetailsOrderDescription:
		{
			EditImageTextViewTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"description"];
			[cell setTextForTextView:self.imageDetails.comment];
            tableViewCell = cell;
			break;
		}
	}
	
    tableViewCell.backgroundColor = [UIColor piwigoCellBackgroundColor];
    tableViewCell.tintColor = [UIColor piwigoOrange];
	return tableViewCell;
}


#pragma mark - UITableViewDelegate Methods

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	
	if (indexPath.row == EditImageDetailsOrderPrivacy)
	{
        // Dismiss the keyboard
        [self.view endEditing:YES];
        
        // Store recent modification
        [self updateImageParameters];
        
        // Create view controller
        SelectPrivacyViewController *privacySelectVC = [SelectPrivacyViewController new];
		privacySelectVC.delegate = self;
		[privacySelectVC setPrivacy:(kPiwigoPrivacy)self.imageDetails.privacyLevel];
		[self.navigationController pushViewController:privacySelectVC animated:YES];
	}
	else if (indexPath.row == EditImageDetailsOrderTags)
	{
        // Dismiss the keyboard
        [self.view endEditing:YES];
        
        // Store recent modification
        [self updateImageParameters];
        
        // Create view controller
		TagsViewController *tagsVC = [TagsViewController new];
		tagsVC.delegate = self;
		tagsVC.alreadySelectedTags = [self.imageDetails.tags mutableCopy];
		[self.navigationController pushViewController:tagsVC animated:YES];
    }
    else if (indexPath.row == EditImageDetailsOrderAuthor) {
        if ([self.imageDetails.author isEqualToString:@"NSNotFound"]) { // only update if not yet set, dont overwrite
            if (0 < [[[Model sharedInstance] defaultAuthor] length]) {  // must know the default author
                self.imageDetails.author = [[Model sharedInstance] defaultAuthor];
                [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            }
        }
    }
	
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    BOOL result;
    switch (indexPath.row)
    {
        case EditImageDetailsOrderThumbnail:
        case EditImageDetailsOrderImageName:
        case EditImageDetailsOrderAuthor:
        case EditImageDetailsOrderDescription:
            result = NO;
            break;
            
        default:
            result = YES;
    }
    
    return result;
}


#pragma mark - Keyboard Notifications

- (void)registerForKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

- (void)keyboardWillHide:(NSNotification*)aNotification
{
    [self updateImageParameters];
}

-(void)updateImageParameters
{
    // Title
    EditImageTextFieldTableViewCell *textFieldCell = (EditImageTextFieldTableViewCell*)[self.editImageDetailsTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:EditImageDetailsOrderImageName inSection:0]];
    if (textFieldCell.cellTextField.text != nil) {
        self.imageDetails.imageTitle = textFieldCell.cellTextField.text;
    } else {
        self.imageDetails.imageTitle = @"";
    }

    // Author
    textFieldCell = (EditImageTextFieldTableViewCell*)[self.editImageDetailsTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:EditImageDetailsOrderAuthor inSection:0]];
    if ((textFieldCell.cellTextField.text != nil) && (textFieldCell.cellTextField.text.length > 0)) {
        self.imageDetails.author = textFieldCell.cellTextField.text;
    } else {
        self.imageDetails.author = @"NSNotFound";
    }

    // Description
    EditImageTextViewTableViewCell *textViewCell = (EditImageTextViewTableViewCell*)[self.editImageDetailsTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:EditImageDetailsOrderDescription inSection:0]];
    self.imageDetails.comment = textViewCell.getTextViewText;
}

- (void)unregisterKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}


#pragma mark - SelectPrivacyDelegate Methods

-(void)selectedPrivacy:(kPiwigoPrivacy)privacy
{
	// Update image parameter
    self.imageDetails.privacyLevel = privacy;
	
    // Update table view cell
    EditImagePrivacyTableViewCell *labelCell = (EditImagePrivacyTableViewCell*)[self.editImageDetailsTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:EditImageDetailsOrderPrivacy inSection:0]];
	[labelCell setPrivacyLevel:privacy];
}


#pragma mark - TagsViewControllerDelegate Methods

-(void)didExitWithSelectedTags:(NSArray *)selectedTags
{
    // Update image parameter
	self.imageDetails.tags = selectedTags;

    // Update table view cell
    EditImageTagsTableViewCell *cell = (EditImageTagsTableViewCell*)[self.editImageDetailsTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:EditImageDetailsOrderTags inSection:0]];
    [cell setTagList:self.imageDetails.tags];
}

@end
