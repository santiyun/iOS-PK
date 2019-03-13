//
//  UIView+Toast.h
//  TTT
//
//  Created by yanzhen on 2018/6/9.
//  Copyright © 2018年 yanzhen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (Toast)
@property (nonatomic, assign) IBInspectable CGFloat borderWidth;
@property (nonatomic, strong) IBInspectable UIColor *borderColor;
@property (nonatomic, assign) IBInspectable CGFloat cornerRadius;

- (void)showToast:(NSString *)message;
- (void)showToast:(NSString *)message duration:(NSTimeInterval)duration;
- (void)showTopToast:(NSString *)message;
- (void)showTopToast:(NSString *)message duration:(NSTimeInterval)duration;
- (void)showBottomToast:(NSString *)message;
- (void)showBottomToast:(NSString *)message duration:(NSTimeInterval)duration;
@end

@interface UIViewController (Toast)
- (void)showToast:(NSString *)message;
@end

@interface NSLayoutConstraint (Adjust)
@property (nonatomic, assign) IBInspectable BOOL adjustIphone5;
@property (nonatomic, assign) IBInspectable BOOL adjustIphones;
@end

@interface UILabel (Adjust)
@property (nonatomic, assign) IBInspectable BOOL adjustFont;
@end

@interface UIButton (Adjust)
@property (nonatomic, assign) IBInspectable BOOL adjustFont;
@end
