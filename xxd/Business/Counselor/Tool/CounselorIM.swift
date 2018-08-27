//
//  CounselorIM.swift
//  counselor_t
//
//  Created by chenyusen on 2017/12/13.
//  Copyright © 2017年 TechSen. All rights reserved.
//

import Foundation
import SwiftyJSON

let RCAppKey = "25wehl3u29wqw"


extension Notification.Name {
    public static let IMReceiveMessage: NSNotification.Name = NSNotification.Name("IMReceiveMessage")
    public static let IMSendMessageSuccess: NSNotification.Name = NSNotification.Name("IMSendMessageSuccess")
    public static let IMConnectStatusChanged: NSNotification.Name = NSNotification.Name("IMConnectStatusChanged")
    public static let IMReadReceipt: NSNotification.Name = NSNotification.Name("IMReadReceipt")
    public static let IMConnectFinished: NSNotification.Name = NSNotification.Name("IMConnectFinished")
    public static let IMMessageRecalled: NSNotification.Name = NSNotification.Name("IMMessageRecalled")
    public static let IMMessageDeleted: NSNotification.Name = NSNotification.Name("IMMessageDeleted")
    public static let IMMessageReciveStatusChanged: NSNotification.Name = NSNotification.Name("IMMessageReciveStatusChanged")
}

public class Message {
    enum MessageDirection {
        case send, receive
    }
    
    public private(set) var wrappedMessage: RCMessage
    
    lazy var content: MessageContent = {
        var content: MessageContent!
        if let messageContent = wrappedMessage.content as? RCTextMessage {
            content = TextMessage(messageContent)
        } else if let messageContent = wrappedMessage.content as? RCImageMessage {
            content = ImageMessage(messageContent)
        } else if let messageContent = wrappedMessage.content as? RCVoiceMessage {
            content = VoiceMessage(messageContent)
        } else if let messageContent = wrappedMessage.content as? RCRecallNotificationMessage {
            content = RecallNotificationMessage(messageContent)
        } else {
            content = TextMessage(wrappedMessage.content)
        }
        return content
    }()
    
    var direction: MessageDirection {
        if XDUser.shared.model.imUserId == senderUserId {
            return .send
        } else {
            return .receive
        }
        
    }
    
    var sentStatus: RCSentStatus {
        get { return wrappedMessage.sentStatus }
        set { wrappedMessage.sentStatus = .SentStatus_READ }
    }
    
    
    /// 发送者的用户ID
    var senderUserId: String {
        return wrappedMessage.senderUserId
    }
    
    /// 会话的ID
    var targetId: String {
        return wrappedMessage.targetId
    }
    
    /// 消息的发送时间
    var sentTime: Int {
        return Int(wrappedMessage.sentTime)
    }
    
    /// 消息的ID
    var messageId: Int {
        return wrappedMessage.messageId
    }
    
    var receivedStatus: RCReceivedStatus {
        set { wrappedMessage.receivedStatus = newValue }
        get { return wrappedMessage.receivedStatus }
    }
    
    init(_ message: RCMessage) {
        wrappedMessage = message
    }
}

extension Message: Equatable {
    public static func ==(lhs: Message, rhs: Message) -> Bool {
        return lhs.messageId == rhs.messageId
    }
}


public class MessageContent {
    public private(set) var wrappedMessageContent: RCMessageContent
    
    init(messageContent: RCMessageContent) {
        wrappedMessageContent = messageContent
    }
    
//    var sendname: String? {
//        return wrappedMessageContent.senderUserInfo.name
//    }
    var displayContent: String {
        return "[不支持的消息类型]"
    }
}

public class TextMessage: MessageContent {
    
    init(_ textMessage: RCMessageContent) {
        super.init(messageContent: textMessage)
    }
    
    var content: String? {
        if let textMessage = wrappedMessageContent as? RCTextMessage {
            return textMessage.content
        } else {
            return "[不支持的消息类型]"
        }
    }
    
    override var displayContent: String {
        return (wrappedMessageContent as? RCTextMessage)?.content ?? ""
    }
    
}

public class RecallNotificationMessage: MessageContent {
    
    init(_ recallNotificationMessage: RCRecallNotificationMessage) {
        super.init(messageContent: recallNotificationMessage)
    }
    
    init(operatorId: String) {
        let recallMessageContent = RCRecallNotificationMessage()
        recallMessageContent.operatorId = operatorId
        super.init(messageContent: recallMessageContent)
    }
    
