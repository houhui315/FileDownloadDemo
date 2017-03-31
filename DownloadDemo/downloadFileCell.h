//
//  downloadFileCell.h
//  DownloadDemo
//
//  Created by 蓝泰致铭        on 16/6/24.
//  Copyright © 2016年 houhui. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "downLoadFileModel.h"
#import "UIView+CallEvent.h"

typedef NS_ENUM(NSInteger, EventType) {
    
    EventType_ButtonTouch
};

@interface downloadFileCell : UITableViewCell

@property (nonatomic, strong) downLoadFileModel *myModel;

- (void)congigureForDownloadFileModel:(downLoadFileModel*)model;

@end
