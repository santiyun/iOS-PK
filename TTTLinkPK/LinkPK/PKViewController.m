//
//  PKViewController.m
//  LinkPK
//
//  Created by yanzhen on 2019/1/28.
//  Copyright © 2019 yanzhen. All rights reserved.
//

#import "PKViewController.h"
#import "TTProgressHud.h"
#import "UIView+Toast.h"
#import "PKManager.h"

@interface PKViewController ()<TTTRtcEngineDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *selfPlayer;
@property (weak, nonatomic) IBOutlet UIButton *voiceBtn;
@property (weak, nonatomic) IBOutlet UILabel *roomIdLabel;
@property (weak, nonatomic) IBOutlet UILabel *audioStatsLabel;
@property (weak, nonatomic) IBOutlet UILabel *videoStatsLabel;
//其他主播窗口
@property (weak, nonatomic) IBOutlet UIView *otherView;
@property (weak, nonatomic) IBOutlet UIImageView *otherPlayer;
@property (weak, nonatomic) IBOutlet UIButton *otherVoiceBtn;
@property (weak, nonatomic) IBOutlet UILabel *otherVideoStatsLabel;
@property (weak, nonatomic) IBOutlet UILabel *otherAudioStatsLabel;
//
@property (weak, nonatomic) IBOutlet UITextField *roomIdTf;
@property (weak, nonatomic) IBOutlet UIButton *pkBtn;

@property (nonatomic, strong) TTTRtcVideoCompositingLayout *layout;
@property (nonatomic) BOOL mutedSelf;
@property (nonatomic) int64_t otherUid;
@end

@implementation PKViewController

- (TTTRtcVideoCompositingLayout *)layout {
    if (!_layout) {
        _layout = [[TTTRtcVideoCompositingLayout alloc] init];
        //合流的分辨率可以同时放大一个系数
        _layout.canvasWidth = 704;//352 * 2
        _layout.canvasHeight = 640;//
        _layout.backgroundColor = @"#e8e6e8";
    }
    return _layout;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _roomIdLabel.text = [NSString stringWithFormat:@"房间Id: %lld   Uid: %lld", PKManager.manager.roomId, PKManager.manager.uid];
    _roomIdTf.text = [NSUserDefaults.standardUserDefaults stringForKey:@"T3_PK_OTHERROOMID"];
    
    PKManager.manager.rtcEngine.delegate = self;
    TTTRtcVideoCanvas *videoCanvas = [[TTTRtcVideoCanvas alloc] init];
    videoCanvas.uid = PKManager.manager.uid;
    videoCanvas.view = _selfPlayer;
    videoCanvas.renderMode = TTTRtc_Render_Adaptive;
    //设置本地渲染视图
    [PKManager.manager.rtcEngine setupLocalVideo:videoCanvas];
}

- (IBAction)startPK:(UIButton *)sender {
    if (_roomIdTf.text.length <= 0) {
        [self showToast:@"请输入正确的房间id"];
        return;
    }
    [_roomIdTf resignFirstResponder];
    if (sender.isSelected) {
        //取消订阅其它频道主播视频，对方主播会退出自己所在房间
        [PKManager.manager.rtcEngine unSubscribeOtherChannel:_roomIdTf.text.longLongValue];
        [self adjustVideoSize:NO];
    } else {
        NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
        [ud setValue:_roomIdTf.text forKey:@"T3_PK_OTHERROOMID"];
        [ud synchronize];
        //订阅其它频道主播视频，会收到对应频道主播以副播的身份加入频道------注意双方必须相互订阅
        [PKManager.manager.rtcEngine subscribeOtherChannel:_roomIdTf.text.longLongValue];
        [self adjustVideoSize:YES];
    }
}


- (IBAction)switchCamera:(id)sender {
    //切换摄像头
    [PKManager.manager.rtcEngine switchCamera];
}

- (IBAction)muteLocalAudio:(UIButton *)sender {
    sender.selected = !sender.isSelected;
    _mutedSelf = sender.isSelected;
    //开启/关闭静音功能
    [PKManager.manager.rtcEngine muteLocalAudioStream:sender.isSelected];
}

