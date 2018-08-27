//
//  ColumnDetailTopBarView.swift
//  xxd
//
//  Created by Lisen on 2018/7/20.
//  Copyright © 2018年 com.smartstudy. All rights reserved.
//

import UIKit

/// 专栏导航栏作者信息视图
class ColumnDetailTopBarView: UIView {
    var avatarURL: String = "" {
        didSet {
            avatarImageView.kf.setImage(with: URL(string: avatarURL), placeholder: UIImage(named: "default_avatar"))
        }
    }
    var name: String? {
        didSet {
            nameLabel.text = name
        }
    }
    var time: String? {
        didSet {
            timeLabel.text = time
        }
    }
    private lazy var backBtn: UIButton = {
        let button: UIButton = UIButton(frame: CGRect(x: 0, y: XDSize.statusBarHeight, width: XDSize.topBarHeight, height: XDSize.topBarHeight), title: "", fontSize: 0, titleColor: UIColor.clear, target: self, action: #selector(eventBackbuttonResponse(_:)))
        button.setImage(UIImage(named: "top_left_arrow"), for: .normal)
        return button
    }()
    private lazy var avatarImageView: UIImageView = {
        let imageView: UIImageView = UIImageView(frame: CGRect.zero)
        imageView.layer.cornerRadius = 16.0
        imageView.layer.masksToBounds = true
        return imageView
    }()
    private lazy var nameLabel: UILabel = UILabel(frame: CGRect.zero, text: "", textColor: XDColor.itemTitle, fontSize: 12.0)
    private lazy var timeLabel: UILabel = UILabel(frame: CGRect.zero, text: "", textColor: XDColor.itemText, fontSize: 10.0)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initContentViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    @objc private func eventBackbuttonResponse(_ sender: UIButton) {
        UIApplication.topVC()?.navigationController?.popViewController(animated: true)
    }
    
    private func initContentViews() {
        backgroundColor = UIColor.white
        addSubview(backBtn)
        addSubview(avatarImageView)
        avatarImageView.snp.makeConstraints { (make) in
            make.right.equalTo(-16.0)
            make.bottom.equalTo(-6.0)
            make.width.height.equalTo(32.0)
        }
        addSubview(timeLabel)
        timeLabel.snp.makeConstraints { (make) in
            make.bottom.equalTo(-8.0)
            make.right.equalTo(avatarImageView.snp.left).offset(-8.0)
        }
        addSubview(nameLabel)
        nameLabel.snp.makeConstraints { (make) in
            make.right.equalTo(timeLabel)
            make.bottom.equalTo(timeLabel.snp.top).offset(-1.0)
        }
        addSubview(UIView(frame: CGRect(x: 0, y: height - XDSize.unitWidth, width: XDSize.screenWidth, height: XDSize.unitWidth), color: XDColor.mainLine))
    }
}

/// 专栏界面作者信息
class ColumnHeaderUserInfoView: UIView {
    var avatarURL: String = "" {
        didSet {
            authorAvatar.kf.setImage(with: URL(string: avatarURL), placeholder: UIImage(named: "default_avatar"))
        }
    }
    var name: String = "" {
        didSet {
            authorName.text = name
        }
    }
    var time: String = "" {
        didSet {
            timeAndCountLabel.text = time
        }
    }
    private lazy var authorAvatar: UIImageView = {
        let imageView: UIImageView = UIImageView(frame: CGRect.zero)
        imageView.layer.cornerRadius = 9.0
        imageView.layer.masksToBounds = true
        return imageView
    }()
    private lazy var authorName: UILabel = UILabel(frame: CGRect.zero, text: "", textColor: UIColor(0x58646E), fontSize: 13.0)
    private lazy var timeAndCountLabel: UILabel = UILabel(frame: CGRect.zero, text: "", textColor: XDColor.itemText, fontSize: 13.0)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initContentViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    private func initContentViews() {
        addSubview(authorAvatar)
        authorAvatar.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.left.equalTo(20.0)
            make.width.height.equalTo(18.0)
        }
        addSubview(authorName)
        authorName.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.left.equalTo(authorAvatar.snp.right).offset(6.0)
            make.width.lessThanOrEqualTo(112.0)
        }
        addSubview(timeAndCountLabel)
        timeAndCountLabel.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.left.equalTo(authorName.snp.right).offset(10.0)
        }
    }
}

