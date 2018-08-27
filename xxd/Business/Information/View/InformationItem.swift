//
//  InformationItem.swift
//  xxd
//
//  Created by remy on 2018/1/18.
//  Copyright © 2018年 com.smartstudy. All rights reserved.
//

import SnapKit
import Kingfisher

// 资讯列表 item
class InformationItem: SSCellItem {
    
    var cellHeight: CGFloat = 0
    var model: InformationModel! {
        didSet {
            initData()
        }
    }
    
    override init!(attributes: [AnyHashable : Any]! = [:]) {
        super.init(attributes: attributes)
        bottomLineType = .right

        if attributes.count > 0 {
            model = InformationModel.yy_model(with: attributes)
            initData()
        }
    }
    
    override init!(cellClass: AnyClass!, userInfo: Any!) {
        super.init(cellClass: cellClass, userInfo: userInfo)
    }
    
    override func cellClass() -> AnyClass! {
        return model.type == .normal ? InformationItemCell.self : InformationItemCoverCell.self
    }
    
    private func initData() {
        if model.type == .normal {
            let multiline = model.title.widthForFont(UIFont.boldSystemFont(ofSize: 16)).rounded(.up) > (XDSize.screenWidth - 32).rounded(.up)
            cellHeight = multiline ? 106 : 84
        } else {
            cellHeight = 116
        }
    }
}

// 资讯列表 cell
class InformationItemCell: SSTableViewCell {
    
    var titleLabel: UILabel!
    private var tagLabel: UILabel!
    private var visitCountLabel: UILabel!
    private var visitImageView: UIImageView!
    private var bottomLine: UIView!
    private var centerBottomLine: UIView!
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = UIColor.white
        
        // 标题
        titleLabel = UILabel(frame: .null, text: "", textColor: XDColor.itemTitle, fontSize: 16, bold: true)
        titleLabel.numberOfLines = 2
        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (make) in
            make.top.left.equalTo(contentView).offset(16)
            make.right.equalTo(contentView).offset(-16)
        }
        
        // 分割线
        bottomLine = UIView(frame: .null, color: XDColor.itemLine)
        contentView.addSubview(bottomLine)
        bottomLine.snp.makeConstraints { (make) in
            make.left.equalTo(contentView).offset(16)
            make.right.bottom.equalTo(contentView)
            make.height.equalTo(XDSize.unitWidth)
        }
        centerBottomLine = UIView(frame: .null, color: XDColor.itemLine)
        contentView.addSubview(centerBottomLine)
        centerBottomLine.snp.makeConstraints { (make) in
            make.left.equalTo(contentView).offset(16)
            make.right.equalTo(contentView).offset(-16)
            make.bottom.equalTo(contentView)
            make.height.equalTo(XDSize.unitWidth)
        }
        
        // 标签
        tagLabel = UILabel(text: "", textColor: XDColor.main, fontSize: 10)
        tagLabel.layer.cornerRadius = 7.5
        tagLabel.layer.borderWidth = XDSize.unitWidth
        tagLabel.layer.borderColor = XDColor.main.cgColor
        contentView.addSubview(tagLabel)
        tagLabel.snp.makeConstraints { (make) in
            make.left.equalTo(contentView).offset(16)
            make.bottom.equalTo(contentView).offset(-16)
            make.height.equalTo(15)
        }
        
        // 访问人数
        visitImageView = UIImageView(image: UIImage(named: "information_visit_count"))
        contentView.addSubview(visitImageView)
        visitImageView.snp.makeConstraints { (make) in
            make.centerY.equalTo(tagLabel)
            make.left.equalTo(tagLabel.snp.right).offset(8)
        }
        visitCountLabel = UILabel(text: "", textColor: XDColor.itemText, fontSize: 11)
        contentView.addSubview(visitCountLabel)
        visitCountLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(visitImageView)
            make.left.equalTo(visitImageView.snp.right).offset(2)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override static func height(for object: Any!, at indexPath: IndexPath!, tableView: UITableView!) -> CGFloat {
        return (object as! InformationItem).cellHeight
    }
    
    override func shouldUpdate(with object: Any!) -> Bool {
        if super.shouldUpdate(with: object), let object = object as? InformationItem {
            titleLabel.setText(object.model.title, lineHeight: 22)
            tagLabel.text = object.model.tagName.isEmpty ? "" : "  \(object.model.tagName)  "
            visitCountLabel.text = "\(object.model.visitCount)"
            centerBottomLine.isHidden = true
            bottomLine.isHidden = true
            switch object.bottomLineType {
            case .right:
                bottomLine.isHidden = false
            case .center:
                centerBottomLine.isHidden = false
            default:
                break
            }
        }
        return true
    }
}

class InformationItemCoverCell: InformationItemCell {
    
    private var coverView: UIImageView!
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        // 封面
        coverView = UIImageView()
        coverView.contentMode = .scaleAspectFill
        coverView.layer.masksToBounds = true
        contentView.addSubview(coverView)
        coverView.snp.makeConstraints { (make) in
            make.right.equalTo(contentView).offset(-16)
            make.top.equalTo(contentView).offset(16)
            make.size.equalTo(CGSize(width: 114, height: 85))
        }
        
        // 标题
        titleLabel.snp.remakeConstraints { (make) in
            make.top.left.equalTo(contentView).offset(16)
            make.right.equalTo(coverView.snp.left).offset(-16)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func shouldUpdate(with object: Any!) -> Bool {
        if super.shouldUpdate(with: object), let object = object as? InformationItem {
            coverView.kf.setImage(with: URL(string: object.model.coverURL), placeholder: UIImage.getPlaceHolderImage(size: CGSize(width: 114, height: 85)))
        }
        return true
    }
}
