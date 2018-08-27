//
//  TargetCollegeStatUserCellItem.swift
//  xxd
//
//  Created by Lisen on 2018/6/4.
//  Copyright © 2018年 com.smartstudy. All rights reserved.
//

import UIKit

class TargetCollegeStatUserCellItem: SSCellItem {
    var model: TargetCollegeWatcherModel!
    var isPrivacy: Bool = false
    
    convenience init(model: TargetCollegeWatcherModel) {
        self.init()
        self.model = model
    }
    
    override init!(attributes: [AnyHashable : Any]! = [:]) {
        super.init(attributes: attributes)
        self.model = TargetCollegeWatcherModel.yy_model(with: attributes)
    }
    
    override init!(cellClass: AnyClass!, userInfo: Any!) {
        super.init(cellClass: cellClass, userInfo: userInfo)
    }
    
    override func cellClass() -> AnyClass! {
        return TargetCollegeStatUserCell.self
    }
}

class TargetCollegeStatUserCell: SSTableViewCell {
    
    private lazy var userAvatar: UIImageView = {
        let imageView: UIImageView = UIImageView(frame: CGRect.zero)
        imageView.layer.cornerRadius = 20.0
        imageView.layer.masksToBounds = true
        return imageView
    }()
    private lazy var userName: UILabel = UILabel(frame: CGRect.zero, text: "", textColor: XDColor.itemTitle, fontSize: 15.0)
    private lazy var countLabel: UILabel = UILabel(frame: CGRect.zero, text: "", textColor: XDColor.itemText, fontSize: 13.0)
    private lazy var bottomLine: UIView = UIView(frame: CGRect.zero, color: XDColor.itemLine)
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = UIColor.white
        contentView.addSubview(userAvatar)
        userAvatar.snp.makeConstraints { (make) in
            make.left.equalTo(16.0)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(40.0)
        }
        contentView.addSubview(countLabel)
        countLabel.snp.makeConstraints { (make) in
            make.right.equalTo(-16.0)
            make.centerY.equalToSuperview()
        }
        contentView.addSubview(userName)
        userName.snp.makeConstraints { (make) in
            make.left.equalTo(userAvatar.snp.right).offset(12.0)
            make.centerY.equalToSuperview()
            make.right.lessThanOrEqualTo(countLabel.snp.left).offset(-4.0)
        }
        contentView.addSubview(bottomLine)
        bottomLine.snp.makeConstraints { (make) in
            make.left.equalTo(16.0)
            make.right.equalTo(-16.0)
            make.bottom.equalToSuperview()
            make.height.equalTo(XDSize.unitWidth)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) { }
    override func setHighlighted(_ highlighted: Bool, animated: Bool) { }
    
    override static func height(for object: Any!, at indexPath: IndexPath!, tableView: UITableView!) -> CGFloat {
        return 72.0
    }
    
    override func shouldUpdate(with object: Any!) -> Bool {
        if super.shouldUpdate(with: object), let object = object as? TargetCollegeStatUserCellItem {
            userAvatar.kf.setImage(with: URL(string: object.model.avatar), placeholder: UIImage(named: "default_avatar"))
            userName.text = object.model.name
            countLabel.attributedText = "共" + NSAttributedString(string: "\(object.model.selectSchoolCount)", attributes: [NSAttributedStringKey.foregroundColor: UIColor(0x078CF1)]) + "所选校"
        }
        
        return true
    }
}

