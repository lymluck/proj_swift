//
//  TargetCollegeOtherItem.swift
//  xxd
//
//  Created by Lisen on 2018/6/5.
//  Copyright © 2018年 com.smartstudy. All rights reserved.
//

import UIKit

class TargetCollegeOtherItem: SSCellItem {
    var model: TargetCollegeModel!
    
    override init!(attributes: [AnyHashable : Any]! = [:]) {
        super.init(attributes: attributes)
        model = TargetCollegeModel.yy_model(with: attributes)
    }
    
    override init!(cellClass: AnyClass!, userInfo: Any!) {
        super.init(cellClass: cellClass, userInfo: userInfo)
    }
    
    override func cellClass() -> AnyClass! {
        return TargetCollegeOtherItemCell.self
    }
}


class TargetCollegeOtherItemCell: SSTableViewCell {
    private var rankLabel: UILabel!
    private var titleLabel: UILabel!
    private var typeView: UIImageView!
    
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.backgroundColor = UIColor.white
        
        let rankWidth: CGFloat = 27.0
        // 排名
        rankLabel = UILabel(frame: CGRect(x: 16.0, y: 20.0, width: rankWidth, height: 14.0), text: "", textColor: XDColor.itemTitle, fontSize: 14)
        rankLabel.textAlignment = .center
        contentView.addSubview(rankLabel)
        let label = UILabel(frame: CGRect(x: 16.0, y: rankLabel.bottom, width: rankWidth, height: 12), text: "#", textColor: XDColor.itemText, fontSize: 10)!
        label.textAlignment = .center
        contentView.addSubview(label)
        // 标题
        titleLabel = UILabel(frame: .null, text: "", textColor: XDColor.itemTitle, fontSize: 15)
        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(contentView)
            make.left.equalTo(51.0)
            make.right.lessThanOrEqualToSuperview().offset(-51.0)
        }
        // 类型
        typeView = UIImageView()
        typeView.contentMode = .left
        contentView.addSubview(typeView)
        typeView.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.width.height.equalTo(20.0)
            make.right.equalTo(-16.0)
        }
        let bottomLine = UIView(frame: CGRect(x: 16.0, y: contentView.height - XDSize.unitWidth, width: contentView.width-32.0, height: XDSize.unitWidth), color: XDColor.itemLine)
        bottomLine.autoresizingMask = [.flexibleWidth, .flexibleTopMargin]
        contentView.addSubview(bottomLine)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) { }
    override func setSelected(_ selected: Bool, animated: Bool) { }
    
    override static func height(for object: Any!, at indexPath: IndexPath!, tableView: UITableView!) -> CGFloat {
        return 66.0
    }
    
    override func shouldUpdate(with object: Any!) -> Bool {
        if super.shouldUpdate(with: object), let object = object as? TargetCollegeOtherItem {
            rankLabel.text = object.model.worldRank.isEmpty ? "N/A" : object.model.worldRank
            titleLabel.text = object.model.chineseName
            if object.model.targetCollegeType == .bottom {
                typeView.image = UIImage(named: "target_bottom")
            } else if object.model.targetCollegeType == .middle {
                typeView.image = UIImage(named: "target_middle")
            } else {
                typeView.image = UIImage(named: "target_top")
            }
        }
        return true
    }
    
}
