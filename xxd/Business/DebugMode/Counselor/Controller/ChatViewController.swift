//
//  ChatViewController.swift
//  counselor_t
//
//  Created by chenyusen on 2017/12/8.
//  Copyright © 2017年 TechSen. All rights reserved.
//

import UIKit
import DeviceKit
import AVFoundation
import SwiftyJSON

let UserID = "UserID"
let IMUserID = "IMUserID"

let timeTagDelta = 120  // 打时间节点的间隔,  单位s


class ChatListView: UITableView {
    private var completion: (() -> ())?
    var topLoadMoreControl: TopLoadMoreRefreshControl? {
        didSet {
            if let oldValue = oldValue {
                contentInset.top -= oldValue.deltaHeight
                oldValue.removeFromSuperview()
            }
            if let topLoadMoreControl = topLoadMoreControl {
                addSubview(topLoadMoreControl)
                contentInset.top += topLoadMoreControl.deltaHeight
            }
        }
    }
    
    override init(frame: CGRect, style: UITableViewStyle) {
        super.init(frame: frame, style: style)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    /// 滚到最底部
    ///
    /// - Parameter animated: 是否动画
    func scrollToBottomMessage(animated: Bool) {
        if let cellCount = self.dataSource?.tableView(self, numberOfRowsInSection: 0), cellCount > 0 {
            scrollToRow(at: IndexPath(row: cellCount - 1, section: 0), at: .bottom, animated: animated)
        }
    }
    
//    /// 重新加载数据
//    ///
//    /// - Parameter completion: 加载数据完成并刷新UI后的回调
//    public func reloadData(completion: (()->())? = nil) {
//        self.completion = completion
//        reloadData()
//    }
    
    
    /// 重新加载数据,在加载完数据后自动滚到最底部
    ///
    /// - Parameter completion: 加载完数据后的回调
    public func reloadAndScrollToBottom(completion: (()->())? = nil, animated: Bool = true) {
        reloadData { [weak self] in
            self?.scrollToBottomMessage(animated: animated)
            if let completion = completion {
                completion()
            }
        }
    }
    
    override func touchesShouldCancel(in view: UIView) -> Bool {
        return true
    }
    
    deinit {
        topLoadMoreControl?.invalidateObservation()
    }
}

class ChatViewController: TableViewController {
    var chatInputBar: ChatInputBar!
    var conversation: Conversation! {
        return CounselorIM.shared.conversation(targetId: targetId)
    }
    var targetId: String
    override init(query: [String : Any]?) {
        targetId = query?[IMUserID] as? String ?? ""
        super.init(query: query)
        self.tableViewClass = ChatListView.self
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        autoresizesForKeyboard = true
        autoAdjustiPhoneX = false
        tableView.showsHorizontalScrollIndicator = false
        let moreButtonItem = NavigationBarButtonItem(image: UIImage(named: "more_btn")!,
                                                     target: self,
                                                     action: #selector(moreItemPressed))

        navigationBar?.rightButtonItems = [moreButtonItem]
        
        let centerView = ChatNavigationCenterView()
        navigationBar?.centerView = centerView
        
        TeacherInfoHelper.shared.teacherInfo(targetId, needCompany: true) { (info) in
            if let info = info {
                centerView.bind(info)
            }
        }
        
//        tableViewAction.shouldScrollToTop = false
        tableView.separatorStyle = .none
        tableView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(chatListViewTapped)))
        // 去数据库拉取最新的20条
        let messages: [Message] = CounselorIM.shared.latestMessages(targetId: targetId).reversed()
        let messageCellItems: [ChatCellItem] = messages.map {
            
            return ChatCellItemFactory.chatCellItem($0)
        }
        // 进行时间节点穿插
        let chatCellItems = insertTimes(messageCellItems)
        
