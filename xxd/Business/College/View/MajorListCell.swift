//
//  MajorListCell.swift
//  xxd
//
//  Created by Lisen on 2018/7/2.
//  Copyright © 2018年 com.smartstudy. All rights reserved.
//

import UIKit

class MajorListHeaderView: UICollectionReusableView {
    
    var categoryName: String? {
        didSet {
            titleLabel.text = categoryName
        }
    }
    var categoryId: String?
    var isMoreBtnHidden: Bool = false {
        didSet {
            moreBtn.isHidden = isMoreBtnHidden
        }
    }
    private lazy var titleLabel: UILabel = {
        let label: UILabel = UILabel(frame: CGRect.zero, text: "热门专业", textColor: XDColor.itemTitle, fontSize: 17.0, bold: true)
        return label
    }()
    private lazy var moreBtn: UIButton = {
        let button: UIButton = UIButton(frame: CGRect.zero, title: "查看更多", fontSize: 13.0, titleColor: XDColor.itemText, target: self, action: #selector(eventButtonResponse(_:)))
        button.setImage(UIImage(named: "more_right_arrow"), for: .normal)
        button.titleEdgeInsets = UIEdgeInsets(top: 0.0, left: -9.0, bottom: 0.0, right: 9.0)
        button.imageEdgeInsets = UIEdgeInsets(top: 1.0, left: 54.0, bottom: 1.0, right: -54.0)
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
        }
        addSubview(moreBtn)
        moreBtn.snp.makeConstraints { (make) in
            make.right.top.bottom.equalToSuperview()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    @objc private func eventButtonResponse(_ sender: UIButton) {
        routerEvent(name: "MajorHeaderViewTap", data: ["categoryId": categoryId ?? ""])
    }
}

class MajorListFooterView: UICollectionReusableView {
    
    lazy var separatorView: UIView = UIView(frame: CGRect(x: 0.0, y: bounds.height-XDSize.unitWidth, width: bounds.width, height: XDSize.unitWidth), color: XDColor.itemLine)    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(separatorView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

class MajorListCell: UICollectionViewCell {
    
    var majorName: String? {
        didSet {
            majorLabel.text = majorName
        }
    }
    private lazy var majorLabel: UILabel = UILabel(frame: CGRect.zero, text: "", textColor: UIColor(0x26343F), fontSize: 13.0)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = UIColor(0xF5F6F7)
        contentView.layer.cornerRadius = 17.0
        majorLabel.textAlignment = .center
        contentView.addSubview(majorLabel)
        majorLabel.snp.makeConstraints { (make) in
            make.left.equalTo(6.0)
            make.right.equalTo(-6.0)
            make.centerY.equalToSuperview()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
}
