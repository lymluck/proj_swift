//
//  HighSchoolCategoryItemCell.swift
//  xxd
//
//  Created by Lisen on 2018/4/4.
//  Copyright © 2018年 com.smartstudy. All rights reserved.
//

import UIKit

// MARK: 美高分类Cell
class HighSchoolCategoryItem: SSCellItem {
    
    var model: HighSchoolCategoryModel!
    
    override init!(attributes: [AnyHashable : Any]! = [:]) {
        super.init(attributes: attributes)
        model = HighSchoolCategoryModel.yy_model(with: attributes)
    }
    
    override init!(cellClass: AnyClass!, userInfo: Any!) {
        super.init(cellClass: cellClass, userInfo: userInfo)
    }
    
    override func cellClass() -> AnyClass! {
        return HighSchoolCategoryItemCell.self
    }
}

class HighSchoolCategoryItemCell: SSTableViewCell {

    // MARK: properties
    var title: String? {
        didSet {
            lbCategory.text = title
        }
    }
    
    private lazy var leftView: UIView = {
        let view: UIView = UIView(frame: CGRect.zero, color: UIColor.init(hexWithLong: 0x078CF1))
        return view
    }()
    
    private lazy var lbCategory: UILabel = {
        let label: UILabel = UILabel(frame: CGRect.zero)
        label.font = UIFont.systemFont(ofSize: 16.0)
        return label
    }()
    
    private lazy var imgArrow: UIImageView = {
        let image: UIImageView = UIImageView(frame: CGRect.zero, image: UIImage(named: "item_right_arrow"))
        return image
    }()
    
    // MARK: life cycle
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        initContentViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(false, animated: animated)
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(false, animated: animated)
    }
    
    override static func height(for object: Any!, at indexPath: IndexPath!, tableView: UITableView!) -> CGFloat {
        return 64.0
    }
    
    override func shouldUpdate(with object: Any!) -> Bool {
        if super.shouldUpdate(with: object) {
            if let item = object as? HighSchoolCategoryItem {
                lbCategory.text = "\(item.model.year)" + "\(item.model.org)" + item.model.title
            }
        }
        
        return true
    }
    
    // MARK: private methods
    private func initContentViews() {
        contentView.backgroundColor = UIColor.white
        contentView.addSubview(leftView)
        contentView.addSubview(imgArrow)
        contentView.addSubview(lbCategory)
        leftView.snp.makeConstraints { (make) in
            make.left.top.bottom.equalTo(self.contentView)
            make.width.equalTo(4.0)
        }
        imgArrow.snp.makeConstraints { (make) in
            make.centerY.equalTo(contentView)
            make.right.equalTo(contentView).offset(-16.0)
        }
        lbCategory.snp.makeConstraints { (make) in
            make.left.equalTo(contentView).offset(20.0)
            make.top.bottom.equalTo(contentView)
            make.right.equalTo(-30.0)
        }
        // 分割线
        let bottomLine = UIView(frame: CGRect(x: 16, y: contentView.height - XDSize.unitWidth, width: contentView.width - 16.0, height: XDSize.unitWidth), color: XDColor.itemLine)
        bottomLine.autoresizingMask = [.flexibleWidth, .flexibleTopMargin]
        contentView.addSubview(bottomLine)
    }
}