        // 如果消息数量为20个, 则说明消息有分页,此时,将放置下拉加载更多控件
        if messageCellItems.count == 20 {
            (tableView as? ChatListView)?.topLoadMoreControl = TopLoadMoreRefreshControl(refreshBlock: { [weak self] in
                // 当前最老的一条消息的id
                if self == nil { return }
                if let messageCellItems = self?.tableViewModel.cellItems().filter({ $0 is ChatMessageCellItem }),
                let oldestMessageCellItem = messageCellItems.first,
                let oldestMessage = oldestMessageCellItem.model as? Message {
                    CounselorIM.shared.historyMessages(targetId: self!.targetId,
                                                       from: oldestMessage.messageId,
                                                       completion: { (messages) in
                                                        let newMessages = messages.reversed()
                                                        let newMessageCellItems: [ChatCellItem] = newMessages.map {
                                                            return ChatCellItemFactory.chatCellItem($0)
                                                        }
                                                        // 进行时间节点穿插
                                                        let chatCellItems = self!.insertTimes(newMessageCellItems)
                                                        self?.tableViewModel.insert(chatCellItems, at: 0)
                                                        
                                                        
                                                        let contentSizeHeight = self!.tableView.contentSize.height
                                                        self!.tableView.reloadData()
                                                        let newContentSizeHeight = self!.tableView.contentSize.height
                                                        let deltaHeight = newContentSizeHeight - contentSizeHeight
                                                        // 神秘的26
                                                        self!.tableView.contentOffset.y += deltaHeight - 30 - 26
                                                        
                                                        if newMessages.count < 20 {
                                                            (self?.tableView as? ChatListView)?.topLoadMoreControl?.neverDisplay = true
                                                        } else {
                                                            (self?.tableView as? ChatListView)?.topLoadMoreControl?.stopAnimating()
                                                        }
                        
                    })
                }
            })
           
        }
        
        tableViewModel.add(chatCellItems)
        
        
        let device = Device()
        let chatInputBarHeight: CGFloat = (device == .iPhoneX || device == .simulator(.iPhoneX)) ? 49 + 34 : 49
        chatInputBar = ChatInputBar(frame: CGRect(x: 0, y: view.height - chatInputBarHeight, width: view.width, height: chatInputBarHeight))
        chatInputBar.delegate = self
        view.addSubview(chatInputBar)
   
        tableView.keyboardDismissMode = .onDrag
        tableView.height -= chatInputBar.height
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(imReceiveMessage(_:)),
                                               name: .IMReceiveMessage,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(reSendMessageSuccess(_:)),
                                               name: .ReSendMessageSuccess,
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(imSendMessageSuccess(_:)),
                                               name: .IMSendMessageSuccess,
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(sensorStateChange(_:)),
                                               name: .UIDeviceProximityStateDidChange,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(imMessageRecalled(_:)),
                                               name: .IMMessageRecalled,
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(imReadReceipt(_:)),
                                               name: .IMReadReceipt,
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(applicationDidBecomeActive(_:)),
                                               name: .UIApplicationDidBecomeActive,
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(imMessageDeleted(_:)),
                                               name: .IMMessageDeleted,
                                               object: nil)
        (tableView as? ChatListView)?.reloadAndScrollToBottom(animated: false)
        (tableView as? ChatListView)?.topLoadMoreControl?.addObservation()
    }
    
    deinit {
        tableView.delegate = nil
        tableView.dataSource = nil
        tableView = nil
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        (tableView as? ChatListView)?.topLoadMoreControl?.addObservation()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        tryClearUnreadCount()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        (tableView as? ChatListView)?.topLoadMoreControl?.invalidateObservation()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        AudioManager.shared.stopAllAudioPlay()
    }

    override func keyboardWillAppear(animated: Bool, withBounds bounds: CGRect) {
        chatInputBar.top = bounds.minY - 49
        tableView.height = chatInputBar.top - tableView.top
        (tableView as? ChatListView)?.scrollToBottomMessage(animated: false)
    }
 
    override func keyboardWillDisappear(animated: Bool, withBounds bounds: CGRect) {
        chatInputBar.bottom = bounds.minY
        tableView.height = chatInputBar.top - tableView.top
    }
}


// MARK: - Actions
extension ChatViewController {
    @objc func moreItemPressed() {
        navigationController?.pushViewController(TeacherInfoViewController(query: [IMUserID: targetId]), animated: true)
    }
    
