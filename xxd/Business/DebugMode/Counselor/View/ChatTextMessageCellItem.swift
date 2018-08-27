//
//  ChatTextMessageCellItem.swift
//  counselor_t
//
//  Created by chenyusen on 2018/1/10.
//  Copyright © 2018年 TechSen. All rights reserved.
//

import UIKit


class ChatMessageTextCellLayout: ChatMessageCellLayout {
    var textFrame: CGRect = CGRect.zero
}

/// text message cell item
class ChatTextMessageCellItem: ChatMessageCellItem {
    
    override var cellClass: UITableViewCell.Type? {
        return ChatTextMessageCell.self
    }
    
    override func updateLayout() {
        if layout == nil {
            let layout = ChatMessageTextCellLayout()
            self.layout = layout
            
            /// 计算文本的frame
            if let text = ((model as? Message)?.content as? TextMessage)?.content {
                
                let label = UILabel(frame: CGRect.zero, text: nil, fontSize: messageTextFontSize)!
                label.numberOfLines = 0
                label.setText(text, lineHeight: messageTextLineHeight)
//                label.set(text: text, lineHeight: messageTextLineHeight)
                label.width = bubbleMaxWidth - 2 * bubbleContentHPadding
                label.sizeToFit()
                layout.bubbleFrame = calBubbleFrame(withContentSize: label.size, isSelf: isSelf)
                layout.textFrame = CGRect(x: isSelf ? bubbleContentHPadding : bubbleContentHPadding + bubbleTriangleWidth, y: bubbleContentVPadding, width: label.width, height: label.height)
                layout.cellHeight = layout.bubbleFrame.maxY + messageCellBottomMargin
            }
            super.updateLayout()
        }
    }
    
    override var cellHeight: CGFloat {
        return layout?.cellHeight ?? 0
    }
}

/// text message cell
class ChatTextMessageCell: ChatMessageCell {
    var textContentLabel: UILabel!
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        textContentLabel = UILabel(frame: CGRect.zero, text: nil, textColor: UIColor(0x26343F), fontSize: messageTextFontSize)!
        textContentLabel.numberOfLines = 0
        //        textContentLabel.borderWidth = unitWidth
        //        textContentLabel.borderColor = UIColor.black
    }
    
    override func updateCell(_ cellItem: TableCellItemProtocol?) {
        super.updateCell(cellItem)
        if let cellItem = cellItem as? ChatTextMessageCellItem,
            let layout = cellItem.layout as? ChatMessageTextCellLayout,
            let contentMessage = (cellItem.model as? Message)?.content as? TextMessage {
            textContentLabel.setText(contentMessage.content, lineHeight: messageTextLineHeight)
//            textContentLabel.set(text: contentMessage.content, lineHeight: messageTextLineHeight)
            textContentLabel.textColor = cellItem.isSelf ? .white : UIColor(0x26343F)
            bubbleView.content = textContentLabel
            textContentLabel.frame = layout.textFrame
//            readStatusLabel.
        }
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func bubbleViewDidLongPressed() {
        if let cellItem = cellItem as? ChatTextMessageCellItem, let message = cellItem.model as? Message {
            var buttonTypes: [ChatPopView.ButtonType] = []
            if cellItem.isSelf {
                buttonTypes.append(contentsOf: [.copy, .transpond])
                if !CounselorIM.shared.isMessageExpire(message) { // 只有没超时的消息才能被撤回
                    buttonTypes.append(.recall)
                } else {
//                        buttonTypes.append(.delete)
                }
            } else {
//                    buttonTypes.append(contentsOf: [.copy, .transpond, .delete])
                buttonTypes.append(contentsOf: [.copy, .transpond])
            }
            
            
            ChatPopView.shared.setButtonTypes(buttonTypes)
            ChatPopView.shared.delegate = self
            ChatPopView.shared.show(referTo: bubbleView)
            bubbleView.showCover = true
        }
    }
}

extension ChatTextMessageCell: ChatPopViewDelegate {
    func chatPopView(didPressed buttonType: ChatPopView.ButtonType) {
        switch buttonType {
        case .copy:
            UIPasteboard.general.string = textContentLabel.text
        case .transpond:
            if let message = cellItem?.model as? Message {
                UIApplication.shared.topViewController()?.presentModal(TranspondViewController(query: [UserInfo.Message: message]))
            }
        case .recall:
            if let message = cellItem?.model as? Message {
                CounselorIM.shared.recallMessage(message)
            }
        case .delete:
            SSLog("删除")
            if let message = cellItem?.model as? Message {
                CounselorIM.shared.deleteMessages([message.messageId])
                NotificationCenter.default.post(name: .IMMessageDeleted,
                                                object: nil,
                                                userInfo: [UserInfo.MessageId: message.messageId])
            }
        default: SSLog("nothing to do")
        }
        
        
    }
}
