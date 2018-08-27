//
//  ConversationListItem.swift
//  xxd
//
//  Created by chenyusen on 2018/3/8.
//  Copyright © 2018年 com.smartstudy. All rights reserved.
//

import UIKit

class ConversationListItem: SSCellItem {
    var conversation: Conversation! {
        didSet {
            setNewPropeties()
            TeacherInfoHelper.shared.teacherInfo(targetId) { [weak self] (teacherInfo) in
                if let teacherInfo = teacherInfo {
                    self?.update(teacherInfo)
                }
            }
        }
    }
    var targetId: String! // 融云UerID
    var nickname: String?
    var avatarURL: String?
    var lastMessageDate: Date?
    var displayDate: String?
    var year: String?
    var title: String?
    var lastMessageContent: String?
    var unreadMessageCount: Int = 0
    
    weak var currentCell: ConversationListCell?
    
    override func cellClass() -> AnyClass! {
        return ConversationListCell.self
    }
    
    override init!(attributes: [AnyHashable : Any]! = [:]) {
        super.init(attributes: attributes)
    }
    
    override init!(cellClass: AnyClass!, userInfo: Any!) {
        super.init(cellClass: cellClass, userInfo: userInfo)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(imReceiveMessage(_:)),
                                               name: .IMReceiveMessage,
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(teacherInfoUpdated(_:)),
                                               name: .TeacherInfoUpdated,
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(clearUnreadCount(_:)),
                                               name: .ClearConversationUnreadCount,
                                               object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func setNewPropeties() {
        lastMessageDate = conversation.lastMessageDate
        if let date = lastMessageDate {
            // 如果是今天,则显示今天的时间
            if date.isInToday { // 今天
                displayDate = date.string(withFormat: "HH:mm")
            } else if date.isInYesterday { // 昨天
                displayDate = date.string(withFormat: "昨天 HH:mm")
            } else if Date().daysSince(date) < 7 { // 7天内
                displayDate = date.string(withFormat: "\(ChatDateCellItem.weekDayName(weekDay: date.weekday))")
            } else {
                displayDate = date.string(withFormat: "yyyy年MM月dd日")
            }
        }
        
        if let lastMessage = conversation.lastMessage {
            lastMessageContent = lastMessage.displayContent
        }
        
        unreadMessageCount = conversation.unreadMessageCount
        //        TSLog("当前会话未读消息数: \(unreadMessageCount)")
        
        // 获取会话中对方的id,然后去更新数据
        targetId = conversation.targetId
        currentCell?.updateMessageInfo()
    }
    
    func update(_ userInfo: TeacherInfo) {
        nickname = userInfo.name
        avatarURL = userInfo.avatar
        year = userInfo.workYear
        title = userInfo.title
        currentCell?.updateUserInfo()
    }
    
    @objc func imReceiveMessage(_ notification: Notification) {
        if let message = notification.userInfo?[UserInfo.Message] as? Message,
            message.targetId == conversation.targetId {
            // 消息有更新
            conversation = CounselorIM.shared.conversation(targetId: targetId)
            setNewPropeties()
        }
    }
    
    @objc func teacherInfoUpdated(_ noti: Notification) {
        if let teacherInfo = noti.userInfo?[TeacherInfoKey] as? TeacherInfo, teacherInfo.id == targetId {
            update(teacherInfo)
        }
    }
    
    @objc func clearUnreadCount(_ noti: Notification) {
        if let conversationId = noti.userInfo?[ConversationKey] as? String, conversationId == targetId {
            unreadMessageCount = 0
            //            TSLog("收到未读消息清0通知, 获取当前未读消息数: \(unreadMessageCount)")
            currentCell?.updateMessageInfo()
        }
    }
 
}


class ConversationListCell: SSTableViewCell {
    private var avatarView: UIImageView!
    private var unReadBadgeView: UnReadBadgeView!
    private var nicknameLabel: UILabel!
    private var dateLabel: UILabel!
    private var lastMessageLabel: UILabel!
    private var tagLabels: [ChatListCellTagView] = []
    
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.backgroundColor = .white
        // 用户头像
        let avatarRadius: CGFloat = 25
        avatarView = UIImageView()
        avatarView.layer.cornerRadius = avatarRadius
        
        avatarView.clipsToBounds = true
        //        avatarView.backgroundColor = .yellow
        contentView.addSubview(avatarView)
        avatarView.snp.makeConstraints { (make) in
            make.left.equalTo(16)
            make.top.equalTo(20)
            make.size.equalTo(CGSize(width: avatarRadius * 2, height: avatarRadius * 2))
        }
        
        unReadBadgeView = UnReadBadgeView()
        let badgeHeight: CGFloat = 18
        unReadBadgeView.layer.cornerRadius = badgeHeight / 2
        contentView.addSubview(unReadBadgeView)
        unReadBadgeView.snp.makeConstraints { (make) in
            make.right.equalTo(avatarView)
            make.top.equalTo(avatarView)
            make.height.equalTo(badgeHeight)
            make.width.greaterThanOrEqualTo(badgeHeight)
        }
        
        
        // 用户昵称
        
