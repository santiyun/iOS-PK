//
//  PKLoginViewController.m
//  LinkPK
//
//  Created by yanzhen on 2019/1/28.
//  Copyright © 2019 yanzhen. All rights reserved.
//

#import "PKLoginViewController.h"
#import "TTProgressHud.h"
#import "UIView+Toast.h"
#import "PKManager.h"

@interface PKLoginViewController ()<TTTRtcEngineDelegate>
@property (weak, nonatomic) IBOutlet UITextField *roomIDTF;

@property (weak, nonatomic) IBOutlet UILabel *versionLabel;
@property (nonatomic) int64_t uid;
@end

@implementation PKLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSString *dateStr = NSBundle.mainBundle.infoDictionary[@"CFBundleVersion"];
    _versionLabel.text= [TTTRtcEngineKit.getSdkVersion stringByAppendingFormat:@"__%@", dateStr];
    _uid = arc4random() % 100000 + 1;
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSString *rid = [ud stringForKey:@"T3_PK_ROOMID"];
    if (rid.longLongValue <= 0) {
        int64_t rid_int = arc4random() % 100000 + 1;
        rid = [NSString stringWithFormat:@"%lld", rid_int];
    }
    _roomIDTF.text = rid;
}

- (IBAction)enterChannel:(id)sender {
    if (_roomIDTF.text.length <= 0) {
        [self showToast:@"请输入正确的房间id"];//可以转换为long long的字符串
        return;
    }
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    [ud setValue:_roomIDTF.text forKey:@"T3_PK_ROOMID"];
    [ud synchronize];
    PKManager.manager.roomId = _roomIDTF.text.longLongValue;
    PKManager.manager.uid = _uid;
    [TTProgressHud showHud:self.view];
    
    TTTRtcEngineKit *engine = PKManager.manager.rtcEngine;
    engine.delegate = self;
    //设置频道属性为直播模式
    [engine setChannelProfile:TTTRtc_ChannelProfile_LiveBroadcasting];
    //设置用户角色为主播，跨房间连麦双方必须都是主播
    [engine setClientRole:TTTRtc_ClientRole_Anchor];
    //启用音频，该方法设置的状态是全局的，退出频道不会重置用户的状态
    [engine muteLocalAudioStream:NO];
    //启动音量监听--不需要监听音量忽略该操作
    [engine enableAudioVolumeIndication:1000 smooth:3];
    
    //推流地址设置，连麦之后不需要重新设置推流地址
    NSString *pushURL = [@"rtmp://push.3ttest.cn/sdk2/" stringByAppendingString:_roomIDTF.text];
    TTTPublisherConfiguration *config = [[TTTPublisherConfiguration alloc] init];
    config.videoBitrate = 1600;//PK时合流码率
    config.videoFrameRate = 15;//PK时合流帧率
    config.publishUrl = pushURL;
    [engine configPublisher:config];
    //设置编码参数   单路直播上行和推cdn参数
    [engine setVideoProfile:CGSizeMake(528, 960) frameRate:15 bitRate:1600];
    //开启预览
    [engine startPreview];
    //加入频道
    [engine joinChannelByKey:nil channelName:_roomIDTF.text uid:_uid joinSuccess:nil];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [_roomIDTF resignFirstResponder];
}

#pragma mark - TTTRtcEngineDelegate
//加入频道成功，进入PK页面
-(void)rtcEngine:(TTTRtcEngineKit *)engine didJoinChannel:(NSString *)channel withUid:(int64_t)uid elapsed:(NSInteger)elapsed {
    [TTProgressHud hideHud:self.view];
    [self performSegueWithIdentifier:@"PK" sender:nil];
}

//加入频道出现错误
-(void)rtcEngine:(TTTRtcEngineKit *)engine didOccurError:(TTTRtcErrorCode)errorCode {
    NSString *errorInfo = @"";
    switch (errorCode) {
        case TTTRtc_Error_Enter_TimeOut:
            errorInfo = @"超时,10秒未收到服务器返回结果";
            break;
        case TTTRtc_Error_Enter_Failed:
            errorInfo = @"该直播间不存在";
            break;
        case TTTRtc_Error_Enter_BadVersion:
            errorInfo = @"版本错误";
            break;
        case TTTRtc_Error_InvalidChannelName:
            errorInfo = @"Invalid channel name";
            break;
        default:
            errorInfo = [NSString stringWithFormat:@"未知错误：%zd",errorCode];
            break;
    }
    [TTProgressHud hideHud:self.view];
    [self showToast:errorInfo];
}
@end
