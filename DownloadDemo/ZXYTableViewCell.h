//
//  ZXYTableViewCell.h
//  ZXYKitDemo
//
//  Created by houhui on 16/6/5.
//  Copyright © 2016年 houhui. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^TableViewCellEventCallBack)(NSDictionary *params);

@interface ZXYTableViewCell : UITableViewCell

- (void)registerEvent:(NSInteger)eventId callBack:(TableViewCellEventCallBack)callBack;

- (void)sendEvent:(NSInteger)eventId withParams:(NSDictionary*)params;

- (void)configureForModel:(id)model;

@end
