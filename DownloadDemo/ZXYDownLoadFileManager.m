//
//  ZXYDownLoadFileManager.m
//  DownloadDemo
//
//  Created by 蓝泰致铭        on 16/6/24.
//  Copyright © 2016年 houhui. All rights reserved.
//

#import "ZXYDownLoadFileManager.h"
#import "ZXYFileManager.h"


static const NSString *NSURLSessionResumeBytesReceived = @"NSURLSessionResumeBytesReceived";
static const NSString *NSURLSessionResumeInfoTempFileName = @"NSURLSessionResumeInfoTempFileName";


typedef void(^getTaskCallback)(NSURLSessionDownloadTask *task);

@interface ZXYDownLoadFileManager ()<NSURLSessionDelegate>

@property (nonatomic, strong) NSMutableArray *downloadArray;
@property (nonatomic, strong) NSURLSession *downloadSession;

@end

@implementation ZXYDownLoadFileManager

// 单例
+(ZXYDownLoadFileManager *)shareInstance
{
    static ZXYDownLoadFileManager * shareInstances = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shareInstances = [[ZXYDownLoadFileManager alloc] init];
        [shareInstances initData];
        
    });
    
    return shareInstances;
}

- (void)initData{
    
    [ZXYFileManager createDownloadResumeDataFoder];
    
    self.downloadArray = [NSMutableArray array];
    
    self.maxDownloadTask = 3;
    
    NSURLSessionConfiguration *sessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:sessionConfig delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    self.downloadSession = session;
}


-(downLoadFileModel*)getDownloadTaskWithFileName:(NSString *)fileName fileUrl:(NSString *)fileUrl downloadPath:(NSString*)path{
    
    //已下载完成
    if ([ZXYFileManager fileExistsAtPath:path]) {
        
        downLoadFileModel *fileModel = [[downLoadFileModel  alloc] initDownloadFinishedWithFileName:fileName fileUrl:fileUrl downloadPath:path];
        return fileModel;
    }else{
        downLoadFileModel *fileModel = [self findDownloadTaskFromFileUrl:fileUrl];
        if (!fileModel) {
            fileModel = [[downLoadFileModel alloc] initWithFileName:fileName fileUrl:fileUrl downloadPath:path];
        }
        return fileModel;
    }
}

-(downLoadFileModel*)findDownloadTaskFromFileUrl:(NSString*)fileUrl{
    
    @synchronized(_downloadArray) {
        
        downLoadFileModel *findModel = nil;
        for (downLoadFileModel *model in self.downloadArray) {
            
            if ([model.fileUrl isEqualToString:fileUrl]) {
                
                findModel = model;
                break;
            }
        }
        return findModel;
    }
}

- (BOOL)fileModelExistsAtDownloadArray:(downLoadFileModel*)model{
    if ([self.downloadArray containsObject:model]) {
        return YES;
    }else{
        return NO;
    }
}

- (void)addDownloadTaskToQueueWithFileModel:(downLoadFileModel *)model{
    
    //下载已完成
    if (model.status == DLStatus_finished) {
        return;
    }
    model.status = DLStatus_wait;
    [self.downloadArray addObject:model];
}

//添加并检测任务执行
- (void)addDownloadTaskToQueueAndCheckDownloadQueueWithModel:(downLoadFileModel*)model{
    
    [self addDownloadTaskToQueueWithFileModel:model];
    //检测任务
    [self checkNeedAddDownloadTaskToDownloadTaskQueue];
}

- (void)stopDownloadTaskWithFileModel:(downLoadFileModel *)model{
    
    //停止任务
    model.status = DLStatus_stop;
    __weak typeof(self) weakSelf = self;
    [self getDownloadTaskWithModel:model callBack:^(NSURLSessionDownloadTask *task) {
        [task cancelByProducingResumeData:^(NSData * _Nullable resumeData) {
            [weakSelf saveDownloadTempFileWithFileModel:model tempData:resumeData];
        }];
    }];
}

- (NSArray*)taskForUrlSession{
    
    __block NSArray *downloadTasks = nil;
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    [self.downloadSession getAllTasksWithCompletionHandler:^(NSArray<__kindof NSURLSessionTask *> * _Nonnull tasks) {
        
        tasks = tasks;
        dispatch_semaphore_signal(semaphore);
    }];
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    return downloadTasks;
}

- (void)getDownloadTaskWithModel:(downLoadFileModel*)model callBack:(getTaskCallback)callBack{
 
    [self.downloadSession getAllTasksWithCompletionHandler:^(NSArray<__kindof NSURLSessionTask *> * _Nonnull tasks) {
        
        NSURLSessionDownloadTask *theTask = nil;
        for (NSURLSessionDownloadTask *task in tasks) {
            
            if (task.taskIdentifier == model.taskIdentifier) {
                
                theTask = task;
                break;
            }
        }
        callBack(theTask);
    }];
}

