//
//  SpecialItem.swift
//  xxd
//
//  Created by remy on 2018/2/22.
//  Copyright © 2018年 com.smartstudy. All rights reserved.
//

class SpecialItem: SSCellItem {
    
    var model: SpecialModel!
    
    override init!(attributes: [AnyHashable : Any]! = [:]) {
        super.init(attributes: attributes)
        model = SpecialModel.yy_model(with: attributes)
    }
    
    override init!(cellClass: AnyClass!, userInfo: Any!) {
        super.init(cellClass: cellClass, userInfo: userInfo)
    }
    
    override func cellClass() -> AnyClass! {
        return SpecialItemCell.self
    }
}

class SpecialItemCell: SSTableViewCell {
    
    private var coverView: UIImageView!
    private var visitCountLabel: UILabel!
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        // 封面
        coverView = UIImageView(frame: CGRect(x: 16, y: 20, width: XDSize.screenWidth - 32, height: 195))
        coverView.layer.cornerRadius = 3
        coverView.layer.masksToBounds = true
        contentView.addSubview(coverView)
        let layer = CAGradientLayer()
        layer.frame = CGRect(x: 0, y: coverView.height * 0.5, width: coverView.width, height: coverView.height * 0.5)
        layer.colors = [UIColor.black.withAlphaComponent(0).cgColor, UIColor.black.withAlphaComponent(0.2).cgColor]
        coverView.layer.addSublayer(layer)
        
        // 访问人数
        visitCountLabel = UILabel(text: "", textColor: UIColor.white, fontSize: 11)
        contentView.addSubview(visitCountLabel)
        visitCountLabel.snp.makeConstraints { (make) in
            make.right.equalTo(coverView).offset(-12)
            make.bottom.equalTo(coverView).offset(-10)
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
        return 235
    }
    
    override func shouldUpdate(with object: Any!) -> Bool {
        if super.shouldUpdate(with: object), let object = object as? SpecialItem {
            coverView.setAutoOSSImage(urlStr: object.model.imageURL)
            visitCountLabel.text = "\(object.model.visitCount)人看过"
        }
        return true
    }
}
