//
//  RecallCellItem.swift
//  counselor_t
//
//  Created by chenyusen on 2018/2/2.
//  Copyright © 2018年 TechSen. All rights reserved.
//

import UIKit

private let kContentSize: CGFloat = 12

class RecallCellLayout: ChatCellLayout {
    var contentFrame: CGRect!
}

class RecallCellItem: ChatMessageCellItem {
    static var calLabel: UILabel = {
        let label = UILabel(frame: CGRect.zero, text: nil, textColor: .white, fontSize: kContentSize)!
        label.numberOfLines = 0
        return label
    }()
    var content: String?
    override var cellClass: UITableViewCell.Type? {
        return RecallCell.self
    }
    
    override var model: Any? {
        didSet {
            if let message = (model as? Message) {
                if message.senderUserId == XDUser.shared.model.imUserId {
                    content = "你撤回了一条消息"
                } else {
                    TeacherInfoHelper.shared.teacherInfo(message.targetId,
                                                         completion: { [weak self] (studentInfo) in
                        if self == nil { return }
                        if let studentInfo = studentInfo {
                            self?.content = (studentInfo.name ?? "") + "撤回了一条消息"
                            (self?.currentCell as? RecallCell)?.updateCell(self!)
                        }
                    })
                }
                
                let layout = RecallCellLayout()
                // 计算frame
                RecallCellItem.calLabel.text = content
                RecallCellItem.calLabel.size = CGSize(width: XDSize.screenWidth - 100, height: 10000)
                RecallCellItem.calLabel.sizeToFit()
                RecallCellItem.calLabel.height = max(22, RecallCellItem.calLabel.height + 6)
                
                layout.contentFrame = CGRect(x: (XDSize.screenWidth - RecallCellItem.calLabel.width) * 0.5,
                                             y: 10,
                                             width: RecallCellItem.calLabel.width + 10,
                                             height: RecallCellItem.calLabel.height)
                layout.cellHeight = RecallCellItem.calLabel.height + 20
                self.layout = layout
            }
        }
    }
    
    override var cellHeight: CGFloat {
        return layout?.cellHeight ?? 0
    }
}

class RecallCell: ChatCell {
    var contentLabel: UILabel!
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentLabel = UILabel(frame: CGRect.zero, text: nil, textColor: .white, fontSize: kContentSize)!
        contentLabel.numberOfLines = 0
        contentLabel.layer.cornerRadius = 6
        contentLabel.clipsToBounds = true
        contentLabel.textAlignment = .center
        contentLabel.backgroundColor = UIColor(0xC4C9CC).withAlphaComponent(0.9)
        contentView.addSubview(contentLabel)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func updateCell(_ cellItem: TableCellItemProtocol?) {
        super.updateCell(cellItem)
        if let cellItem = cellItem as? RecallCellItem,
            let layout = cellItem.layout as? RecallCellLayout {
            contentLabel.text = cellItem.content
            contentLabel.frame = layout.contentFrame
        }
    }
}
