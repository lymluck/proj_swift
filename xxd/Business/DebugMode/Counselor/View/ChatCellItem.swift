//
//  ChatMessageCellItem.swift
//  counselor_t
//
//  Created by chenyusen on 2017/12/8.
//  Copyright © 2017年 TechSen. All rights reserved.
//

import UIKit
import Kingfisher
import SwiftyJSON

let messageCellTopMargin: CGFloat = 20
let messageCellBottomMargin: CGFloat = 20

let bubbleHMargin: CGFloat = 65

let avatarWidth: CGFloat = 40
let avatarHMargin: CGFloat = 16

let bubbleMaxWidth: CGFloat = {UIScreen.main.bounds.width - bubbleHMargin - 64}()
//var bubbleMaxImageWidth: CGFloat = {UIScreen.main.width - bubbleHMargin - 128}()
let bubbleMaxImageWidth: CGFloat = {UIScreen.main.bounds.width - bubbleHMargin - 200}()

var bubbleContentHPadding: CGFloat = 13
var bubbleContentVPadding: CGFloat = 9
var bubbleTriangleWidth: CGFloat = 5

let messageTextLineHeight: CGFloat = 21
let messageTextFontSize: CGFloat = 16

let kChatCellItemKey = "kChatCellItemKey"
extension Notification.Name {
    public static let ReSendMessageSuccess: NSNotification.Name = NSNotification.Name("ReSendMessageSuccess")
}


func calBubbleFrame(withContentSize size: CGSize, autoAdjust: Bool = true, isSelf: Bool) -> CGRect {
    var newSize = size
    if autoAdjust {
        newSize = CGSize(width: size.width + 2 * bubbleContentHPadding + bubbleTriangleWidth, height: size.height + 2 * bubbleContentVPadding)
    }

    return CGRect(origin: CGPoint(x: isSelf ? XDSize.screenWidth - bubbleHMargin - newSize.width : bubbleHMargin, y: messageCellTopMargin), size: newSize)
}


/// 布局
class ChatCellLayout {
    var cellHeight: CGFloat?
}

class ChatMessageCellLayout: ChatCellLayout {
    var bubbleFrame: CGRect = CGRect.zero
    var avatarOrigin: CGPoint = CGPoint.zero
    var readStatusFrame: CGRect = CGRect.zero
}


struct ChatCellItemFactory {
    static func chatCellItem(_ item: Any) -> ChatCellItem {
        var messageCellItem: ChatCellItem!
        if let item = item as? Message {
            if let textMessage = item.content as? TextMessage {
                if item.direction == .send {
                    messageCellItem = createSendCellItem(.text(textMessage.content ?? ""), targetId: item.targetId)
                } else {
                    messageCellItem = ChatTextMessageCellItem()
                }
            } else if let imageMessage = item.content as? ImageMessage {
                if item.direction == .send {
                    var img: UIImage? = imageMessage.originalImage
                    if img == nil {
                        img = imageMessage.thumbnailImage
                    }
                    messageCellItem = createSendCellItem(.image(img!), targetId: item.targetId)
                } else {
                    messageCellItem = ChatImageMessageCellItem()
                }
            } else if let voiceMessage = item.content as? VoiceMessage {
                if item.direction == .send {
                    messageCellItem = createSendCellItem(.voice(voiceMessage.wavAudioData, voiceMessage.duration), targetId: item.targetId)
                } else {
                    messageCellItem = ChatVoiceMessageCellItem()
                }
            } else if item.content is RecallNotificationMessage {
                messageCellItem = RecallCellItem()
            }
            messageCellItem.model = item
            return messageCellItem
        } else if let date = item as? Date {
            let dateCellItem = ChatDateCellItem()
            dateCellItem.date = date
            return dateCellItem
        }
        fatalError("未知")
    }
    