- (void)handleCreateResumeDataWithFileModel:(downLoadFileModel*)model{
    
    NSString *resumeDataPath = [self getResumeFilePathWithFileModel:model];
    if (![ZXYFileManager fileExistsAtPath:resumeDataPath]) {
        if ((model.currentDownloadSize/(float)model.fileSize)*100 > 5) {
            //大于5%时创建resume文件方便应用关闭后也照常下载
            __weak typeof(self) weakSelf = self;

            [self getDownloadTaskWithModel:model callBack:^(NSURLSessionDownloadTask *task) {
                [task cancelByProducingResumeData:^(NSData * _Nullable resumeData) {
                    
                    [weakSelf saveDownloadTempFileWithFileModel:model tempData:resumeData];
                    [weakSelf startOrResumeDownloadFileWithFileModel:model];
                }];
            }];
        }
    }
}

- (void)stopDownloadTaskAndCheckDownloadQueueWithModel:(downLoadFileModel *)model{
    
    __weak typeof(self) weakSelf = self;
    [self getDownloadTaskWithModel:model callBack:^(NSURLSessionDownloadTask *task) {
        [task cancelByProducingResumeData:^(NSData * _Nullable resumeData) {
            model.status = DLStatus_stop;
            [weakSelf saveDownloadTempFileWithFileModel:model tempData:resumeData];
            [weakSelf.downloadArray removeObject:model];
            [weakSelf checkNeedAddDownloadTaskToDownloadTaskQueue];
        }];
    }];
}

- (void)addMutiDownloadTaskToDownloadQueueWithFileModelArray:(NSArray<__kindof downLoadFileModel *>*)tasks{
    //添加多个任务，当然，先判断该任务是否已存在
    for (downLoadFileModel *model in tasks) {
        
        if (![self fileModelExistsAtDownloadArray:model]) {
            [self addDownloadTaskToQueueWithFileModel:model];
        }
    }
    //检测下载状态并下载
    [self checkNeedAddDownloadTaskToDownloadTaskQueue];
}

- (void)stopMutiDownloadTaskToDownliadQueueWithFileModelArray:(NSArray<__kindof downLoadFileModel *>*)tasks{
    
    //删除多个任务，当任务存在时
    NSMutableArray *removeArray = [NSMutableArray array];
    for (downLoadFileModel *model in tasks) {
        
        if ([self fileModelExistsAtDownloadArray:model]) {
            if (model.status == DLStatus_downloading) {
                [self stopDownloadTaskWithFileModel:model];
            }else if (model.status == DLStatus_wait){
                model.status = DLStatus_no;
            }
            
            [removeArray addObject:model];
        }
    }
    if ([removeArray count]) {
        [self.downloadArray removeObjectsInArray:removeArray];
    }
    
    //检测下载状态并下载
    [self checkNeedAddDownloadTaskToDownloadTaskQueue];
}

//检查是否需要添加下载任务
- (void)checkNeedAddDownloadTaskToDownloadTaskQueue{
    
    for (NSInteger i = 0; i < [self.downloadArray count]; i++) {
        if (i < _maxDownloadTask) {
            downLoadFileModel *model = self.downloadArray[i];
            if (model.status == DLStatus_wait) {
                [self startOrResumeDownloadFileWithFileModel:model];
            }
        }else{
            break;
        }
    }
}

-(void)handleDownloadCacheWithFileModel:(downLoadFileModel*)model{
    
    //如果有resumeData文件时
    NSString *resumeFilePath = [self getResumeFilePathWithFileModel:model];
    if ([ZXYFileManager fileExistsAtPath:resumeFilePath]) {
        NSMutableDictionary *resumeDict = [NSMutableDictionary dictionaryWithContentsOfFile:resumeFilePath];
        NSNumber *resumeFileSizeNumber = resumeDict[NSURLSessionResumeBytesReceived];
        NSString *cacheFileName = resumeDict[NSURLSessionResumeInfoTempFileName];
        NSString *tmpFilePath = [[ZXYFileManager tmpPath] stringByAppendingPathComponent:cacheFileName];
        
        if (![ZXYFileManager fileExistsAtPath:tmpFilePath]) {
            //如果缓存文件不存在，则要删掉resumeData文件
            
            [self removeDownloadResumeFileWithFileModel:model];
        }else{
            NSNumber *cacheFileSizeNum = [NSNumber numberWithLongLong:[ZXYFileManager fileSizeAtPath:tmpFilePath]];
            if ([resumeFileSizeNumber compare:cacheFileSizeNum] != NSOrderedSame) {
                //如果两个不同，则把cache文件的大小作为resumedata里当前下载的文件大小并保存起来
                resumeDict[NSURLSessionResumeBytesReceived] = cacheFileSizeNum;
                [resumeDict writeToFile:resumeFilePath atomically:YES];
            }
        }
    }
}

- (void)startOrResumeDownloadFileWithFileModel:(downLoadFileModel*)model{
    
    //处理resumedata文件
    [self handleDownloadCacheWithFileModel:model];
    
    NSURL *url = [NSURL URLWithString:model.fileUrl];
    NSURLSessionDownloadTask *downloadTask;
    NSData *tempData = [self getDownLoadResumeDataWithFileModel:model];
    if (tempData) {
        
        downloadTask = [self.downloadSession downloadTaskWithResumeData:tempData];
    }else{
        downloadTask = [self.downloadSession downloadTaskWithURL:url];
    }
    [downloadTask resume];
    
    model.status = DLStatus_downloading;
    model.taskIdentifier = downloadTask.taskIdentifier;
}

