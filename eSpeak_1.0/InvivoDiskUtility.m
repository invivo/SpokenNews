//
//  InvivoDiskUtility.m
//  ivRoamingApp
//
//  Created by Yu Ho Kwok on 6/8/11.
//  Copyright 2011 invivo interactve hong kong. All rights reserved.
//


#import "InvivoDiskUtility.h"
#import <CommonCrypto/CommonDigest.h>

@implementation InvivoDiskUtility

+ (NSArray*)getFileListInFolder:(NSString*)path{
    if(ISDEBUG)
        NSLog(@"invivo utility: list folder %@", path);
    //int count;
    NSArray *directoryContent = [[NSFileManager defaultManager]contentsOfDirectoryAtPath:path error:nil];
    if(ISDEBUG)
        NSLog(@"invivo utility: result - %@", directoryContent);
    return directoryContent;
}

+ (NSArray*)getFileListInDocument:(NSString*)path{
    return [InvivoDiskUtility getFileListInFolder:[InvivoDiskUtility getDocumentFolder]];
}

+ (NSArray*)getFileListInDocumentInCache:(NSString*)path{
    return [InvivoDiskUtility getFileListInFolder:[InvivoDiskUtility getDocumentFolderWithCache:path]];
}

#pragma mark - check file and folder existence

+ (BOOL)checkFileExistsInDocumentCache:(NSString *)cacheFolder withFile:(NSString*)fileName{
    NSString *combinedPath = [NSString stringWithFormat:@"%@/%@", cacheFolder, fileName];
    return [self checkFileExistsInDocument:combinedPath];
}

+ (BOOL)checkFileExistsInDocument:(NSString*)fileName{
    NSString *path = [InvivoDiskUtility getDocumentFolder];
    NSString *filePath = [path stringByAppendingFormat:@"/%@",fileName];
    return [InvivoDiskUtility checkFileExists:filePath];
}

+ (BOOL)checkFileExists:(NSString*)filePath{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    return [fileManager fileExistsAtPath:filePath];
}

+ (BOOL)checkDirExistsInDocument:(NSString*)fileName{
    NSString *path = [InvivoDiskUtility getDocumentFolder];
    NSString *filePath = [path stringByAppendingFormat:@"/%@",fileName];
    NSLog(@"invivo utility: check exists: %@", filePath);
    return [InvivoDiskUtility checkFileExists:filePath];
}

+ (BOOL)checkDirExists:(NSString*)filePath{
    BOOL isDir;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if([fileManager fileExistsAtPath:filePath isDirectory:&isDir])
    {
        NSLog(@"invivo utility: check exists: %@", filePath);
        return isDir;
    } else {
        return NO;
    }
}

#pragma mark - create cache folder and helper class

////

+ (BOOL)createCacheFolder:(NSString*)cacheName{
    NSString *path;
    path = [[InvivoDiskUtility getDocumentFolder]stringByAppendingPathComponent:cacheName];
    
	NSError *error;
	if (![[NSFileManager defaultManager] fileExistsAtPath:path])	//Does directory already exist?
	{
		if (![[NSFileManager defaultManager] createDirectoryAtPath:path
									   withIntermediateDirectories:NO
														attributes:nil
															 error:&error])
		{
            if(ISDEBUG)
                NSLog(@"invivo utility: error on creating folder");
			return NO;
		}
        if(ISDEBUG)
            NSLog(@"invivo utility: create folder success");
        return YES;
	}
    
    if(ISDEBUG)
        NSLog(@"invivo utility: folder exists");
    return YES;
}

+ (NSString*)getDocumentFolder{
    
    BOOL isCache = YES;
    NSArray *paths;
    if(!isCache)
    {
        // Documents directory
        paths = NSSearchPathForDirectoriesInDomains
        (NSDocumentDirectory, NSUserDomainMask, YES);
    } else {
        //Cache directory
        paths = NSSearchPathForDirectoriesInDomains
        (NSCachesDirectory, NSUserDomainMask, YES);
    }
    
    
    
    NSString *documentsPath = [paths objectAtIndex:0];
    // <Application Home>/Documents/foo.plist
    NSString *thePath = [NSString stringWithString:documentsPath];
    return thePath;
}

#pragma mark - get Array and Dict

