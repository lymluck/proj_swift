//
//  CollegeSearchItem.swift
//  xxd
//
//  Created by remy on 2018/2/21.
//  Copyright © 2018年 com.smartstudy. All rights reserved.
//

import Kingfisher

class CollegeSearchItem: SSCellItem {
    
    var model: CollegeModel!
    
    override init!(attributes: [AnyHashable : Any]! = [:]) {
        super.init(attributes: attributes)
        model = CollegeModel.yy_model(with: attributes)
        model.logoURL = UIImage.OSSImageURLString(urlStr: model.logoURL, size: CGSize(width: 30, height: 30), policy: .pad)
    }
    
    override init!(cellClass: AnyClass!, userInfo: Any!) {
        super.init(cellClass: cellClass, userInfo: userInfo)
    }
    
    override func cellClass() -> AnyClass! {
        return CollegeSearchItemCell.self
    }
}

class CollegeSearchItemCell: SSTableViewCell {
    
    private var logo: UIImageView!
    private var chineseName: UILabel!
    private var englishName: UILabel!
    private var bottomLine: UIView!
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.backgroundColor = UIColor.white
        
        // logo
        let logoWrap = UIView(frame: CGRect(x: 16, y: 9, width: 46, height: 46))
        logoWrap.backgroundColor = UIColor.white
        logoWrap.layer.cornerRadius = 23
        logoWrap.layer.borderWidth = 3
        logoWrap.layer.borderColor = XDColor.itemLine.cgColor
        contentView.addSubview(logoWrap)
        logo = UIImageView(frame: CGRect(x: 8, y: 8, width: 30, height: 30))
        logo.layer.cornerRadius = 15
        logo.layer.masksToBounds = true
        logoWrap.addSubview(logo)
        
        // 中文名
        chineseName = UILabel(frame: .zero, text: "", textColor: XDColor.itemTitle, fontSize: 15, bold: true)
        contentView.addSubview(chineseName)
        chineseName.snp.makeConstraints { (make) in
            make.left.equalTo(logoWrap.snp.right).offset(9)
            make.top.equalTo(contentView).offset(16)
        }
        
        // 英文名
        englishName = UILabel(text: "", textColor: XDColor.itemText, fontSize: 13)
        contentView.addSubview(englishName)
        englishName.snp.makeConstraints { (make) in
            make.left.equalTo(logoWrap.snp.right).offset(9)
            make.top.equalTo(contentView).offset(35)
        }
        
        // 分割线
        bottomLine = UIView(frame: CGRect(x: 0, y: contentView.height - XDSize.unitWidth, width: contentView.width, height: XDSize.unitWidth), color: XDColor.itemLine)
        bottomLine.autoresizingMask = [.flexibleWidth, .flexibleTopMargin]
        contentView.addSubview(bottomLine)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override static func height(for object: Any!, at indexPath: IndexPath!, tableView: UITableView!) -> CGFloat {
        return 64
    }
    
    override func shouldUpdate(with object: Any!) -> Bool {
        if super.shouldUpdate(with: object), let object = object as? CollegeSearchItem {
            bottomLine.isHidden = object.bottomLineType == .none
            logo.kf.setImage(with: URL(string: object.model.logoURL), placeholder: UIImage(named: "default_college_logo"))
            chineseName.text = object.model.chineseName
            englishName.text = object.model.englishName
        }
        return true
    }
}

class HighschoolSearchItem: SSCellItem {
    
    var model: CollegeModel!
    
    override init!(attributes: [AnyHashable : Any]! = [:]) {
        super.init(attributes: attributes)
        model = CollegeModel.yy_model(with: attributes)
    }
    
    override init!(cellClass: AnyClass!, userInfo: Any!) {
        super.init(cellClass: cellClass, userInfo: userInfo)
    }
    
    override func cellClass() -> AnyClass! {
        return HighschoolSearchItemCell.self
    }
}

class HighschoolSearchItemCell: SSTableViewCell {
    
    private var chineseName: UILabel!
    private var englishName: UILabel!
    private var bottomLine: UIView!
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.backgroundColor = UIColor.white
        
        // 中文名
        chineseName = UILabel(frame: .zero, text: "", textColor: XDColor.itemTitle, fontSize: 15, bold: true)
        contentView.addSubview(chineseName)
        chineseName.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(16)
            make.top.equalTo(contentView).offset(16)
        }
        
        // 英文名
        englishName = UILabel(text: "", textColor: XDColor.itemText, fontSize: 13)
        contentView.addSubview(englishName)
        englishName.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(16)
            make.top.equalTo(contentView).offset(35)
        }
        
        // 分割线
        bottomLine = UIView(frame: CGRect(x: 0, y: contentView.height - XDSize.unitWidth, width: contentView.width, height: XDSize.unitWidth), color: XDColor.itemLine)
        bottomLine.autoresizingMask = [.flexibleWidth, .flexibleTopMargin]
        contentView.addSubview(bottomLine)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override static func height(for object: Any!, at indexPath: IndexPath!, tableView: UITableView!) -> CGFloat {
        return 64
    }
    
    override func shouldUpdate(with object: Any!) -> Bool {
        if super.shouldUpdate(with: object), let object = object as? HighschoolSearchItem {
            bottomLine.isHidden = object.bottomLineType == .none
            chineseName.text = object.model.chineseName
            englishName.text = object.model.englishName
        }
        return true
    }
}
