//
//  GpaDescSectionItem.swift
//  xxd
//
//  Created by remy on 2018/1/30.
//  Copyright © 2018年 com.smartstudy. All rights reserved.
//

let kEventFormulaSectionTap = "kEventFormulaSectionTap"

class GpaDescSectionItem: NSObject {
    
    var index = 0
    var isSelected = false {
        willSet {
            if newValue != isSelected {
                sectionView?.item = self
            }
        }
    }
    var model: GpaDescModel!
    weak var sectionView: GpaDescSectionItemHeader?
}

class GpaDescSectionItemHeader: UITableViewHeaderFooterView {
    
    var item: GpaDescSectionItem? {
        didSet {
            if let item = item {
                item.sectionView = self
                titleLabel.text = item.model.name
                self.arrowImageView.transform = item.isSelected ? CGAffineTransform(rotationAngle: CGFloat.pi / 2) : CGAffineTransform.identity
            }
        }
    }
    weak var delegate: CourseOutlineSectionViewDelegate?
    private var titleLabel: UILabel!
    private var itemView: UIButton!
    private var arrowImageView: UIImageView!
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        contentView.backgroundColor = UIColor.white
        backgroundView = nil
        
        // 点击区域
        itemView = UIButton(frame: contentView.bounds, title: "", fontSize: 0, titleColor: UIColor.clear, target: self, action: #selector(itemTap(sender:)))
        itemView.setBackgroundColor(XDColor.itemLine, for: .highlighted)
        itemView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        contentView.addSubview(itemView)
        
        // 标题
        titleLabel = UILabel(text: "", textColor: XDColor.itemTitle, fontSize: 16)
        itemView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (make) in
            make.left.equalTo(itemView).offset(16)
            make.centerY.equalTo(itemView)
        }
        
        // 箭头
        arrowImageView = UIImageView(image: UIImage(named: "blue_right_arrow"))
        itemView.addSubview(arrowImageView)
        arrowImageView.snp.makeConstraints { (make) in
            make.right.equalTo(itemView).offset(-19)
            make.centerY.equalTo(itemView)
        }
        
        // 分割线
        let bottomLine = UIView(frame: CGRect(x: 0, y: contentView.height - XDSize.unitWidth, width: contentView.width, height: XDSize.unitWidth), color: XDColor.itemLine)
        bottomLine.autoresizingMask = [.flexibleWidth, .flexibleTopMargin]
        contentView.addSubview(bottomLine)
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
    @objc func itemTap(sender: UIButton) {
        if let item = item {
            item.isSelected = !item.isSelected
            arrowImageView.transform = item.isSelected ? CGAffineTransform(rotationAngle: .pi / 2) : CGAffineTransform.identity
            routerEvent(name: kEventFormulaSectionTap, data: ["item":item])
        }
    }
}
