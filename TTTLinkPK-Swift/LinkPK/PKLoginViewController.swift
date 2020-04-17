//
//  PKLoginViewController.swift
//  LinkPK
//
//  Created by Work on 2019/3/14.
//  Copyright © 2019 yanzhen. All rights reserved.
//

import UIKit
import TTTRtcEngineKit

class PKLoginViewController: UIViewController {

    private var uid: Int64 = 0
    @IBOutlet private weak var roomIDTF: UITextField!
    @IBOutlet private weak var versionLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        versionLabel.text = TTTRtcEngineKit.getSdkVersion()
        uid = Int64(arc4random() % 100000) + 1
        if let rid = UserDefaults.standard.value(forKey: "ENTERROOMID") as? Int64 {
            roomIDTF.text = rid.description
        } else {
            roomIDTF.text = (arc4random() % 100000 + 1).description
        }
    }
    
    @IBAction private func joinChannel(_ sender: Any) {
        if roomIDTF.text == nil || roomIDTF.text!.count == 0 || roomIDTF.text!.count >= 19 {
            showToast("请输入19位以内的房间ID")
            return
        }
        let rid = Int64(roomIDTF.text!)!
        UserDefaults.standard.set(rid, forKey: "ENTERROOMID")
        UserDefaults.standard.synchronize()
        TTProgressHud.showHud(view)
        PKManager.manager.roomID = rid
        PKManager.manager.uid = uid
        //
        let engine = PKManager.manager.rtcEngine
        engine?.delegate = self
        //设置频道属性为直播模式
        engine?.setChannelProfile(.channelProfile_LiveBroadcasting)
        //设置用户角色为主播，跨房间连麦双方必须都是主播
        engine?.setClientRole(.clientRole_Anchor)
        //启用音频，该方法设置的状态是全局的，退出频道不会重置用户的状态
        engine?.muteLocalAudioStream(false)
        //启动音量监听
        engine?.enableAudioVolumeIndication(1000, smooth: 3)
        
        //推流地址设置，连麦之后不需要重新设置推流地址
        let config = TTTPublisherConfiguration()
        config.publishUrl = "rtmp://push.3ttest.cn/sdk2/" + rid.description
        config.videoBitrate = 1600//PK时合流码率
        config.videoFrameRate = 15//PK时合流帧率
        engine?.configPublisher(config)
        //设置本地视频分辨率---竖屏模式下交换视频宽高
        engine?.setVideoProfile(CGSize(width: 528, height: 960), frameRate: 15, bitRate: 1600)
        //开启预览
        engine?.startPreview()
        //加入频道
        engine?.joinChannel(byKey: nil, channelName: roomIDTF.text!, uid: uid, joinSuccess: nil)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        roomIDTF.resignFirstResponder()
    }
    
}

extension PKLoginViewController: TTTRtcEngineDelegate {
    //加入频道成功，进入PK页面
    func rtcEngine(_ engine: TTTRtcEngineKit!, didJoinChannel channel: String!, withUid uid: Int64, elapsed: Int) {
        TTProgressHud.hideHud(for: view)
        performSegue(withIdentifier: "PK", sender: nil)
    }
    //加入频道出现错误
    func rtcEngine(_ engine: TTTRtcEngineKit!, didOccurError errorCode: TTTRtcErrorCode) {
        var errorInfo = ""
        switch errorCode {
        case .error_Enter_TimeOut:
            errorInfo = "超时,10秒未收到服务器返回结果"
        case .error_Enter_Failed:
            errorInfo = "无法连接服务器"
        case .error_Enter_BadVersion:
            errorInfo = "版本错误"
        case .error_InvalidChannelName:
            errorInfo = "Invalid channel name"
        default:
            errorInfo = "未知错误: " + errorCode.rawValue.description
        }
        TTProgressHud.hideHud(for: view)
        showToast(errorInfo)
    }
}