    static func createSendCellItem(_ content: CounselorIM.MessageType, targetId: String) -> ChatMessageCellItem {
        
        var messageCellItem: ChatMessageCellItem!
        switch content {
        case .text(_):
            messageCellItem = ChatTextMessageCellItem()
        case .image(_):
            messageCellItem = ChatImageMessageCellItem()
        case .voice(_, _):
            messageCellItem = ChatVoiceMessageCellItem()
        }
        messageCellItem.handleBlock = { [weak messageCellItem] in
            //            // 删除之前的消息
            if messageCellItem?.currentCell != nil {
                CounselorIM.shared.deleteMessages([(messageCellItem?.model as! Message).messageId])
            }
            (messageCellItem?.currentCell as? TableCell)?.updateCell(messageCellItem)
            
            let extraDict: [String: Any] = [:]
            
            messageCellItem?.model = CounselorIM.shared.send(message: content,
                                                             targetId: targetId,
                                                             extra: JSON(extraDict).rawString(),
                                                             progress: messageCellItem?.handleProgress,
                                                             completion: { (result) in
                switch result {
                case let .success(messageId):
                    SSLog("send message success: \(messageId)")
                    messageCellItem?.handleCompletion(true)
                    
                case let .failure(errorCode, messageId):
                    messageCellItem?.handleCompletion(false)
                    SSLog("send message failure\(errorCode) \(messageId)")
                }
            })
            
//            // 删除之前的消息
//            if messageCellItem?.currentCell != nil {
//
//                NotificationCenter.default.post(name: .ReSendMessageSuccess,
//                                                object: self,
//                                                userInfo: [kChatCellItemKey: messageCellItem!])
//            }
        }
        return messageCellItem
    }
}

/// base cell item
public class ChatCellItem: TableCellItem {
    var layout: ChatCellLayout?
//    func updateLayout() { }
}

/// base message cell
public class ChatCell: TableCell {
    public override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.backgroundView = nil
        self.contentView.backgroundColor = .clear
        self.backgroundColor = .clear
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func setSelected(_ selected: Bool, animated: Bool) {
        
    }
    
    public override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        
    }
}


public class ChatMessageCellItem: ChatCellItem {
    var isSelf: Bool = false
    var id: String?
    var avatorUrl: String?
    var handleBlock: (()->())?
    var handleProgress: ((Int)->())?
    
    override public var cellClass: UITableViewCell.Type? {
        return ChatMessageCell.self
    }
   
    
    override public var model: Any? {
        didSet {
            
            if let message = model as? Message {
                isSelf = message.direction == .send
                id = message.senderUserId
                if isSelf {
                    avatorUrl = XDUser.shared.model.avatarURL
                } else {
                    TeacherInfoHelper.shared.teacherInfo(message.senderUserId, completion: { [weak self] (info) in
                        self?.avatorUrl = info?.avatar
                        if let currentCell = self?.currentCell as? TableCell {
                            currentCell.updateCell(self)
                        }
                    })
                }
            }
            NotificationCenter.default.addObserver(self,
                                                   selector: #selector(studentInfoUpdated(_:)),
                                                   name: .TeacherInfoUpdated,
                                                   object: nil)
            updateLayout()
        }
    }
    
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func handleCompletion(_ success: Bool) {
        if let currentCell = currentCell as? TableCell {
            DispatchQueue.main.async {
                currentCell.updateCell(self)
            }
        }
    }
    
    
    func updateLayout() {
        if let layout = layout as? ChatMessageCellLayout {
            // 用于计算用户头像的frame
            layout.avatarOrigin = CGPoint(x: isSelf ? (XDSize.screenWidth - avatarHMargin - avatarWidth) : avatarHMargin, y: messageCellTopMargin)
            
            layout.readStatusFrame = CGRect(x: layout.bubbleFrame.minX - 30,
                                            y: layout.bubbleFrame.maxY - 12,
                                            width: 30,
                                            height: 12)
        }
    }
    
    func execute() {
        handleBlock?()
    }
    
    func update() {
        if let currentCell = currentCell as? TableCell {
            currentCell.updateCell(self)
        }
    }
}

extension ChatMessageCellItem {
    @objc func studentInfoUpdated(_ noti: Notification) {
        if let studentInfo = noti.userInfo?[TeacherInfoKey] as? TeacherInfo, studentInfo.id == self.id {
            avatorUrl = studentInfo.avatar
            (currentCell as? TableCell)?.updateCell(self)
        }
    }
}

public class ChatMessageCell: ChatCell {
    /// 头像
    var avatarView: UIImageView!
    
    /// 气泡
    var bubbleView: ChatBubbleView!
    
    var readStatusLabel: UILabel!
    
    var reSendButton: UIButton!
    var sendingView: UIActivityIndicatorView!
    