        nicknameLabel = UILabel(frame: CGRect.zero, text: nil, textColor: UIColor(0x26343F), fontSize: 17)
        contentView.addSubview(nicknameLabel)
        nicknameLabel.snp.makeConstraints { (make) in
            make.left.equalTo(82)
            make.top.equalTo(22)
            make.right.lessThanOrEqualToSuperview().offset(-120)
        }
        
        // 时间
        dateLabel = UILabel(frame: CGRect.zero, text: nil, textColor: UIColor(0x949BA1), fontSize: 12)
        contentView.addSubview(dateLabel)
        dateLabel.snp.makeConstraints { (make) in
            make.right.equalTo(-16)
            make.centerY.equalTo(nicknameLabel)
        }
        
        
        for _ in 0..<2 {
            let tagLabel = ChatListCellTagView()
            tagLabels.append(tagLabel)
            contentView.addSubview(tagLabel)
            tagLabel.isHidden = true
        }
        
        
        // 最新一条消息
        lastMessageLabel = UILabel(frame: CGRect.zero, text: nil, textColor: UIColor(0x949BA1), fontSize: 14)
        contentView.addSubview(lastMessageLabel)
        lastMessageLabel.snp.makeConstraints { (make) in
            make.left.equalTo(nicknameLabel)
            make.top.equalTo(76)
            make.right.lessThanOrEqualToSuperview().offset(-16)
        }
        
        // 分割线
        let bottomLine = UIView()
        bottomLine.backgroundColor = UIColor(0xE4E5E6)
        contentView.addSubview(bottomLine)
        bottomLine.snp.makeConstraints { (make) in
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(XDSize.unitWidth)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func shouldUpdate(with object: Any!) -> Bool {
        if super.shouldUpdate(with: object) {
            if let cellItem = item as? ConversationListItem {
                cellItem.currentCell = self
                updateMessageInfo()
                updateUserInfo()   
            }
            return true
        } else {
            return false
        }
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        contentView.backgroundColor = highlighted ? UIColor(0xF2F2F2) : .white
    }
    
    override func prepareForReuse() {
        if let cellItem = item as? ConversationListItem, cellItem.currentCell == self {
            cellItem.currentCell = nil
        }
        super.prepareForReuse()
    }
}

class ChatListCellTagView: UIButton {
    
    
    var text: String? {
        didSet {
            setTitle(text, for: .normal)
            if let text = text, !text.isEmpty {
                contentEdgeInsets = UIEdgeInsetsMake(0, 8, 0, 8)
            } else {
                contentEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0)
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        clipsToBounds = true
        self.isUserInteractionEnabled = false
        setTitleColor(UIColor(0x949BA1), for: .normal)
        titleLabel?.font = UIFont.systemFont(ofSize: 11)
        backgroundColor = UIColor(0xF5F6F7)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = height * 0.5
    }
}

class UnReadBadgeView: UILabel {
    override init(frame: CGRect) {
        super.init(frame: frame)
        textColor = .white
        font = UIFont.systemFont(ofSize: 13)
        customBackgroundColor = UIColor(0xF12C20)
        textAlignment = .center
        clipsToBounds = true
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var backgroundColor: UIColor? {
        set {
            
        }
        get {
            return super.backgroundColor
        }
    }
    
    var customBackgroundColor: UIColor? {
        set {
            super.backgroundColor = newValue
        }
        get {
            return super.backgroundColor
        }
    }
}

extension ConversationListCell {
    func updateMessageInfo() {
        if let cellItem = item as? ConversationListItem,
            let lastMessage = cellItem.conversation.lastMessage {
            dateLabel.text = cellItem.displayDate
            lastMessageLabel.text = cellItem.lastMessageContent
            if cellItem.conversation.lastestMessageDirection == .MessageDirection_RECEIVE && lastMessage is VoiceMessage && cellItem.conversation.receivedStatus != .ReceivedStatus_LISTENED {
                lastMessageLabel.textColor = UIColor(0xFF4046)
            } else {
                lastMessageLabel.textColor = UIColor(0x949BA1)
            }
            
            unReadBadgeView.text = "\(cellItem.unreadMessageCount)"
            unReadBadgeView.isHidden = cellItem.unreadMessageCount == 0
        }
    }
    
    func updateUserInfo() {
        if let cellItem = item as? ConversationListItem {
            avatarView.kf.setImage(with: cellItem.avatarURL?.url)
            nicknameLabel.text = cellItem.nickname
            
            tagLabels.forEach { $0.isHidden = true }
            var tags: [String] = []
            
            if let title = cellItem.title, !title.isEmpty {
                tags.append(title)
            }
            if let year = cellItem.year, !year.isEmpty {
                tags.append("从业" + year + "年")
            }
          
            var lastTagLabel: ChatListCellTagView!
            for (index, tag) in tags.enumerated() {
                let tagLabel = tagLabels[index]
                tagLabel.isHidden = false
                tagLabel.text = tag
                tagLabel.snp.makeConstraints({ (make) in
                    if index == 0 {
                        make.left.equalTo(nicknameLabel)
                    } else {
                        make.left.equalTo(lastTagLabel.snp.right).offset(12)
                    }
                    make.height.equalTo(14)
                    make.top.equalTo(nicknameLabel.snp.bottom).offset(10)
                    
                })
                lastTagLabel = tagLabel
            }
        }
    }
}
