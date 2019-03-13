//
//  PKManager.h
//  LinkPK
//
//  Created by yanzhen on 2019/1/28.
//  Copyright © 2019 yanzhen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <TTTRtcEngineKit/TTTRtcEngineKit.h>

@interface PKManager : NSObject

@property (nonatomic, strong) TTTRtcEngineKit *rtcEngine;
@property (nonatomic) int64_t roomId;
@property (nonatomic) int64_t uid;
+ (instancetype)manager;

@end

