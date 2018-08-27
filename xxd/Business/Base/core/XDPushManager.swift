//
//  XDPushManager.swift
//  xxd
//
//  Created by remy on 2017/12/28.
//  Copyright © 2017年 com.smartstudy. All rights reserved.
//

class XDPushManager {
    
    static func handlePush(_ info: [AnyHashable : Any], isForeground: Bool) {
        var link = (info["link"] as? String) ?? ""
        // 旧版的消息中心类型推送
        if let from = info["from"] as? String, from == "xxd" {
            if link.isEmpty {
                // 旧版消息的url兼容,由于没有link
                link = "xuanxiaodi://notifications"
            }
            if isForeground {
                if let unreadMessageCount = Int(XDUser.shared.model.unreadMessageCount) {
                    let messageCount = unreadMessageCount + 1
                    XDUser.shared.model.unreadMessageCount = String(messageCount)
                    NotificationCenter.default.post(name: .XD_NOTIFY_UPDATE_UNREAD_MESSAGE, object: nil)
                }
                
            }
        }
        if !isForeground {
            XDRoute.schemeRoute(url: URL(string: link))
        }
    }
}
