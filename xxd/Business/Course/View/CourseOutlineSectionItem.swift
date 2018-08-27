//
//  CourseOutlineSectionItem.swift
//  xxd
//
//  Created by remy on 2018/1/22.
//  Copyright © 2018年 com.smartstudy. All rights reserved.
//

import SnapKit

class CourseOutlineSectionItem: NSObject {
    
    var index = 0
    var title = ""
    var isSelected = false {
        willSet {
            if newValue != isSelected {
                cellItems = newValue ? realCellItems : [CourseOutlineItem]()
                sectionView?.item = self
            }
        }
    }
    var cellItems = [CourseOutlineItem]()
    var realCellItems = [CourseOutlineItem]()
    weak var sectionView: CourseOutlineSectionView?
    var isUserInteractionEnabled = false
}

protocol CourseOutlineSectionViewDelegate: class {
    
    func courseOutlineSectionViewDidPress(item: CourseOutlineSectionItem)
}

class CourseOutlineSectionView: UITableViewHeaderFooterView {
    
    var item: CourseOutlineSectionItem? {
        didSet {
            if let item = item {
                item.sectionView = self
                titleLabel.text = item.title
                backButton.isUserInteractionEnabled = item.isUserInteractionEnabled
                arrowImageView.isHidden = !item.isUserInteractionEnabled
                UIView.animate(withDuration: 0.1, animations: {
                    [unowned self] in
                    self.arrowImageView.transform = item.isSelected ? CGAffineTransform(rotationAngle: CGFloat.pi / 2) : CGAffineTransform.identity
                })
            }
        }
    }
    weak var delegate: CourseOutlineSectionViewDelegate?
    private var titleLabel: UILabel!
    private var backButton: UIButton!
    private var arrowImageView: UIImageView!
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        contentView.backgroundColor = UIColor.white
        backgroundView = nil
        
        // 点击区域
        backButton = UIButton(frame: contentView.bounds, title: "", fontSize: 0, titleColor: UIColor.clear, target: self, action: #selector(onBackButtonPressed(sender:)))
        backButton.setBackgroundColor(XDColor.itemLine, for: .highlighted)
        backButton.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        contentView.insertSubview(backButton, at: 0)
        
        // 标题
        titleLabel = UILabel(frame: CGRect(x: 16, y: 0, width: XDSize.screenWidth - 80, height: 56), text: "", textColor: XDColor.itemTitle, fontSize: 16)
        contentView.addSubview(titleLabel)
        
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
        item = nil
        super.prepareForReuse()
    }
    
    //MARK:- Action
    @objc func onBackButtonPressed(sender: UIButton) {
        if let item = item {
            item.isSelected = !item.isSelected
            UIView.animate(withDuration: 0.1, animations: {
                [unowned self] in
                self.arrowImageView.transform = item.isSelected ? CGAffineTransform(rotationAngle: CGFloat.pi / 2) : CGAffineTransform.identity
            })
            delegate?.courseOutlineSectionViewDidPress(item: item)
        }
    }
}
