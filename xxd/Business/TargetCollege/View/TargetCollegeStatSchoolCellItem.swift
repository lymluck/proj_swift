//
//  TargetCollegeStatSchoolCellItem.swift
//  xxd
//
//  Created by Lisen on 2018/6/4.
//  Copyright © 2018年 com.smartstudy. All rights reserved.
//

import UIKit

class TargetCollegeStatSchoolCellItem: SSCellItem {
    
    var model: TargetCollegeTopSchoolModel!
    var isLast: Bool = false
    convenience init(model: TargetCollegeTopSchoolModel) {
        self.init()
        self.model = model
    }
    
    override func cellClass() -> AnyClass! {
        return TargetCollegeStatSchoolCell.self
    }
}

class TargetCollegeStatSchoolCell: SSTableViewCell {
    private var logo: UIImageView!
    private var chineseName: UILabel!
    private var englishName: UILabel!
    private var selectNumLabel: UILabel!
    private var bottomLine: UIView!
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.backgroundColor = UIColor.white
        
        // logo
        let logoWrap = UIView(frame: CGRect(x: 16, y: 16.0, width: 70, height: 70))
        logoWrap.backgroundColor = UIColor.white
        logoWrap.layer.cornerRadius = 35
        logoWrap.layer.borderWidth = 4
        logoWrap.layer.borderColor = XDColor.itemLine.cgColor
        contentView.addSubview(logoWrap)
        logo = UIImageView(frame: CGRect(x: 10, y: 10, width: 50, height: 50))
        logo.layer.cornerRadius = 25
        logo.layer.masksToBounds = true
        logoWrap.addSubview(logo)
        // 中文名
        chineseName = UILabel(frame: .zero, text: "", textColor: XDColor.itemTitle, fontSize: 17, bold: true)
        contentView.addSubview(chineseName)
        chineseName.snp.makeConstraints { (make) in
            make.left.equalTo(logoWrap.snp.right).offset(12.0)
            make.right.equalTo(contentView).offset(-16)
            make.top.equalTo(contentView).offset(24.0)
        }
        // 英文名
        englishName = UILabel(text: "", textColor: XDColor.itemText, fontSize: 13)
        contentView.addSubview(englishName)
        englishName.snp.makeConstraints { (make) in
            make.left.equalTo(chineseName)
            make.right.equalTo(contentView).offset(-16)
            make.top.equalTo(chineseName.snp.bottom).offset(4.0)
        }
        // 选择人数
        selectNumLabel = UILabel(text: "", textColor: XDColor.itemText, fontSize: 13)
        contentView.addSubview(selectNumLabel)
        selectNumLabel.snp.makeConstraints { (make) in
            make.left.equalTo(chineseName)
            make.right.equalTo(contentView).offset(-16)
            make.top.equalTo(englishName.snp.bottom).offset(12.0)
        }
        // 分割线
        bottomLine = UIView(frame: CGRect(x: 16.0, y: contentView.height - XDSize.unitWidth, width: contentView.width-32.0, height: XDSize.unitWidth), color: XDColor.itemLine)
        bottomLine.autoresizingMask = [.flexibleWidth, .flexibleTopMargin]
        contentView.addSubview(bottomLine)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override static func height(for object: Any!, at indexPath: IndexPath!, tableView: UITableView!) -> CGFloat {
        return 102.0
    }
    
    override func shouldUpdate(with object: Any!) -> Bool {
        if super.shouldUpdate(with: object), let object = object as? TargetCollegeStatSchoolCellItem {
            logo.kf.setImage(with: URL(string: object.model.logo), placeholder: UIImage(named: "default_college_logo"))
            chineseName.text = object.model.chineseName
            englishName.text = object.model.englishName
            selectNumLabel.attributedText = "共有" + NSAttributedString(string: "\(object.model.selectedCount)", attributes: [NSAttributedStringKey.foregroundColor: UIColor(0x078CF1)]) + "人选择"
            bottomLine.isHidden = object.isLast
        }
        return true
    }
}
