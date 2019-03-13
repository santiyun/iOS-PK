//
//  UIView+Toast.m
//  TTT
//
//  Created by yanzhen on 2018/6/9.
//  Copyright © 2018年 yanzhen. All rights reserved.
//

#import "UIView+Toast.h"

static CGFloat const TTToastAlpha = 1;
static CGFloat const TTToastTopPadding = 74;
static CGFloat const TTToastBottomPadding = 59;
static CGFloat const TTToastHorizontalPadding = 10;
static CGFloat const TTToastVerticalPadding = 10;
static NSTimeInterval const TTToastDefaultDuration = 2.5;

static CGFloat const TTToastShadowRadius = 6;
static CGSize const TTToastShadowOffset = {4, 4};
static CGFloat const TTToastFontSize = 16;
static NSTimeInterval const TTToastFadeDuration = 0.2;
static CGFloat const TTToastCornerRadius = 3;

typedef enum : NSUInteger {
    ToastTypeCenter,
    ToastTypeTop,
    ToastTypeBottom,
} ToastType;

@implementation UIView (Toast)

- (void)showToast:(NSString *)message
{
    [self showToast:message duration:TTToastDefaultDuration position:ToastTypeCenter];
}

- (void)showToast:(NSString *)message duration:(NSTimeInterval)duration
{
    [self showToast:message duration:duration position:ToastTypeCenter];
}

- (void)showTopToast:(NSString *)message
{
    [self showToast:message duration:TTToastDefaultDuration position:ToastTypeTop];
}

- (void)showTopToast:(NSString *)message duration:(NSTimeInterval)duration
{
    [self showToast:message duration:duration position:ToastTypeTop];
}

- (void)showBottomToast:(NSString *)message
{
    [self showToast:message duration:TTToastDefaultDuration position:ToastTypeBottom];
}

- (void)showBottomToast:(NSString *)message duration:(NSTimeInterval)duration
{
    [self showToast:message duration:duration position:ToastTypeBottom];
}
#pragma mark - private
- (void)showToast:(NSString *)message duration:(NSTimeInterval)duration position:(ToastType)position {
    UIView *toast = [self viewForMessage:message];
    [self showToastView:toast duration:duration position:position];
}

- (void)showToastView:(UIView *)toast duration:(NSTimeInterval)duration position:(ToastType)position
{
    toast.userInteractionEnabled = NO;
    [self makeToastCenter:toast type:position];
    toast.alpha = 0;
    [self addSubview:toast];
    
    [UIView animateWithDuration:TTToastFadeDuration delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        toast.alpha = TTToastAlpha;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:TTToastFadeDuration delay:duration options:UIViewAnimationOptionCurveEaseIn animations:^{
            toast.alpha = 0;
        } completion:^(BOOL finished) {
            [toast removeFromSuperview];
        }];
    }];
}

- (void)makeToastCenter:(UIView *)toast type:(ToastType)type
{
    CGFloat centerX = self.bounds.size.width * 0.5;
    CGPoint toastCenter = CGPointZero;
    CGFloat halfToastH = toast.frame.size.height * 0.5;
    switch (type) {
        case ToastTypeTop:
            toastCenter = CGPointMake(centerX, halfToastH + TTToastTopPadding);
            break;
        case ToastTypeBottom:
            toastCenter = CGPointMake(centerX, self.bounds.size.height - halfToastH - TTToastBottomPadding);
            break;
        default:
            toastCenter = CGPointMake(centerX, self.bounds.size.height * 0.5);
            break;
    }
    toast.center = toastCenter;
}

- (UIView *)viewForMessage:(NSString *)message
{
    UIView *toast = [[UIView alloc] init];
    toast.backgroundColor = [UIColor blackColor];
    toast.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
    toast.layer.cornerRadius = TTToastCornerRadius;
    toast.layer.shadowColor = [UIColor blackColor].CGColor;
    toast.layer.shadowOpacity = 1;
    toast.layer.shadowRadius = TTToastShadowRadius;
    toast.layer.shadowOffset = TTToastShadowOffset;
    //
    UILabel *messageLabel = [[UILabel alloc] init];
    messageLabel.numberOfLines = 0;
    messageLabel.lineBreakMode = NSLineBreakByCharWrapping;
    UIFont *font = [UIFont systemFontOfSize:TTToastFontSize];
    messageLabel.font = font;
    messageLabel.textColor = [UIColor whiteColor];
    messageLabel.text = message;
    
    CGSize maxSize = CGSizeMake(self.bounds.size.width * 0.8, self.bounds.size.height * 0.8);
    CGSize messageSize = [message boundingRectWithSize:maxSize options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : font} context:nil].size;
    messageLabel.frame = CGRectMake(TTToastHorizontalPadding, TTToastVerticalPadding, messageSize.width, messageSize.height);
    toast.frame = CGRectMake(0, 0, messageSize.width + 2 * TTToastHorizontalPadding, messageSize.height + 2 * TTToastVerticalPadding);
    [toast addSubview:messageLabel];
    return toast;
}

#pragma mark - property
-(void)setBorderWidth:(CGFloat)borderWidth{
    self.layer.borderWidth = borderWidth;
}

-(CGFloat)borderWidth{
    return 0;
}

-(void)setBorderColor:(UIColor *)borderColor{
    self.layer.borderColor = borderColor.CGColor;
}

-(UIColor *)borderColor{
    return 0;
}

-(void)setCornerRadius:(CGFloat)cornerRadius{
    self.layer.masksToBounds = YES;
    self.layer.cornerRadius = cornerRadius;
}

-(CGFloat)cornerRadius{
    return 0;
}
@end
@implementation UIViewController (Toast)
-(void)showToast:(NSString *)message
{
    [self.view showToast:message];
}
@end

@implementation NSLayoutConstraint (Adjust)
-(void)setAdjustIphone5:(BOOL)adjustIphone5 {
    if (adjustIphone5) {
        CGFloat width = UIScreen.mainScreen.bounds.size.width;
        if (width <= 320) {
            self.constant = self.constant * width / 375;
        }
    }
}

-(BOOL)adjustIphone5 {
    return NO;
}

-(void)setAdjustIphones:(BOOL)adjustIphones {
    if (adjustIphones) {
        self.constant = self.constant * UIScreen.mainScreen.bounds.size.width / 375;
    }
}

-(BOOL)adjustIphones {
    return NO;
}
@end

@implementation UILabel (Adjust)
-(BOOL)adjustFont {
    return NO;
}

-(void)setAdjustFont:(BOOL)adjustFont {
    if (adjustFont) {
        CGFloat size = self.font.pointSize * UIScreen.mainScreen.bounds.size.width / 375;
        self.font = [UIFont systemFontOfSize:size];
    }
}
@end

@implementation UIButton (Adjust)
-(BOOL)adjustFont {
    return NO;
}

-(void)setAdjustFont:(BOOL)adjustFont {
    if (adjustFont) {
        CGFloat size = self.titleLabel.font.pointSize * UIScreen.mainScreen.bounds.size.width / 375;
        self.titleLabel.font = [UIFont systemFontOfSize:size];
    }
}
@end
