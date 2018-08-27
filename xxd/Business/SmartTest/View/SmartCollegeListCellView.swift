//
//  SmartCollegeListCellView.swift
//  xxd
//
//  Created by remy on 2018/2/8.
//  Copyright © 2018年 com.smartstudy. All rights reserved.
//

import Kingfisher

private let kCellHeight: CGFloat = 110

class SmartCollegeListCellView: UITableViewCell {
    
    private var logo: UIImageView!
    private var chineseName: UILabel!
    private var englishName: UILabel!
    private var acceptRate: UILabel!
    private var localRank: UILabel!
    var stageView: UIView!
    var addToMyTarget: UIImageView!
    var model: SmartCollegeModel! {
        didSet {
            logo.kf.setImage(with: URL(string: model.logoURL), placeholder: UIImage(named: "default_college_logo"))
            chineseName.text = model.chineseName
            englishName.text = model.englishName
            acceptRate.text = "\("accept_rate".localized)：\(model.acceptRate)"
            localRank.text = String(format: "college_local_rank".localized, model.localRank.isEmpty ? "accept_rate_empty".localized : model.localRank)
            addToMyTarget.image = UIImage(named: model.isSelected ? "is_my_target" : "add_my_target")
        }
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.backgroundColor = UIColor.white
        
        // 点击区域
        stageView = UIView(frame: CGRect(x: 0, y: 0, width: XDSize.screenWidth, height: kCellHeight))
        contentView.addSubview(stageView)
        
        // logo
        let logoWrap = UIView(frame: CGRect(x: 16, y: 20, width: 70, height: 70))
        logoWrap.backgroundColor = UIColor.white
        logoWrap.layer.cornerRadius = 35
        logoWrap.layer.borderWidth = 5
        logoWrap.layer.borderColor = XDColor.itemLine.cgColor
        stageView.addSubview(logoWrap)
        logo = UIImageView(frame: CGRect(x: 5, y: 5, width: 60, height: 60))
        logo.layer.cornerRadius = 30
        logo.layer.masksToBounds = true
        logoWrap.addSubview(logo)
        
        // 中文名
        chineseName = UILabel(frame: .zero, text: "", textColor: XDColor.itemTitle, fontSize: 17, bold: true)
        stageView.addSubview(chineseName)
        chineseName.snp.makeConstraints { (make) in
            make.left.equalTo(stageView).offset(100)
            make.right.equalTo(stageView).offset(-60)
            make.top.equalTo(stageView).offset(15)
        }
        
        // 英文名
        englishName = UILabel(text: "", textColor: XDColor.itemText, fontSize: 13)
        stageView.addSubview(englishName)
        englishName.snp.makeConstraints { (make) in
            make.left.right.equalTo(chineseName)
            make.top.equalTo(chineseName.snp.bottom).offset(2)
        }
        
        // 录取率
        acceptRate = UILabel(text: "", textColor: XDColor.itemText, fontSize: 13)
        stageView.addSubview(acceptRate)
        acceptRate.snp.makeConstraints { (make) in
            make.left.right.equalTo(chineseName)
            make.top.equalTo(englishName.snp.bottom).offset(8)
        }
        
        // 国内排名
        localRank = UILabel(text: "", textColor: XDColor.main, fontSize: 13)
        stageView.addSubview(localRank)
        localRank.snp.makeConstraints { (make) in
            make.left.right.equalTo(chineseName)
            make.top.equalTo(acceptRate.snp.bottom).offset(2)
        }
        
        // 添加/删除选校
        addToMyTarget = UIImageView()
        addToMyTarget.contentMode = .center
        addToMyTarget.isUserInteractionEnabled = true
        contentView.addSubview(addToMyTarget)
        addToMyTarget.snp.makeConstraints { (make) in
            make.right.centerY.equalTo(contentView)
            make.size.equalTo(CGSize(width: 60, height: 60))
        }
        
        // 分割线
        let bottomLine = UIView(frame: CGRect(x: 0, y: contentView.height - XDSize.unitWidth, width: contentView.width, height: XDSize.unitWidth), color: XDColor.itemLine)
        bottomLine.autoresizingMask = [.flexibleWidth, .flexibleTopMargin]
        contentView.addSubview(bottomLine)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
