//
//  TranspondViewController.swift
//  counselor_t
//
//  Created by chenyusen on 2018/2/8.
//  Copyright © 2018年 TechSen. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift

class TranspondViewController: TableViewController {
    
    var message: Message!
    
    override init(query: [String : Any]?) {
        super.init(query: query)
        
        message = query?[UserInfo.Message] as? Message
        
        assert(message != nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        navigationBar?.itemTintColor = UIColor(0x949BA1)
        super.viewDidLoad()
        title = "选择一个聊天"
        tableView.separatorStyle = .none
        
        // 会话列表
        let conversationList = CounselorIM.shared.conversationList()
        let cellItems: [ToTranspondUserCellItem] = conversationList.map {
            let cellItem = ToTranspondUserCellItem()
            cellItem.model = $0
            return cellItem
        }
        
        let recentlyChatList = SectionItem(model: "最近聊天",
                                          headerHeight: 24,
                                          headerSectionViewClass: TranspondViewHeaderSection.self,
                                          rows: cellItems)
        
        tableViewModel.add(recentlyChatList)
        
        tableViewAction.tap(to: ToTranspondUserCellItem.self) { [weak self] (cellItem, _) -> (Bool) in
            guard let sSelf = self else { return true }
            let contentView = TranspondContentView()
            contentView.delegate = self
            if let targetId = (cellItem.model as? Conversation)?.targetId {
                contentView.targetId = targetId
                contentView.message = sSelf.message
                PopViewController(contentView: contentView).show()
            }
            
            
            return true
        }

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.enableAutoToolbar = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        IQKeyboardManager.shared.enable = false
        IQKeyboardManager.shared.enableAutoToolbar = false
    }
    
}

extension TranspondViewController: TranspondContentViewDelegate {
    func hasSendSuccess() {
        delay(1.5) { [weak self] in
            self?.dismiss(animated: true, completion: nil)
        }
    }
    
    
}
