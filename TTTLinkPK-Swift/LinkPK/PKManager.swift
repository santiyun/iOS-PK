//
//  PKManager.swift
//  LinkPK
//
//  Created by Work on 2019/3/14.
//  Copyright © 2019 yanzhen. All rights reserved.
//

import UIKit
import TTTRtcEngineKit

class PKManager: NSObject {

    public static let manager = PKManager()
    public var rtcEngine: TTTRtcEngineKit!
    public var roomID: Int64 = 0 //频道id
    public var uid: Int64 = 0    //自己id
    private override init() {
        super.init()
        //初始化TTTRtcEngineKit对象，输入申请的AppID
        rtcEngine = TTTRtcEngineKit.sharedEngine(withAppId: <#AppId#>, delegate: nil)
    }
}