    override var displayContent: String {
        return "[撤回消息]"
    }
    
}

public class ImageMessage: MessageContent {
    
    init(_ imageMessage: RCImageMessage) {
        super.init(messageContent: imageMessage)
    }
    
    var imageUrl: URL? {
        if let imageUrl = (wrappedMessageContent as? RCImageMessage)?.imageUrl {
            return URL(string: imageUrl)
        }
        return nil
    }
    
    var originalImage: UIImage? {
        set {
            (wrappedMessageContent as? RCImageMessage)?.originalImage = newValue
        }
        get {
            return (wrappedMessageContent as? RCImageMessage)?.originalImage
        }
    }
    
    var thumbnailImage: UIImage? {
        return (wrappedMessageContent as? RCImageMessage)?.thumbnailImage
    }
    
    override var displayContent: String {
        return "[图片]"
    }
}

public class VoiceMessage: MessageContent {
    
    init(_ voiceMessage: RCVoiceMessage) {
        super.init(messageContent: voiceMessage)
    }
    
    var wavAudioData: Data {
        return (wrappedMessageContent as? RCVoiceMessage)!.wavAudioData
    }
    
    var duration: Int {
        return (wrappedMessageContent as? RCVoiceMessage)!.duration
    }
    
    override var displayContent: String {
        return "[语音]"
    }
}

public class UndefineMessage: MessageContent {
    init(_ undefineMessage: RCMessageContent) {
        super.init(messageContent: undefineMessage)
    }
}

public protocol CounselorIMDelegate: class {
    
    /// 收到消息回调
    ///
    /// - Parameters:
    ///   - message: 收到的消息
    ///   - left: 剩余未收到的消息数
    func received(message: Message, left: Int)
    
    
    /// 消息被撤回回调
    ///
    /// - Parameter messageId: 被撤回的消息
    func onMessageRecalled(_ messageId: Int)
}

public protocol CounselorConnectDelegate: class {
    
    
    /// 连接状态改变回调
    ///
    /// - Parameter status: 当前状态
    func connectionStatusChanged(_ status: ConnectionStatus)
}

public class Conversation {
    public enum MessageType {
        case text, image, voice, undefined
    }
    let wrappedConversation: RCConversation
    init(_ conversation: RCConversation) {
        wrappedConversation = conversation
    }
    
    var receivedStatus: RCReceivedStatus {
        return wrappedConversation.receivedStatus
    }
    
    var lastestMessageDirection: RCMessageDirection {
        return wrappedConversation.lastestMessageDirection
    }
    
    
    /// 最后一条消息的时间
    var lastMessageDate: Date {
        let lastMessageTimestamp = max(wrappedConversation.receivedTime, wrappedConversation.sentTime)
        return Date(timeIntervalSince1970: Double(lastMessageTimestamp/1000))
    }
    
    /// 会话目标id
    var targetId: String {
        return wrappedConversation.targetId
    }
    
    /// 未读消息数
    var unreadMessageCount: Int {
        return Int(wrappedConversation.unreadMessageCount)
    }
    
    /// 最后一条消息的发送时间
    var sentTime: Int64 { return wrappedConversation.sentTime }
    
    /// 最后一条消息的接收时间
    var receivedTime: Int64 { return wrappedConversation.receivedTime }
 
    var messageType: MessageType {
        switch wrappedConversation.objectName {
        case "RC:TxtMsg":
            return .text
        case "RC:ImgMsg":
            return .image
        case "RC:VcMsg":
            return .voice
        default:
            return .undefined
        }
    }
    
    var lastMessage: MessageContent? {
        if let textMessage =  wrappedConversation.lastestMessage as? RCTextMessage {
            return TextMessage(textMessage)
        } else if let imageMessage =  wrappedConversation.lastestMessage as? RCImageMessage {
            return ImageMessage(imageMessage)
        } else if let voiceMessage = wrappedConversation.lastestMessage as? RCVoiceMessage {
            return VoiceMessage(voiceMessage)
        } else if let recallMessage = wrappedConversation.lastestMessage as? RCRecallNotificationMessage {
            return RecallNotificationMessage(recallMessage)
        }
        return UndefineMessage(wrappedConversation.lastestMessage)
    }
}

public class CounselorIM: NSObject {
    
    /// 消息类型
    ///
    /// - text: 文本消息
    /// - image: 图片消息
    /// - voice: 语音消息
    public enum MessageType {
        case text(String)
        case image(UIImage)
        case voice(Data, Int)
    }
    
