# 主播跨房间PK
在社交娱乐等业务场景中，为了增强趣味性和互动性，经常会设计一些主播PK的互动场景，将不同房间的主播拉入同一个房间内进行游戏互动，同时各主播原有房间的观众还能同时观看到自己关注的主播表演并进行打赏等互动。

## 典型场景
主播A和主播B分别创建2个直播房间，房间内无连麦副播，直接将房间内的主播画面推流到CDN进行直播。当主播A向主播B发出PK邀请，主播A所在的房间将拉取一路B主播的流进入A房间进行实时PK互动，主播B所在的房间将拉取一路A主播的流进入B房间进行实时PK互动，同时通过后台的混频转码服务将2个主播的音视频数据进行合成后推送到原先的CDN地址。各自的CDN观众看到两个主播开始 PK。由于两个主播各自的 CDN 推流地址未发生改变，CDN 观众端不需要切换 CDN 拉流地址。当PK活动结束后，各自房间停止拉对方的流，即可恢复原来的直播模式。


# 架构设计

![](TTTLib/PK.png)


# 接口使用列表

1. 创建 TTT 音视频引擎对象 [sharedEngineWithAppId](http://www.3ttech.cn/index.php?menu=72&type=iOS#sharedEngineWithAppId)
2. 设置频道模式，PK 场景下频道模式需要设定为直播模式 [setChannelProfile](http://www.3ttech.cn/index.php?menu=72&type=iOS#setChannelProfile)
3. 设置用户角色，PK 场景下需要角色设定为主播 [setClientRole](http://www.3ttech.cn/index.php?menu=72&type=iOS#setClientRole) 
4. 设置 SDK 的 CDN 推流地址 [configPublisher](http://www.3ttech.cn/index.php?menu=72&type=iOS#configPublisher) 
5. 加入频道 [joinChannelByKey](http://www.3ttech.cn/index.php?menu=72&type=iOS#joinChannelByKey)
6. 启动本地视频预览 [startPreview](http://www.3ttech.cn/index.php?menu=72&type=iOS#startPreview)
7. 设置本地视频显示属性 [setupLocalVideo](http://www.3ttech.cn/index.php?menu=72&type=iOS#setupLocalVideo)
8. 设置远端视频显示属性 [setupRemoteVideo](http://www.3ttech.cn/index.php?menu=72&type=iOS#setupRemoteVideo)
9. 停止本地视频预览 [stopPreview](http://www.3ttech.cn/index.php?menu=72&type=iOS#stopPreview)
10. 发起 PK [subscribeOtherChannel](http://www.3ttech.cn/index.php?menu=72&type=iOS#subscribeOtherChannel) 
11. 结束 PK [unSubscribeOtherChannel](http://www.3ttech.cn/index.php?menu=72&type=iOS#unSubscribeOtherChannel)
12. 离开频道 [leaveChannel](http://www.3ttech.cn/index.php?menu=72&type=iOS#leaveChannel)

可选方法

1. 启用说话音量提示 [enableAudioVolumeIndication](http://www.3ttech.cn/index.php?menu=72&type=iOS#enableAudioVolumeIndication)
2. 静音/取消静音 [muteLocalAudioStream](http://www.3ttech.cn/index.php?menu=72&type=iOS#muteLocalAudioStream)
3. 切换摄像头 [switchCamera](http://www.3ttech.cn/index.php?menu=72&type=iOS#switchCamera)

### 实现细节
* PK 模式下，双方主播的 CDN 推流地址应与普通模式时选用的 URL 地址是一致的，确保 CDN 观众无需切换 CDN 地址。
* PK 模式下，若要结束 PK 模式，每个主播都调用 [unSubscribeOtherChannel]() 接口。例如 A 和 B 主播进行 PK，结束 PK 时 A 和 B 主播都需要调用。若只有一方调用，则另一方没有调用，没有调用接口的一方视频会继续接收，但音频会停止接收，状态就会不对。

# 示例程序

#### 准备工作
1. 在三体云官网SDK下载页 [http://3ttech.cn/index.php?menu=53](http://3ttech.cn/index.php?menu=53) 下载对应平台的 连麦直播SDK。
2. 登录三体云官网 [http://dashboard.3ttech.cn/index/login](http://dashboard.3ttech.cn/index/login) 注册体验账号，进入控制台新建自己的应用并获取APPID。

## iOS工程配置

SDK包含**TTTRtcEngineKit.framework**和**TTTPlayerKit.framework** 

**两个framework只支持真机，不支持模拟器**


把下载的SDK放在demo的**TTTLib**目录下, 在**PKManager**文件填写申请的AppID

工程已做如下配置，直接运行工程

1. 设置Bitcode为NO
2. 设置后台音频模式
3. 导入系统库

 * libxml2.tbd
 * libc++.tbd
 * libz.tbd
 * libsqlite3.tbd
 * ReplayKit.framework
 * CoreTelephony.framework
 * SystemConfiguration.framework
   

# 常见问题
1. 由于部分模拟器会存在功能缺失或者性能问题，所以 SDK 不支持模拟器的使用。

2. 主播PK模式下，不建议在房间内有副播的情况下进行，因为房间原有的副播也能与新进入的主播进行音视频互动，可能影响主播间的PK效果。
