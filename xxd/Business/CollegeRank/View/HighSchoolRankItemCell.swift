//
//  HighSchoolRankItemCell.swift
//  xxd
//
//  Created by Lisen on 2018/4/4.
//  Copyright © 2018年 com.smartstudy. All rights reserved.
//

import UIKit

class HighSchoolRankItem: SSCellItem {
    // MARK: properties
    var model: HighSchoolRankModel!
    
    // MARK: life cycle
    override init!(attributes: [AnyHashable : Any]! = [:]) {
        super.init(attributes: attributes)
        model = HighSchoolRankModel.yy_model(with: attributes)
    }
    
    override init!(cellClass: AnyClass!, userInfo: Any!) {
        super.init(cellClass: cellClass, userInfo: userInfo)
    }
    
    override func cellClass() -> AnyClass! {
        return HighSchoolRankItemCell.self
    }
}

class HighSchoolRankItemCell: SSTableViewCell {
    
    // MARK: properties
    private lazy var rankLabel: UILabel = UILabel(frame: CGRect.zero, text: "", textColor: UIColor(0xFF9C08), fontSize: 16.0)
    private lazy var symbolLabel: UILabel = UILabel(frame: CGRect.zero, text: "#", textColor: UIColor(0xC4C9CC), fontSize: 10.0)
    private lazy var nameLabel: UILabel = UILabel(frame: CGRect.zero, text: "", textColor: UIColor(0x26343F), fontSize: 16.0)
    private lazy var consultBtn: UIButton = {
        let button: UIButton = UIButton(frame: CGRect.zero)
        button.setTitle("咨询该校", for: .normal)
        button.setBackgroundColor(UIColor(0x078CF1), for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14.0)
        button.layer.cornerRadius = 4.0
        button.layer.masksToBounds = true
        button.addTarget(self, action: #selector(HighSchoolRankItemCell.eventButtonResponse(_:)), for: .touchUpInside)
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
        return 64.0
    }
    
    override func shouldUpdate(with object: Any!) -> Bool {
        if super.shouldUpdate(with: object) {
            if let item = object as? HighSchoolRankItem {
                rankLabel.text = item.model.rank
                nameLabel.text = item.model.chineseName
            }
        }
        return true
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
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().offset(16.0)
            make.width.equalTo(30.0)
            make.height.equalTo(16.0)
        }
        contentView.addSubview(nameLabel)
        nameLabel.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.left.equalTo(rankLabel.snp.right).offset(8.0)
            make.right.equalToSuperview().offset(-120.0)
            make.height.equalTo(16.0)
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
