//
//  TargetCollegeTypeSelectorView.swift
//  xxd
//
//  Created by remy on 2018/2/2.
//  Copyright © 2018年 com.smartstudy. All rights reserved.
//

protocol TargetCollegeTypeSelectorViewDelegate: class {
    
    func targetCollegeTypeSelectorView(model: TargetCollegeModel, type: TargetCollegeType)
}

class TargetCollegeTypeSelectorViewButton: UIButton {
    
    var textLabel: UILabel!
    var dotView: UIView!
    var type: TargetCollegeType! {
        didSet {
            let info = typeStringWithType(type)
            textLabel.text = info.type
            dotView.backgroundColor = info.color
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        textLabel = UILabel(text: "", textColor: XDColor.itemTitle, fontSize: 15)
        addSubview(textLabel)
        
        dotView = UIView()
        addSubview(dotView)
        
        dotView.layer.cornerRadius = 3.5
        
        setBackgroundColor(UIColor.white, for: .normal)

        setBackgroundColor(XDColor.itemLine, for: .highlighted)
        setBackgroundColor(XDColor.itemLine, for: .selected)
        setBackgroundColor(XDColor.itemLine, for: [.selected, .highlighted])
        
        textLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(self)
            make.left.equalTo(dotView.snp.right).offset(18)
        }
        
        dotView.snp.makeConstraints { (make) in
            make.centerY.equalTo(self)
            make.left.equalTo(self).offset(29)
            make.size.equalTo(CGSize(width: 7, height: 7))
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func typeStringWithType(_ type: TargetCollegeType) -> (type: String, color: UIColor) {
        switch type {
        case .top:
            return ("user_target_match_top".localized, UIColor(0xF6511D))
        case .middle:
            return ("user_target_match_middle".localized, UIColor(0x1781F1))
        case .bottom:
            return ("user_target_match_bottom".localized, UIColor(0x2FCB86))
        case .remove:
            return ("user_target_remove".localized, UIColor(0xCCCCCC))
        }
    }
}

class TargetCollegeTypeSelectorView: UIView {
    
    weak var delegate: TargetCollegeTypeSelectorViewDelegate?
    var buttons = [TargetCollegeTypeSelectorViewButton]()
    var model: TargetCollegeModel! {
        didSet {
            for btn in buttons {
                btn.isSelected = btn.type == model.targetCollegeType
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        let buttonTypes: [TargetCollegeType] = [.top, .middle, .bottom, .remove]
        for type in buttonTypes {
            let btn = TargetCollegeTypeSelectorViewButton()
            btn.addTarget(self, action: #selector(onColleageTypeButtonPressed(sender:)), for: .touchUpInside)
            btn.type = type
            addSubview(btn)
            
            btn.snp.makeConstraints { (make) in
                make.height.equalTo(self).multipliedBy(1 / CGFloat(buttonTypes.count))
                make.left.right.equalTo(self)
                if let lastBtn = buttons.last {
                    make.top.equalTo(lastBtn.snp.bottom)
                } else {
                    make.top.equalTo(self)
                }
            }
            
            buttons.append(btn)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK:- Action
    @objc func onColleageTypeButtonPressed(sender: UIButton) {
        let type = (sender as! TargetCollegeTypeSelectorViewButton).type!
        delegate?.targetCollegeTypeSelectorView(model: model, type: type)
    }
}