    public enum ConnectResult {
        case success(String?)
        case failure(Int)
    }
    public enum SendResult {
        case success(messageId: Int)
        case failure(errorCode: Int, messageId: Int)
    }
    
    public typealias ConnectCompletion = (ConnectResult) -> ()
    public typealias SendCompletion = (SendResult) -> ()
    
    
    public static var shared = CounselorIM()
    public weak var delegate: CounselorIMDelegate?
    public weak var connectDelegate: CounselorConnectDelegate?
    
    var connectionStatus: ConnectionStatus {
        return mapConnectionStatus(RCIMClient.shared().getConnectionStatus())
    }

    
    private override init() {
        super.init()
        RCIMClient.shared().initWithAppKey(RCAppKey)
        RCIMClient.shared().setReceiveMessageDelegate(self, object: nil)
        RCIMClient.shared().setRCConnectionStatusChangeDelegate(self)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(imReadReceipt(_:)),
                                               name: Notification.Name.RCLibDispatchReadReceipt,
                                               object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    /// 连接IM服务器
    ///
    /// - Parameters:
    ///   - token: 连接IM服务器所需Token
    ///   - completion: 连接后的回调
    public func connect(withToken token: String, completion: @escaping ConnectCompletion, tokenIncorrect:(() -> ())? = nil) {
        RCIMClient.shared().connect(withToken: token,
                                    success: { completion(.success($0)) },
                                    error: { completion(.failure($0.rawValue)) },
                                    tokenIncorrect: { tokenIncorrect?() })
    }
    
    public func setDeviceToken(_ deviceToken: Data) {
        let token = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
        RCIMClient.shared().setDeviceToken(token)
    }
    
    
    /// 断开IM服务器链接
    public func logout() {
        RCIMClient.shared().logout()
    }
}

public extension CounselorIM {
    
    
    /// 发送消息
    ///
    /// - Parameters:
    ///   - message: 待发送的消息
    ///   - targetId: 对象用户id
    ///   - completion: 发送完成回调
    @discardableResult
    public func send(message: MessageType, targetId:String, extra: String? = nil, progress: ((Int) -> ())? = nil, completion: @escaping SendCompletion) -> Message {
        var rcMessage: RCMessage!
        switch message {
        case let .text(text):
            let rcTextMessage = RCTextMessage(content: text)
            if let extra = extra {
                rcTextMessage?.extra = extra
            }
            rcTextMessage?.senderUserInfo = RCIMClient.shared().currentUserInfo
            rcMessage = RCIMClient.shared().sendMessage(.ConversationType_PRIVATE,
                                                            targetId: targetId,
                                                            content: rcTextMessage,
                                                            pushContent: nil,
                                                            pushData: nil,
                                                            success: {msgId in
                                                                DispatchQueue.main.async {
                                                                    completion(.success(messageId: msgId))
                                                                    self.sendMessageSuccess(message: Message(rcMessage))
                                                                }
            },
                                                            error: { completion(.failure(errorCode: $0.rawValue, messageId: $1)) })
        case let .image(image):
            let rcImageMessage = RCImageMessage(image: image)
            if let extra = extra {
                rcImageMessage?.extra = extra
            }
            rcImageMessage?.senderUserInfo = RCIMClient.shared().currentUserInfo
            rcMessage = RCIMClient.shared().sendMediaMessage(.ConversationType_PRIVATE,
                                                                 targetId: targetId,
                                                                 content: rcImageMessage,
                                                                 pushContent: nil,
                                                                 pushData: nil,
                                                                 progress: {(progressValue, _) in DispatchQueue.main.async { progress?(Int(progressValue)) } },
                                                                 success: {msgId in
                                                                    DispatchQueue.main.async {
                                                                        completion(.success(messageId: msgId))
                                                                        self.sendMessageSuccess(message: Message(rcMessage))
                                                                    }
            },
                                                                 error: { completion(.failure(errorCode: $0.rawValue, messageId: $1)) },
                                                                 cancel: nil)
        case let .voice(audioData, duration):
            let rcVoiceMessage = RCVoiceMessage(audio: audioData, duration: duration)
            if let extra = extra {
                rcVoiceMessage?.extra = extra
            }
            rcVoiceMessage?.senderUserInfo = RCIMClient.shared().currentUserInfo
            rcMessage = RCIMClient.shared().sendMessage(.ConversationType_PRIVATE,
                                                        targetId: targetId,
                                                        content: rcVoiceMessage,
                                                        pushContent: nil,
                                                        pushData: nil,
                                                        success: {msgId in
                                                            DispatchQueue.main.async {
                                                                completion(.success(messageId: msgId))
                                                                self.sendMessageSuccess(message: Message(rcMessage))
                                                            }
            },
                                                        error: { completion(.failure(errorCode: $0.rawValue, messageId: $1)) })
        }
        return Message(rcMessage)
    }
    
