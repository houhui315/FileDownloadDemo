//
//  FileDownloadViewController.m
//  DownloadDemo
//
//  Created by houhui on 16/6/25.
//  Copyright © 2016年 houhui. All rights reserved.
//

#import "FileDownloadViewController.h"
#import "downloadFileCell.h"
#import "ZXYDownLoadFileManager.h"

static NSString *const cellIdentifier = @"cellIdentifier";

@interface FileDownloadViewController ()<UITableViewDelegate,UITableViewDataSource>{
    
    BOOL DownloadAll;
}

@property (nonatomic, strong) UITableView *tabelView;

//所有的文件
@property (nonatomic, strong) NSMutableArray *allDataArray;

@property (nonatomic, strong) NSTimer *timer;

@end

@implementation FileDownloadViewController

- (void)dealloc{
    
    [_allDataArray removeAllObjects];
    _allDataArray = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"多文件下载";
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:@"返回" style:UIBarButtonItemStylePlain target:self action:@selector(stopTimer)];
    self.navigationItem.leftBarButtonItem = item;
    
    [self checkShowAllStatus];
    
    [self initData];
    
    [self initTableView];
    
    _timer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(timerStep) userInfo:nil repeats:YES];
}

- (void)stopTimer{
    
    [_timer invalidate];
    _timer = nil;
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)checkShowAllStatus{
    
    if (DownloadAll) {
        
        UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:@"全部停止" style:UIBarButtonItemStylePlain target:self action:@selector(downloadOrStopDownloadAll:)];
        self.navigationItem.rightBarButtonItem = item;
    }else{
        
        UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:@"全部下载" style:UIBarButtonItemStylePlain target:self action:@selector(downloadOrStopDownloadAll:)];
        self.navigationItem.rightBarButtonItem = item;
    }
}

- (void)downloadOrStopDownloadAll:(id)sender{
    
    if (!DownloadAll) {
        
        [self downLoadAll];
    }else{
        
        [self cancelAll];
    }
    DownloadAll = !DownloadAll;
    [self checkShowAllStatus];
}

- (void)downLoadAll{
    
    ZXYDownLoadFileManager *manager = [ZXYDownLoadFileManager shareInstance];
    [manager addMutiDownloadTaskToDownloadQueueWithFileModelArray:self.allDataArray];
    [self updateUI];
}

- (void)cancelAll{
    
    [ZXYSharedDownLoadFileManager stopMutiDownloadTaskToDownliadQueueWithFileModelArray:self.allDataArray];
    [self updateUI];
}

- (void)timerStep{
    
    [self updateUI];
}

- (void)updateUI{
    
    [self.tabelView reloadData];
}

- (void)initData{
    
    _allDataArray = [NSMutableArray array];
    
    [self testData];
}

- (void)initTableView{
    
    UITableView *tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    tableView.delegate = self;
    tableView.dataSource = self;
    [self.view addSubview:tableView];
    [tableView registerClass:[downloadFileCell class] forCellReuseIdentifier:cellIdentifier];
    self.tabelView = tableView;
}

- (void)testData{
    
    ZXYDownLoadFileManager *manager = [ZXYDownLoadFileManager shareInstance];
    
    NSString *cacheDir = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    
    downLoadFileModel *model = [manager getDownloadTaskWithFileName:@"zxy_saas_tc_old_8.2.4.ipa" fileUrl:@"https://dn-zxyapp.qbox.me/zxy_saas_tc_old_8.2.4.ipa"  downloadPath:[cacheDir stringByAppendingPathComponent:@"zxy_saas_tc_old_8.2.4.ipa"]];
    [self.allDataArray addObject:model];
    
    downLoadFileModel *model2 = [manager getDownloadTaskWithFileName:@"zxy_saas_tc_8.2.4.ipa" fileUrl:@"https://dn-zxyapp.qbox.me/zxy_saas_tc_8.2.4.ipa"  downloadPath:[cacheDir stringByAppendingPathComponent:@"zxy_saas_tc_8.2.4.ipa"]];
    [self.allDataArray addObject:model2];
    
    downLoadFileModel *model3 = [manager getDownloadTaskWithFileName:@"zxy_saas_8.0.ipa" fileUrl:@"https://dn-zxyapp.qbox.me/zxy_saas_8.0.ipa"  downloadPath:[cacheDir stringByAppendingPathComponent:@"zxy_saas_8.0.ipa"]];
    [self.allDataArray addObject:model3];
    
    downLoadFileModel *model4 = [manager getDownloadTaskWithFileName:@"zxy_zpld_1.2.3.ipa" fileUrl:@"https://dn-zxyapp.qbox.me/zxy_zpld_1.2.3.ipa"  downloadPath:[cacheDir stringByAppendingPathComponent:@"zxy_zpld_1.2.3.ipa"]];
    [self.allDataArray addObject:model4];
    
    downLoadFileModel *model5 = [manager getDownloadTaskWithFileName:@"zxy_zpld_1.2.4.ipa" fileUrl:@"https://dn-zxyapp.qbox.me/zxy_zpld_1.2.4.ipa" downloadPath:[cacheDir stringByAppendingPathComponent:@"zxy_zpld_1.2.4.ipa"]];
    [self.allDataArray addObject:model5];
    
    downLoadFileModel *model6 = [manager getDownloadTaskWithFileName:@"simpholders_2_2.dmg" fileUrl:@"https://simpholders.com/site/assets/files/1968/simpholders_2_2.dmg" downloadPath:[cacheDir stringByAppendingPathComponent:@"simpholders_2_2.dmg"]];
    [self.allDataArray addObject:model6];
    
//    downLoadFileModel *model8 = [manager getDownloadTaskWithFileName:@"aaqsimpholders_2_2.dmg" fileUrl:@"https://fffsimpholders.com/site/assets/files/1968/aaqsimpholders_2_2.dmg" savedPath:[cacheDir stringByAppendingPathComponent:@"aaqsimpholders_2_2.dmg"]];
//    [self.allDataArray addObject:model8];
}


-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [_allDataArray count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return 44.f;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    downloadFileCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    downLoadFileModel *model = _allDataArray[indexPath.row];
    [cell congigureForDownloadFileModel:model];
    
    __weak typeof(self) weakSelf = self;
    [cell registerEvent:EventType_ButtonTouch callBack:^(NSDictionary *params) {
        
        [weakSelf buttonTouchedFromCell:cell model:model];
    }];
    
    return cell;
}


#pragma mark EventHandle methods

- (void)buttonTouchedFromCell:(downloadFileCell *)cell model:(downLoadFileModel *)model{
    
    ZXYDownLoadFileManager *manager = [ZXYDownLoadFileManager shareInstance];
    switch (model.status) {
        case DLStatus_no:{
            
            [manager addDownloadTaskToQueueAndCheckDownloadQueueWithModel:model];
        }break;
        case DLStatus_wait:{
            
        }break;
        case DLStatus_downloading:{
            [manager stopDownloadTaskAndCheckDownloadQueueWithModel:model];
        }break;
        case DLStatus_stop:{
            [manager addDownloadTaskToQueueAndCheckDownloadQueueWithModel:model];
        }break;
        case DLStatus_finished:{
            
        }break;
        case DLStatus_failed:{
            [manager addDownloadTaskToQueueAndCheckDownloadQueueWithModel:model];
        }break;
            
        default:
            break;
    }
    [cell congigureForDownloadFileModel:model];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
