//
//  TargetCollegeOtherDetailHeaderView.swift
//  xxd
//
//  Created by Lisen on 2018/6/4.
//  Copyright © 2018年 com.smartstudy. All rights reserved.
//

import UIKit

class TargetCollegeOtherDetailHeaderView: UIView {
    
    var userModel: OtherUserModel? {
        didSet {
            if let model = userModel {
                userAvatar.kf.setImage(with: URL(string: model.userAvatar), placeholder: UIImage(named: "default_avatar"))
                nameLabel.text = userModel?.userName
                var countryName = "-"
                if !model.targetCountryName.isEmpty {
                    countryName = model.targetCountryName
                }
                var time = "-"
                if !model.admissionYear.isEmpty {
                    time = model.admissionYear
                }
                var degree = "-"
                if !model.targetDegreeName.isEmpty {
                    degree = model.targetDegreeName
                }
                let paragraph = NSMutableParagraphStyle()
                paragraph.lineSpacing = 6.0
                paragraph.alignment = .center
                countryLabel.attributedText = NSAttributedString(string: countryName, attributes: [NSAttributedStringKey.foregroundColor: XDColor.main, NSAttributedStringKey.font: UIFont.systemFont(ofSize: 16.0), NSAttributedStringKey.paragraphStyle: paragraph]) + "\n意向地"
                timeLabel.attributedText = NSAttributedString(string: time, attributes: [NSAttributedStringKey.foregroundColor: XDColor.main, NSAttributedStringKey.font: UIFont.systemFont(ofSize: 16.0), NSAttributedStringKey.paragraphStyle: paragraph]) + "\n出国时间"
                degreeLabel.attributedText = NSAttributedString(string: degree, attributes: [NSAttributedStringKey.foregroundColor: XDColor.main, NSAttributedStringKey.font: UIFont.systemFont(ofSize: 16.0), NSAttributedStringKey.paragraphStyle: paragraph]) + "\n申请项目"
            }
        }
    }
    
    private let viewWidth: CGFloat = (XDSize.screenWidth-XDSize.unitWidth*2.0)/3.0
    private lazy var userAvatar: UIImageView = {
        let imageView: UIImageView = UIImageView(frame: CGRect.zero)
        imageView.layer.cornerRadius = 45.0
        imageView.layer.masksToBounds = true
        return imageView
    }()
    private lazy var nameLabel: UILabel = UILabel(frame: CGRect.zero, text: "", textColor: XDColor.itemTitle, fontSize: 18.0, bold: true)
    private lazy var separatorView: UIView = UIView(frame: CGRect.zero, color: XDColor.itemLine)
    private lazy var leftLineView: UIView = UIView(frame: CGRect.zero, color: XDColor.itemLine)
    private lazy var rightLineView: UIView = UIView(frame: CGRect.zero, color: XDColor.itemLine)
    private lazy var countryLabel: UILabel = {
        let label: UILabel = UILabel(frame: CGRect.zero, text: "", textColor: XDColor.itemText, fontSize: 13.0)
        label.textAlignment = .center
        label.numberOfLines = 2
        return label
    }()
    private lazy var timeLabel: UILabel = {
        let label: UILabel = UILabel(frame: CGRect.zero, text: "", textColor: XDColor.itemText, fontSize: 13.0)
        label.textAlignment = .center
        label.numberOfLines = 2
        return label
    }()
    private lazy var degreeLabel: UILabel = {
        let label: UILabel = UILabel(frame: CGRect.zero, text: "", textColor: XDColor.itemText, fontSize: 13.0)
        label.textAlignment = .center
        label.numberOfLines = 2
        return label
    }()
    override init(frame: CGRect) {
        super.init(frame: frame)
        initContentViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    private func initContentViews() {
        backgroundColor = UIColor.white
        addSubview(userAvatar)
        userAvatar.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.top.equalTo(20.0)
            make.width.height.equalTo(90.0)
        }
        nameLabel.textAlignment = .center
        addSubview(nameLabel)
        nameLabel.snp.makeConstraints { (make) in
            make.top.equalTo(userAvatar.snp.bottom).offset(20.0)
            make.centerX.equalToSuperview()
            make.width.equalTo(172.0)
        }
        addSubview(separatorView)
        separatorView.snp.makeConstraints { (make) in
            make.top.equalTo(168.0)
            make.left.right.equalToSuperview()
            make.height.equalTo(XDSize.unitWidth)
        }
        addSubview(countryLabel)
        countryLabel.snp.makeConstraints { (make) in
            make.top.equalTo(separatorView.snp.bottom)
            make.left.equalToSuperview()
            make.width.equalTo(viewWidth)
            make.height.equalTo(69.0)
        }
        addSubview(leftLineView)
        leftLineView.snp.makeConstraints { (make) in
            make.centerY.equalTo(countryLabel)
            make.height.equalTo(30.0)
            make.width.equalTo(XDSize.unitWidth)
            make.left.equalTo(countryLabel.snp.right)
        }
        addSubview(timeLabel)
        timeLabel.snp.makeConstraints { (make) in
            make.top.equalTo(separatorView.snp.bottom)
            make.left.equalTo(leftLineView.snp.right)
            make.width.equalTo(viewWidth)
            make.height.equalTo(69.0)
        }
        addSubview(rightLineView)
        rightLineView.snp.makeConstraints { (make) in
            make.centerY.equalTo(countryLabel)
            make.height.equalTo(30.0)
            make.width.equalTo(XDSize.unitWidth)
            make.left.equalTo(timeLabel.snp.right)
        }
        addSubview(degreeLabel)
        degreeLabel.snp.makeConstraints { (make) in
            make.top.equalTo(separatorView.snp.bottom)
            make.left.equalTo(rightLineView.snp.right)
            make.width.equalTo(viewWidth)
            make.height.equalTo(69.0)
        }
    }
}
