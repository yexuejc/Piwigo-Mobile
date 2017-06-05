//
//  DefaultImageSizeViewController.m
//  piwigo
//
//  Created by Spencer Baker on 5/12/15.
//  Copyright (c) 2015 bakercrew. All rights reserved.
//

#import "DefaultImageSizeViewController.h"
#import "PiwigoImageData.h"
#import "Model.h"

@interface DefaultImageSizeViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;

@end

@implementation DefaultImageSizeViewController

-(instancetype)init
{
	self = [super init];
	
	self.view.backgroundColor = [UIColor whiteColor];
	self.title = NSLocalizedString(@"defaultImageSizeTitle", @"Default Size");
	
	self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
	self.tableView.translatesAutoresizingMaskIntoConstraints = NO;
	self.tableView.dataSource = self;
	self.tableView.delegate = self;
	[self.view addSubview:self.tableView];
	[self.view addConstraints:[NSLayoutConstraint constraintFillSize:self.tableView]];
	
	return self;
}

#pragma mark - UITableView Methods

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
	return 50.0;
}
-(UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
	UIView *header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 50)];
	
	UILabel *headerLabel = [UILabel new];
	headerLabel.translatesAutoresizingMaskIntoConstraints = NO;
	headerLabel.font = [UIFont piwigoFontNormal];
	headerLabel.textColor = [UIColor piwigoGray];
    headerLabel.textAlignment = NSTextAlignmentCenter;
	headerLabel.text = NSLocalizedString(@"defaultImageSizeHeader", @"Please Select an Image Size");
	headerLabel.adjustsFontSizeToFitWidth = YES;
	headerLabel.minimumScaleFactor = 0.5;
	[header addSubview:headerLabel];
	[header addConstraint:[NSLayoutConstraint constraintViewFromBottom:headerLabel amount:10]];
	[header addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-15-[header]-15-|"
																   options:kNilOptions
																   metrics:nil
																	 views:@{@"header" : headerLabel}]];
	
	return header;
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return kPiwigoImageSizeEnumCount;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
	if(!cell) {
		cell = [UITableViewCell new];
	}
	
    // Name of the image size
    cell.textLabel.font = [UIFont piwigoFontNormal];
    cell.textLabel.textColor = [UIColor piwigoGray];
    cell.textLabel.adjustsFontSizeToFitWidth = NO;
    cell.textLabel.text = [PiwigoImageData nameForImageSizeType:(kPiwigoImageSize)indexPath.row];
    
    // Add checkmark in front of selected item
	if([Model sharedInstance].defaultImagePreviewSize == indexPath.row) {
		cell.accessoryType = UITableViewCellAccessoryCheckmark;
	} else {
		cell.accessoryType = UITableViewCellAccessoryNone;
	}
	
    // Disable unavailable sizes
    switch (indexPath.row) {
        case kPiwigoImageSizeSquare:
            if ([Model sharedInstance].hasSquareSizeImages) {
                cell.userInteractionEnabled = YES;
            } else {
                cell.userInteractionEnabled = NO;
                cell.textLabel.tintColor = [UIColor piwigoGrayLight];
                cell.textLabel.text = [cell.textLabel.text stringByAppendingString:NSLocalizedString(@"defaultImageSize_disabled", @" (disabled on server)")];
            }
            break;
        case kPiwigoImageSizeThumb:
            if ([Model sharedInstance].hasThumbSizeImages) {
                cell.userInteractionEnabled = YES;
            } else {
                cell.userInteractionEnabled = NO;
                cell.textLabel.tintColor = [UIColor piwigoGrayLight];
                cell.textLabel.text = [cell.textLabel.text stringByAppendingString:NSLocalizedString(@"defaultImageSize_disabled", @" (disabled on server)")];
            }
            break;
        case kPiwigoImageSizeXXSmall:
            if ([Model sharedInstance].hasXXSmallSizeImages) {
                cell.userInteractionEnabled = YES;
            } else {
                cell.userInteractionEnabled = NO;
                cell.textLabel.tintColor = [UIColor piwigoGrayLight];
                cell.textLabel.text = [cell.textLabel.text stringByAppendingString:NSLocalizedString(@"defaultImageSize_disabled", @" (disabled on server)")];
            }
            break;
        case kPiwigoImageSizeXSmall:
            if ([Model sharedInstance].hasXSmallSizeImages) {
                cell.userInteractionEnabled = YES;
            } else {
                cell.userInteractionEnabled = NO;
                cell.textLabel.tintColor = [UIColor piwigoGrayLight];
                cell.textLabel.text = [cell.textLabel.text stringByAppendingString:NSLocalizedString(@"defaultImageSize_disabled", @" (disabled on server)")];
            }
            break;
        case kPiwigoImageSizeSmall:
            if ([Model sharedInstance].hasSmallSizeImages) {
                cell.userInteractionEnabled = YES;
            } else {
                cell.userInteractionEnabled = NO;
                cell.textLabel.tintColor = [UIColor piwigoGrayLight];
                cell.textLabel.text = [cell.textLabel.text stringByAppendingString:NSLocalizedString(@"defaultImageSize_disabled", @" (disabled on server)")];
            }
            break;
        case kPiwigoImageSizeMedium:
            if ([Model sharedInstance].hasMediumSizeImages) {
                cell.userInteractionEnabled = YES;
            } else {
                cell.userInteractionEnabled = NO;
                cell.textLabel.tintColor = [UIColor piwigoGrayLight];
                cell.textLabel.text = [cell.textLabel.text stringByAppendingString:NSLocalizedString(@"defaultImageSize_disabled", @" (disabled on server)")];
            }
            break;
        case kPiwigoImageSizeLarge:
            if ([Model sharedInstance].hasLargeSizeImages) {
                cell.userInteractionEnabled = YES;
            } else {
                cell.userInteractionEnabled = NO;
                cell.textLabel.tintColor = [UIColor piwigoGrayLight];
                cell.textLabel.text = [cell.textLabel.text stringByAppendingString:NSLocalizedString(@"defaultImageSize_disabled", @" (disabled on server)")];
            }
            break;
        case kPiwigoImageSizeXLarge:
            if ([Model sharedInstance].hasXLargeSizeImages) {
                cell.userInteractionEnabled = YES;
            } else {
                cell.userInteractionEnabled = NO;
                cell.textLabel.tintColor = [UIColor piwigoGrayLight];
                cell.textLabel.text = [cell.textLabel.text stringByAppendingString:NSLocalizedString(@"defaultImageSize_disabled", @" (disabled on server)")];
            }
            break;
        case kPiwigoImageSizeXXLarge:
            if ([Model sharedInstance].hasXXLargeSizeImages) {
                cell.userInteractionEnabled = YES;
            } else {
                cell.userInteractionEnabled = NO;
                cell.textLabel.tintColor = [UIColor piwigoGrayLight];
                cell.textLabel.text = [cell.textLabel.text stringByAppendingString:NSLocalizedString(@"defaultImageSize_disabled", @" (disabled on server)")];
            }
            break;
        case kPiwigoImageSizeFullRes:
            cell.userInteractionEnabled = YES;
            break;
            
        default:
            break;
    }
    
	return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	
	[Model sharedInstance].defaultImagePreviewSize = (kPiwigoImageSize)indexPath.row;
	[[Model sharedInstance] saveToDisk];
	[self.tableView reloadData];
	
	[self.navigationController popViewControllerAnimated:YES];
}

@end
