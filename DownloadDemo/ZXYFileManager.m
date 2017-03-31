//
//  ZXYFileManager.m
//  DownloadDemo
//
//  Created by houhui on 16/6/26.
//  Copyright © 2016年 houhui. All rights reserved.
//

#import "ZXYFileManager.h"

@implementation ZXYFileManager

+(void)createDownloadResumeDataFoder{
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSString *downloadResumeDataFolderPath = [ZXYFileManager downloadResumeDataPath];
    BOOL bl;
    if (![fileManager fileExistsAtPath:downloadResumeDataFolderPath isDirectory:&bl]) {
        
        NSError *error = nil;
        [fileManager createDirectoryAtPath:downloadResumeDataFolderPath withIntermediateDirectories:YES attributes:nil error:&error];
        NSAssert(!error, @"create downloadResumeDataFoler failed");
    }
}

+(NSString*)downloadResumeDataPath{
    
    NSString *downloadResumeDataFolderPath = [[ZXYFileManager cachePath] stringByAppendingPathComponent:@"downloadResumeData"];
    return downloadResumeDataFolderPath;
}

+(NSString*)cachePath{
    
    NSString *cacheDir = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    return cacheDir;
}

+ (NSString*)tmpPath{
    
    NSString *tmp = NSTemporaryDirectory();
    return tmp;
}

+(BOOL)fileExistsAtPath:(NSString*)path{
    
    NSFileManager *manager = [NSFileManager defaultManager];
    return [manager fileExistsAtPath:path];
}


+ (BOOL)moveItemAtURL:(NSURL *)srcURL toURL:(NSURL *)dstURL error:(NSError **)error{
    NSFileManager *manager = [NSFileManager defaultManager];
    return [manager moveItemAtURL:srcURL toURL:dstURL error:error];
}

+ (BOOL)removeItemAtPath:(NSString *)path error:(NSError **)error{
    
    NSFileManager *manager = [NSFileManager defaultManager];
    if ([manager fileExistsAtPath:path]) {
        return [manager removeItemAtPath:path error:error];
    }
    return YES;
}

+ (long long)fileSizeAtPath:(NSString*)filePath{
    
    NSFileManager* manager = [NSFileManager defaultManager];
    
    if ([manager fileExistsAtPath:filePath]){
        
        return [[manager attributesOfItemAtPath:filePath error:nil] fileSize];
    }
    return 0;
}

@end
