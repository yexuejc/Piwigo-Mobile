//
//  PiwigoImageData.h
//  piwigo
//
//  Created by Spencer Baker on 1/15/15.
//  Copyright (c) 2015 bakercrew. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Model.h"

typedef enum {
	kPiwigoImageSizeSquare,
	kPiwigoImageSizeThumb,
	kPiwigoImageSizeXXSmall,
	kPiwigoImageSizeXSmall,
	kPiwigoImageSizeSmall,
	kPiwigoImageSizeMedium,
	kPiwigoImageSizeLarge,
	kPiwigoImageSizeXLarge,
	kPiwigoImageSizeXXLarge,
	kPiwigoImageSizeFullRes,
	kPiwigoImageSizeEnumCount
} kPiwigoImageSize;

@interface PiwigoImageData : NSObject

// API pwg.categories.getList returns:
//      id, categories, name, comment, hit
//      file, date_creation, date_available, width, height
//      element_url, derivatives, (page_url)
//
@property (nonatomic, assign) NSInteger imageId;                // id
@property (nonatomic, strong) NSArray *categoryIds;             // categories
@property (nonatomic, strong) NSString *imageTitle;             // title (don't use title!)
@property (nonatomic, strong) NSString *comment;                // description (don't use description!)
@property (nonatomic, assign) NSInteger visits;                 // hit
@property (nonatomic, strong) NSString *fileName;               // file name
@property (nonatomic, strong) NSDate *dateCreated;              // date_creation
@property (nonatomic, strong) NSDate *datePosted;               // date_available
@property (nonatomic, assign) NSInteger fullResWidth;           // width
@property (nonatomic, assign) NSInteger fullResHeight;          // height
@property (nonatomic, strong) NSString *fullResPath;            // element_url

@property (nonatomic, strong) NSString *SquarePath;             // derivatives
@property (nonatomic, assign) NSInteger SquareWidth;
@property (nonatomic, assign) NSInteger SquareHeight;

@property (nonatomic, strong) NSString *ThumbPath;
@property (nonatomic, assign) NSInteger ThumbWidth;
@property (nonatomic, assign) NSInteger ThumbHeight;

@property (nonatomic, strong) NSString *XXSmallPath;
@property (nonatomic, assign) NSInteger XXSmallWidth;
@property (nonatomic, assign) NSInteger XXSmallHeight;

@property (nonatomic, strong) NSString *XSmallPath;
@property (nonatomic, assign) NSInteger XSmallWidth;
@property (nonatomic, assign) NSInteger XSmallHeight;

@property (nonatomic, strong) NSString *SmallPath;
@property (nonatomic, assign) NSInteger SmallWidth;
@property (nonatomic, assign) NSInteger SmallHeight;

@property (nonatomic, strong) NSString *MediumPath;
@property (nonatomic, assign) NSInteger MediumWidth;
@property (nonatomic, assign) NSInteger MediumHeight;

@property (nonatomic, strong) NSString *LargePath;
@property (nonatomic, assign) NSInteger LargeWidth;
@property (nonatomic, assign) NSInteger LargeHeight;

@property (nonatomic, strong) NSString *XLargePath;
@property (nonatomic, assign) NSInteger XLargeWidth;
@property (nonatomic, assign) NSInteger XLargeHeight;

@property (nonatomic, strong) NSString *XXLargePath;
@property (nonatomic, assign) NSInteger XXLargeWidth;
@property (nonatomic, assign) NSInteger XXLargeHeight;

// API pwg.images.getInfo returns in addition:
//
//      author, level, tags, (added_by), rating_score, (rates), (representative_ext)
//      filesize, (md5sum), (date_metadata_update), (lastmodified), (rotation), (latitude), (longitude)
//      (comments), (comments_paging), (coi)
//
@property (nonatomic, strong) NSString *author;                 // author
@property (nonatomic, assign) NSInteger privacyLevel;           // level
@property (nonatomic, strong) NSArray *tags;                    // tags
@property (nonatomic, assign) float ratingScore;                // rating score
@property (nonatomic, assign) NSInteger fileSize;               // filesize

@property (nonatomic, assign) BOOL isVideo;

-(NSString*)getURLFromImageSizeType:(kPiwigoImageSize)imageSize;
+(float)widthForImageSizeType:(kPiwigoImageSize)imageSize;

+(NSInteger)optimumAlbumThumbnailSizeForDevice;
+(NSString*)nameForAlbumThumbnailSizeType:(kPiwigoImageSize)imageSize withInfo:(BOOL)addInfo;

+(NSInteger)optimumImageThumbnailSizeForDevice;
+(NSString*)nameForImageThumbnailSizeType:(kPiwigoImageSize)imageSize withInfo:(BOOL)addInfo;

+(NSInteger)optimumImageSizeForDevice;
+(NSString*)nameForImageSizeType:(kPiwigoImageSize)imageSize withInfo:(BOOL)addInfo;

@end
