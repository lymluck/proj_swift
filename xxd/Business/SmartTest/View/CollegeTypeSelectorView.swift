//
//  CollegeTypeSelectorView.swift
//  xxd
//
//  Created by remy on 2018/2/9.
//  Copyright © 2018年 com.smartstudy. All rights reserved.
//

private let ITEM_TYPE_TAG_BASE = 1000

protocol CollegeTypeSelectorViewDelegate: class {
    
    func collegeTypeDidSelected(typeId: String)
}

class CollegeTypeSelectorView: UIView {
    
    weak var delegate: CollegeTypeSelectorViewDelegate?
    
    convenience init() {
        self.init(frame: CGRect(x: (XDSize.screenWidth - 295) * 0.5, y: (XDSize.screenHeight - 240) * 0.5, width: 295, height: 240))
        let typeList = ["user_target_match_top_college", "user_target_match_middle_college", "user_target_match_bottom_college"]
        let typeColorList = [0xF6511D, 0x1781F1, 0x2FCB86]
        backgroundColor = UIColor.white
        layer.cornerRadius = 6
        layer.shadowOpacity = 0.18
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowRadius = 8
        layer.shadowOffset = CGSize(width: 0, height: 8)
        
        let titleLabel = UILabel(frame: CGRect(x: 30, y: 0, width: width, height: 72), text: "user_target_add".localized, textColor: XDColor.main, fontSize: 17, bold: true)!
        addSubview(titleLabel)
        addSubview(UIView(frame: CGRect(x: 0, y: titleLabel.bottom - XDSize.unitWidth, width: width, height: XDSize.unitWidth), color: XDColor.itemLine))
        
        for (index, type) in typeList.enumerated() {
            let item = UIView(frame: CGRect(x: 0, y: 72 + CGFloat(56 * index), width: width, height: 56))
            item.tag = ITEM_TYPE_TAG_BASE + index
            item.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(itemTap(gestureRecognizer:))))
            addSubview(item)
            
            let textLabel = UILabel(frame: CGRect(x: 48, y: 0, width: item.width - 54, height: item.height), text: type.localized, textColor: XDColor.itemTitle, fontSize: 15)!
            item.addSubview(textLabel)
            
            let color = UIColor(typeColorList[index])
            let dotView = UIView(frame: CGRect(x: 30, y: 24, width: 8, height: 8), color: color)
            dotView.layer.cornerRadius = 4
            item.addSubview(dotView)
        }
    }
    
    //MARK:- Action
    @objc func itemTap(gestureRecognizer: UIGestureRecognizer) {
        let index = gestureRecognizer.view!.tag - ITEM_TYPE_TAG_BASE
        let typeId = ["MS_MATCH_TYPE_TOP","MS_MATCH_TYPE_MIDDLE","MS_MATCH_TYPE_BOTTOM"][index]
        delegate?.collegeTypeDidSelected(typeId: typeId)
    }
}
