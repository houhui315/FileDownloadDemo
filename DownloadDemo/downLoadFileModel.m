//
//  downLoadFileModel.m
//  DownloadDemo
//
//  Created by houhui on 16/6/23.
//  Copyright © 2016年 houhui. All rights reserved.
//

#import "downLoadFileModel.h"

@implementation downLoadFileModel

- (instancetype)initWithFileName:(NSString*)fileName fileUrl:(NSString*)fileUrl downloadPath:(NSString*)downloadPath{
    
    if (self = [super init]) {
        
        _fileName = fileName;
        _fileUrl = fileUrl;
        _downLoadPath = downloadPath;
        _status = DLStatus_no;
    }
    return self;
}

- (instancetype)initDownloadFinishedWithFileName:(NSString*)fileName fileUrl:(NSString*)fileUrl downloadPath:(NSString*)downloadPath{
    
    if (self = [super init]) {
        
        _fileName = fileName;
        _fileUrl = fileUrl;
        _downLoadPath = downloadPath;
        _status = DLStatus_finished;
    }
    return self;
}

@end
