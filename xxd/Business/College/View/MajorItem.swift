//
//  MajorItem.swift
//  xxd
//
//  Created by remy on 2018/2/14.
//  Copyright © 2018年 com.smartstudy. All rights reserved.
//

class MajorItem: SSCellItem {
    
    var model: MajorModel!
    var whiteBGColor = true
    
    override init!(attributes: [AnyHashable : Any]! = [:]) {
        super.init(attributes: attributes)
        model = MajorModel.yy_model(with: attributes)
    }
    
    override init!(cellClass: AnyClass!, userInfo: Any!) {
        super.init(cellClass: cellClass, userInfo: userInfo)
    }
    
    override func cellClass() -> AnyClass! {
        return MajorItemCell.self
    }
}

class MajorItemCell: SSTableViewCell {
    
    private var titleLabel: UILabel!
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.backgroundColor = UIColor.white
        
        // 标题
        titleLabel = UILabel(frame: .null, text: "", textColor: UIColor(0x58646E), fontSize: 15)
        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(contentView)
            make.left.equalTo(contentView).offset(24)
            make.right.lessThanOrEqualToSuperview().offset(-24)
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
        return 56
    }
    
    override func shouldUpdate(with object: Any!) -> Bool {
        if super.shouldUpdate(with: object), let object = object as? MajorItem {
            titleLabel.text = object.model.name
            contentView.backgroundColor = object.whiteBGColor ? UIColor.white : XDColor.mainBackground
        }
        return true
    }
}
