//
//  TTProgressHud.m
//  TTT
//
//  Created by yanzhen on 2018/6/9.
//  Copyright © 2018年 yanzhen. All rights reserved.
//

#import "TTProgressHud.h"

static const BOOL TTHudWhite = YES;
static const CGFloat TTHudMinWH = 80;
static const CGFloat TTHudTakeMax = 0.7;
static const CGFloat TTHudPadding = 15;
static const CGFloat TTHudShowViewCornerRadius = 5;
static const NSTimeInterval TThudHideDelay = 1;
static const CGFloat TTHudTitleFontSize = 16;

@interface TTProgressHud()
@property (nonatomic, strong) UIView *showView;
@end

@implementation TTProgressHud

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _showView = [[UIView alloc] init];
        _showView.backgroundColor = TTHudWhite ? [UIColor colorWithWhite:0.8 alpha:0.6] : [UIColor blackColor];
        
        _showView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
        _showView.layer.cornerRadius = TTHudShowViewCornerRadius;
        [self addSubview:_showView];
    }
    return self;
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    _showView.center = CGPointMake(self.bounds.size.width * 0.5, self.bounds.size.height * 0.5);
}

+ (void)showHud:(UIView *)view
{
    [self showHud:view message:nil];
}

+ (void)showHud:(UIView *)view message:(NSString *)message
{
    [self showHud:view message:message textColor:nil];
}

+ (void)showHud:(UIView *)view message:(NSString *)message textColor:(UIColor *)color
{
    [self hideHud:view];
    TTProgressHud *hud = [[TTProgressHud alloc] initWithFrame:view.bounds];
    [hud create:message textColor:color];
    [view addSubview:hud];
}

+ (void)showHud:(UIView *)view imageName:(NSString *)imageName
{
    [self showHud:view imageName:imageName hideDelay:TThudHideDelay];
}

+ (void)showHud:(UIView *)view imageName:(NSString *)imageName hideDelay:(NSTimeInterval)delay
{
    if (imageName.length == 0) { return; }
    [self hideHud:view];
    TTProgressHud *hud = [[TTProgressHud alloc] initWithFrame:view.bounds];
    [hud create:imageName];
    [view addSubview:hud];
    [hud performSelector:@selector(removeFromSuperview) withObject:nil afterDelay:delay];
}

+ (void)showHud:(UIView *)view imageName:(NSString *)imageName message:(NSString *)message
{
    [self showHud:view imageName:imageName message:message hideDelay:TThudHideDelay];
}

+ (void)showHud:(UIView *)view imageName:(NSString *)imageName message:(NSString *)message hideDelay:(NSTimeInterval)delay
{
    [self showHud:view imageName:imageName message:message textColor:nil hideDelay:delay];
}

+ (void)showHud:(UIView *)view imageName:(NSString *)imageName message:(NSString *)message textColor:(UIColor *)color
{
    [self showHud:view imageName:imageName message:message textColor:nil hideDelay:TThudHideDelay];
}

+ (void)showHud:(UIView *)view imageName:(NSString *)imageName message:(NSString *)message textColor:(UIColor *)color hideDelay:(NSTimeInterval)delay
{
    if (imageName.length == 0) { return; }
    if (message.length == 0) {
        [self showHud:view imageName:imageName];
        return;
    }
    [self hideHud:view];
    TTProgressHud *hud = [[TTProgressHud alloc] initWithFrame:view.bounds];
    [view addSubview:hud];
    [hud create:imageName message:message textColor:color];
    [hud performSelector:@selector(removeFromSuperview) withObject:nil afterDelay:delay];
}

+(void)hideHud:(UIView *)view
{
    for (UIView *hud in view.subviews) {
        if ([hud isKindOfClass:[TTProgressHud class]]) {
            [UIView animateWithDuration:1 animations:^{
                hud.alpha = 0;
            } completion:^(BOOL finished) {
                [hud removeFromSuperview];
            }];
        }
    }
}
#pragma mark - private
- (void)create:(NSString *)imageName
{
    UIImageView *imageView = [self createImgView:imageName];//注意图片的大小
    _showView.frame = CGRectMake(0, 0, TTHudMinWH, TTHudMinWH);
    imageView.center = CGPointMake(TTHudMinWH / 2, TTHudMinWH / 2);
}

- (void)create:(NSString *)message textColor:(UIColor *)color
{
    if (message.length == 0) {
        UIActivityIndicatorView *indicatorView = [self createActivityIndicatorView];
        _showView.frame = CGRectMake(0, 0, TTHudMinWH, TTHudMinWH);
        indicatorView.center = CGPointMake(TTHudMinWH / 2, TTHudMinWH / 2);
        return;
    }
    UIActivityIndicatorView *indicatorView = [self createActivityIndicatorView];
    [self adjustViewAndAddTitleLabel:indicatorView message:message textColor:color];
}

- (void)create:(NSString *)imageName message:(NSString *)message textColor:(UIColor *)color
{
    UIImageView *imageView = [self createImgView:imageName];
    [self adjustViewAndAddTitleLabel:imageView message:message textColor:color];
}

- (void)adjustViewAndAddTitleLabel:(UIView *)view message:(NSString *)message textColor:(UIColor *)color
{
    UILabel *titleLabel = [self createTitleLabel];
    titleLabel.text = message;
    if (color) {
        titleLabel.textColor = color;
    }
    CGSize maxSize = CGSizeMake(self.bounds.size.width * TTHudTakeMax, self.bounds.size.height * TTHudTakeMax);
    CGSize textSize = [message boundingRectWithSize:maxSize options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : titleLabel.font} context:nil].size;
    CGFloat showW = textSize.width + TTHudPadding * 2;
    if (showW < TTHudMinWH) {
        showW = TTHudMinWH;
    }
    CGFloat showH = TTHudPadding + view.frame.size.height + TTHudPadding * 2.34;
    _showView.frame = CGRectMake(0, 0, showW, showH);
    view.center = CGPointMake(showW * 0.5, view.frame.size.height * 0.5 + TTHudPadding);
    titleLabel.frame = CGRectMake(TTHudPadding, CGRectGetMaxY(view.frame) + TTHudPadding / 3, showW - TTHudPadding * 2, TTHudPadding + 2);
}

- (UIActivityIndicatorView *)createActivityIndicatorView
{
    UIActivityIndicatorView *indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    indicatorView.color = TTHudWhite ? [UIColor blackColor] : [UIColor whiteColor];
    [indicatorView startAnimating];
    [_showView addSubview:indicatorView];
    return indicatorView;
}

- (UILabel *)createTitleLabel
{
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.textColor = TTHudWhite ? [UIColor blackColor] : [UIColor whiteColor];
    titleLabel.font = [UIFont systemFontOfSize:TTHudTitleFontSize];
    titleLabel.backgroundColor = [UIColor clearColor];
    [_showView addSubview:titleLabel];
    return titleLabel;
}

- (UIImageView *)createImgView:(NSString *)imageName
{
    UIImage *image = [UIImage imageNamed:imageName];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    [_showView addSubview:imageView];
    return imageView;
}

@end
