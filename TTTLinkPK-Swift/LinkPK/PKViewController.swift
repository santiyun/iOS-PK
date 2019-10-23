//
//  PKViewController.swift
//  LinkPK
//
//  Created by Work on 2019/3/14.
//  Copyright © 2019 yanzhen. All rights reserved.
//

import UIKit
import TTTRtcEngineKit

class PKViewController: UIViewController {

    private var otherUid: Int64 = 0 //pk主播的Id
    private var mutedSelf = false
    //xib
    @IBOutlet private weak var pkBtn: UIButton!
    @IBOutlet private weak var pkRoomIDTF: UITextField!
    //self
    @IBOutlet private weak var selfPlayer: UIImageView!
    @IBOutlet private weak var voiceBtn: UIButton!
    @IBOutlet private weak var idLabel: UILabel!
    @IBOutlet private weak var audioStatsLabel: UILabel!
    @IBOutlet private weak var videoStatsLabel: UILabel!
    //remote
    @IBOutlet private weak var remoteView: UIView!
    @IBOutlet private weak var remotePlayer: UIImageView!
    @IBOutlet private weak var remoteVoiceBtn: UIButton!
    @IBOutlet private weak var remoteVideoStatsLabel: UILabel!
    @IBOutlet private weak var remoteAudioStatsLabel: UILabel!
    private lazy var layout: TTTRtcVideoCompositingLayout = {
        let layout  = TTTRtcVideoCompositingLayout()
        layout.canvasWidth = 352
        layout.canvasHeight = 640
        layout.backgroundColor = "#e8e6e8"
        return layout
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        idLabel.text = "roomId: \(PKManager.manager.roomID)   Uid: \(PKManager.manager.uid)"
        pkRoomIDTF.text = UserDefaults.standard.string(forKey: "T3_PK_OTHERROOMID")
        
        PKManager.manager.rtcEngine.delegate = self
        //开启预览本地，然后设置渲染视图
        PKManager.manager.rtcEngine.startPreview()
        let videoCanvas = TTTRtcVideoCanvas()
        videoCanvas.uid = PKManager.manager.uid
        videoCanvas.view = selfPlayer
        videoCanvas.renderMode = .render_Adaptive
        PKManager.manager.rtcEngine.setupLocalVideo(videoCanvas)
    }
    
    @IBAction private func startPK(_ sender: UIButton) {
        if pkRoomIDTF.text == nil || pkRoomIDTF.text!.count == 0 {
            showToast("请输入正确的房间ID")
            return
        }
        pkRoomIDTF.resignFirstResponder()
        let roomId = Int64(pkRoomIDTF.text!)!
        if sender.isSelected {
            //取消订阅其它频道主播视频，对用主播会退出自己所在房间
            PKManager.manager.rtcEngine.unSubscribeOtherChannel(roomId)
        } else {
            UserDefaults.standard.set(pkRoomIDTF.text, forKey: "T3_PK_OTHERROOMID")
            UserDefaults.standard.synchronize()
            //订阅其它频道主播视频，会收到对应频道主播以副播的身份加入频道------注意双方必须相互订阅
            PKManager.manager.rtcEngine.subscribeOtherChannel(roomId)
        }
    }
    
    //切换摄像头
    @IBAction private func switchCamera(_ sender: Any) {
        PKManager.manager.rtcEngine.switchCamera()
    }
    
    @IBAction private func muteLocalAudio(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        mutedSelf = sender.isSelected
        //开启/关闭静音功能
        PKManager.manager.rtcEngine.muteLocalAudioStream(sender.isSelected)
    }
    
    @IBAction private func exitChannel(_ sender: Any) {
        let alert = UIAlertController(title: "提示", message: "你确定要退出房间吗？", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
        let sureAction = UIAlertAction(title: "确定", style: .default) { [weak self] (action) in
            self?.dimissVc()
        }
        alert.addAction(sureAction)
        present(alert, animated: true, completion: nil)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        pkRoomIDTF.resignFirstResponder()
    }
}

extension PKViewController: TTTRtcEngineDelegate {
    //其它频道（房间）主播以副播加入当前频道--注意该场景下频道内应该没有副播
    func rtcEngine(_ engine: TTTRtcEngineKit!, didJoinedOfUid uid: Int64, clientRole: TTTRtcClientRole, isVideoEnabled: Bool, elapsed: Int) {
        if clientRole != .clientRole_Broadcaster { return } //只处理副播
        if otherUid > 0 { return }//Demo只考虑两人PK
        otherUid = uid
        
        pkBtn.isSelected = true
        remoteView.isHidden = false
        pkRoomIDTF.isUserInteractionEnabled = false
        //显示PK副播的视频
        let videoCanvas = TTTRtcVideoCanvas()
        videoCanvas.uid = uid
        videoCanvas.view = remotePlayer
        videoCanvas.renderMode = .render_Adaptive
        PKManager.manager.rtcEngine.setupRemoteVideo(videoCanvas)
        //刷新SEI，cdn根据SEI设置视频流位置
        refreshVideoCompositingLayout()
    }
    
