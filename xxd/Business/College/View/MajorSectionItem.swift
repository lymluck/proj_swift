//
//  MajorSectionItem.swift
//  xxd
//
//  Created by remy on 2018/2/14.
//  Copyright © 2018年 com.smartstudy. All rights reserved.
//

protocol MajorSectionItemDelegate: class {
    
    func sectionItemDidSelected(item: MajorSectionItem)
}

class MajorSectionItem: NSObject {
    
    var index = 0
    var isSelected = false {
        willSet {
            if newValue != isSelected {
                sectionView?.item = self
            }
        }
    }
    var model: MajorModel!
    weak var delegate: MajorSectionItemDelegate?
    weak var sectionView: MajorSectionView?
}

class MajorSectionView: UITableViewHeaderFooterView {

    var item: MajorSectionItem? {
        didSet {
            if let item = item {
                item.sectionView = self
                arrowImageView.transform = item.isSelected ? CGAffineTransform(rotationAngle: .pi / 2) : CGAffineTransform.identity
                titleLabel.text = item.model.name
            }
        }
    }
    private var backButton: UIButton!
    private var titleLabel: UILabel!
    private var arrowImageView: UIImageView!
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        contentView.backgroundColor = UIColor.white
        
        // 点击区域
        backButton = UIButton(frame: contentView.bounds, title: "", fontSize: 0, titleColor: UIColor.clear, target: self, action: #selector(onBackButtonPressed(sender:)))!
        backButton.setBackgroundColor(XDColor.itemLine, for: .highlighted)
        backButton.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        contentView.insertSubview(backButton, at: 0)
        
        // 标题
        titleLabel = UILabel(frame: CGRect(x: 17, y: 0, width: XDSize.screenWidth - 80, height: 64), text: "", textColor: XDColor.itemTitle, fontSize: 17)
        contentView.addSubview(titleLabel)
        
        // 分割线
        let bottomLine = UIView(frame: CGRect(x: 0, y: contentView.height - XDSize.unitWidth, width: contentView.width, height: XDSize.unitWidth), color: XDColor.itemLine)
        bottomLine.autoresizingMask = [.flexibleWidth, .flexibleTopMargin]
        contentView.addSubview(bottomLine)
        
        // 竖线
        let vLine = UIView(frame: CGRect(x: 0, y: 0, width: 4, height: contentView.height), color: XDColor.main)
        vLine.autoresizingMask = .flexibleHeight
        contentView.addSubview(vLine)
        
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
