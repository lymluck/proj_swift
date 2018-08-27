//
//  CourseGroupListItem.swift
//  xxd
//
//  Created by remy on 2018/1/18.
//  Copyright © 2018年 com.smartstudy. All rights reserved.
//

import SnapKit

// 课程列表 section item
class CourseGroupSectionItem: NSObject {

    var title = ""
}

// 课程列表 section header
class CourseGroupSectionHeader: UITableViewHeaderFooterView {
    
    private var titleLabel: UILabel!
    var item: CourseGroupSectionItem? {
        didSet {
            titleLabel.text = item?.title
        }
    }
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        contentView.backgroundColor = UIColor.white
        
        let visitImageView = UIImageView(image: UIImage(named: "course_play"))
        contentView.addSubview(visitImageView)
        visitImageView.snp.makeConstraints { (make) in
            make.left.equalTo(contentView).offset(16)
            make.centerY.equalTo(contentView)
            make.size.equalTo(CGSize(width: 18, height: 18))
        }
        
        titleLabel = UILabel(frame: .null, text: "", textColor: XDColor.itemTitle, fontSize: 17, bold: true)
        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (make) in
            make.left.equalTo(contentView).offset(42)
            make.centerY.equalTo(contentView)
        }
        
        let bottomLine = UIView(frame: CGRect(x: 0, y: contentView.height - XDSize.unitWidth, width: XDSize.screenWidth, height: XDSize.unitWidth), color: XDColor.itemLine)
        bottomLine.autoresizingMask = [.flexibleWidth, .flexibleTopMargin]
        contentView.addSubview(bottomLine)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// 课程列表 item
class CourseGroupListItem: SSCellItem {
    
    var model: CourseModel!
    var cellHeight: CGFloat = 112
    var isLast = false {
        didSet {
            cellHeight = isLast ? 124 : 112
        }
    }
    
    override init!(attributes: [AnyHashable : Any]! = [:]) {
        super.init(attributes: attributes)
        model = CourseModel.yy_model(with: attributes)
    }
    
    override init!(cellClass: AnyClass!, userInfo: Any!) {
        super.init(cellClass: cellClass, userInfo: userInfo)
    }
    
    override func cellClass() -> AnyClass! {
        return CourseGroupListItemCell.self
    }
}

// 课程列表 cell
class CourseGroupListItemCell: SSTableViewCell {
    
    private var titleLabel: UILabel!
    private var visitCountLabel: UILabel!
    private var sectionCountLabel: UILabel!
    private var coverView: UIImageView!
    private var bottomLine: UIView!
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.backgroundColor = UIColor.white
        
        // 封面
        coverView = UIImageView()
        coverView.contentMode = .scaleAspectFill
        coverView.layer.cornerRadius = 4
        coverView.layer.masksToBounds = true
        contentView.addSubview(coverView)
        coverView.snp.makeConstraints { (make) in
            make.top.left.equalTo(contentView).offset(16)
            make.size.equalTo(CGSize(width: 143, height: 80))
        }
        
        // 标题
        titleLabel = UILabel(frame: .null, text: "", textColor: XDColor.itemTitle, fontSize: 16, bold: true)
        titleLabel.numberOfLines = 2
        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (make) in
            make.top.equalTo(coverView)
            make.left.equalTo(coverView.snp.right).offset(16)
            make.right.equalTo(contentView).offset(-16)
        }
        
        // 课时
        sectionCountLabel = UILabel(text: "", textColor: UIColor(0x55646F), fontSize: 12)
        contentView.addSubview(sectionCountLabel)
        sectionCountLabel.snp.makeConstraints { (make) in
            make.left.equalTo(coverView.snp.right).offset(16)
            make.bottom.equalTo(coverView)
        }
        
        // 访问人数
        visitCountLabel = UILabel(text: "", textColor: XDColor.itemText, fontSize: 11)
        contentView.addSubview(visitCountLabel)
        visitCountLabel.snp.makeConstraints { (make) in
            make.left.equalTo(sectionCountLabel.snp.right)
            make.right.lessThanOrEqualToSuperview().offset(-16)
            make.centerY.equalTo(sectionCountLabel)
        }
        
        // 分割线
        bottomLine = UIView(frame: CGRect(x: 0, y: 0, width: XDSize.screenWidth, height: XDSize.unitWidth), color: XDColor.itemLine)
        contentView.addSubview(bottomLine)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override static func height(for object: Any!, at indexPath: IndexPath!, tableView: UITableView!) -> CGFloat {
        return (object as! CourseGroupListItem).cellHeight
    }
    
    override func shouldUpdate(with object: Any!) -> Bool {
        if super.shouldUpdate(with: object), let object = object as? CourseGroupListItem {
            if object.isLast {
                bottomLine.backgroundColor = XDColor.mainBackground
                bottomLine.left = 0
                bottomLine.top = object.cellHeight - 12
                bottomLine.height = 12
            } else {
                bottomLine.backgroundColor = XDColor.itemLine
                bottomLine.left = 16
                bottomLine.top = object.cellHeight - XDSize.unitWidth
                bottomLine.height = XDSize.unitWidth
            }
            titleLabel.text = object.model.name
            var attr = NSMutableAttributedString()
            attr += "共 "
            attr += NSAttributedString(string: "\(object.model.sectionCount)", attributes: [NSAttributedStringKey.foregroundColor:XDColor.main])
            attr += " 课程"
            attr += NSAttributedString(string: "  |  ", attributes: [NSAttributedStringKey.foregroundColor:XDColor.itemLine])
            sectionCountLabel.attributedText = attr
            visitCountLabel.text = "\(object.model.visitCount)人看过"
            let size = CGSize(width: 143, height: 80)
            coverView.setOSSImage(urlStr: object.model.coverURL, size: size, policy: .fill, placeholderImage: UIImage.getPlaceHolderImage(size: size))
        }
        return true
    }
}
