//
//  OtherUserInfoItem.swift
//  xxd
//
//  Created by Lisen on 2018/8/3.
//  Copyright © 2018 com.smartstudy. All rights reserved.
//

import UIKit

class OtherUserInfoItem: SSCellItem {
    var model: OtherUserInfoModel!
    
    override init!(attributes: [AnyHashable : Any]! = [:]) {
        super.init(attributes: attributes)
        model = OtherUserInfoModel.yy_model(with: attributes)
    }
    
    override init!(cellClass: AnyClass!, userInfo: Any!) {
        super.init(cellClass: cellClass, userInfo: userInfo)
    }
    
    override func cellClass() -> AnyClass! {
        return OtherUserInfoItemCell.self
    }
}

class OtherUserInfoItemCell: SSTableViewCell {
    
    private lazy var titleLabel: UILabel = UILabel(text: "", textColor: XDColor.itemText, fontSize: 16)
    private lazy var nameLabel: UILabel = UILabel(text: "", textColor: XDColor.itemTitle, fontSize: 16)
    private lazy var bottomLine: UIView = UIView(frame: CGRect.zero, color: XDColor.itemLine)
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.backgroundColor = UIColor.white
        titleLabel.numberOfLines = 0
        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(contentView)
            make.left.equalTo(contentView).offset(16)
            make.width.equalTo(85.0)
            make.height.equalTo(22.0)
        }
        contentView.addSubview(nameLabel)
        nameLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(contentView)
            make.left.equalTo(101.0)
            make.right.equalTo(-16.0)
            make.height.equalTo(22.0)
        }
        contentView.addSubview(bottomLine)
        bottomLine.snp.makeConstraints { (make) in
            make.left.equalTo(16.0)
            make.bottom.right.equalToSuperview()
            make.height.equalTo(XDSize.unitWidth)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func shouldUpdate(with object: Any!) -> Bool {
        if super.shouldUpdate(with: object), let item = object as? OtherUserInfoItem {
            titleLabel.text = item.model.title
            nameLabel.text = item.model.name
        }
        return true
    }
    
    override static func height(for object: Any!, at indexPath: IndexPath!, tableView: UITableView!) -> CGFloat {
        return 64.0
    }
    
}
