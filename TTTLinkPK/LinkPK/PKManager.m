//
//  PKManager.m
//  LinkPK
//
//  Created by yanzhen on 2019/1/28.
//  Copyright © 2019 yanzhen. All rights reserved.
//

#import "PKManager.h"

@implementation PKManager
static id _manager;
+ (instancetype)manager
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _manager = [[self alloc] init];
    });
    return _manager;
}

+(instancetype)allocWithZone:(struct _NSZone *)zone
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _manager = [super allocWithZone:zone];
    });
    return _manager;
}

- (id)copyWithZone:(NSZone *)zone
{
    return _manager;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        //初始化TTTRtcEngineKit对象，输入申请的AppID
        _rtcEngine = [TTTRtcEngineKit sharedEngineWithAppId:<#AppId#> delegate:nil];
    }
    return self;
}
@end
