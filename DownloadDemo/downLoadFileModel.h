//
//  downLoadFileModel.h
//  DownloadDemo
//
//  Created by houhui on 16/6/23.
//  Copyright © 2016年 houhui. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, DLStatus) {
    
    DLStatus_no,
    DLStatus_wait,
    DLStatus_downloading,
    DLStatus_stop,
    DLStatus_failed,
    DLStatus_finished
};

@interface downLoadFileModel : NSObject

@property (nonatomic, strong) NSString *fileName;
@property (nonatomic, strong) NSString *fileUrl;
@property (nonatomic, strong) NSString *downLoadPath;
@property (nonatomic, assign) NSUInteger fileSize;
@property (nonatomic, assign) NSUInteger currentDownloadSize;

@property (nonatomic, assign) NSUInteger taskIdentifier;

@property (nonatomic, assign) DLStatus status;

//初始化下载状态
- (instancetype)initWithFileName:(NSString*)fileName fileUrl:(NSString*)fileUrl downloadPath:(NSString*)downloadPath;

//初始化完成状态
- (instancetype)initDownloadFinishedWithFileName:(NSString*)fileName fileUrl:(NSString*)fileUrl downloadPath:(NSString*)downloadPath;

@end