- (IBAction)leaveChannel:(id)sender {
    __weak PKViewController *weakSelf = self;
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"你确定要退出房间吗？" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction *sure = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [weakSelf dismiss];
    }];
    [alert addAction:cancel];
    [alert addAction:sure];
    [self presentViewController:alert animated:YES completion:nil];
}

//PK时调整本地分辨率
- (void)adjustVideoSize:(BOOL)isPK {
    if (isPK) {
        [PKManager.manager.rtcEngine setVideoProfile:CGSizeMake(352, 640) frameRate:15 bitRate:1200];
    } else {
        [PKManager.manager.rtcEngine setVideoProfile:CGSizeMake(528, 960) frameRate:15 bitRate:1600];
    }
}

- (void)dismiss {
    //离开频道
    [PKManager.manager.rtcEngine leaveChannel:nil];
    //开启预览，必须对应关闭预览
    [PKManager.manager.rtcEngine stopPreview];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [_roomIdTf resignFirstResponder];
}

#pragma mark - TTTRtcEngineDelegate

//其它频道（房间）主播以副播加入当前频道
- (void)rtcEngine:(TTTRtcEngineKit *)engine didJoinedOfUid:(int64_t)uid clientRole:(TTTRtcClientRole)clientRole isVideoEnabled:(BOOL)isVideoEnabled elapsed:(NSInteger)elapsed {
    if (clientRole != TTTRtc_ClientRole_Broadcaster) { return; }
    if (_otherUid > 0) { return; }
    _otherUid = uid;
    
    _pkBtn.selected = YES;
    _otherView.hidden = NO;
    _roomIdTf.userInteractionEnabled = NO;
    TTTRtcVideoCanvas *videoCanvas = [[TTTRtcVideoCanvas alloc] init];
    videoCanvas.uid = uid;
    videoCanvas.view = _otherPlayer;
    videoCanvas.renderMode = TTTRtc_Render_Adaptive;
    //显示副播的视频
    [PKManager.manager.rtcEngine setupRemoteVideo:videoCanvas];
    //刷新SEI，cdn根据SEI设置视频流位置
    [self refreshVideoCompositingLayout];
}
//远端用户离线
- (void)rtcEngine:(TTTRtcEngineKit *)engine didOfflineOfUid:(int64_t)uid reason:(TTTRtcUserOfflineReason)reason {
    if (uid != _otherUid) { return; }
    _otherUid = 0;
    //结束PK之后刷新SEI
    [self refreshVideoCompositingLayout];
    _pkBtn.selected = NO;
    _otherView.hidden = YES;
    _roomIdTf.userInteractionEnabled = YES;
    //PK用户离线，需要取消订阅对方视频
    [engine unSubscribeOtherChannel:_roomIdTf.text.longLongValue];
    [self adjustVideoSize:NO];
}

//网络丢失（会自动重连）
- (void)rtcEngineConnectionDidLost:(TTTRtcEngineKit *)engine {
    [TTProgressHud showHud:self.view message:@"网络链接丢失，正在重连..."];
}
//重新连接服务器成功
- (void)rtcEngineReconnectServerSucceed:(TTTRtcEngineKit *)engine {
    [TTProgressHud hideHud:self.view];
}
//重新连接服务器失败，需要退出房间
- (void)rtcEngineReconnectServerTimeout:(TTTRtcEngineKit *)engine {
    [TTProgressHud hideHud:self.view];
    [self.view.window showToast:@"网络丢失，请检查网络"];
    [self dismiss];
}
//在房间内被服务器踢出
- (void)rtcEngine:(TTTRtcEngineKit *)engine didKickedOutOfUid:(int64_t)uid reason:(TTTRtcKickedOutReason)reason {
    NSString *errorInfo = @"";
    switch (reason) {
        case TTTRtc_KickedOut_PushRtmpFailed:
            errorInfo = @"rtmp推流失败";
            break;
        case TTTRtc_KickedOut_ReLogin:
            errorInfo = @"重复登录";
            break;
        case TTTRtc_KickedOut_NewChairEnter:
            errorInfo = @"其他人以主播身份进入";
            break;
        default:
            errorInfo = @"未知错误";
            break;
    }
    [self.view.window showToast:errorInfo];
    [self dismiss];
}
//---音视频数据统计
//上报本地音视频上行码率
- (void)rtcEngine:(TTTRtcEngineKit *)engine localAudioStats:(TTTRtcLocalAudioStats *)stats {
    _audioStatsLabel.text = [NSString stringWithFormat:@"A-↑%ldkbps", stats.sentBitrate];
}