- (void)stopDownloadWithFileModelAndCheckDownloadTaskWithModel:(downLoadFileModel*)model{
    
    [self stopDownloadTaskWithFileModel:model];
    [self.downloadArray removeObject:model];
    [self checkNeedAddDownloadTaskToDownloadTaskQueue];
}


- (void)saveDownloadTempFileWithFileModel:(downLoadFileModel*)model tempData:(NSData*)data{
    
    NSString *tempFilePath = [self getResumeFilePathWithFileModel:model];
    [data writeToFile:tempFilePath atomically:YES];
}

#pragma mark NSURLSessionDelegate method

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task
didCompleteWithError:(nullable NSError *)error{
//    if (error) {
//        [self downLoadErrorWithTaskIdentifier:task];
//    }
}

- (void)downLoadErrorWithTaskIdentifier:(NSURLSessionTask*)task{
    downLoadFileModel *fileModel = [self getDownloadModelWithTaskIdentifier:task.taskIdentifier];
    fileModel.status = DLStatus_failed;
}

-(void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location
{
    [self downLoadFinishedWithTaskIdentifier:downloadTask DownloadingToURL:location];
}


- (void)downLoadFinishedWithTaskIdentifier:(NSURLSessionDownloadTask*)task DownloadingToURL:(NSURL *)location{
    downLoadFileModel *fileModel = [self getDownloadModelWithTaskIdentifier:task.taskIdentifier];
    fileModel.status = DLStatus_finished;
    
    NSError *err = nil;
    NSURL *downloadURL = [NSURL fileURLWithPath:fileModel.downLoadPath];
    if ([ZXYFileManager moveItemAtURL:location toURL:downloadURL error:&err]) {
        
        /* Store some reference to the new URL */
    } else {
        /* Handle the error. */
    }
    
    [self.downloadArray removeObject:fileModel];
    [self removeDownloadResumeFileWithFileModel:fileModel];
    
    [self checkNeedAddDownloadTaskToDownloadTaskQueue];
}

- (void)removeDownloadResumeFileWithFileModel:(downLoadFileModel*)fileModel{
    
    NSString *tempFilePath = [self getResumeFilePathWithFileModel:fileModel];
    NSError *error = nil;
    if ([ZXYFileManager removeItemAtPath:tempFilePath error:&error]) {
        // remve resuedata
    }
    NSAssert(!error, @"remove resumedata failed");
}

- (downLoadFileModel*)getDownloadModelWithTaskIdentifier:(NSUInteger)taskIdentifier{
    
    @synchronized(_downloadArray) {
        downLoadFileModel *fileModel = nil;
        for (downLoadFileModel *model in _downloadArray) {
            
            if (model.taskIdentifier == taskIdentifier) {
                
                fileModel = model;
                break;
            }
        }
        return fileModel;
    }
}

-(void)updateDownloadProgressWithTaskIdentifier:(NSURLSessionDownloadTask*)task totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite{
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        downLoadFileModel *fileModel = [self getDownloadModelWithTaskIdentifier:task.taskIdentifier];
        if (fileModel) {
            fileModel.currentDownloadSize = totalBytesWritten;
            fileModel.fileSize = totalBytesExpectedToWrite;
        }else{
            NSLog(@"name=%@,task=%lu",fileModel.fileName,(unsigned long)task.taskIdentifier);
        }
        
//        [self handleCreateResumeDataWithFileModel:fileModel];
    });
}

-(void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite{
    
    if (totalBytesExpectedToWrite != NSURLSessionTransferSizeUnknown) {
        [self updateDownloadProgressWithTaskIdentifier:downloadTask totalBytesWritten:totalBytesWritten totalBytesExpectedToWrite:totalBytesExpectedToWrite];
    }
}

-(void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didResumeAtOffset:(int64_t)fileOffset expectedTotalBytes:(int64_t)expectedTotalBytes{
    
    [self updateDownloadProgressWithTaskIdentifier:downloadTask totalBytesWritten:fileOffset totalBytesExpectedToWrite:expectedTotalBytes];
}

- (NSData*)getDownLoadResumeDataWithFileModel:(downLoadFileModel*)model{
    NSString *tempFilePath = [self getResumeFilePathWithFileModel:model];
    NSData *tempData = [NSData dataWithContentsOfFile:tempFilePath];
    return tempData;
}

-(NSString*)getResumeFilePathWithFileModel:(downLoadFileModel*)fileModel{
    
    NSString *cacheDir = [ZXYFileManager downloadResumeDataPath];
    NSString *tempFilePath = [[cacheDir stringByAppendingPathComponent:fileModel.fileName] stringByAppendingPathExtension:@"data"];
    return tempFilePath;
}

@end
