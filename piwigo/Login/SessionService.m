//
//  SessionService.m
//  piwigo
//
//  Created by Spencer Baker on 1/20/15.
//  Copyright (c) 2015 bakercrew. All rights reserved.
//

#import "AppDelegate.h"
#import "ImagesCollection.h"
#import "Model.h"
#import "PiwigoImageData.h"
#import "SessionService.h"

@implementation SessionService

// Get Piwigo server methods
// and determine if the Community extension is installed and active
+(NSURLSessionTask*)getMethodsListOnCompletion:(void (^)(NSDictionary *methodsList))completion
                                     onFailure:(void (^)(NSURLSessionTask *task, NSError *error))fail
{
    return [self post:kReflectionGetMethodList
        URLParameters:nil
           parameters:nil
             progress:^(NSProgress * progress) {
                 if ([Model sharedInstance].userCancelledCommunication) {
                     [progress cancel];
                 }
             }
              success:^(NSURLSessionTask *task, id responseObject) {
                  
                  if(completion) {
                      
                      // Did the server answer the request? (it should have)
                      if([[responseObject objectForKey:@"stat"] isEqualToString:@"ok"])
                      {
                          // Loop over the methods
                          id methodsList = [[responseObject objectForKey:@"result"] objectForKey:@"methods"];
                          for (NSString *method in methodsList) {
                              
                              // Check if the Community extension is installed and active (> 2.9a)
                              if([method isEqualToString:@"community.session.getStatus"]) {
                                  [Model sharedInstance].usesCommunityPluginV29 = YES;
                              }
                          }
                          completion([[responseObject objectForKey:@"result"] objectForKey:@"methods"]);
                      }
                      else  // Strange…
                      {
                          completion(nil);
                      }
                  }
              } failure:^(NSURLSessionTask *task, NSError *error) {
                  
                  if(fail) {
                      fail(task, error);
                  }
              }];
}

+(NSURLSessionTask*)performLoginWithUser:(NSString*)user
                             andPassword:(NSString*)password
                            onCompletion:(void (^)(BOOL result, id response))completion
                               onFailure:(void (^)(NSURLSessionTask *task, NSError *error))fail
{
    [[Model sharedInstance] saveToDisk];
    
    return [self post:kPiwigoSessionLogin
        URLParameters:nil
           parameters:@{@"username" : user,
                        @"password" : password}
             progress:^(NSProgress * progress) {
                 if ([Model sharedInstance].userCancelledCommunication) {
                     [progress cancel];
                 }
             }
              success:^(NSURLSessionTask *task, id responseObject) {
                  
                  if(completion) {
                      if([[responseObject objectForKey:@"stat"] isEqualToString:@"ok"] && [[responseObject objectForKey:@"result"] boolValue])
                      {
                          [Model sharedInstance].username = user;
                          [Model sharedInstance].hadOpenedSession = YES;
                          [[Model sharedInstance] saveToDisk];
                          completion(YES, [responseObject objectForKey:@"result"]);
                      }
                      else
                      {
                          // May be this server only uses HTTP authentication
                          if ([Model sharedInstance].performedHTTPauthentication) {
                              [Model sharedInstance].username = user;
                              [Model sharedInstance].hadOpenedSession = YES;
                              [[Model sharedInstance] saveToDisk];
                             completion(YES, nil);
                          } else {
                              [Model sharedInstance].hadOpenedSession = NO;
                              completion(NO, nil);
                          }
                      }
                  }
              }
              failure:^(NSURLSessionTask *task, NSError *error) {
                  
                  if(fail)
                  {
                      [Model sharedInstance].hadOpenedSession = NO;
                      fail(task, error);
                  }
              }];
}

