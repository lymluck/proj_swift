//
//  MajorCountryRankItem.swift
//  xxd
//
//  Created by Lisen on 2018/7/3.
//  Copyright © 2018年 com.smartstudy. All rights reserved.
//

import UIKit

class MajorCountryRankItem: SSCellItem {
    var model: RankModel!
    
    override init!(attributes: [AnyHashable : Any]! = [:]) {
        super.init(attributes: attributes)
        model = RankModel.yy_model(with: attributes)
    }
    
    override init!(cellClass: AnyClass!, userInfo: Any!) {
        super.init(cellClass: cellClass, userInfo: userInfo)
    }
    
    override func cellClass() -> AnyClass! {
        return MajorCountryRankItemCell.self
    }
}

/// 新版专业排名列表
class MajorCountryRankItemCell: SSTableViewCell {
    var ranking: String? {
        didSet {
            rankLabel.text = ranking
        }
    }
    private lazy var rankLabel: UILabel = UILabel(frame: CGRect.zero, text: "", textColor: XDColor.itemTitle, fontSize: 16.0)
    private lazy var separatorView: UIView = UIView(frame: CGRect.zero, color: XDColor.itemLine)
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.backgroundColor = UIColor.white
        contentView.addSubview(rankLabel)
        rankLabel.snp.makeConstraints { (make) in
            make.left.equalTo(16.0)
            make.right.equalTo(-16.0)
            make.centerY.equalToSuperview()
        }
        contentView.addSubview(separatorView)
        separatorView.snp.makeConstraints { (make) in
            make.left.bottom.right.equalToSuperview()
            make.height.equalTo(0.5)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override static func height(for object: Any!, at indexPath: IndexPath!, tableView: UITableView!) -> CGFloat {
        return 64.0
    }
    
    override func shouldUpdate(with object: Any!) -> Bool {
        if super.shouldUpdate(with: object), let item = object as? MajorCountryRankItem {
            rankLabel.text = item.model.name
        }
        return true
    }
    
}