    @objc func chatListViewTapped() {
        self.view.endEditing(true)
    }
}

// MARK: - Tools
extension ChatViewController {
    func tryClearUnreadCount() {
        
        guard isVisible
            && UIApplication.shared.applicationState == .active
            && CounselorIM.shared.unreadCount(withTargetId: targetId) > 0 else { return }
        
        // 清空本地会话维护的未读消息数
        if CounselorIM.shared.clearMessageUnreadStatus(withTargetId: targetId) {
            NotificationCenter.default.post(name: .ClearConversationUnreadCount,
                                            object: nil,
                                            userInfo: [ConversationKey: targetId])
        }
        trySendReadReceipt()
        
    }
    
    func trySendReadReceipt() {
        CounselorIM.shared.sendReadReceipt(targetId,
                                           timestamp: conversation.sentTime)
    }
    
    
    /// 进行时间结点穿插
    ///
    /// - Parameter chatMessageCellItems: 源chatCellItems
    /// - Returns: 穿插后的cellChatItems
    func insertTimes(_ chatCellItems: [ChatCellItem]) -> [ChatCellItem] {
        // 穿插时间节点
        // 过滤出属于messagecellItem的
        let messageChatCellItems = chatCellItems.filter { $0 is ChatMessageCellItem }
        
        var newChatCellItems: [ChatCellItem] = []
        
        // 两两之间对比, 如果时间差超过2分钟,则插入一个时间节点cell
        for index in 0..<messageChatCellItems.count {
            let currentMessageCellItem = messageChatCellItems[index]
            
            guard let currentMessage = (currentMessageCellItem as? ChatMessageCellItem)?.model as? Message else {
                continue
            }
            if index == 0 { // 第一条,强行插入时间节点
                newChatCellItems.append(ChatCellItemFactory.chatCellItem(Date(timeIntervalSince1970: TimeInterval(currentMessage.sentTime / 1000))))
            }
            newChatCellItems.append(currentMessageCellItem)
            
            
            if index+1 < messageChatCellItems.count {
                if let nextMessage = (messageChatCellItems[index+1] as? ChatMessageCellItem)?.model as? Message,
                    (nextMessage.sentTime - currentMessage.sentTime) > timeTagDelta * 1000 {
                    newChatCellItems.append(ChatCellItemFactory.chatCellItem(Date(timeIntervalSince1970: TimeInterval(currentMessage.sentTime / 1000))))
                }
            }
        }
        
        return newChatCellItems
    }
    
    func allMessageItems() -> [ChatMessageCellItem] {
        if let allMessageItems = (tableViewModel.cellItems().filter{ $0 is ChatMessageCellItem }) as? [ChatMessageCellItem] {
            return allMessageItems
        }
        return []
    }
}

extension ChatViewController: ChatInputBarDelegate {
    func chatInputBarSend(_ message: CounselorIM.MessageType) {
        let messageCellItem = ChatCellItemFactory.createSendCellItem(message, targetId: targetId)
        messageCellItem.execute()
        // 判断当中是否要穿插时间节点cell
        // 过滤出聊天
        let lastMessageCellItem = tableViewModel.cellItems().last { $0 is ChatMessageCellItem }
        if let lastMessage = lastMessageCellItem?.model as? Message,
            let currentMessage = messageCellItem.model as? Message,
            (currentMessage.sentTime - lastMessage.sentTime) > timeTagDelta * 1000 { // 超过2分钟的消息需要添加一个时间节点cell
            let sendDate = Date(timeIntervalSince1970: TimeInterval(currentMessage.sentTime / 1000))
            let dateCellItem = ChatCellItemFactory.chatCellItem(sendDate)
            tableViewModel.add(dateCellItem)
        }
        tableViewModel.add(messageCellItem)
 
    
        if let tableView = tableView as? ChatListView {
            tableView.reloadAndScrollToBottom()
        }
    }
}


