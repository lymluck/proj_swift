//
//  RankCategoryItem.swift
//  xxd
//
//  Created by remy on 2018/4/18.
//  Copyright © 2018年 com.smartstudy. All rights reserved.
//

class RankCategoryItem: SSCellItem {
    
    var model: RankModel!
    
    override init!(attributes: [AnyHashable : Any]! = [:]) {
        super.init(attributes: attributes)
        model = RankModel.yy_model(with: attributes)
    }
    
    override init!(cellClass: AnyClass!, userInfo: Any!) {
        super.init(cellClass: cellClass, userInfo: userInfo)
    }
    
    override func cellClass() -> AnyClass! {
        return RankCategoryItemCell.self
    }
}

class RankCategoryItemCell: SSTableViewCell {
    
    private var titleLabel: UILabel!
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.backgroundColor = UIColor.white
        
        // 标题
        titleLabel = UILabel(frame: .null, text: "", textColor: XDColor.itemTitle, fontSize: 15)
        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(contentView)
            make.left.equalTo(contentView).offset(16)
            make.right.lessThanOrEqualToSuperview().offset(-41)
        }
        
        // 箭头
        let arrowImageView = UIImageView(image: UIImage(named: "item_right_arrow"))
        contentView.addSubview(arrowImageView)
        arrowImageView.snp.makeConstraints { (make) in
            make.right.equalTo(contentView).offset(-16)
            make.centerY.equalTo(contentView)
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
        return 64
    }
    
    override func shouldUpdate(with object: Any!) -> Bool {
        if super.shouldUpdate(with: object), let object = object as? RankCategoryItem {
            titleLabel.text = object.model.name
        }
        return true
    }
}
