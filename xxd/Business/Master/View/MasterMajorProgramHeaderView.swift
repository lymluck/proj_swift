//
//  MasterMajorProgramHeaderView.swift
//  xxd
//
//  Created by Lisen on 2018/7/12.
//  Copyright © 2018年 com.smartstudy. All rights reserved.
//

import UIKit

class MasterMajorProgramHeaderView: UIView {
    
    var logoURL: String = "" {
        didSet {
            let url: String = UIImage.OSSImageURLString(urlStr: logoURL, size: CGSize(width: 66, height: 66), policy: .pad)
            logoImageView.kf.setImage(with: URL(string: url), placeholder: UIImage(named: "default_college_logo"))
        }
    }
    var chineseName: String? {
        didSet {
            chineseLabel.text = chineseName
        }
    }
    var englishName: String? {
        didSet {
            let paragraph = NSMutableParagraphStyle()
            paragraph.maximumLineHeight = 18.0
            paragraph.minimumLineHeight = 18.0
            paragraph.alignment = .center
            englishLabel.attributedText = NSAttributedString(string: englishName!, attributes: [NSAttributedStringKey.paragraphStyle: paragraph])
        }
    }
    var schoolName: String? {
        didSet {
            schoolLabel.text = schoolName
        }
    }
    var rank: Int = 0 {
        didSet {
            if rank == 0 {
                rankLabel.text = "-"
            } else if (0...99).contains(rank) {
                rankLabel.text = "\(rank)"
            } else {
                rankLabel.font = UIFont.systemFont(ofSize: 10.0)
                rankLabel.text = "\(rank)"
            }
        }
    }
    
    private lazy var logoImageView: UIImageView = UIImageView(frame: CGRect(x: 12.0, y: 12.0, width: 66.0, height: 66.0))
    private lazy var chineseLabel: UILabel = {
        let label: UILabel = UILabel(frame: CGRect.zero, text: "", textColor: XDColor.itemTitle, fontSize: 20.0, bold: true)
        return label
    }()
    private lazy var englishLabel: UILabel = UILabel(frame: CGRect.zero, text: "", textColor: XDColor.itemTitle, fontSize: 16.0, bold: true)
    private lazy var schoolLabel: UILabel = UILabel(frame: CGRect.zero, text: "", textColor: XDColor.itemText, fontSize: 14.0)
    lazy var rankLabel: UILabel = {
        let label: UILabel = UILabel(frame: CGRect.zero, text: "1", textColor: UIColor.white, fontSize: 13.0)
        label.textAlignment = .center
        label.backgroundColor = UIColor(0x078CF1)
        return label
    }()
    private lazy var separatorView: UIView = UIView(frame: CGRect.zero, color: UIColor(0xF5F6F7))
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initContentViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    private func initContentViews() {
        backgroundColor = UIColor.white
        chineseLabel.textAlignment = .center
        chineseLabel.numberOfLines = 0
        englishLabel.numberOfLines = 0
        schoolLabel.textAlignment = .center
        schoolLabel.numberOfLines = 0
        let logoWrapView: UIView = UIView(frame: CGRect.zero, color: UIColor.white)
        logoWrapView.layer.cornerRadius = 45.0
        logoWrapView.layer.borderWidth = 5.0
        logoWrapView.layer.borderColor = UIColor(0xEEEEEE).cgColor
        logoImageView.layer.cornerRadius = 33.0
        logoImageView.layer.masksToBounds = true
        logoWrapView.addSubview(logoImageView)
        addSubview(logoWrapView)
        logoWrapView.snp.makeConstraints { (make) in
            make.top.equalTo(8.0)
            make.centerX.equalToSuperview()
            make.width.height.equalTo(90.0)
        }
        addSubview(chineseLabel)
        chineseLabel.snp.makeConstraints { (make) in
            make.top.equalTo(logoWrapView.snp.bottom).offset(12.0)
            make.left.equalTo(24.0)
            make.right.equalTo(-24.0)
        }
        addSubview(englishLabel)
        englishLabel.snp.makeConstraints { (make) in
            make.top.equalTo(chineseLabel.snp.bottom).offset(2.0)
            make.centerX.equalToSuperview()
            make.left.equalTo(24.0)
            make.right.equalTo(-24.0)
        }
        addSubview(schoolLabel)
        schoolLabel.snp.makeConstraints { (make) in
            make.top.equalTo(englishLabel.snp.bottom).offset(11.0)
            make.left.equalTo(24.0)
            make.right.equalTo(-24.0)
        }
        addSubview(rankLabel)
        rankLabel.snp.makeConstraints { (make) in
            make.top.equalTo(schoolLabel.snp.bottom).offset(12.0)
            make.centerX.equalToSuperview()
            make.width.height.equalTo(20.0)
        }
        addSubview(separatorView)
        separatorView.snp.makeConstraints { (make) in
            make.left.bottom.right.equalToSuperview()
            make.height.equalTo(12.0)
        }

    }
    
}
