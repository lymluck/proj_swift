//
//  MasterMajorCollegeItem.swift
//  xxd
//
//  Created by Lisen on 2018/7/11.
//  Copyright © 2018年 com.smartstudy. All rights reserved.
//

import UIKit

class MasterMajorCollegeItem: SSCellItem {
    var model: MasterMajorModel!
    var isTopThree: Bool = false
    var isLast: Bool = false
    override func cellStyle() -> UITableViewCellStyle {
        if isTopThree {
            return .value1
        }
        return .default
    }
    
    override init!(attributes: [AnyHashable : Any]! = [:]) {
        super.init(attributes: attributes)
        model = MasterMajorModel.yy_model(with: attributes)
    }
    
    override init!(cellClass: AnyClass!, userInfo: Any!) {
        super.init(cellClass: cellClass, userInfo: userInfo)
    }
    
    override func cellClass() -> AnyClass! {
        return MasterMajorCollegeItemCell.self
    }
}

class MasterMajorCollegeItemCell: SSTableViewCell {
    private lazy var rankLabel: UILabel = {
        let label: UILabel = UILabel(frame: CGRect.zero, text: "", textColor: UIColor.white, fontSize: 13.0)
        label.textAlignment = .center
        label.backgroundColor = UIColor(0x078CF1)
        return label
    }()
    private lazy var collegeLabel: UILabel = {
        let label: UILabel = UILabel(frame: CGRect.zero, text: "", textColor: XDColor.itemTitle, fontSize: 17.0)
        label.numberOfLines = 0
        return label
    }()
    private lazy var chineseLabel: UILabel = UILabel(frame: CGRect.zero, text: "", textColor: XDColor.itemText, fontSize: 14.0)
    private lazy var englishLabel: UILabel = UILabel(frame: CGRect.zero, text: "", textColor: XDColor.itemText, fontSize: 14.0)
    private lazy var separatorView: UIView = UIView(frame: CGRect.zero, color: XDColor.itemLine)
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        initContentViews()
        if style == .default {
            layoutContentViews()
        } else {
            layoutTopThreeCellContentViews()
        }
    }
    
    override static func height(for object: Any!, at indexPath: IndexPath!, tableView: UITableView!) -> CGFloat {
        if let item = object as? MasterMajorCollegeItem {
            if item.isTopThree {
                return 82.0
            } else {
                return 93.0
            }
        }
        return 93.0
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) { }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) { }
    
    override func shouldUpdate(with object: Any!) -> Bool {
        if super.shouldUpdate(with: object), let item = object as? MasterMajorCollegeItem {
            let rank = item.model.categoryRank
            if rank == 0 {
                rankLabel.text = "-"
            } else if (0...99).contains(rank) {
                rankLabel.text = "\(rank)"
            } else {
                rankLabel.font = UIFont.systemFont(ofSize: 10.0)
                rankLabel.text = "\(rank)"
            }
            collegeLabel.text = item.model.schoolName
            chineseLabel.text = item.model.chineseName
            englishLabel.text = item.model.englishName
            separatorView.isHidden = item.isLast
        }
        return true
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    private func initContentViews() {
        contentView.backgroundColor = UIColor.white
        addSubview(rankLabel)
        addSubview(collegeLabel)
        addSubview(chineseLabel)
        addSubview(englishLabel)
        addSubview(separatorView)
    }
    
    private func layoutContentViews() {
        rankLabel.snp.makeConstraints { (make) in
            make.left.equalTo(16.0)
            make.top.equalTo(16.0)
            make.width.height.equalTo(20.0)
        }
        collegeLabel.snp.makeConstraints { (make) in
            make.left.equalTo(rankLabel.snp.right).offset(12.0)
            make.top.equalTo(16.0)
            make.right.equalTo(-16.0)
        }
        chineseLabel.snp.makeConstraints { (make) in
            make.left.equalTo(collegeLabel)
            make.top.equalTo(collegeLabel.snp.bottom).offset(8.0)
            make.right.equalTo(-16.0)
        }
        englishLabel.snp.makeConstraints { (make) in
            make.left.equalTo(collegeLabel)
            make.top.equalTo(chineseLabel.snp.bottom).offset(3.0)
            make.right.equalTo(-16.0)
        }
        separatorView.snp.makeConstraints { (make) in
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(XDSize.unitWidth)
        }
    }
    
    private func layoutTopThreeCellContentViews() {
        collegeLabel.font = UIFont.systemFont(ofSize: 16.0)
        chineseLabel.font = UIFont.systemFont(ofSize: 13.0)
        englishLabel.font = UIFont.systemFont(ofSize: 13.0)
        rankLabel.snp.makeConstraints { (make) in
            make.left.equalTo(16.0)
            make.top.equalTo(12.0)
            make.width.height.equalTo(20.0)
        }
        collegeLabel.snp.makeConstraints { (make) in
            make.left.equalTo(rankLabel.snp.right).offset(12.0)
            make.top.equalTo(12.0)
            make.right.equalTo(-16.0)
        }
        chineseLabel.snp.makeConstraints { (make) in
            make.left.equalTo(collegeLabel)
            make.top.equalTo(collegeLabel.snp.bottom).offset(8.0)
            make.right.equalTo(-16.0)
        }
        englishLabel.snp.makeConstraints { (make) in
            make.left.equalTo(collegeLabel)
            make.top.equalTo(chineseLabel.snp.bottom).offset(3.0)
            make.right.equalTo(-16.0)
        }
        separatorView.snp.makeConstraints { (make) in
            make.left.equalTo(48.0)
            make.right.equalTo(-16.0)
            make.bottom.equalToSuperview()
            make.height.equalTo(XDSize.unitWidth)
        }
    }
}