    private func sendMessageSuccess(message: Message) {
        NotificationCenter.default.post(name: .IMSendMessageSuccess, object: nil, userInfo: [UserInfo.Message: message])
    }
    
    
    /// 设置消息的接收状态
    ///
    /// - Parameters:
    ///   - messageId: 消息的id
    ///   - receivedStatus: 接收状态
    /// - Returns: 设置是否生效
    func setMessage(messageId: Int, receivedStatus: RCReceivedStatus) -> Bool {
        return RCIMClient.shared().setMessageReceivedStatus(messageId, receivedStatus: receivedStatus)
    }
    
    @discardableResult
    public func deleteMessages(_ msgIds: [Int]) -> Bool {
        return RCIMClient.shared().deleteMessages(msgIds)
    }
    
    
    /// 获取所有未读消息数
    ///
    /// - Returns: 未读消息数
    public func totalUnreadCount() -> Int {
        return Int(RCIMClient.shared().getTotalUnreadCount())
    }
    
    
    /// 获取某个回话的未读消息数
    ///
    /// - Parameter targetId: 目标会话id
    /// - Returns: 该会话的未读消息数
    public func unreadCount(withTargetId targetId: String) -> Int {
        return Int(RCIMClient.shared().getUnreadCount(.ConversationType_PRIVATE, targetId: targetId))
    }
    
    
    /// 清除某个会话中的未读消息数
    ///
    /// - Parameter targetId: 目标会话id
    /// - Returns: 是否清除成功
    
    @discardableResult
    public func clearMessageUnreadStatus(withTargetId targetId: String) -> Bool {
        return RCIMClient.shared().clearMessagesUnreadStatus(.ConversationType_PRIVATE, targetId: targetId)
    }
    
    
    /// 发送某个会话的阅读消息回执
    ///
    /// - Parameters:
    ///   - targetId: 目标会话Id
    ///   - timestamp: 该绘画中已经阅读的最后一条消息的发送时间戳
    public func sendReadReceipt(_ targetId: String, timestamp: Int64) {
        RCIMClient.shared().sendReadReceiptMessage(.ConversationType_PRIVATE,
                                                   targetId: targetId,
                                                   time: timestamp,
                                                   success: nil,
                                                   error: nil)
    }
    
    
    /// 获取会话列表
    ///
    /// - Returns: 会话列表
    public func conversationList() -> [Conversation] {
        if let conversations = RCIMClient.shared().getConversationList([RCConversationType.ConversationType_PRIVATE.rawValue]) as? [RCConversation] {
            let wrapConversations = conversations.map({ (conversation) -> Conversation in
                return Conversation(conversation)
            })
            return wrapConversations;
        }
        return []
    }
    
    public func conversation(targetId: String) -> Conversation? {
        if let conversation = RCIMClient.shared().getConversation(.ConversationType_PRIVATE, targetId: targetId) {
            return Conversation(conversation)
        }
        return nil
    }
    
    
    /// 获取本地会话存储的最新消息
    ///
    /// - Parameters:
    ///   - targetId: 会话的目标Id
    ///   - count: 一次拉去多少条消息
    /// - Returns: 返回的消息数组
    public func latestMessages(targetId: String, count: Int = 20) -> [Message] {
        let originMessages = RCIMClient.shared().getLatestMessages(.ConversationType_PRIVATE, targetId: targetId, count: Int32(count)) as! [RCMessage]
        let messages: [Message] = originMessages.map { Message($0) }
        return messages
    }
    
    
    /// 获取本地会话存储的从指定消息id起的更早消息
    ///
    /// - Parameters:
    ///   - targetId: 会话的目标Id
    ///   - oldestMessageId: 指定最早的消息
    ///   - count: 一次拉取的条数
    public func historyMessages(targetId: String, from oldestMessageId: Int, count: Int = 20, completion: @escaping ([Message]) -> ()) {
        DispatchQueue.global().async {
            let originMessages = RCIMClient.shared().getHistoryMessages(.ConversationType_PRIVATE, targetId: targetId, oldestMessageId: oldestMessageId, count: Int32(count)) as! [RCMessage]
            let messages: [Message] = originMessages.map { Message($0) }
            DispatchQueue.main.async {
                completion(messages)
            }
        }
        
    }
    