    //远端用户离线
    func rtcEngine(_ engine: TTTRtcEngineKit!, didOfflineOfUid uid: Int64, reason: TTTRtcUserOfflineReason) {
        if uid != otherUid { return }
        otherUid = 0
        refreshVideoCompositingLayout()
        pkBtn.isSelected = false
        remoteView.isHidden = true
        pkRoomIDTF.isUserInteractionEnabled = true
        let roomId = Int64(pkRoomIDTF.text!)!
        PKManager.manager.rtcEngine.unSubscribeOtherChannel(roomId)
    }
    
    //上报本地音视频上行码率
    func rtcEngine(_ engine: TTTRtcEngineKit!, report stats: TTTRtcStats!) {
        videoStatsLabel.text = "V-↑\(stats.txVideoKBitrate)kbps"
        audioStatsLabel.text = "A-↑\(stats.txAudioKBitrate)kbps"
    }
    
    //上报远端用户音频下行码率
    func rtcEngine(_ engine: TTTRtcEngineKit!, remoteAudioStats stats: TTTRtcRemoteAudioStats!) {
        remoteAudioStatsLabel.text = "A-↓\(stats.receivedBitrate)kbps"
    }
    
    //上报远端用户视频下行码率
    func rtcEngine(_ engine: TTTRtcEngineKit!, remoteVideoStats stats: TTTRtcRemoteVideoStats!) {
        remoteVideoStatsLabel.text = "V-↓\(stats.receivedBitrate)kbps"
    }
    
    //报告房间内用户的音量包括自己
    func rtcEngine(_ engine: TTTRtcEngineKit!, reportAudioLevel userID: Int64, audioLevel: UInt, audioLevelFullRange: UInt) {
        if userID == PKManager.manager.uid {
            if mutedSelf {
                voiceBtn.setImage(#imageLiteral(resourceName: "voice_close"), for: .normal)
            } else {
                voiceBtn.setImage(getVoiceImg(audioLevel), for: .normal)
            }
        } else if userID == otherUid {
            remoteVoiceBtn.setImage(getVoiceImg(audioLevel), for: .normal)
        }
    }
    
    //网络丢失（会自动重连）
    func rtcEngineConnectionDidLost(_ engine: TTTRtcEngineKit!) {
        TTProgressHud.showHud(view, message: "网络链接丢失，正在重连...", color: nil)
    }
    
    //重新连接服务器成功
    func rtcEngineReconnectServerSucceed(_ engine: TTTRtcEngineKit!) {
        TTProgressHud.hideHud(for: view)
    }
    
    //重新连接服务器失败，需要退出房间
    func rtcEngineReconnectServerTimeout(_ engine: TTTRtcEngineKit!) {
        TTProgressHud.hideHud(for: view)
        view.window?.showToast("网络丢失，请检查网络")
        dimissVc()
    }
    
    //在房间内被服务器踢出
    func rtcEngine(_ engine: TTTRtcEngineKit!, didKickedOutOfUid uid: Int64, reason: TTTRtcKickedOutReason) {
        var errorInfo = ""
        switch reason {
        case .kickedOut_PushRtmpFailed:
            errorInfo = "rtmp推流失败"
        case .kickedOut_ReLogin:
            errorInfo = "重复登录"
        case .kickedOut_NewChairEnter:
            errorInfo = "其他人以主播身份进入"
        default:
            errorInfo = "未知错误"
        }
        view.window?.showToast(errorInfo)
        dimissVc()
    }
}


private extension PKViewController {
    func dimissVc() {
        if otherUid > 0 {
            PKManager.manager.rtcEngine.unSubscribeOtherChannel(Int64(pkRoomIDTF.text!)!)
        }
        //开启预览，必须对应关闭预览
        PKManager.manager.rtcEngine.stopPreview()
        PKManager.manager.rtcEngine.leaveChannel(nil)
        dismiss(animated: true, completion: nil)
    }
    
    //刷新SEI
    func refreshVideoCompositingLayout() {
        layout.regions.removeAllObjects()
        let anchor = TTTRtcVideoCompositingRegion()
        anchor.uid = PKManager.manager.uid
        anchor.x = 0
        anchor.y = 0
        anchor.width = 1
        anchor.height = 1
        anchor.zOrder = 0
        anchor.alpha = 1
        anchor.renderMode = .render_Adaptive
        layout.regions.add(anchor)
        if otherUid > 0 {
            let other = TTTRtcVideoCompositingRegion()
            other.uid = otherUid
            other.x = 0
            other.y = Double(remoteView.frame.origin.y / view.bounds.size.height)
            other.width = 0.5
            other.height = 0.375
            other.zOrder = 1
            other.alpha = 1
            other.renderMode = .render_Adaptive
            layout.regions.add(other)
        }
        PKManager.manager.rtcEngine.setVideoCompositingLayout(layout)
    }
    
    func getVoiceImg(_ audioLevel: UInt) -> UIImage {
        var image: UIImage = #imageLiteral(resourceName: "voice_small")
        if audioLevel < 4 {
            image = #imageLiteral(resourceName: "voice_small")
        } else if audioLevel < 7 {
            image = #imageLiteral(resourceName: "voice_middle")
        } else {
            image = #imageLiteral(resourceName: "voice_big")
        }
        return image
    }
}
