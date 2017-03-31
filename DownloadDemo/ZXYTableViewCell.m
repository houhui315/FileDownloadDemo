//
//  ZXYTableViewCell.m
//  ZXYKitDemo
//
//  Created by houhui on 16/6/5.
//  Copyright © 2016年 houhui. All rights reserved.
//

#import "ZXYTableViewCell.h"

@interface ZXYTableViewCell ()

@property (nonatomic, strong) NSMutableDictionary *eventDictionary;

@end

@implementation ZXYTableViewCell

- (void)dealloc{
    
    _eventDictionary = nil;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    
    if ([super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        _eventDictionary = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)registerEvent:(NSInteger)eventId callBack:(TableViewCellEventCallBack)callBack{
    
    NSString *eventKey = [NSString stringWithFormat:@"%ld",eventId];
    if ([_eventDictionary objectForKey:eventKey]) {
        return;
    }
    [_eventDictionary setObject:callBack forKey:eventKey];
}

- (void)sendEvent:(NSInteger)eventId withParams:(NSDictionary*)params{
    
    TableViewCellEventCallBack callback = [_eventDictionary objectForKey:[NSString stringWithFormat:@"%ld",eventId]];
    if (!callback) {
        return;
    }
    callback(params);
}

- (void)awakeFromNib {
    // Initialization code
    [super awakeFromNib];
}

- (void)configureForModel:(id)model{
    
    
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
