//
//  ViewController.m
//  DownloadDemo
//
//  Created by houhui on 16/6/23.
//  Copyright © 2016年 houhui. All rights reserved.
//

#import "ViewController.h"
#import "FileDownloadViewController.h"


@interface ViewController ()
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:@"下载" style:UIBarButtonItemStyleDone target:self action:@selector(pushToDownloadPage)];
    self.navigationItem.rightBarButtonItem = item;
}

- (void)pushToDownloadPage{
    
    FileDownloadViewController *downloadVC = [FileDownloadViewController new];
    [self.navigationController pushViewController:downloadVC animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
