//
//  StatusDefine.swift
//  counselor_t
//
//  Created by chenyusen on 2017/12/18.
//  Copyright © 2017年 TechSen. All rights reserved.
//

import Foundation

struct UserInfo {
    static let ConnectStatus: String = "ConnectStatus"
    static let Message: String = "message"
    static let MessageId: String = "messageId"
}

public enum ConnectionStatus {
    case unkown
    case connected
    case unavailable
    case connecting
    case unconnected
    case signUp
    case tokenIncorrect
    case disconnException
    case networkUnavailable
    case airplaneMode
    case cellualr2G
    case cellular3G4G
    case wifi
    case kickedOfflineByOtherClient
    case loginOnWeb
    case serverInvalid
    case validateInvalid
}


public enum SentStatus {
    case sending // 消息发送中
    case failed // 消息发送失败
    case sent // 消息已经送达
    case received // 消息已接收
    case read // 已阅读
    case destroyed // 被对方销毁
    case cancel // 被取消
}


