//
//  TeacherReportCellItem.swift
//  xxd
//
//  Created by chenyusen on 2018/3/9.
//  Copyright © 2018年 com.smartstudy. All rights reserved.
//

import UIKit

class TeacherReportCellItem: TableCellItem {
    
    var isSelected: Bool = false {
        didSet {
            (currentCell as? TeacherReportCell)?.updateCell(self)
        }
    }
    var title: String!
    var id: String!

    override var cellClass: UITableViewCell.Type? {
        return TeacherReportCell.self
    }
    
    override var cellHeight: CGFloat {
        return 64
    }
}


class TeacherReportCell: TableCell {
    var titleLabel: UILabel!
    var selectedView: UIImageView!
    
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.backgroundColor = .white
        
        titleLabel = UILabel()
        titleLabel.textColor = UIColor(0x26343F)
        titleLabel.font = UIFont.systemFont(ofSize: 16)
        contentView.addSubview(titleLabel)
        
        titleLabel.snp.makeConstraints { (make) in
            make.left.equalTo(16)
            make.centerY.equalToSuperview()
        }
        
        selectedView = UIImageView(image: UIImage(named: "selected"))
        selectedView.isHidden = true
        contentView.addSubview(selectedView)
        selectedView.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.right.equalTo(-16)
        }
    }
 
    
    override func updateCell(_ cellItem: TableCellItemProtocol?) {
        super.updateCell(cellItem)
        if let cellItem = cellItem as? TeacherReportCellItem {
            titleLabel.text = cellItem.title
            selectedView.isHidden = !cellItem.isSelected
            selectionStyle = .none
        }
    }
}
