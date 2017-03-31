//
//  ZXYFileManager.h
//  DownloadDemo
//
//  Created by houhui on 16/6/26.
//  Copyright © 2016年 houhui. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ZXYFileManager : NSObject

//创建下载中断临时文件夹
+(void)createDownloadResumeDataFoder;

//文件路径是否存在
+(BOOL)fileExistsAtPath:(NSString*)path;

+(NSString*)downloadResumeDataPath;

+(NSString*)cachePath;

+ (NSString*)tmpPath;

//移动文件
+ (BOOL)moveItemAtURL:(NSURL *)srcURL toURL:(NSURL *)dstURL error:(NSError **)error;
//删除文件
+ (BOOL)removeItemAtPath:(NSString *)path error:(NSError **)error;

+ (long long)fileSizeAtPath:(NSString*)filePath;

@end
