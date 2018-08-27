//
//  CounselorChatListViewController.swift
//  xxd
//
//  Created by chenyusen on 2018/3/2.
//  Copyright © 2018年 com.smartstudy. All rights reserved.
//

import UIKit

class CounselorChatListViewController: SSTableViewController {
    var hasInitializeUsersInfos = false

    override func viewDidLoad() {
        
        super.viewDidLoad()
        navigationBar.isHidden = true
        
        tableView.frame = view.bounds
        tableView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        tableView.rowHeight = 110
        
        updateConversationList()
        
        tableViewActions.attach(to: ConversationListItem.self, tap: { [weak self] (object, target, indexPath) -> Bool in
            if let cellItem = object as? ConversationListItem {
                guard CounselorIM.shared.connectionStatus == .connected else { return true }
                self?.navigationController?.pushViewController(ChatViewController(query: [IMUserID: cellItem.targetId]), animated: true)
                
            }
            
            return true
        })
        
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(imConnectStatusChanged(_:)),
                                               name: .IMConnectStatusChanged,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(imReceiveMessage(_:)),
                                               name: .IMReceiveMessage,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(imMessageRecalled(_:)),
                                               name: .IMMessageRecalled,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(imSendMessageSuccess(_:)),
                                               name: .IMSendMessageSuccess,
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(userHasLogout(_:)),
                                               name: NSNotification.Name(rawValue: XD_NOTIFY_SIGN_OUT),
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(connectFinished(_:)),
                                               name: .IMConnectFinished,
                                               object: nil)
        
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(reciveStatusChanged(_:)),
                                               name: .IMMessageReciveStatusChanged,
                                               object: nil)
        
    }

    
    private func updateConversationList() {
        // 获取会话列表
        let conversationList = CounselorIM.shared.conversationList()

        let ids = conversationList.map {$0.targetId }
        
        // 强制从网络更新数据
        if ids.count > 0 && !hasInitializeUsersInfos {
            TeacherInfoHelper.shared.updateTeacherInfos(ids)
            hasInitializeUsersInfos = true
        }
        

        let cellItems: [ConversationListItem] = conversationList.map {
            let cellItem = ConversationListItem()!
            cellItem.conversation = $0
            return cellItem
        }
        tableViewModel.sections?.removeAllObjects()
        tableViewModel.addObjects(from: cellItems)
        tableView.reloadData()
    }
    
    override func showEmpty(_ show: Bool) {
        
    }
    
    override func showError(_ show: Bool) {
        
    }
}

// MARK: - Notification
extension CounselorChatListViewController {
    @objc func imConnectStatusChanged(_ notification: Notification) {
        if let status = notification.userInfo?[UserInfo.ConnectStatus] as? ConnectionStatus,
            status == .connected {
            updateConversationList()
        }
    }
    
    @objc func imSendMessageSuccess(_ notification: Notification) {
        updateConversationList()
    }
    
    @objc func connectFinished(_ notification: Notification) {
        updateConversationList()
    }
    
    @objc func imReceiveMessage(_ notification: Notification) {
        if notification.userInfo?[UserInfo.Message] as? Message != nil {
            updateConversationList()
        }
    }
    
    @objc func imMessageRecalled(_ notification: Notification) {
        updateConversationList()
    }
    
    @objc func userHasLogout(_ notification: Notification) {
        tableViewModel.sections.removeAllObjects()
        tableView.reloadData()
    }
    
    @objc func reciveStatusChanged(_ noti: Notification) {
        updateConversationList()
    }
    
    
}
