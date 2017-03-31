//
//  downloadFileCell.m
//  DownloadDemo
//
//  Created by 蓝泰致铭        on 16/6/24.
//  Copyright © 2016年 houhui. All rights reserved.
//

#import "downloadFileCell.h"

@interface downloadFileCell ()

@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *downloadDegreeLabel;
@property (nonatomic, strong) UIButton *downloadButton;

@end

@implementation downloadFileCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        [self initSubViews];
    }
    return self;
}

- (void)initSubViews{
    
    self.backgroundColor = [UIColor whiteColor];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 200, 20)];
    nameLabel.textColor = [UIColor blackColor];
    [self.contentView addSubview:nameLabel];
    nameLabel.font = [UIFont systemFontOfSize:13.f];
    self.nameLabel = nameLabel;
    
    UILabel *downloadDegree = [[UILabel alloc] initWithFrame:CGRectMake(self.bounds.size.width - 90 - 60, 10, 70, 20)];
    downloadDegree.textColor = [UIColor blackColor];
    downloadDegree.font = [UIFont systemFontOfSize:13.f];
    [self.contentView addSubview:downloadDegree];
    self.downloadDegreeLabel = downloadDegree;
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setFrame:CGRectMake(self.bounds.size.width - 70, 10, 60, 30)];
    [self.contentView addSubview:button];
    [button setBackgroundColor:[UIColor whiteColor]];
    [button.titleLabel setFont:[UIFont systemFontOfSize:14.f]];
    [button setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(buttonTouch:) forControlEvents:UIControlEventTouchUpInside];
    self.downloadButton = button;
}

- (void)buttonTouch:(id)sender{
    
    [self sendEvent:EventType_ButtonTouch withParams:nil];
}

- (void)updateButtonTitleWithString:(NSString*)string{
    
    [self.downloadButton setTitle:string forState:UIControlStateNormal];
}

- (void)changeButtonTitleWithStatus:(DLStatus)status{
    
    NSString *string = @"下载";
    switch (status) {
        case DLStatus_no:{
            
            string = @"下载";
        }break;
        case DLStatus_wait:{
            string =@"等待中";
        }break;
        case DLStatus_downloading:{
            string = @"暂停下载";
        }break;
        case DLStatus_stop:{
            string = @"继续下载";
        }break;
        case DLStatus_failed:{
            string = @"下载失败";
        }break;
        case DLStatus_finished:{
            string = @"已完成";
            [self.downloadButton setEnabled:NO];
        }break;
            
        default:
            break;
    }
    [self updateButtonTitleWithString:string];
}

- (void)updateProgressWhenDownloadindWithModel:(downLoadFileModel*)model{
    
    if (model.fileSize > 0) {
        double degree = (double)model.currentDownloadSize/model.fileSize;
        self.downloadDegreeLabel.text = [NSString stringWithFormat:@"%.2f %%",degree*100];
        self.downloadDegreeLabel.hidden = NO;
    }else{
        self.downloadDegreeLabel.hidden = YES;
    }
}

- (void)congigureForDownloadFileModel:(downLoadFileModel*)model{
    
    _myModel = model;
    self.nameLabel.text = model.fileName;
    
    [self changeButtonTitleWithStatus:model.status];
    
    
    if (model.status == DLStatus_downloading) {
        [self updateProgressWhenDownloadindWithModel:model];
    }else{
        self.downloadDegreeLabel.hidden = YES;
    }
}

@end
