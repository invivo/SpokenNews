//
//  InvivoDiskUtility.h
//  Invivo Framework
//
//  Created by Yu Ho Kwok on 6/8/11.
//  Copyright 2011 invivo interactve hong kong. All rights reserved.
//

#import <Foundation/Foundation.h>
#define ISDEBUG 1

@interface InvivoDiskUtility : NSObject


//list folder
+ (NSArray*)getFileListInFolder:(NSString*)path;
+ (NSArray*)getFileListInDocument:(NSString*)path;
+ (NSArray*)getFileListInDocumentInCache:(NSString*)path;

//document folder helper
+ (NSString*)getDocumentFolder;
+ (NSString*)getDocumentFolderWithCache:(NSString*)cacheName;

+ (BOOL)createCacheFolder:(NSString*)cacheName;

//get UIImage
+ (UIImage*)getUIImageFromDocument:(NSString*)filename;
+ (UIImage*)getUIImageThumbnailFromDocument:(NSString*)filename;
+ (UIImage*)getUIImageFromCache:(NSString*)filename;
+ (UIImage*)imageByScalingAndCroppingForSize:(CGSize)targetSize withImage:(UIImage*)sourceImg;
+ (UIImage*)getUIImageLoveThumbnailFromDocument:(NSString*)filename;

//get string
+ (NSString*)getNSStringFromDocument:(NSString*)filename;

//get NSArray or Dictionary
+ (NSMutableArray*)getNSMutableArrayFromDocument:(NSString*)filename;
+ (NSMutableArray*)getNSMutableArrayFromDocumentInCache:(NSString*)cacheName withFileName:(NSString*)filename;

+ (NSMutableDictionary*)getNSMutableDictionaryFromDocument:(NSString*)filename;
+ (NSMutableDictionary*)getNSMutableDictionaryFromDocumentInCache:(NSString*)cacheName withFileName:(NSString*)filename;


//md5 of file
+ (NSString*)getMD5OfFile:(NSString*)path;
+ (NSString*)getMD5OfFileAtDocument:(NSString*)filename;
+ (NSString*)getMD5OfFileAtDocumentCache:(NSString*)cacheFolder withFileName:(NSString*)fileName;

//delete file
+(BOOL)deleteFile:(NSString*)path;
+(BOOL)deleteFileAtDocument:(NSString*)filename;
+(BOOL)deleteFileAtDocumentCache:(NSString*)cacheFolder withFileName:(NSString*)fileName;

//write file to folder
+ (BOOL)writeFile:(id)object withFileName:(NSString*)filename;
+ (BOOL)writeFileToDocument:(id)object withFileName:(NSString*)filename;
+ (BOOL)writeFileToDocument:(id)object withCache:(NSString*)cacheName
               withFileName:(NSString *)filename;
//check file existence
+ (BOOL)checkFileExists:(NSString*)filePath;
+ (BOOL)checkFileExistsInDocument:(NSString*)fileName;
+ (BOOL)checkFileExistsInDocumentCache:(NSString *)cacheFolder withFile:(NSString*)fileName;
//check dir existence
+ (BOOL)checkDirExists:(NSString*)filePath;
+ (BOOL)checkDirExistsInDocument:(NSString*)fileName;
@end

