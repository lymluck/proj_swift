//
//  HighSchoolListCell.swift
//  xxd
//
//  Created by Lisen on 2018/4/7.
//  Copyright © 2018年 com.smartstudy. All rights reserved.
//

import UIKit

class HighSchoolListItem: SSCellItem {
    var model: HighSchoolListModel!
    override init!(attributes: [AnyHashable : Any]! = [:]) {
        super.init(attributes: attributes)
        model = HighSchoolListModel.yy_model(with: attributes)
    }
    
    override init!(cellClass: AnyClass!, userInfo: Any!) {
        super.init(cellClass: cellClass, userInfo: userInfo)
    }
    
    override func cellClass() -> AnyClass! {
        return HighSchoolListCell.self
    }
}

// MARK: 高中简介视图
class XDHighSchoolProfileView: UIView {
    // MARK: properties
    var viewObject: HighSchoolListModel? {
        didSet {
            cNameLabel.text = viewObject?.chineseName
            eNameLabel.text = viewObject?.englishName
            locationLabel.text = viewObject?.provinceName
            if let percent = viewObject?.seniorFacultyRatio, !percent.isEmpty {
                percentLabel.text = "高级教师占比: " + percent
            } else {
                percentLabel.text = ""
            }
        }
    }
    
    var chineseName: String? {
        didSet {
            cNameLabel.text = chineseName
        }
    }
    var englishName: String? {
        didSet {
            eNameLabel.text = englishName
        }
    }
    var location: String? {
        didSet {
            locationLabel.text = location
        }
    }
    var percent: String? {
        didSet {
            if let percent = percent, !percent.isEmpty {
                percentLabel.text = "高级教师占比: " + percent
            } else {
                percentLabel.text = ""
            }
        }
    }
    
    private lazy var cNameLabel: UILabel = UILabel(frame: CGRect.zero, text: "", textColor: UIColor(0x26343F), fontSize: 16.0, bold: true)
    private lazy var eNameLabel: UILabel = UILabel(frame: CGRect.zero, text: "", textColor: UIColor(0x26343F), fontSize: 13.0)
    private lazy var locationLabel: UILabel = UILabel(frame: CGRect.zero, text: "", textColor: UIColor(0x949BA1), fontSize: 13.0)
    private lazy var percentLabel: UILabel = UILabel(frame: CGRect.zero, text: "", textColor: UIColor(0x58646E), fontSize: 13.0)
    
    // MARK: life cycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        initContentViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: private methods
    private func initContentViews() {
        self.addSubview(cNameLabel)
        self.addSubview(eNameLabel)
        self.addSubview(locationLabel)
        self.addSubview(percentLabel)
        
        cNameLabel.snp.makeConstraints { (make) in
            make.left.top.right.equalToSuperview()
            make.height.equalTo(16.0)
        }
        eNameLabel.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.top.equalTo(cNameLabel.snp.bottom).offset(2.0)
            make.height.equalTo(15.0)
        }
        locationLabel.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.top.equalTo(eNameLabel.snp.bottom).offset(3.0)
            make.height.equalTo(13.0)
        }
        percentLabel.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.top.equalTo(locationLabel.snp.bottom).offset(11.0)
            make.height.equalTo(13.0)
        }
    }
}

//美高院校库
class HighSchoolListCell: SSTableViewCell {

    // MARK: properties
    private lazy var rankLabel: UILabel = UILabel(frame: CGRect.zero, text: "", textColor: UIColor(0xFF9C08), fontSize: 16.0)
    private lazy var symbolLabel: UILabel = UILabel(frame: CGRect.zero, text: "#", textColor: UIColor(0xC4C9CC), fontSize: 10.0)
    private lazy var nameLabel: UILabel = UILabel(frame: CGRect.zero, text: "", textColor: UIColor(0x26343F), fontSize: 16.0)
    private lazy var profileView: XDHighSchoolProfileView = XDHighSchoolProfileView(frame: CGRect.zero)
    private lazy var consultBtn: UIButton = {
        let button: UIButton = UIButton(frame: CGRect.zero)
        button.setTitle("咨询该校", for: .normal)
        button.setBackgroundColor(UIColor(0x078CF1), for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14.0)
        button.layer.cornerRadius = 4.0
        button.layer.masksToBounds = true
        button.addTarget(self, action: #selector(HighSchoolListCell.eventButtonResponse(_:)), for: .touchUpInside)
        return button
    }()
    // MARK: life cycle
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        initContentViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override static func height(for object: Any!, at indexPath: IndexPath!, tableView: UITableView!) -> CGFloat {
        return 104.0
    }
    
    override func shouldUpdate(with object: Any!) -> Bool {
        if super.shouldUpdate(with: object) {
            if let item = object as? HighSchoolListItem {
                rankLabel.text = item.model.rank.isEmpty ? "N/A" : item.model.rank
                profileView.viewObject = item.model
            }
        }
        return true
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    // MARK: event response
    @objc func eventButtonResponse(_ sender: UIButton) {
        XDRoute.pushMQChatVC()
    }
    
    // MARK: private methods
    private func initContentViews() {
        rankLabel.textAlignment = .center
        contentView.backgroundColor = UIColor.white
        contentView.addSubview(rankLabel)
        contentView.addSubview(symbolLabel)
        contentView.addSubview(consultBtn)
        consultBtn.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.right.equalTo(-16.0)
            make.width.equalTo(80.0)
            make.height.equalTo(30.0)
        }
        rankLabel.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(17.0)
            make.left.equalToSuperview().offset(16.0)
            make.width.equalTo(30.0)
            make.height.equalTo(16.0)
        }
        contentView.addSubview(profileView)
        profileView.snp.makeConstraints { (make) in
            make.top.equalTo(rankLabel)
            make.left.equalTo(rankLabel.snp.right).offset(8.0)
            make.bottom.equalToSuperview().offset(-14.0)
            make.right.equalToSuperview().offset(-120.0)
        }
        symbolLabel.snp.makeConstraints { (make) in
            make.top.equalTo(rankLabel.snp.bottom)
            make.left.equalTo(rankLabel).offset(12.0)
            make.width.equalTo(6.0)
            make.height.equalTo(10.0)
        }
        // 分割线
        let bottomLine = UIView(frame: CGRect(x: 16, y: contentView.height - XDSize.unitWidth, width: contentView.width - 16.0, height: XDSize.unitWidth), color: XDColor.itemLine)
        bottomLine.autoresizingMask = [.flexibleWidth, .flexibleTopMargin]
        contentView.addSubview(bottomLine)
    }
}
