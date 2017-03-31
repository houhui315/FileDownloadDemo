//
//  ZXYDownLoadFileManager.h
//  DownloadDemo
//
//  Created by 蓝泰致铭        on 16/6/24.
//  Copyright © 2016年 houhui. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "downLoadFileModel.h"

#define ZXYSharedDownLoadFileManager [ZXYDownLoadFileManager shareInstance]

@interface ZXYDownLoadFileManager : NSObject

//设定最大支持的任务数,默认3个
@property (nonatomic, assign) NSUInteger maxDownloadTask;

+(ZXYDownLoadFileManager *)shareInstance;

//初始化下载任务
-(downLoadFileModel*)getDownloadTaskWithFileName:(NSString *)fileName fileUrl:(NSString *)fileUrl downloadPath:(NSString*)path;

//添加下载任务
- (void)addDownloadTaskToQueueAndCheckDownloadQueueWithModel:(downLoadFileModel*)model;

//停止下载任务
- (void)stopDownloadTaskAndCheckDownloadQueueWithModel:(downLoadFileModel *)model;

//增加多个下载任务
- (void)addMutiDownloadTaskToDownloadQueueWithFileModelArray:(NSArray<__kindof downLoadFileModel *>*)tasks;

//删除多个下载任务
- (void)stopMutiDownloadTaskToDownliadQueueWithFileModelArray:(NSArray<__kindof downLoadFileModel *>*)tasks;

@end
