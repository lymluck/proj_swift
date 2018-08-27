//
//  CollegeActivityItem.swift
//  xxd
//
//  Created by Lisen on 2018/6/28.
//  Copyright © 2018年 com.smartstudy. All rights reserved.
//

import UIKit

class CollegeActivityItem: SSCellItem {
    
    var model: CollegeActivityModel!
    
    override init!(attributes: [AnyHashable : Any]! = [:]) {
        super.init(attributes: attributes)
        model = CollegeActivityModel.yy_model(with: attributes)
    }
    
    override init!(cellClass: AnyClass!, userInfo: Any!) {
        super.init(cellClass: cellClass, userInfo: userInfo)
    }
    
    override func cellClass() -> AnyClass! {
        return CollegeActivityItemCell.self
    }
    
}

/// 活动列表cell
class CollegeActivityItemCell: SSTableViewCell {
    
    private lazy var titleLabel: UILabel = {
        let label: UILabel = UILabel(frame: CGRect.zero, text: "", textColor: XDColor.itemTitle, fontSize: 17.0, bold: true)
        label.numberOfLines = 2
        return label
    }()
    private lazy var activityTimeLabel: UILabel = {
        let label: UILabel = UILabel(frame: CGRect.zero, text: "", textColor: XDColor.itemText, fontSize: 13.0)
        label.numberOfLines = 0
        return label
    }()
    private lazy var activityPlaceLabel: UILabel = {
        let label: UILabel = UILabel(frame: CGRect.zero, text: "", textColor: XDColor.itemText, fontSize: 13.0)
        label.numberOfLines = 0
        return label
    }()
    private lazy var separatorView: UIView = UIView(frame: CGRect.zero, color: XDColor.itemLine)
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        initContentViews()
    }
    
    override static func height(for object: Any!, at indexPath: IndexPath!, tableView: UITableView!) -> CGFloat {
        if let item = object as? CollegeActivityItem {
            let titleHeight = item.model.title.labelHeight(maxWidth: XDSize.screenWidth-32.0, font: UIFont.boldSystemFont(ofSize: 17.0), numberOfLines: 2)
            let timeHeight = ("活动时间: " + item.model.activityTime).heightForFont(UIFont.systemFont(ofSize: 13.0), XDSize.screenWidth-32.0, 18.0).rounded()
            let placeHeight = ("活动地点: " + item.model.activityPlace).heightForFont(UIFont.systemFont(ofSize: 13.0), XDSize.screenWidth-32.0, 18.0).rounded()
            return 52.0+titleHeight+timeHeight+placeHeight
        }
        return 0.0
    }
    
    override func shouldUpdate(with object: Any!) -> Bool {
        if super.shouldUpdate(with: object), let item = object as? CollegeActivityItem {
            titleLabel.text = item.model.title
            titleLabel.setText(item.model.title, lineSpace: 3.0)
            let timeAttributedText = NSAttributedString(string: "活动时间: ", attributes: [NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 13.0)]) + item.model.activityTime
            activityTimeLabel.setAttr(timeAttributedText, lineSpace: 2.0)
            let placeAttributedText = NSAttributedString(string: "活动地点: ", attributes: [NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 13.0)]) + item.model.activityPlace
            activityPlaceLabel.setAttr(placeAttributedText, lineSpace: 2.0)
        }
        return true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func initContentViews() {
        contentView.backgroundColor = UIColor.white
        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (make) in
            make.top.equalTo(20.0)
            make.left.equalTo(16.0)
            make.right.equalTo(-16.0)
        }
        contentView.addSubview(activityTimeLabel)
        activityTimeLabel.snp.makeConstraints { (make) in
            make.top.equalTo(titleLabel.snp.bottom).offset(12.0)
            make.left.equalTo(16.0)
            make.right.equalTo(-16.0)
        }
        contentView.addSubview(activityPlaceLabel)
        activityPlaceLabel.snp.makeConstraints { (make) in
            make.top.equalTo(activityTimeLabel.snp.bottom).offset(4.0)
            make.left.equalTo(activityTimeLabel)
            make.right.equalTo(-16.0)
        }
        contentView.addSubview(separatorView)
        separatorView.snp.makeConstraints { (make) in
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(0.5)
        }
    }
}

/// 活动详情界面中的分区视图
class ActivityItemView: UIView {
    var title: String? {
        didSet {
            titleLabel.text = title
        }
    }
    var content: String = "" {
        didSet {
            detailLabel.setText(content, lineSpace: 3.0)
            height = content.heightForFont(detailLabel.font, XDSize.screenWidth-32.0, 19.0) + 76.0
        }
    }
    var time: String = "" {
        didSet {
            timeLabel.setText(time, lineSpace: 3.0)
            height += time.heightForFont(timeLabel.font, XDSize.screenWidth-32.0, 19.0) + 4.0
        }
    }
    var hideSeparatorView: Bool = false {
        didSet {
            separatorView.isHidden = hideSeparatorView
        }
    }
    private lazy var titleLabel: UILabel = {
        let label: UILabel = UILabel(frame: CGRect.zero, text: "", textColor: XDColor.itemTitle, fontSize: 19.0, bold: true)
        return label
    }()
    private lazy var detailLabel: UILabel = {
        let label: UILabel = UILabel(frame: CGRect.zero, text: "", textColor: UIColor(0x58546E), fontSize: 14.0)
        label.numberOfLines = 0
        return label
    }()
    private lazy var timeLabel: UILabel = {
        let label: UILabel = UILabel(frame: CGRect.zero, text: "", textColor: UIColor(0x58546E), fontSize: 14.0)
        label.numberOfLines = 0
        return label
    }()
    private lazy var separatorView: UIView = UIView(frame: CGRect.zero, color: XDColor.itemLine)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initContentViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    private func initContentViews() {
        backgroundColor = UIColor.white
        addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (make) in
            make.top.equalTo(20.0)
            make.left.equalTo(16.0)
            make.right.equalTo(-16.0)
            make.height.equalTo(24.0)
        }
        addSubview(detailLabel)
        detailLabel.snp.makeConstraints { (make) in
            make.top.equalTo(titleLabel.snp.bottom).offset(12.0)
            make.left.equalTo(16.0)
            make.right.equalTo(-16.0)
        }
        addSubview(timeLabel)
        timeLabel.snp.makeConstraints { (make) in
            make.top.equalTo(detailLabel.snp.bottom).offset(4.0)
            make.left.equalTo(16.0)
            make.right.equalTo(-16.0)
        }
        addSubview(separatorView)
        separatorView.snp.makeConstraints { (make) in
            make.bottom.equalToSuperview()
            make.left.equalTo(16.0)
            make.right.equalTo(-16.0)
            make.height.equalTo(0.5)
        }
    }
}
