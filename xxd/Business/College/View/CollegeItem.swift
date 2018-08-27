//
//  CollegeItem.swift
//  xxd
//
//  Created by remy on 2018/2/13.
//  Copyright © 2018年 com.smartstudy. All rights reserved.
//

import Kingfisher

class CollegeItem: SSCellItem {
    
    var model: CollegeModel!
    var isRankHidden: Bool = true
    var rankBackgroundColor: UIColor = UIColor.white
    
    override init!(attributes: [AnyHashable : Any]! = [:]) {
        super.init(attributes: attributes)
        model = CollegeModel.yy_model(with: attributes)
        model.logoURL = UIImage.OSSImageURLString(urlStr: model.logoURL, size: CGSize(width: 60, height: 60), policy: .pad)
        if model.acceptRate.isEmpty {
            model.acceptRate = "accept_rate_empty".localized
        }
    }
    
    override init!(cellClass: AnyClass!, userInfo: Any!) {
        super.init(cellClass: cellClass, userInfo: userInfo)
    }
    
    override func cellClass() -> AnyClass! {
        return CollegeItemCell.self
    }
}

class CollegeItemCell: SSTableViewCell {

    private var logo: UIImageView!
    private var chineseName: UILabel!
    private var englishName: UILabel!
    private var location: UILabel!
    private var acceptRate: UILabel!
    private var rankLabel: UILabel!
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.backgroundColor = UIColor.white
        
        // logo
        let logoWrap = UIView(frame: CGRect(x: 16, y: 20, width: 70, height: 70))
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
            make.left.equalTo(contentView).offset(100)
            make.right.equalTo(contentView).offset(-41.0)
            make.top.equalTo(contentView).offset(16)
        }
        
        // 英文名
        englishName = UILabel(text: "", textColor: XDColor.itemText, fontSize: 13)
        contentView.addSubview(englishName)
        englishName.snp.makeConstraints { (make) in
            make.left.equalTo(contentView).offset(100)
            make.right.equalTo(contentView).offset(-41.0)
            make.top.equalTo(chineseName.snp.bottom).offset(3)
        }
        
        // 位置
        location = UILabel(text: "", textColor: XDColor.itemText, fontSize: 13)
        contentView.addSubview(location)
        location.snp.makeConstraints { (make) in
            make.left.equalTo(contentView).offset(100)
            make.right.equalTo(contentView).offset(-16)
            make.top.equalTo(englishName.snp.bottom).offset(3)
        }
        
        // 录取率
        acceptRate = UILabel(text: "", textColor: XDColor.main, fontSize: 13)
        contentView.addSubview(acceptRate)
        acceptRate.snp.makeConstraints { (make) in
            make.left.equalTo(contentView).offset(100)
            make.right.equalTo(contentView).offset(-16)
            make.top.equalTo(location.snp.bottom).offset(9)
        }
        
        // 排名
        rankLabel = UILabel(text: "", textColor: UIColor.white, fontSize: 11.0)
        rankLabel.textAlignment = .center
        contentView.addSubview(rankLabel)
        rankLabel.snp.makeConstraints { (make) in
            make.top.equalTo(chineseName).offset(2.0)
            make.right.equalToSuperview()
            make.width.equalTo(36.0)
            make.height.equalTo(18.0)
        }
        
        // 分割线
        let bottomLine = UIView(frame: CGRect(x: 0, y: contentView.height - XDSize.unitWidth, width: contentView.width, height: XDSize.unitWidth), color: XDColor.itemLine)
        bottomLine.autoresizingMask = [.flexibleWidth, .flexibleTopMargin]
        contentView.addSubview(bottomLine)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) { }
    override func setSelected(_ selected: Bool, animated: Bool) { }
    
    override static func height(for object: Any!, at indexPath: IndexPath!, tableView: UITableView!) -> CGFloat {
        return 110
    }
    
    override func shouldUpdate(with object: Any!) -> Bool {
        if super.shouldUpdate(with: object), let object = object as? CollegeItem {
            rankLabel.isHidden = object.isRankHidden
            rankLabel.backgroundColor = object.rankBackgroundColor
            rankLabel.text = "\(object.model.orderRank)"
            logo.kf.setImage(with: URL(string: object.model.logoURL), placeholder: UIImage(named: "default_college_logo"))
            chineseName.text = object.model.chineseName
            englishName.text = object.model.englishName
            let locationText = object.model.cityName.isEmpty ? object.model.provinceName : "\(object.model.provinceName)-\(object.model.cityName)"
            location.text = locationText
            acceptRate.text = "\("accept_rate".localized)：\(object.model.acceptRate)"
        }
        return true
    }
}