+(NSURLSessionTask*)getPiwigoStatusAtLogin:(BOOL)isLogginIn
                              OnCompletion:(void (^)(NSDictionary *responseObject))completion
                                 onFailure:(void (^)(NSURLSessionTask *task, NSError *error))fail
{
    return [self post:kPiwigoSessionGetStatus
        URLParameters:nil
           parameters:nil
             progress:^(NSProgress * progress) {
                 if ([Model sharedInstance].userCancelledCommunication) {
                     [progress cancel];
                 }
             }
              success:^(NSURLSessionTask *task, id responseObject) {
                  
                  if(completion) {
                      if([[responseObject objectForKey:@"stat"] isEqualToString:@"ok"])
                      {
                          NSDictionary *result = [responseObject objectForKey:@"result"];

                          if (isLogginIn) {
                              [Model sharedInstance].pwgToken = [result objectForKey:@"pwg_token"];
                              [Model sharedInstance].language = [result objectForKey:@"language"];
                              
                              // Piwigo server version should be of format 1.2.3
                              NSMutableString *versionStr = [result objectForKey:@"version"];
                              NSArray<NSString *> *components = [versionStr componentsSeparatedByString:@"."];
                              switch (components.count) {
                                  case 1:
                                      // Version of type 1
                                      [versionStr appendString:@".0.0"];
                                      break;

                                  case 2:
                                      // Version of type 1.2
                                      [versionStr appendString:@".0"];
                                      break;

                                  default:
                                      break;
                              }
                              [Model sharedInstance].version = versionStr;
                              
                              NSString *charset = [[result objectForKey:@"charset"] uppercaseString];
                              if ([charset isEqualToString:@"UTF-8"]) {
                                  [Model sharedInstance].stringEncoding = NSUTF8StringEncoding;
                              } else if ([charset isEqualToString:@"UTF-16"]) {
                                  [Model sharedInstance].stringEncoding = NSUTF16StringEncoding;
                              } else if ([charset isEqualToString:@"ISO-8859-1"]) {
                                  [Model sharedInstance].stringEncoding = NSWindowsCP1252StringEncoding;
                              } else if ([charset isEqualToString:@"US-ASCII"]) {
                                  [Model sharedInstance].stringEncoding = NSASCIIStringEncoding;
                              } else if ([charset isEqualToString:@"X-EUC"]) {
                                  [Model sharedInstance].stringEncoding = NSJapaneseEUCStringEncoding;
                              } else if ([charset isEqualToString:@"ISO-8859-3"]) {
                                  [Model sharedInstance].stringEncoding = NSISOLatin1StringEncoding;
                              } else if ([charset isEqualToString:@"ISO-8859-3"]) {
                                  [Model sharedInstance].stringEncoding = NSISOLatin1StringEncoding;
                              } else if ([charset isEqualToString:@"SHIFT-JIS"]) {
                                  [Model sharedInstance].stringEncoding = NSShiftJISStringEncoding;
                              } else if ([charset isEqualToString:@"CP870"]) {
                                  [Model sharedInstance].stringEncoding = NSISOLatin2StringEncoding;
                              } else if ([charset isEqualToString:@"UNICODE"]) {
                                  [Model sharedInstance].stringEncoding = NSUnicodeStringEncoding;
                              } else if ([charset isEqualToString:@"WINDOWS-1251"]) {
                                  [Model sharedInstance].stringEncoding = NSWindowsCP1251StringEncoding;
                              } else if ([charset isEqualToString:@"WINDOWS-1252"]) {
                                  [Model sharedInstance].stringEncoding = NSWindowsCP1252StringEncoding;
                              } else if ([charset isEqualToString:@"WINDOWS-1253"]) {
                                  [Model sharedInstance].stringEncoding = NSWindowsCP1253StringEncoding;
                              } else if ([charset isEqualToString:@"WINDOWS-1254"]) {
                                  [Model sharedInstance].stringEncoding = NSWindowsCP1254StringEncoding;
                              } else if ([charset isEqualToString:@"WINDOWS-1250"]) {
                                  [Model sharedInstance].stringEncoding = NSWindowsCP1250StringEncoding;
                              } else if ([charset isEqualToString:@"ISO-2022-JP"]) {
                                  [Model sharedInstance].stringEncoding = NSISO2022JPStringEncoding;
                              } else if ([charset isEqualToString:@"ISO-2022-JP"]) {
                                  [Model sharedInstance].stringEncoding = NSISO2022JPStringEncoding;
                              } else if ([charset isEqualToString:@"MACINTOSH"]) {
                                  [Model sharedInstance].stringEncoding = NSMacOSRomanStringEncoding;
                              } else if ([charset isEqualToString:@"UNICODEFFFE"]) {
                                  [Model sharedInstance].stringEncoding = NSUTF16BigEndianStringEncoding;
                              } else if ([charset isEqualToString:@"UTF-32"]) {
                                  [Model sharedInstance].stringEncoding = NSUTF32StringEncoding;
                              } else {
                                  // UTF-8 string encoding by default
                                  [Model sharedInstance].stringEncoding = NSUTF8StringEncoding;
                              }
                              
                              // Upload chunk size is null if not provided by server
                              NSInteger uploadChunkSize = [[result objectForKey:@"upload_form_chunk_size"] integerValue];
                              if (uploadChunkSize != 0) {
                                  [Model sharedInstance].uploadChunkSize = [[result objectForKey:@"upload_form_chunk_size"] integerValue];
                              } else {
                                  // Just in case…
                                  [Model sharedInstance].uploadChunkSize = 500;
                              }

                              // Images and videos can be uploaded if their file types are found.
                              // The iPhone creates mov files that will be uploaded in mp4 format.
                              // This string is nil if the server does not provide it.
                              [Model sharedInstance].uploadFileTypes = [result objectForKey:@"upload_file_types"];
                              
                              // User rights are determined by Community extension (if installed)
                              if(![Model sharedInstance].usesCommunityPluginV29) {
                                  NSString *userStatus = [result objectForKey:@"status"];
                                  [Model sharedInstance].hasAdminRights = ([userStatus isEqualToString:@"admin"] || [userStatus isEqualToString:@"webmaster"]);
                              }
                              
                              // Collect the list of available sizes
                              // Let's start with default values
                              [Model sharedInstance].hasSquareSizeImages  = YES;
                              [Model sharedInstance].hasThumbSizeImages   = YES;
                              [Model sharedInstance].hasXXSmallSizeImages = NO;
                              [Model sharedInstance].hasXSmallSizeImages  = NO;
                              [Model sharedInstance].hasSmallSizeImages   = NO;
                              [Model sharedInstance].hasMediumSizeImages  = YES;
                              [Model sharedInstance].hasLargeSizeImages   = NO;
                              [Model sharedInstance].hasXLargeSizeImages  = NO;
                              [Model sharedInstance].hasXXLargeSizeImages = NO;
                              
                              // Update list of available sizes
                              id availableSizesList = [result objectForKey:@"available_sizes"];
                              for (NSString *size in availableSizesList) {
                                  if ([size isEqualToString:@"square"]) {
                                      [Model sharedInstance].hasSquareSizeImages = YES;
                                  } else if ([size isEqualToString:@"thumb"]) {
                                      [Model sharedInstance].hasThumbSizeImages = YES;
                                  } else if ([size isEqualToString:@"2small"]) {
                                      [Model sharedInstance].hasXXSmallSizeImages = YES;
                                  } else if ([size isEqualToString:@"xsmall"]) {
                                      [Model sharedInstance].hasXSmallSizeImages = YES;
                                  } else if ([size isEqualToString:@"small"]) {
                                      [Model sharedInstance].hasSmallSizeImages = YES;
                                  } else if ([size isEqualToString:@"medium"]) {
                                      [Model sharedInstance].hasMediumSizeImages = YES;
                                  } else if ([size isEqualToString:@"large"]) {
                                      [Model sharedInstance].hasLargeSizeImages = YES;
                                  } else if ([size isEqualToString:@"xlarge"]) {
                                      [Model sharedInstance].hasXLargeSizeImages = YES;
                                  } else if ([size isEqualToString:@"xxlarge"]) {
                                      [Model sharedInstance].hasXXLargeSizeImages = YES;
                                  }
                              }
                              
                              // Check that the actual default album thumbnail size is available
                              // and select the next available size in case of unavailability
                              switch ([Model sharedInstance].defaultAlbumThumbnailSize) {
                                  case kPiwigoImageSizeSquare:
                                      // Should always be available
                                      break;
                                  case kPiwigoImageSizeThumb:
                                      // Should always be available
                                      break;
                                  case kPiwigoImageSizeXXSmall:
                                      if (![Model sharedInstance].hasXXSmallSizeImages) {
                                          // Look for next available larger size
                                          if ([Model sharedInstance].hasXSmallSizeImages) {
                                              [Model sharedInstance].defaultAlbumThumbnailSize = kPiwigoImageSizeXSmall;
                                          } else if ([Model sharedInstance].hasSmallSizeImages) {
                                              [Model sharedInstance].defaultAlbumThumbnailSize = kPiwigoImageSizeSmall;
                                          } else {
                                              [Model sharedInstance].defaultAlbumThumbnailSize = kPiwigoImageSizeMedium;
                                          }
                                      }
                                      break;
                                  case kPiwigoImageSizeXSmall:
                                      if (![Model sharedInstance].hasXSmallSizeImages) {
                                          // Look for next available larger size
                                          if ([Model sharedInstance].hasSmallSizeImages) {
                                              [Model sharedInstance].defaultAlbumThumbnailSize = kPiwigoImageSizeSmall;
                                          } else {
                                              [Model sharedInstance].defaultAlbumThumbnailSize = kPiwigoImageSizeMedium;
                                          }
                                      }
                                      break;
                                  case kPiwigoImageSizeSmall:
                                      if (![Model sharedInstance].hasSmallSizeImages) {
                                          // Select next available larger size
                                          [Model sharedInstance].defaultAlbumThumbnailSize = kPiwigoImageSizeMedium;
                                      }
                                      break;
                                  case kPiwigoImageSizeMedium:
                                      // Should always be available
                                      break;
                                  case kPiwigoImageSizeLarge:
                                      if (![Model sharedInstance].hasLargeSizeImages) {
                                          [Model sharedInstance].defaultAlbumThumbnailSize = kPiwigoImageSizeMedium;
                                      }
                                      break;
                                  case kPiwigoImageSizeXLarge:
                                      if (![Model sharedInstance].hasXLargeSizeImages) {
                                          [Model sharedInstance].defaultAlbumThumbnailSize = kPiwigoImageSizeMedium;
                                      }
                                      break;
                                  case kPiwigoImageSizeXXLarge:
                                      if (![Model sharedInstance].hasXXLargeSizeImages) {
                                          [Model sharedInstance].defaultAlbumThumbnailSize = kPiwigoImageSizeMedium;
                                      }
                                      break;
                                  case kPiwigoImageSizeFullRes:
                                  default:
                                      [Model sharedInstance].defaultAlbumThumbnailSize = kPiwigoImageSizeMedium;
                                      break;
                              }
                              
                              // Check that the actual default image thumbnail size is available
                              // and select the next available size in case of unavailability
                              switch ([Model sharedInstance].defaultThumbnailSize) {
                                  case kPiwigoImageSizeSquare:
                                      // Should always be available
                                      break;
                                  case kPiwigoImageSizeThumb:
                                      // Should always be available
                                      break;
                                  case kPiwigoImageSizeXXSmall:
                                      if (![Model sharedInstance].hasXXSmallSizeImages) {
                                          // Look for next available larger size
                                          if ([Model sharedInstance].hasXSmallSizeImages) {
                                              [Model sharedInstance].defaultThumbnailSize = kPiwigoImageSizeXSmall;
                                          } else if ([Model sharedInstance].hasSmallSizeImages) {
                                              [Model sharedInstance].defaultThumbnailSize = kPiwigoImageSizeSmall;
                                          } else {
                                              [Model sharedInstance].defaultThumbnailSize = kPiwigoImageSizeMedium;
                                          }
                                      }
                                      break;
                                  case kPiwigoImageSizeXSmall:
                                      if (![Model sharedInstance].hasXSmallSizeImages) {
                                          // Look for next available larger size
                                          if ([Model sharedInstance].hasSmallSizeImages) {
                                              [Model sharedInstance].defaultThumbnailSize = kPiwigoImageSizeSmall;
                                          } else {
                                              [Model sharedInstance].defaultThumbnailSize = kPiwigoImageSizeMedium;
                                          }
                                      }
                                      break;
                                  case kPiwigoImageSizeSmall:
                                      if (![Model sharedInstance].hasSmallSizeImages) {
                                          // Select next available larger size
                                          [Model sharedInstance].defaultThumbnailSize = kPiwigoImageSizeMedium;
                                      }
                                      break;
                                  case kPiwigoImageSizeMedium:
                                      // Should always be available
                                      break;
                                  case kPiwigoImageSizeLarge:
                                      if (![Model sharedInstance].hasLargeSizeImages) {
                                          [Model sharedInstance].defaultThumbnailSize = kPiwigoImageSizeMedium;
                                      }
                                      break;
                                  case kPiwigoImageSizeXLarge:
                                      if (![Model sharedInstance].hasXLargeSizeImages) {
                                          [Model sharedInstance].defaultThumbnailSize = kPiwigoImageSizeMedium;
                                      }
                                      break;
                                  case kPiwigoImageSizeXXLarge:
                                      if (![Model sharedInstance].hasXXLargeSizeImages) {
                                          [Model sharedInstance].defaultThumbnailSize = kPiwigoImageSizeMedium;
                                      }
                                      break;
                                  case kPiwigoImageSizeFullRes:
                                  default:
                                      [Model sharedInstance].defaultThumbnailSize = kPiwigoImageSizeMedium;
                                      break;
                              }

                              // Calculate number of thumbnails per row for that selection
                              NSInteger minNberOfImages = [ImagesCollection imagesPerRowInPortraitForView:nil maxWidth:[PiwigoImageData widthForImageSizeType:(kPiwigoImageSize)[Model sharedInstance].defaultThumbnailSize]];

                              // Make sure that default number fits inside selected range
                              [Model sharedInstance].thumbnailsPerRowInPortrait = MAX([Model sharedInstance].thumbnailsPerRowInPortrait, minNberOfImages);
                              [Model sharedInstance].thumbnailsPerRowInPortrait = MIN([Model sharedInstance].thumbnailsPerRowInPortrait, 2*minNberOfImages);

                              // Check that the actual default image preview size is still available
                              // and select the next available size in case of unavailability
                              switch ([Model sharedInstance].defaultImagePreviewSize) {
                                  case kPiwigoImageSizeSquare:
                                      // Should always be available
                                      break;
                                  case kPiwigoImageSizeThumb:
                                      // Should always be available
                                      break;
                                  case kPiwigoImageSizeXXSmall:
                                      if (![Model sharedInstance].hasXXSmallSizeImages) {
                                          // Look for next available larger size
                                          if ([Model sharedInstance].hasXSmallSizeImages) {
                                              [Model sharedInstance].defaultImagePreviewSize = kPiwigoImageSizeXSmall;
                                          } else if ([Model sharedInstance].hasSmallSizeImages) {
                                              [Model sharedInstance].defaultImagePreviewSize = kPiwigoImageSizeSmall;
                                          } else {
                                              [Model sharedInstance].defaultImagePreviewSize = kPiwigoImageSizeMedium;
                                          }
                                      }
                                      break;
                                  case kPiwigoImageSizeXSmall:
                                      if (![Model sharedInstance].hasXSmallSizeImages) {
                                          // Look for next available larger size
                                          if ([Model sharedInstance].hasSmallSizeImages) {
                                              [Model sharedInstance].defaultImagePreviewSize = kPiwigoImageSizeSmall;
                                          } else {
                                              [Model sharedInstance].defaultImagePreviewSize = kPiwigoImageSizeMedium;
                                          }
                                      }
                                      break;
                                  case kPiwigoImageSizeSmall:
                                      if (![Model sharedInstance].hasSmallSizeImages) {
                                          // Select next available larger size
                                          [Model sharedInstance].defaultImagePreviewSize = kPiwigoImageSizeMedium;
                                      }
                                      break;
                                  case kPiwigoImageSizeMedium:
                                      // Should always be available
                                      break;
                                  case kPiwigoImageSizeLarge:
                                      if (![Model sharedInstance].hasLargeSizeImages) {
                                          // Look for next available larger size
                                          if ([Model sharedInstance].hasXLargeSizeImages) {
                                              [Model sharedInstance].defaultImagePreviewSize = kPiwigoImageSizeXLarge;
                                          } else if ([Model sharedInstance].hasXXLargeSizeImages) {
                                              [Model sharedInstance].defaultImagePreviewSize = kPiwigoImageSizeXXLarge;
                                          } else {
                                              [Model sharedInstance].defaultImagePreviewSize = kPiwigoImageSizeFullRes;
                                          }
                                      }
                                      break;
                                  case kPiwigoImageSizeXLarge:
                                      if (![Model sharedInstance].hasXLargeSizeImages) {
                                          // Look for next available larger size
                                          if ([Model sharedInstance].hasXXLargeSizeImages) {
                                              [Model sharedInstance].defaultImagePreviewSize = kPiwigoImageSizeXXLarge;
                                          } else {
                                              [Model sharedInstance].defaultImagePreviewSize = kPiwigoImageSizeFullRes;
                                          }
                                      }
                                      break;
                                  case kPiwigoImageSizeXXLarge:
                                      if (![Model sharedInstance].hasXXLargeSizeImages) {
                                          [Model sharedInstance].defaultImagePreviewSize = kPiwigoImageSizeFullRes;
                                      }
                                      break;
                                  case kPiwigoImageSizeFullRes:
                                  default:
                                      [Model sharedInstance].defaultImagePreviewSize = kPiwigoImageSizeFullRes;
                                      break;
                              }
                          }
                          [[Model sharedInstance] saveToDisk];

                          completion(result);
                      } else {
                          completion(nil);
                      }
                  }
              } failure:^(NSURLSessionTask *task, NSError *error) {
                  
                  if(fail) {
                      fail(task, error);
                  }
              }];
}

