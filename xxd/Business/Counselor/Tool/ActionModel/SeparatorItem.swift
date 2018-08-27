//
//  SeparatorItem.swift
//  counselor_t
//
//  Created by chenyusen on 2017/12/18.
//  Copyright © 2017年 TechSen. All rights reserved.
//

import UIKit

class SeparatorItem: TableCellItem {
    var height: CGFloat = 10
    var color: UIColor = UIColor(red: 247.0/255.0, green: 247.0/255.0, blue: 247.0/255.0, alpha: 1)
    override var cellClass: UITableViewCell.Type? {
        return SeparatorCell.self
    }
    
    override var cellHeight: CGFloat {
        return height
    }
}


class SeparatorCell: TableCell {
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func updateCell(_ cellItem: TableCellItemProtocol?) {
        if let cellItem = cellItem as? SeparatorItem {
            self.contentView.backgroundColor = cellItem.color
        }
    }
}