+ (NSString*)getDocumentFolderWithCache:(NSString*)cacheName{
    NSString *path = [InvivoDiskUtility getDocumentFolder];
    NSString *filePath = [path stringByAppendingFormat:@"/%@",cacheName];
    return filePath;
}

+ (NSMutableArray*)getNSMutableArrayFromDocument:(NSString*)filename
{
    NSString *path = [InvivoDiskUtility getDocumentFolder];
    NSString *filePath = [path stringByAppendingFormat:@"/%@",filename];
    return [NSMutableArray arrayWithContentsOfFile:filePath];
}

+ (NSMutableArray*)getNSMutableArrayFromDocumentInCache:(NSString*)cacheName withFileName:(NSString*)filename{
    NSString *path = [NSString stringWithFormat:@"%@/%@",cacheName, filename];
    return [InvivoDiskUtility getNSMutableArrayFromDocument:path];
}

+ (NSMutableDictionary*)getNSMutableDictionaryFromDocument:(NSString*)filename
{
    NSString *path = [InvivoDiskUtility getDocumentFolder];
    NSString *filePath = [path stringByAppendingFormat:@"/%@",filename];
    return [NSMutableDictionary dictionaryWithContentsOfFile:filePath];
}

+ (NSMutableDictionary*)getNSMutableDictionaryFromDocumentInCache:(NSString*)cacheName withFileName:(NSString*)filename{
    NSString *path = [NSString stringWithFormat:@"%@/%@",cacheName, filename];
    return [InvivoDiskUtility getNSMutableDictionaryFromDocument:path];
}

#pragma mark - get file helper function


