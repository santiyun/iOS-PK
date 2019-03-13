//
//  TTProgressHud.h
//  TTT
//
//  Created by yanzhen on 2018/6/9.
//  Copyright © 2018年 yanzhen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TTProgressHud : UIView
+ (void)showHud:(UIView *)view;
+ (void)showHud:(UIView *)view message:(NSString *)message;
+ (void)showHud:(UIView *)view message:(NSString *)message textColor:(UIColor *)color;

+ (void)showHud:(UIView *)view imageName:(NSString *)imageName;
+ (void)showHud:(UIView *)view imageName:(NSString *)imageName hideDelay:(NSTimeInterval)delay;

+ (void)showHud:(UIView *)view imageName:(NSString *)imageName message:(NSString *)message;
+ (void)showHud:(UIView *)view imageName:(NSString *)imageName message:(NSString *)message hideDelay:(NSTimeInterval)delay;
+ (void)showHud:(UIView *)view imageName:(NSString *)imageName message:(NSString *)message textColor:(UIColor *)color;
+ (void)showHud:(UIView *)view imageName:(NSString *)imageName message:(NSString *)message textColor:(UIColor *)color hideDelay:(NSTimeInterval)delay;

+ (void)hideHud:(UIView *)view;
@end