    public func recallMessage(_ message: Message, completion: ((Bool, Int) -> ())? = nil) {
        
        RCIMClient.shared().recall(message.wrappedMessage, success: { (code) in
            SSLog("消息撤回成功\(code)")
            completion?(true, message.messageId)
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: .IMMessageRecalled,
                                                object: nil,
                                                userInfo: [UserInfo.MessageId: message.messageId])
            }
        }) { (errorCode) in
            SSLog("消息撤回失败\(errorCode)")
            completion?(false, message.messageId)
        }
    }
}


// MARK: - 黑名单相关
extension CounselorIM {
    public func getBlacklistStatus(targetId: String, completion: @escaping (Bool) -> ()) {
        RCIMClient.shared().getBlacklistStatus(targetId, success: { (code) in
            DispatchQueue.main.async(execute: {
                completion(code == 0)
            })
        }) { (errorCode) in
            DispatchQueue.main.async(execute: {
                completion(false)
            })
        }
    }
    
    public func add(toBlackList targetId: String, completion: @escaping (Bool) -> ()) {
        RCIMClient.shared().add(toBlacklist: targetId, success: {
            DispatchQueue.main.async(execute: {
                completion(true)
            })
        }) { (_) in
            DispatchQueue.main.async(execute: {
                completion(false)
            })
        }
    }
    
    public func remove(fromBlackList targetId: String, completion: @escaping (Bool) -> ()) {
        RCIMClient.shared().remove(fromBlacklist: targetId, success: {
            DispatchQueue.main.async(execute: {
                completion(true)
            })
        }) { (_) in
            DispatchQueue.main.async(execute: {
                completion(false)
            })
        }
    }
}

/// MARK: - Notification Actions
extension CounselorIM {
    @objc private func imReadReceipt(_ notification: Notification) {
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: .IMReadReceipt, object: nil, userInfo: notification.userInfo)
        }
    }
}


extension CounselorIM: RCIMClientReceiveMessageDelegate {
    public func onReceived(_ message: RCMessage!, left nLeft: Int32, object: Any!) {
        DispatchQueue.main.async {
            self.delegate?.received(message: Message(message), left: Int(nLeft))
        }
    }
    
    public func onMessageRecalled(_ messageId: Int) {
        DispatchQueue.main.async {
            self.delegate?.onMessageRecalled(messageId)
        }
    }
}

extension CounselorIM {
    public func isMessageExpire(_ message: Message, overTime: Int = 60 * 5 * 1000) -> Bool {
        // 判断当前时间与消息时间的时间差, 只有超过5分钟的,才允许撤销
        SSLog("时间差为\(RCIMClient.shared().getDeltaTime())")
        let deltaTime = (Int(Date().timeIntervalSince1970 * 1000) - Int(RCIMClient.shared().getDeltaTime()) - message.sentTime)
        SSLog("时间差为\(deltaTime)毫秒")
        return deltaTime > overTime
    }
}

extension CounselorIM: RCConnectionStatusChangeDelegate {
    public func onConnectionStatusChanged(_ status: RCConnectionStatus) {
        connectDelegate?.connectionStatusChanged(mapConnectionStatus(status))
    }
    
    func mapConnectionStatus(_ status: RCConnectionStatus) -> ConnectionStatus {
        switch status {
            
        case .ConnectionStatus_UNKNOWN:
            return .unkown
            
        case .ConnectionStatus_Connected:
            return .connected
            
        case .ConnectionStatus_NETWORK_UNAVAILABLE:
            return .unavailable
            
        case .ConnectionStatus_AIRPLANE_MODE:
            return .airplaneMode
            
        case .ConnectionStatus_Cellular_2G:
            return .cellualr2G
            
        case .ConnectionStatus_Cellular_3G_4G:
            return .cellular3G4G
            
        case .ConnectionStatus_WIFI:
            return .wifi
            
        case .ConnectionStatus_KICKED_OFFLINE_BY_OTHER_CLIENT:
            return .kickedOfflineByOtherClient
            
        case .ConnectionStatus_LOGIN_ON_WEB:
            return .loginOnWeb
            
        case .ConnectionStatus_SERVER_INVALID:
            return .serverInvalid
            
        case .ConnectionStatus_VALIDATE_INVALID:
            return.validateInvalid
        default:
            return .unkown
        }
    }
}