+(NSURLSessionTask*)getCommunityStatusOnCompletion:(void (^)(NSDictionary *responseObject))completion
                                         onFailure:(void (^)(NSURLSessionTask *task, NSError *error))fail
{
    return [self post:kCommunitySessionGetStatus
        URLParameters:nil
           parameters:nil
             progress:^(NSProgress * progress) {
                 if ([Model sharedInstance].userCancelledCommunication) {
                     [progress cancel];
                 }
             }
              success:^(NSURLSessionTask *task, id responseObject) {
                  
                  if(completion) {
                      if([[responseObject objectForKey:@"stat"] isEqualToString:@"ok"])
                      {
                          NSString *userStatus = [[responseObject objectForKey:@"result" ] objectForKey:@"real_user_status"];
                          [Model sharedInstance].hasAdminRights = ([userStatus isEqualToString:@"admin"] || [userStatus isEqualToString:@"webmaster"]);
                          
                          completion([responseObject objectForKey:@"result"]);
                      }
                      else
                      {
                          completion(nil);
                      }
                  }
              } failure:^(NSURLSessionTask *task, NSError *error) {
                  
                  if(fail) {
                      fail(task, error);
                  }
              }];
}

+(NSURLSessionTask*)sessionLogoutOnCompletion:(void (^)(NSURLSessionTask *task, BOOL sucessfulLogout))completion
                                    onFailure:(void (^)(NSURLSessionTask *task, NSError *error))fail
{
	return [self post:kPiwigoSessionLogout
		URLParameters:nil
           parameters:nil
             progress:nil
			  success:^(NSURLSessionTask *task, id responseObject) {
				  
				  if(completion) {
					  if([[responseObject objectForKey:@"stat"] isEqualToString:@"ok"])
					  {
						  completion(task, [[responseObject objectForKey:@"result" ] boolValue]);
					  }
					  else
					  {
                          // Display Piwigo error
                          NSInteger errorCode = NSNotFound;
                          if ([responseObject objectForKey:@"err"]) {
                              errorCode = [[responseObject objectForKey:@"err"] intValue];
                          }
                          NSString *errorMsg = @"";
                          if ([responseObject objectForKey:@"message"]) {
                              errorMsg = [responseObject objectForKey:@"message"];
                          }
                          [NetworkHandler showPiwigoError:errorCode withMessage:errorMsg forPath:kPiwigoCategoriesGetImages andURLparams:nil];

                          completion(task, NO);
					  }
				  }
			  } failure:^(NSURLSessionTask *task, NSError *error) {
				  
                  NSInteger statusCode = [[[error userInfo] valueForKey:AFNetworkingOperationFailingURLResponseErrorKey] statusCode];
                  if ((statusCode == 401) ||        // Unauthorized
                      (statusCode == 403) ||        // Forbidden
                      (statusCode == 404))          // Not Found
                  {
                      NSLog(@"…notify kPiwigoNetworkErrorEncounteredNotification!");
                      dispatch_async(dispatch_get_main_queue(), ^{
                          [[NSNotificationCenter defaultCenter] postNotificationName:kPiwigoNetworkErrorEncounteredNotification object:nil userInfo:nil];
                      });

                      if (fail) {
                          fail(task, error);
                      }
                  }
                  else {
                      if (fail) {
                          [SessionService showConnectionError:error];
                          fail(task, error);
                      }
                  }
			  }];
}

@end
