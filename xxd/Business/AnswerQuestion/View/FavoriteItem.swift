//
//  FavoriteItem.swift
//  xxd
//
//  Created by remy on 2018/1/29.
//  Copyright © 2018年 com.smartstudy. All rights reserved.
//

import Kingfisher

class FavoriteItem: SSCellItem {

    var cellHeight: CGFloat = 0
    var textHeight: CGFloat = 0
    var model: FavoriteModel!
    
    override init!(attributes: [AnyHashable : Any]! = [:]) {
        super.init(attributes: attributes)
        model = FavoriteModel.yy_model(with: attributes)
        if model.displayImage.isEmpty {
            let height = model.displayText.heightForFont(UIFont.systemFont(ofSize: 16), XDSize.screenWidth - 32, 22)
            textHeight = CGFloat.minimum(height, 66)
            // x + 47 + 17 + 10
            cellHeight = textHeight + 74;
        } else {
            // 16 + 8 + 111 + 16
            let height = model.displayText.heightForFont(UIFont.systemFont(ofSize: 16), XDSize.screenWidth - 151, 22)
            textHeight = CGFloat.minimum(height, 66)
            // 83 + 47 + 15 + 10
            cellHeight = 155;
        }
    }
    
    override init!(cellClass: AnyClass!, userInfo: Any!) {
        super.init(cellClass: cellClass, userInfo: userInfo)
    }
    
    override func cellClass() -> AnyClass! {
        return FavoriteItemCell.self
    }
}

class FavoriteItemCell: SSTableViewCell {
    
    private var titleLabel: UILabel!
    private var favoriteTime: UILabel!
    private var displayText: UILabel!
    private var displayImage: UIImageView!
    private var bottomLine: UIView!
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.backgroundColor = UIColor.white
        
        // 标题
        titleLabel = UILabel(text: "", textColor: XDColor.itemText, fontSize: 14)
        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (make) in
            make.top.left.equalTo(contentView).offset(16)
        }
        
        // 时间
        favoriteTime = UILabel(text: "", textColor: XDColor.itemText, fontSize: 12)
        contentView.addSubview(favoriteTime)
        favoriteTime.snp.makeConstraints { (make) in
            make.right.equalTo(contentView).offset(-16)
            make.top.equalTo(contentView).offset(16)
        }
        
        // 内容
        displayText = UILabel(frame: CGRect(x: 16, y: 47, width: 0, height: 0), text: "", textColor: XDColor.itemTitle, fontSize: 16)
        displayText.numberOfLines = 3
        contentView.addSubview(displayText)
        
        // 封面
        displayImage = UIImageView()
        displayImage.contentMode = .scaleAspectFill
        displayImage.layer.masksToBounds = true
        contentView.addSubview(displayImage)
        displayImage.snp.makeConstraints { (make) in
            make.top.equalTo(contentView).offset(47)
            make.right.equalTo(contentView).offset(-16)
            make.size.equalTo(CGSize(width: 110, height: 83))
        }
        
        // 分割线
        bottomLine = UIView(frame: CGRect(x: 0, y: contentView.height - 10, width: contentView.width, height: 10), color: XDColor.mainBackground)
        bottomLine.autoresizingMask = [.flexibleWidth, .flexibleTopMargin]
        contentView.addSubview(bottomLine)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override class func height(for object: Any!, at indexPath: IndexPath!, tableView: UITableView!) -> CGFloat {
        return (object as! FavoriteItem).cellHeight
    }
    
    override func shouldUpdate(with object: Any!) -> Bool {
        if super.shouldUpdate(with: object), let object = object as? FavoriteItem {
            titleLabel.text = object.model.title
            favoriteTime.text = object.model.favoriteTime
            displayText.setText(object.model.displayText, lineHeight: 22)
            displayText.height = object.textHeight
            if !object.model.displayImage.isEmpty {
                // 16 + 8 + 111 + 16
                displayText.width = XDSize.screenWidth - 151
                displayImage.isHidden = false
                displayImage.kf.setImage(with: URL(string: object.model.displayImage), placeholder: UIImage(named: "default_favorite_image"))
            } else {
                displayText.width = XDSize.screenWidth - 32
                displayImage.isHidden = true
            }
        }
        return true
    }
}
