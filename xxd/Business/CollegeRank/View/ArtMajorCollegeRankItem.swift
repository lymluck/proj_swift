//
//  ArtMajorCollegeRankItem.swift
//  xxd
//
//  Created by Lisen on 2018/7/5.
//  Copyright © 2018年 com.smartstudy. All rights reserved.
//

import UIKit

class ArtMajorCollegeRankItem: SSCellItem {
    
    var model: ArtMajorCollegeRankModel!
    override init!(attributes: [AnyHashable : Any]! = [:]) {
        super.init(attributes: attributes)
        model = ArtMajorCollegeRankModel.yy_model(with: attributes)
    }
    
    override init!(cellClass: AnyClass!, userInfo: Any!) {
        super.init(cellClass: cellClass, userInfo: userInfo)
    }
    
    override func cellClass() -> AnyClass! {
        return ArtMajorCollegeRankItemCell.self
    }
}

/// 艺术专业院校排名
class ArtMajorCollegeRankItemCell: SSTableViewCell {
    
    private lazy var rankLabel: UILabel = {
        let label: UILabel = UILabel(frame: CGRect.zero, text: "", textColor: UIColor.white, fontSize: 13.0)
        label.textAlignment = .center
        label.backgroundColor = UIColor(0x24BEE4)
        return label
    }()
    private lazy var majorLabel: UILabel = {
        let label: UILabel = UILabel(frame: CGRect.zero, text: "", textColor: XDColor.itemTitle, fontSize: 17.0, bold: true)
        label.numberOfLines = 0
        return label
    }()
    private lazy var chineseLabel: UILabel = UILabel(frame: CGRect.zero, text: "", textColor: XDColor.itemTitle, fontSize: 12.0)
    private lazy var englishLabel: UILabel = UILabel(frame: CGRect.zero, text: "", textColor: XDColor.itemText, fontSize: 13.0)
    private lazy var separatorView: UIView = UIView(frame: CGRect.zero, color: XDColor.itemLine)
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        initContentViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func shouldUpdate(with object: Any!) -> Bool {
        if super.shouldUpdate(with: object), let item = object as? ArtMajorCollegeRankItem {
            rankLabel.text = "\(item.model.rank)"
            majorLabel.text = item.model.majorName
            chineseLabel.text = item.model.schoolChineseName
            englishLabel.text = item.model.schoolEnglishName
        }
        return true
    }
    
    override static func height(for object: Any!, at indexPath: IndexPath!, tableView: UITableView!) -> CGFloat {
        if let item = object as? ArtMajorCollegeRankItem {
//            let majorHeight: CGFloat = item.model.majorName.labelHeight(maxWidth: XDSize.screenWidth-64.0, font: UIFont.boldSystemFont(ofSize: 17.0), numberOfLines: 2)
            let majorHeight: CGFloat = item.model.majorName.heightForFont(UIFont.boldSystemFont(ofSize: 17.0), XDSize.screenWidth-64.0)
            return majorHeight + 81.0
        }
        return 98.0
    }
    
    private func initContentViews() {
        contentView.backgroundColor = UIColor.white
        contentView.addSubview(rankLabel)
        rankLabel.snp.makeConstraints { (make) in
            make.top.equalTo(19.0)
            make.left.equalTo(16.0)
            make.width.height.equalTo(20.0)
        }
        contentView.addSubview(majorLabel)
        majorLabel.snp.makeConstraints { (make) in
            make.top.equalTo(19.0)
            make.left.equalTo(rankLabel.snp.right).offset(12.0)
            make.right.equalTo(-16.0)
        }
        contentView.addSubview(chineseLabel)
        chineseLabel.snp.makeConstraints { (make) in
            make.left.equalTo(majorLabel)
            make.top.equalTo(majorLabel.snp.bottom).offset(12.0)
            make.right.equalTo(-16.0)
        }
        contentView.addSubview(englishLabel)
        englishLabel.snp.makeConstraints { (make) in
            make.left.equalTo(majorLabel)
            make.top.equalTo(chineseLabel.snp.bottom).offset(4.0)
            make.right.equalTo(-16.0)
        }
        contentView.addSubview(separatorView)
        separatorView.snp.makeConstraints { (make) in
            make.left.bottom.right.equalToSuperview()
            make.height.equalTo(1.0)
        }
    }
    
}
