//
//  RankSectionItem.swift
//  xxd
//
//  Created by remy on 2018/1/24.
//  Copyright © 2018年 com.smartstudy. All rights reserved.
//

import Kingfisher

protocol RankSectionItemDelegate: class {
    
    func sectionItemDidSelected(item: RankSectionItem)
}

class RankSectionItem: NSObject {
    
    var index = 0
    var isSelected = false {
        willSet {
            if newValue != isSelected {
                sectionView?.item = self
            }
        }
    }
    var model: RankModel!
    weak var delegate: RankSectionItemDelegate?
    weak var sectionView: RankSectionView?
    var hasSeparate = false
}

class RankSectionView: UITableViewHeaderFooterView {

    var item: RankSectionItem? {
        didSet {
            if let item = item {
                item.sectionView = self
                logoView.kf.setImage(with: URL(string: item.model.logoURL), placeholder: UIImage(named: "default_college_logo"))
                arrowImageView.transform = item.isSelected ? CGAffineTransform(rotationAngle: .pi / 2) : CGAffineTransform.identity
                titleLabel.text = item.model.name
            }
        }
    }
    private var backButton: UIButton!
    private var titleLabel: UILabel!
    private var logoView: UIImageView!
    private var arrowImageView: UIImageView!
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        contentView.backgroundColor = UIColor.white
        backgroundView = nil
        
        // 点击区域
        backButton = UIButton(frame: contentView.bounds, title: "", fontSize: 0, titleColor: UIColor.clear, target: self, action: #selector(onBackButtonPressed(sender:)))!
        backButton.setBackgroundColor(XDColor.itemLine, for: .highlighted)
        backButton.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        contentView.insertSubview(backButton, at: 0)
        
        // 标题
        titleLabel = UILabel(frame: CGRect(x: 62, y: 0, width: XDSize.screenWidth - 103, height: 66), text: "", textColor: XDColor.itemTitle, fontSize: 17)
        contentView.addSubview(titleLabel)
        
        // logo
        logoView = UIImageView(frame: CGRect(x: 16, y: 16, width: 34, height: 34))
        contentView.addSubview(logoView)
        
        // 分割线
        let bottomLine = UIView(frame: CGRect(x: 0, y: contentView.height - XDSize.unitWidth, width: contentView.width, height: XDSize.unitWidth), color: XDColor.itemLine)
        bottomLine.autoresizingMask = [.flexibleWidth, .flexibleTopMargin]
        contentView.addSubview(bottomLine)
        
        // 箭头
        arrowImageView = UIImageView(image: UIImage(named: "item_right_arrow"))
        contentView.addSubview(arrowImageView)
        arrowImageView.snp.makeConstraints { (make) in
            make.right.equalTo(contentView).offset(-16)
            make.centerY.equalTo(contentView)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        if item?.sectionView === self {
            item?.sectionView = nil
        }
    }
    
    //MARK:- Action
    @objc func onBackButtonPressed(sender: UIButton) {
        if let item = item {
            item.isSelected = !item.isSelected
            arrowImageView.transform = item.isSelected ? CGAffineTransform(rotationAngle: .pi / 2) : CGAffineTransform.identity
            item.delegate?.sectionItemDidSelected(item: item)
        }
    }
}
