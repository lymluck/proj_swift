//
//  IndexSearchSectionItem.swift
//  xxd
//
//  Created by remy on 2018/2/21.
//  Copyright © 2018年 com.smartstudy. All rights reserved.
//

enum IndexSearchType: Int {
    case college
    case highschool
    case course
    case qa
    case info
}

class IndexSearchSectionItem: NSObject {
    
    var cellItems = [SSCellItem]()
    var type: IndexSearchType!
    var title = ""
    var resultCount = 0
    var showCount = 0
}

class IndexSearchSectionHeader: UITableViewHeaderFooterView {
    
    private var titleLabel: UILabel!
    var item: IndexSearchSectionItem! {
        didSet {
            titleLabel.text = item.title
        }
    }
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        contentView.backgroundColor = XDColor.mainBackground
        
        // 标题
        titleLabel = UILabel(frame: .zero, text: "", textColor: XDColor.itemText, fontSize: 13)
        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(contentView)
            make.left.equalTo(contentView).offset(16)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

class IndexSearchSectionFooterItem: SSCellItem {
    
    weak var item: IndexSearchSectionItem!
    
    override func cellClass() -> AnyClass! {
        return IndexSearchSectionFooterCell.self
    }
}

class IndexSearchSectionFooterCell: SSTableViewCell {
    
    private var titleLabel: UILabel!
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.backgroundColor = UIColor.white
        
        // 标题
        titleLabel = UILabel(frame: .null, text: "", textColor: XDColor.main, fontSize: 13)
        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (make) in
            make.center.equalTo(contentView)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override static func height(for object: Any!, at indexPath: IndexPath!, tableView: UITableView!) -> CGFloat {
        return 44
    }
    
    override func shouldUpdate(with object: Any!) -> Bool {
        if super.shouldUpdate(with: object), let object = object as? IndexSearchSectionFooterItem {
            let left = max(object.item.resultCount - object.item.showCount, 0)
            titleLabel.text = "更多\(object.item.title)结果(\(left))"
        }
        return true
    }
}
