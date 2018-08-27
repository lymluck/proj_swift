//
//  RankCollegeItem.swift
//  xxd
//
//  Created by remy on 2018/1/24.
//  Copyright © 2018年 com.smartstudy. All rights reserved.
//

class RankCollegeItem: SSCellItem {
    
    var model: RankCollegeModel!
    
    override init!(attributes: [AnyHashable : Any]! = [:]) {
        super.init(attributes: attributes)
        model = RankCollegeModel.yy_model(with: attributes)
    }
    
    override init!(cellClass: AnyClass!, userInfo: Any!) {
        super.init(cellClass: cellClass, userInfo: userInfo)
    }
    
    override func cellClass() -> AnyClass! {
        return RankCollegeItemCell.self
    }
}

class RankCollegeItemCell: SSTableViewCell {
    
    private var rankLabel: UILabel!
    private var titleLabel: UILabel!
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.backgroundColor = UIColor.white
        selectionStyle = .none
        
        let rankWidth: CGFloat = 60
        
        // 排名
        rankLabel = UILabel(frame: CGRect(x: 0, y: 19, width: rankWidth, height: 20), text: "", textColor: XDColor.itemTitle, fontSize: 17)
        rankLabel.textAlignment = .center
        contentView.addSubview(rankLabel)
        let label = UILabel(frame: CGRect(x: 0, y: rankLabel.bottom, width: rankWidth, height: 12), text: "#", textColor: XDColor.itemText, fontSize: 10)!
        label.textAlignment = .center
        contentView.addSubview(label)
        
        // 标题
        titleLabel = UILabel(frame: .null, text: "", textColor: XDColor.itemTitle, fontSize: 17)
        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(contentView)
            make.left.equalTo(contentView).offset(rankWidth)
            make.right.lessThanOrEqualToSuperview().offset(-16)
        }
        
        // 分割线
        let bottomLine = UIView(frame: CGRect(x: 0, y: contentView.height - XDSize.unitWidth, width: contentView.width, height: XDSize.unitWidth), color: XDColor.itemLine)
        bottomLine.autoresizingMask = [.flexibleWidth, .flexibleTopMargin]
        contentView.addSubview(bottomLine)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override static func height(for object: Any!, at indexPath: IndexPath!, tableView: UITableView!) -> CGFloat {
        return 66
    }
    
    override func shouldUpdate(with object: Any!) -> Bool {
        if super.shouldUpdate(with: object), let object = object as? RankCollegeItem {
            rankLabel.text = object.model.rank.isEmpty ? "N/A" : object.model.rank
            titleLabel.text = object.model.chineseName
            if let _ = object.model.rank.range(of: "-") {
                rankLabel.font = UIFont.systemFont(ofSize: 12)
            } else {
                rankLabel.font = UIFont.systemFont(ofSize: 17)
            }
        }
        return true
    }
}
