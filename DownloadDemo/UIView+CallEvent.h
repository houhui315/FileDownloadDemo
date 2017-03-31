//
//  UIView+CallEvent.h
//  ZXYKitDemo
//
//  Created by 蓝泰致铭        on 16/6/30.
//  Copyright © 2016年 houhui. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^UIViewEventCallBack)(NSDictionary *params);

@interface UIView (CallEvent)

- (void)registerEvent:(NSInteger)eventId callBack:(UIViewEventCallBack)callBack;

- (void)sendEvent:(NSInteger)eventId withParams:(NSDictionary*)params;

- (void)configureForModel:(id)model;

@end
