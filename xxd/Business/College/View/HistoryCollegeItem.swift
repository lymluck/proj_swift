//
//  HistoryCollegeItem.swift
//  xxd
//
//  Created by Lisen on 2018/6/11.
//  Copyright © 2018年 com.smartstudy. All rights reserved.
//

import UIKit

class HistoryCollegeItem: SSCellItem {
    var model: CollegeModel!
    var isLast: Bool = false
    var isHeaderVisible: Bool = false
    var groupName: String = ""
    override init!(attributes: [AnyHashable : Any]! = [:]) {
        super.init(attributes: attributes)
        model = CollegeModel.yy_model(with: attributes)
    }
    
    override init!(cellClass: AnyClass!, userInfo: Any!) {
        super.init(cellClass: cellClass, userInfo: userInfo)
    }
    
    override func cellClass() -> AnyClass! {
        return HistoryCollegeItemCell.self
    }
}

class HistoryCollegeItemCell: SSTableViewCell {
    private lazy var contentBackgroundView: UIView = UIView(frame: CGRect.zero, color: UIColor.white)
    private lazy var collegeName: UILabel = UILabel(frame: .zero, text: "", textColor: XDColor.itemTitle, fontSize: 16.0)
    private lazy var time: UILabel = UILabel(frame: .zero, text: "", textColor: XDColor.itemText, fontSize: 13.0)
    private lazy var headerLabel: UILabel = UILabel(frame: .zero, text: "", textColor: XDColor.itemText, fontSize: 14.0)
    private lazy var headerBackgroundView: UIView = UIView(frame: CGRect.zero, color: XDColor.mainBackground)
    private var bottomLine: UIView!
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        let tapGes: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(eventHeaderLabelTapResponse(_:)))
        headerBackgroundView.addGestureRecognizer(tapGes)
        contentView.backgroundColor = XDColor.mainBackground
        contentView.addSubview(contentBackgroundView)
        contentBackgroundView.snp.makeConstraints { (make) in
            make.left.bottom.right.equalToSuperview()
            make.height.equalTo(56.0)
        }
        contentView.addSubview(headerBackgroundView)
        headerBackgroundView.snp.makeConstraints { (make) in
            make.left.top.right.equalToSuperview()
            make.bottom.equalTo(contentBackgroundView.snp.top)
        }
        headerBackgroundView.addSubview(headerLabel)
        headerLabel.snp.makeConstraints { (make) in
            make.top.equalTo(14.0)
            make.left.equalTo(16.0)
        }
        contentBackgroundView.addSubview(time)
        time.snp.makeConstraints { (make) in
            make.right.equalTo(-16.0)
            make.centerY.equalToSuperview()
        }
        contentBackgroundView.addSubview(collegeName)
        collegeName.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.left.equalTo(16.0)
            make.right.lessThanOrEqualTo(time.snp.left).offset(10.0)
        }
        bottomLine = UIView(frame: CGRect(x: 16.0, y: contentView.height - XDSize.unitWidth, width: contentView.width-16.0, height: XDSize.unitWidth), color: XDColor.itemLine)
        bottomLine.autoresizingMask = [.flexibleWidth, .flexibleTopMargin]
        contentView.addSubview(bottomLine)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) { }
    override func setSelected(_ selected: Bool, animated: Bool) { }
    
    override static func height(for object: Any!, at indexPath: IndexPath!, tableView: UITableView!) -> CGFloat {
        if let item = object as? HistoryCollegeItem, item.isHeaderVisible {
            return 96.0
        }
        return 56.0
    }
    
    override func shouldUpdate(with object: Any!) -> Bool {
        if super.shouldUpdate(with: object), let item = object as? HistoryCollegeItem {
            headerLabel.text = item.groupName
            collegeName.text = item.model.chineseName
            time.text = item.model.viewTimeText
            bottomLine.isHidden = item.isLast
        }
        return true
    }
    
    /// 添加该手势的原因是防止用户在点击到头部视图时进行页面跳转
    @objc private func eventHeaderLabelTapResponse(_ gesture: UITapGestureRecognizer) { }
    
}
