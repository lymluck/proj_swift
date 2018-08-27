//
//  ChatDateCellItem.swift
//  counselor_t
//
//  Created by chenyusen on 2018/1/22.
//  Copyright © 2018年 TechSen. All rights reserved.
//

import UIKit

private let kDateSize: CGFloat = 12

class ChatDateCellLayout: ChatCellLayout {
    var dateFrame: CGRect!
}

class ChatDateCellItem: ChatCellItem {
    static let calLabel = UILabel(frame: CGRect.zero, text: nil, textColor: .white, fontSize: kDateSize)!
    
    static func weekDayName(weekDay: Int) -> String {
        switch weekDay {
        case 1:
            return "星期日"
        case 2:
            return "星期一"
        case 3:
            return "星期二"
        case 4:
            return "星期三"
        case 5:
            return "星期四"
        case 6:
            return "星期五"
        case 7:
            return "星期六"
        default:
            assert(false, "wtf")
            return "星期日"
        }
    }
    
    override var cellHeight: CGFloat {
        return layout?.cellHeight ?? 0
    }
    
    override var cellClass: UITableViewCell.Type? {
        return ChatDateCell.self
    }
    
    private(set) var displayTime: String!
    var date: Date! {
        didSet {
            // 如果是今天,则显示今天的时间
            if date.isInToday { // 今天
                displayTime = date.string(withFormat: "HH:mm")
            } else if date.isInYesterday { // 昨天
                displayTime = date.string(withFormat: "昨天 HH:mm")
            } else if Date().daysSince(date) < 7 { // 7天内
                displayTime = date.string(withFormat: "\(ChatDateCellItem.weekDayName(weekDay: date.weekday)) HH:mm")
            } else {
                displayTime = date.string(withFormat: "yyyy年MM月dd日 HH:mm")
            }
                 
            let layout = ChatDateCellLayout()
            // 计算frame
            ChatDateCellItem.calLabel.text = displayTime
            ChatDateCellItem.calLabel.sizeToFit()
            ChatDateCellItem.calLabel.width += 20
            ChatDateCellItem.calLabel.height = 22
            layout.cellHeight = 22 + 20
            layout.dateFrame = CGRect(x: (XDSize.screenWidth - ChatDateCellItem.calLabel.width) * 0.5,
                                      y: 10,
                                      width: ChatDateCellItem.calLabel.width,
                                      height: ChatDateCellItem.calLabel.height)
            self.layout = layout
        }
    }
    
}

class ChatDateCell: ChatCell {
    var dateLabel: UILabel!
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        dateLabel = UILabel(frame: CGRect.zero, text: nil, textColor: .white, fontSize: kDateSize)!
        dateLabel.layer.cornerRadius = 6
        dateLabel.clipsToBounds = true
        dateLabel.textAlignment = .center
        dateLabel.backgroundColor = UIColor(0xC4C9CC).withAlphaComponent(0.9)
        contentView.addSubview(dateLabel)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func updateCell(_ cellItem: TableCellItemProtocol?) {
        super.updateCell(cellItem)
        if let cellItem = cellItem as? ChatDateCellItem,
            let layout = cellItem.layout as? ChatDateCellLayout {
            dateLabel.text = cellItem.displayTime
            dateLabel.frame = layout.dateFrame
        }
    }
}