+ (NSString*)getNSStringFromDocument:(NSString*)filename
{
    NSString *path = [InvivoDiskUtility getDocumentFolder];
    NSString *filePath = [path stringByAppendingFormat:@"/%@",filename];
    return [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
}

+ (UIImage*)getUIImageFromDocument:(NSString*)filename
{
    NSString *path = [InvivoDiskUtility getDocumentFolder];
    NSString *filePath = [path stringByAppendingFormat:@"/%@",filename];
    return [InvivoDiskUtility getUIImageFromCache:filePath];
}

+ (UIImage*)getUIImageLoveThumbnailFromDocument:(NSString*)filename
{
    NSString *path = [InvivoDiskUtility getDocumentFolder];
    NSString *filePath = [path stringByAppendingFormat:@"/lvth_%@",filename];
    return [InvivoDiskUtility getUIImageFromCache:filePath];
}

+ (UIImage*)getUIImageThumbnailFromDocument:(NSString*)filename
{
    NSString *path = [InvivoDiskUtility getDocumentFolder];
    NSString *filePath = [path stringByAppendingFormat:@"/th_%@",filename];
    return [InvivoDiskUtility getUIImageFromCache:filePath];
}

+ (UIImage*)getUIImageFromCache:(NSString*)filename{
    if (![[NSFileManager defaultManager] fileExistsAtPath:filename])
    {
        return nil;
    } else {
        return [UIImage imageWithContentsOfFile:filename];
    }
}


#pragma mark - file md5

+ (NSString*)getMD5OfFile:(NSString*)path{
    if([InvivoDiskUtility checkFileExists:path])
    {
        //NSLog(@"weddingar_sys_native: get md5 of - %@", path);
        unsigned char md5Buffer[CC_MD5_DIGEST_LENGTH];
        NSData *d = [NSData dataWithContentsOfFile:path];
        CC_MD5(d.bytes, d.length, md5Buffer);
        
        NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
        for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
            [output appendFormat:@"%02x",md5Buffer[i]];
        
        return output;
    } else {
        return nil;
    }
}

+ (NSString*)getMD5OfFileAtDocument:(NSString*)filename{
    NSString *path = [InvivoDiskUtility getDocumentFolder];
    NSString *filePath = [path stringByAppendingFormat:@"/%@",filename];
    return [self getMD5OfFile:filePath];
}

+ (NSString*)getMD5OfFileAtDocumentCache:(NSString*)cacheFolder withFileName:(NSString*)fileName{
    NSString *path = [NSString stringWithFormat:@"%@/%@", cacheFolder, fileName];
    return [self getMD5OfFileAtDocument:path];
}

#pragma mark - delete file

+(BOOL)deleteFileAtDocumentCache:(NSString*)cacheFolder withFileName:(NSString*)fileName{
    NSString *path = [NSString stringWithFormat:@"%@/%@", cacheFolder, fileName];
    return [self deleteFileAtDocument:path];
}

+(BOOL)deleteFileAtDocument:(NSString*)filename{
    NSString *path = [InvivoDiskUtility getDocumentFolder];
    NSString *filePath = [path stringByAppendingFormat:@"/%@",filename];
    return [self deleteFile:filePath];
}

+(BOOL)deleteFile:(NSString*)path{
    if([InvivoDiskUtility checkFileExists:path])
    {
        NSError *err;
        BOOL result = [[NSFileManager defaultManager]removeItemAtPath:path error:&err];
        //if(err && ISDEBUG)
        //   NSLog(@"invivo utility: %@", err);
        return result;
    } else {
        return NO;
    }
}

#pragma mark - write file to cache folder

+ (BOOL)writeFileToDocument:(id)object withCache:(NSString*)cacheName
               withFileName:(NSString *)filename
{
    NSString *path = [NSString stringWithFormat:@"%@/%@", cacheName, filename];
    return [self writeFileToDocument:object withFileName:path];
}

+ (BOOL)writeFileToDocument:(id)object withFileName:(NSString*)filename
{
    NSString *path = [InvivoDiskUtility getDocumentFolder];
    NSString *filePath = [path stringByAppendingFormat:@"/%@",filename];
    return [InvivoDiskUtility writeFile:object withFileName:filePath];
}

+ (BOOL)writeFile:(id)object withFileName:(NSString*)filename
{
    if([object isKindOfClass:[UIImage class]])
    {
        [UIImagePNGRepresentation(object) writeToFile:filename atomically:YES];
        return YES;
    } else if([object isKindOfClass:[NSString class]])
    {
        [object writeToFile:filename atomically:YES encoding:NSUTF8StringEncoding error:nil];
    } else if([object isKindOfClass:[NSData class]])
    {
        [(NSData*)object writeToFile:filename atomically:YES];
        return YES;
    } else if([object isKindOfClass:[NSArray class]] ||
              [object isKindOfClass:[NSMutableArray class]] ||
              [object isKindOfClass:[NSDictionary class]] ||
              [object isKindOfClass:[NSMutableDictionary class]])
    {
        if([(NSMutableArray*)object writeToFile:filename atomically:YES])
        {
            
        }
        return YES;
    }
    return NO;
}

#pragma mark - Scale and crop image

+ (UIImage*)imageByScalingAndCroppingForSize:(CGSize)targetSize withImage:(UIImage*)sourceImg
{
    UIImage *sourceImage = sourceImg;
    UIImage *newImage = nil;
    CGSize imageSize = sourceImage.size;
    CGFloat width = imageSize.width;
    CGFloat height = imageSize.height;
    CGFloat targetWidth = targetSize.width;
    CGFloat targetHeight = targetSize.height;
    CGFloat scaleFactor = 0.0;
    CGFloat scaledWidth = targetWidth;
    CGFloat scaledHeight = targetHeight;
    CGPoint thumbnailPoint = CGPointMake(0.0,0.0);
    
    if (CGSizeEqualToSize(imageSize, targetSize) == NO)
    {
        CGFloat widthFactor = targetWidth / width;
        CGFloat heightFactor = targetHeight / height;
        
        if (widthFactor > heightFactor)
            scaleFactor = widthFactor; // scale to fit height
        else
            scaleFactor = heightFactor; // scale to fit width
        scaledWidth  = width * scaleFactor;
        scaledHeight = height * scaleFactor;
        
        // center the image
        if (widthFactor > heightFactor)
        {
            thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5;
        }
        else
            if (widthFactor < heightFactor)
            {
                thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5;
            }
    }
    
    UIGraphicsBeginImageContext(targetSize); // this will crop
    
    CGRect thumbnailRect = CGRectZero;
    thumbnailRect.origin = thumbnailPoint;
    thumbnailRect.size.width  = scaledWidth;
    thumbnailRect.size.height = scaledHeight;
    
    [sourceImage drawInRect:thumbnailRect];
    
    newImage = UIGraphicsGetImageFromCurrentImageContext();
    if(newImage == nil)
        NSLog(@"invivo utility: could not scale image");
    
    //pop the context to get back to the default
    UIGraphicsEndImageContext();
    return newImage;
}

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

@end