- (void)rtcEngine:(TTTRtcEngineKit *)engine localVideoStats:(TTTRtcLocalVideoStats *)stats {
    _videoStatsLabel.text = [NSString stringWithFormat:@"V-↑%ldkbps_%ldfps", stats.sentBitrate, stats.sentFrameRate];
}
//上报远端用户视频下行码率
- (void)rtcEngine:(TTTRtcEngineKit *)engine remoteVideoStats:(TTTRtcRemoteVideoStats *)stats {
    _otherVideoStatsLabel.text = [NSString stringWithFormat:@"V-↓%ldkbps", stats.receivedBitrate];
}
//上报远端用户音频下行码率
- (void)rtcEngine:(TTTRtcEngineKit *)engine remoteAudioStats:(TTTRtcRemoteAudioStats *)stats {
    _otherAudioStatsLabel.text = [NSString stringWithFormat:@"A-↓%ldkbps", stats.receivedBitrate];
}
//报告房间内用户的音量包括自己
- (void)rtcEngine:(TTTRtcEngineKit *)engine reportAudioLevel:(int64_t)userID audioLevel:(NSUInteger)audioLevel audioLevelFullRange:(NSUInteger)audioLevelFullRange {
    if (userID == PKManager.manager.uid) {
        if (_mutedSelf) {
            [_voiceBtn setImage:[UIImage imageNamed:@"voice_close"] forState:UIControlStateNormal];
        } else {
            [_voiceBtn setImage:[self getVoiceImage:audioLevel] forState:UIControlStateNormal];
        }
    } else if (userID == _otherUid) {
        [_otherVoiceBtn setImage:[self getVoiceImage:audioLevel] forState:UIControlStateNormal];
    }
}
#pragma mark - Help
//刷新SEI
- (void)refreshVideoCompositingLayout {
    //左右分屏
    [self.layout.regions removeAllObjects];
    TTTRtcVideoCompositingRegion *anchor = [[TTTRtcVideoCompositingRegion alloc] init];
    anchor.uid = PKManager.manager.uid;
    anchor.x = 0;
    anchor.y = 0;
    anchor.width = 0.5;
    anchor.height = 1;
    anchor.zOrder = 0;
    anchor.alpha = 1;
    anchor.renderMode = TTTRtc_Render_Adaptive;
    [_layout.regions addObject:anchor];
    if (_otherUid > 0) {
        TTTRtcVideoCompositingRegion *other = [[TTTRtcVideoCompositingRegion alloc] init];
        other.uid = _otherUid;
        other.x = 0.5;
        other.y = 0;
        other.width = 0.5;
        other.height = 1;
        other.zOrder = 1;
        other.alpha = 1;
        other.renderMode = TTTRtc_Render_Adaptive;
        [_layout.regions addObject:other];
    }
    [PKManager.manager.rtcEngine setVideoCompositingLayout:_layout];
}

- (UIImage *)getVoiceImage:(NSUInteger)level {
    UIImage *image = nil;
    if (level < 4) {
        image = [UIImage imageNamed:@"voice_small"];
    } else if (level < 7) {
        image = [UIImage imageNamed:@"voice_middle"];
    } else {
        image = [UIImage imageNamed:@"voice_big"];
    }
    return image;
}
@end
