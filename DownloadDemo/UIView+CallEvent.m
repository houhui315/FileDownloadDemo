//
//  UIView+CallEvent.m
//  ZXYKitDemo
//
//  Created by 蓝泰致铭        on 16/6/30.
//  Copyright © 2016年 houhui. All rights reserved.
//

#import "UIView+CallEvent.h"
#import <objc/runtime.h>

static char *eventDictionaryKey = "eventDictionary";

@implementation UIView (CallEvent)

- (void)dealloc{
    
//    free(eventDictionaryKey);
}

- (NSMutableDictionary*)eventDict{
    
    id value = objc_getAssociatedObject(self, eventDictionaryKey);
    if (value) {
        
        return objc_getAssociatedObject(self, eventDictionaryKey);
    }else{
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        objc_setAssociatedObject(self, eventDictionaryKey, dict, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        return objc_getAssociatedObject(self, eventDictionaryKey);
    }
}

- (void)registerEvent:(NSInteger)eventId callBack:(UIViewEventCallBack)callBack{
    
    NSString *eventKey = [NSString stringWithFormat:@"%ld",eventId];
    NSMutableDictionary *dict = [self eventDict];
    if ([dict objectForKey:eventKey]) {
        return;
    }
    [dict setObject:callBack forKey:eventKey];
}

- (void)sendEvent:(NSInteger)eventId withParams:(NSDictionary*)params{
    NSMutableDictionary *dict = [self eventDict];
    UIViewEventCallBack callback = [dict objectForKey:[NSString stringWithFormat:@"%ld",eventId]];
    if (!callback) {
        return;
    }
    callback(params);
}

- (void)configureForModel:(id)model{
    
    
}


@end
