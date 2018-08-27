//
//  GpaDescItem.swift
//  xxd
//
//  Created by remy on 2018/1/30.
//  Copyright © 2018年 com.smartstudy. All rights reserved.
//

class GpaDescItem: SSCellItem {
    
    var model: GpaDescModel!
    
    override init!(attributes: [AnyHashable : Any]! = [:]) {
        super.init(attributes: attributes)
        model = GpaDescModel.yy_model(with: attributes)
    }
    
    override init!(cellClass: AnyClass!, userInfo: Any!) {
        super.init(cellClass: cellClass, userInfo: userInfo)
    }
    
    override func cellClass() -> AnyClass! {
        return GpaDescItemCell.self
    }
}

class GpaDescItemCell: SSTableViewCell {
    
    private var titleLabel: UILabel!
    private var formulaLabel: UILabel!
    private var formulaImageView: UIImageView!
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.backgroundColor = UIColor.white
        
        // 标题
        titleLabel = UILabel(text: "", textColor: UIColor(0x58646E), fontSize: 15)
        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (make) in
            make.left.equalTo(contentView).offset(24)
            make.top.equalTo(contentView).offset(20)
        }
        
        // 算法公式
        formulaLabel = UILabel(text: "", textColor: XDColor.main, fontSize: 15)
        contentView.addSubview(formulaLabel)
        formulaLabel.snp.makeConstraints { (make) in
            make.left.equalTo(titleLabel)
            make.top.equalTo(titleLabel.snp.bottom).offset(4)
        }
        
        // 算法说明
        formulaImageView = UIImageView()
        formulaImageView.contentMode = .scaleAspectFit
        contentView.addSubview(formulaImageView)
        formulaImageView.snp.makeConstraints { (make) in
            make.left.equalTo(contentView).offset(16)
            make.top.equalTo(formulaLabel.snp.bottom)
            make.bottom.equalTo(contentView).offset(-20)
            make.width.equalTo(XDSize.screenWidth - 32)
            make.height.equalTo(0)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func shouldUpdate(with object: Any!) -> Bool {
        if super.shouldUpdate(with: object), let object = object as? GpaDescItem {
            titleLabel.text = "\(object.model.name)计算公式："
            formulaLabel.text = object.model.formula
            if object.model.scoreTableImageUrl.isEmpty {
                formulaImageView.snp.updateConstraints({ (make) in
                    make.top.equalTo(formulaLabel.snp.bottom)
                    make.height.equalTo(0)
                })
            } else {
                let height = CGFloat((object.model.scoreTable.count + 2) * 31) * XDSize.screenWidth / 375
                formulaImageView.setOSSImage(urlStr: object.model.scoreTableImageUrl, size: CGSize(width: XDSize.screenWidth - 32, height: height), policy: .fit)
                formulaImageView.snp.updateConstraints({ (make) in
                    make.top.equalTo(formulaLabel.snp.bottom).offset(12)
                    make.height.equalTo(height)
                })
            }
        }
        return true
    }
}
