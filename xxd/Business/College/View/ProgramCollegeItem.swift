//
//  ProgramCollegeItem.swift
//  xxd
//
//  Created by remy on 2018/2/14.
//  Copyright © 2018年 com.smartstudy. All rights reserved.
//

import Kingfisher

protocol ProgramCollegeItemDelegate: class {
    
    func programCollegeItemDidSelected(item: ProgramCollegeItem)
}

class ProgramCollegeItem: SSCellItem {
    
    var model: ProgramCollegeModel!
    var cellHeight: CGFloat = 0
    weak var delegate: ProgramCollegeItemDelegate?
    
    override init!(attributes: [AnyHashable : Any]! = [:]) {
        super.init(attributes: attributes)
        model = ProgramCollegeModel.yy_model(with: attributes)
        model.logoURL = UIImage.OSSImageURLString(urlStr: model.logoURL, size: CGSize(width: 60, height: 60), policy: .pad)
        model.majorEnglishName = String(format: "major_english_name".localized, model.majorEnglishName)
        cellHeight = model.majorEnglishName.heightForFont(UIFont.systemFont(ofSize: 13), XDSize.screenWidth - 160) + 122
    }
    
    override init!(cellClass: AnyClass!, userInfo: Any!) {
        super.init(cellClass: cellClass, userInfo: userInfo)
    }
    
    override func cellClass() -> AnyClass! {
        return ProgramCollegeItemCell.self
    }
}

class ProgramCollegeItemCell: SSTableViewCell {
    
    private var logo: UIImageView!
    private var chineseName: UILabel!
    private var englishName: UILabel!
    private var localRank: UILabel!
    private var majorChineseName: UILabel!
    private var majorEnglishName: UILabel!
    private var addToMyTarget: UIImageView!
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.backgroundColor = UIColor.white
        
        // logo
        let logoWrap = UIView(frame: CGRect(x: 16, y: 16, width: 70, height: 70))
        logoWrap.backgroundColor = UIColor.white
        logoWrap.layer.cornerRadius = 35
        logoWrap.layer.borderWidth = 5
        logoWrap.layer.borderColor = XDColor.itemLine.cgColor
        contentView.addSubview(logoWrap)
        logo = UIImageView(frame: CGRect(x: 5, y: 5, width: 60, height: 60))
        logo.layer.cornerRadius = 30
        logo.layer.masksToBounds = true
        logoWrap.addSubview(logo)
        
        // 中文名
        chineseName = UILabel(frame: .zero, text: "", textColor: XDColor.itemTitle, fontSize: 17, bold: true)
        contentView.addSubview(chineseName)
        chineseName.snp.makeConstraints { (make) in
            make.left.equalTo(contentView).offset(100)
            make.right.equalTo(contentView).offset(-60)
            make.top.equalTo(contentView).offset(16)
        }
        
        // 英文名
        englishName = UILabel(text: "", textColor: XDColor.itemText, fontSize: 12)
        contentView.addSubview(englishName)
        englishName.snp.makeConstraints { (make) in
            make.left.equalTo(contentView).offset(100)
            make.right.equalTo(contentView).offset(-60)
            make.top.equalTo(contentView).offset(40)
        }
        
        // 排名
        localRank = UILabel(text: "", textColor: XDColor.main, fontSize: 13)
        contentView.addSubview(localRank)
        localRank.snp.makeConstraints { (make) in
            make.left.equalTo(contentView).offset(100)
            make.right.equalTo(contentView).offset(-60)
            make.top.equalTo(contentView).offset(62)
        }
        
        // 专业中文名
        majorChineseName = UILabel(frame: .zero, text: "", textColor: XDColor.itemText, fontSize: 13)
        contentView.addSubview(majorChineseName)
        majorChineseName.snp.makeConstraints { (make) in
            make.left.equalTo(contentView).offset(100)
            make.right.equalTo(contentView).offset(-60)
            make.top.equalTo(contentView).offset(88)
        }
        
        // 专业英文名
        majorEnglishName = UILabel(text: "", textColor: XDColor.itemText, fontSize: 13)
        majorEnglishName.numberOfLines = 0
        contentView.addSubview(majorEnglishName)
        majorEnglishName.snp.makeConstraints { (make) in
            make.left.equalTo(contentView).offset(100)
            make.right.equalTo(contentView).offset(-60)
            make.top.equalTo(contentView).offset(106)
        }
        
        // 添加/删除选校
        addToMyTarget = UIImageView()
        addToMyTarget.contentMode = .center
        addToMyTarget.isUserInteractionEnabled = true
        contentView.addSubview(addToMyTarget)
        addToMyTarget.snp.makeConstraints { (make) in
            make.top.equalTo(contentView).offset(21)
            make.right.equalTo(contentView)
            make.size.equalTo(CGSize(width: 60, height: 60))
        }
        addToMyTarget.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(addMyTarget(gestureRecognizer:))))
        
        // 分割线
        let bottomLine = UIView(frame: CGRect(x: 0, y: contentView.height - XDSize.unitWidth, width: contentView.width, height: XDSize.unitWidth), color: XDColor.itemLine)
        bottomLine.autoresizingMask = [.flexibleWidth, .flexibleTopMargin]
        contentView.addSubview(bottomLine)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override static func height(for object: Any!, at indexPath: IndexPath!, tableView: UITableView!) -> CGFloat {
        return (object as! ProgramCollegeItem).cellHeight
    }
    
    override func shouldUpdate(with object: Any!) -> Bool {
        if super.shouldUpdate(with: object), let object = object as? ProgramCollegeItem {
            logo.kf.setImage(with: URL(string: object.model.logoURL), placeholder: UIImage(named: "default_college_logo"))
            chineseName.text = object.model.chineseName
            englishName.text = object.model.englishName
            localRank.text = String(format: "college_local_rank".localized, object.model.localRank)
            majorChineseName.text = String(format: "major_chinese_name".localized, object.model.majorChineseName)
            majorEnglishName.text = object.model.majorEnglishName
            addToMyTarget.image = UIImage(named: object.model.isSelected ? "is_my_target" : "add_my_target")
        }
        return true
    }
    
    //MARK:- Action
    @objc func addMyTarget(gestureRecognizer: UIGestureRecognizer) {
        let item = self.item as! ProgramCollegeItem
        item.delegate?.programCollegeItemDidSelected(item: item)
    }
}