// MARK: - Notification Action
extension ChatViewController {
    @objc func imReceiveMessage(_ notification: Notification) {
        if let message = notification.userInfo?[UserInfo.Message] as? Message,
            message.targetId == targetId {
            tableViewModel.add(ChatCellItemFactory.chatCellItem(message))
            if tableView.isDragging || tableView.isTracking {
                tableView.reloadData()
            } else if ChatPopView.shared.isDisplaying {
                tableView.reloadData()
                ChatPopView.shared.isResistant = true
            } else {
                (tableView as! ChatListView).reloadAndScrollToBottom()
            }
            tryClearUnreadCount()
        }
    }
    
    @objc func imMessageRecalled(_ notification: Notification) {
        if let notiMessageId = notification.userInfo?[UserInfo.MessageId] as? Int {
            recallMessage(notiMessageId)
        }
    }
    
    @objc func imSendMessageSuccess(_ notification: Notification) {
        if !isVisible {
            imReceiveMessage(notification)
        }
    }
    
    @objc func imMessageDeleted(_ notification: Notification) {
        if let messageId = notification.userInfo?[UserInfo.MessageId] as? Int {
            
            let removedCellItem = tableViewModel.cellItems().filter {
                 ($0.model as? Message)?.messageId == messageId
            }.first
            

            if let removedCellItem = removedCellItem {
                tableViewModel.remove(cellItem: removedCellItem)
                tableView.reloadData()
            }
        }
    }
    
    func recallMessage(_ recallMessageId: Int) {
        var theIndex: Int?
        for (index, cellItem) in tableViewModel.cellItems().enumerated() {
            if let messageId = (cellItem.model as? Message)?.messageId, recallMessageId == messageId {
                theIndex = index
                break
            }
        }
        if let theIndex = theIndex {
            
            CounselorIM.shared.historyMessages(targetId: targetId,
                                               from: recallMessageId+1,
                                               count: 1,
                                               completion: { [weak self] (messages) in
                                                if self == nil { return }
                                                if let message = messages.first {
                                                    let cellItem = ChatCellItemFactory.chatCellItem(message)
                                                    var cellItems = self!.tableViewModel.cellItems()
                                                    cellItems[theIndex] = cellItem
                                                    self!.tableViewModel.removeAll()
                                                    self!.tableViewModel.add(cellItems)
                                                    self!.tableView.reloadData()
                                                }
            })
        }
    }
    
    @objc func imReadReceipt(_ notification: Notification) {
        let json = JSON(notification.userInfo!)
        if json["tId"].stringValue == targetId {
            let messageTime = json["messageTime"].int ?? 0
            // 筛选当前所有消息中,时间戳小于messageTime的, 并将它们的发送状态标记为已读
            for item in allMessageItems().reversed() {
                if let message = item.model as? Message {
                    if message.sentTime <= messageTime {
                        message.sentStatus = .SentStatus_READ
                        item.update()
                    } else {
                        break
                    }
                }
            }
        }
    }
    
    @objc func applicationDidBecomeActive(_ notification: Notification) {
        // 如果应用进入前台,此时正在显示聊天页面,则需要刷新一次未读消息数和发送已读消息回执
        tryClearUnreadCount()
    }
    
    
    /// 重新发送消息成功
    ///
    /// - Parameter notification: 消息
    @objc func reSendMessageSuccess(_ noti: Notification) {
        if let cellItem = noti.userInfo?[kChatCellItemKey] as? ChatMessageCellItem {
//            var cellItems = tableViewModel.cellItems().removeAll(cellItem)
            var cellItems = tableViewModel.cellItems()
            cellItems.removeAll(cellItem)
            cellItems.append(cellItem)
            tableViewModel.removeAll()
            tableViewModel.add(cellItem)
            (tableView as! ChatListView).reloadAndScrollToBottom()
        }
    }
    
    
    /// 根据红外线传感器的遮挡起开,设置播放方式
    @objc func sensorStateChange(_ notification: Notification) {
        if UIDevice.current.proximityState {
            try? AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayAndRecord)
        } else {
            try? AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
        }
    }
}



let ConversationKey = "ConversationKey"
extension Notification.Name {
    public static let ClearConversationUnreadCount: NSNotification.Name = NSNotification.Name("ClearConversationUnreadCount")
}