    public override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        avatarView = UIImageView(frame: CGRect(x: 16, y: 20, width: avatarWidth, height: avatarWidth))
        avatarView.layer.cornerRadius = avatarWidth * 0.5
        avatarView.clipsToBounds = true
        avatarView.isUserInteractionEnabled = true
        avatarView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(avatarViewPressed)))
//        avatarView.backgroundColor = .orange
        contentView.addSubview(avatarView)
        
        bubbleView = ChatBubbleView(frame: CGRect(x: 65, y: 20, width: 40, height: 40))
        contentView.addSubview(bubbleView)
        bubbleView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(bubbleViewTapped(_:))))
        
        bubbleView.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(bubbleViewLongPressed(_:))))
        
        reSendButton = UIButton()
        reSendButton.setImage(UIImage(named: "send_failed"), for: .normal)
        reSendButton.frame = CGRect(x: 0, y: 0, width: 20, height: 20)
        reSendButton.extendTouchInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        reSendButton.addTarget(self, action: #selector(reSendButtonPressed), for: .touchUpInside)
        contentView.addSubview(reSendButton)
        
        sendingView = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        sendingView.hidesWhenStopped = true
        contentView.addSubview(sendingView)
        
        readStatusLabel = UILabel(text: "未读", textColor: XDColor.main, fontSize: 12)
        readStatusLabel.isHidden = true
        contentView.addSubview(readStatusLabel)
    }
    
    public override func updateCell(_ cellItem: TableCellItemProtocol?) {
        super.updateCell(cellItem)
        if let cellItem = cellItem as? ChatMessageCellItem, let layout = cellItem.layout as? ChatMessageCellLayout, let message = cellItem.model as? Message {
            bubbleView.frame = layout.bubbleFrame // 设置气泡的frame
            readStatusLabel.frame = layout.readStatusFrame // 这只阅读状态的frame
            // 如果是用户自己，则判断是否发送成功
            if !cellItem.isSelf { // 如果是对方发送的消息
                bubbleView.side = .left
                readStatusLabel.isHidden = true
                reSendButton.isHidden = true
                sendingView.stopAnimating()
                
            } else { // 如果是用户自己
                bubbleView.side = .right
                readStatusLabel.isHidden = true // 阅读状态根据判断,可能需要展示
                if message.sentStatus == .SentStatus_SENDING {
                    sendingView.startAnimating()
                    readStatusLabel.isHidden = true
                    reSendButton.isHidden = true
                } else if message.sentStatus == .SentStatus_FAILED {
                    reSendButton.isHidden = false
                    readStatusLabel.isHidden = true
                    sendingView.stopAnimating()
                } else if message.sentStatus == .SentStatus_READ {
                    readStatusLabel.isHidden = false
                    reSendButton.isHidden = true
                    readStatusLabel.text = "已读"
                    sendingView.stopAnimating()
                    readStatusLabel.textColor = UIColor(0x949BA1).withAlphaComponent(0.7)
                } else {
                    readStatusLabel.isHidden = false
                    reSendButton.isHidden = true
                    readStatusLabel.text = "未读"
                    readStatusLabel.textColor = XDColor.main
                    sendingView.stopAnimating()
                }

                reSendButton.right = bubbleView.left - 10
                reSendButton.centerY = bubbleView.centerY
                sendingView.right = bubbleView.left - 10
                sendingView.centerY = bubbleView.centerY
            }
            avatarView.origin = layout.avatarOrigin
            avatarView.kf.setImage(with: URL(string: cellItem.avatorUrl ?? ""))
        }
    }
    
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func bubbleViewDidLongPressed() {
        
    }
}

extension ChatMessageCell {
    @objc func bubbleViewTapped(_ gr: UITapGestureRecognizer) {
        
    }
    
    @objc fileprivate func bubbleViewLongPressed(_ gr: UILongPressGestureRecognizer) {
        if gr.state == .began {
            bubbleViewDidLongPressed()
        }
    }
    
    
    @objc func reSendButtonPressed() {
        if let cellItem = cellItem as? ChatMessageCellItem {
            cellItem.execute()
        }
    }
    
    @objc func avatarViewPressed() {
        if let cellItem = cellItem as? ChatMessageCellItem,
            let userId = (cellItem.model as? Message)?.senderUserId,
            userId != XDUser.shared.model.imUserId {
            UIApplication.topVC()?.navigationController?.pushViewController(TeacherInfoViewController(query: [IMUserID: userId]), animated: true)
        }
    }
}
