//
//  XDTopBarView.swift
//  xxd
//
//  Created by remy on 2018/1/4.
//  Copyright © 2018年 com.smartstudy. All rights reserved.
//

private let TOP_BAR_LEFT_VIEW_TAG = 1200
private let TOP_BAR_RIGHT_VIEW_TAG = 1201
private let TOP_BAR_CENTER_VIEW_TAG = 1202
private let TOP_BAR_SUB_LEFT_VIEW_TAG = 1203

class XDTopBarViewItem {
    
    var text: String?
    var subText: String?
    var textColor: UIColor?
    var image: UIImage?
    var customView: UIView?
    weak var target: AnyObject?
    var action: Selector?
    var subAction: Selector?
}

class XDTopBarView: UIView {
    
    var centerItem = XDTopBarViewItem()
    let leftItem = XDTopBarViewItem()
    let rightItem = XDTopBarViewItem()
    var backgroundView: UIView? {
        didSet {
            if let view = backgroundView, view != oldValue {
                view.frame = bounds
                view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
                insertSubview(view, at: 0)
            }
        }
    }
    let bottomLine = UIView()
    var centerTitle: String? {
        didSet {
            centerItem.text = centerTitle
            setNeedsLayout()
        }
    }
    var subLeftText: String? {
        didSet {
            leftItem.subText = subLeftText
            setNeedsLayout()
        }
    }
    private var _centerView: UIView?
    private(set) var centerView: UIView? {
        get {
            if let v = _centerView {
                return v
            }
            return centerItem.customView
        }
        set {
            _centerView = newValue
        }
    }
    
    convenience init() {
        self.init(frame: CGRect(x: 0, y: 0, width: XDSize.screenWidth, height: XDSize.topHeight))
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.white
        bottomLine.frame = CGRect(x: 0, y: height - XDSize.unitWidth, width: width, height: XDSize.unitWidth)
        bottomLine.backgroundColor = XDColor.mainLine
        bottomLine.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(bottomLine)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        viewWithTag(TOP_BAR_LEFT_VIEW_TAG)?.removeFromSuperview()
        viewWithTag(TOP_BAR_RIGHT_VIEW_TAG)?.removeFromSuperview()
        viewWithTag(TOP_BAR_CENTER_VIEW_TAG)?.removeFromSuperview()
        
        if let customView = leftItem.customView {
            customView.tag = TOP_BAR_LEFT_VIEW_TAG
            addSubview(customView)
        } else if leftItem.text != nil || leftItem.image != nil {
            let buttonView = UIButton(type: .custom)
            buttonView.contentHorizontalAlignment = .left
            buttonView.tag = TOP_BAR_LEFT_VIEW_TAG
            if let action = leftItem.action {
                buttonView.addTarget(leftItem.target, action: action, for: .touchUpInside)
            }
            addSubview(buttonView)
            var width: CGFloat = 20
            if let text = leftItem.text, text.count > 0 {
                buttonView.titleLabel?.font = UIFont.systemFont(ofSize: 16)
                let textColor = leftItem.textColor ?? XDColor.main
                buttonView.setTitleColor(textColor, for: .normal)
                buttonView.setTitleColor(textColor, for: .highlighted)
                buttonView.setTitle(text, for: .normal)
                buttonView.titleEdgeInsets = UIEdgeInsetsMake(0, 16, 0, 0)
                width += text.widthForFont(UIFont.systemFont(ofSize: 16))
            }
            if let image = leftItem.image {
                buttonView.setImage(image, for: .normal)
                buttonView.setImage(image, for: .highlighted)
                buttonView.imageEdgeInsets = UIEdgeInsetsMake(0, 16, 0, 0)
                if width > 20 {
                    buttonView.titleEdgeInsets = UIEdgeInsetsMake(0, 20, 0, 0)
                    width += 4
                }
                width += image.size.width
            }
            buttonView.frame = CGRect(x: 0, y: XDSize.statusBarHeight, width: width, height: XDSize.topBarHeight)
            if let text = leftItem.subText, text.count > 0 {
                let buttonView = UIButton(type: .custom)
                buttonView.tag = TOP_BAR_SUB_LEFT_VIEW_TAG
                buttonView.titleLabel?.font = UIFont.systemFont(ofSize: 16)
                let textColor = leftItem.textColor ?? XDColor.main
                buttonView.setTitleColor(textColor, for: .normal)
                buttonView.setTitleColor(textColor, for: .highlighted)
                buttonView.setTitle(text, for: .normal)
                let subWidth = text.widthForFont(UIFont.systemFont(ofSize: 16))
                buttonView.frame = CGRect(x: width, y: XDSize.statusBarHeight, width: subWidth + 4, height: XDSize.topBarHeight)
                if let action = leftItem.subAction {
                    buttonView.addTarget(leftItem.target, action: action, for: .touchUpInside)
                }
                addSubview(buttonView)
            }
        }
        
        if let customView = rightItem.customView {
            customView.tag = TOP_BAR_RIGHT_VIEW_TAG
            addSubview(customView)
        } else if rightItem.text != nil || rightItem.image != nil {
            let buttonView = UIButton(type: .custom)
            buttonView.contentHorizontalAlignment = .right
            buttonView.tag = TOP_BAR_RIGHT_VIEW_TAG
            if let action = rightItem.action {
                buttonView.addTarget(rightItem.target, action: action, for: .touchUpInside)
            }
            addSubview(buttonView)
            var width: CGFloat = 20
            if let text = rightItem.text, text.count > 0 {
                buttonView.titleLabel?.font = UIFont.systemFont(ofSize: 16)
                let textColor = rightItem.textColor ?? XDColor.main
                buttonView.setTitleColor(textColor, for: .normal)
                buttonView.setTitleColor(textColor, for: .highlighted)
                buttonView.setTitle(text, for: .normal)
                buttonView.titleEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 16)
                width += text.widthForFont(UIFont.systemFont(ofSize: 16))
            } else if let image = rightItem.image {
                buttonView.setImage(image, for: .normal)
                buttonView.setImage(image, for: .highlighted)
                buttonView.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 16)
                width += image.size.width
            }
            buttonView.frame = CGRect(x: self.width - width, y: XDSize.statusBarHeight, width: width, height: XDSize.topBarHeight)
        }
        
        if let customView = centerItem.customView {
            customView.tag = TOP_BAR_CENTER_VIEW_TAG
            addSubview(customView)
        } else if let text = centerItem.text, text.count > 0 {
            let labelView = UILabel()
            labelView.font = UIFont.boldSystemFont(ofSize: 17)
            labelView.textAlignment = .left
            labelView.textColor = centerItem.textColor ?? XDColor.itemTitle
            labelView.tag = TOP_BAR_CENTER_VIEW_TAG
            labelView.text = text
            
            var left = (viewWithTag(TOP_BAR_LEFT_VIEW_TAG)?.width ?? 0) + (viewWithTag(TOP_BAR_SUB_LEFT_VIEW_TAG)?.width ?? 0) + 8
            let right = (viewWithTag(TOP_BAR_RIGHT_VIEW_TAG)?.width ?? 0) + 8
            let textWidth = text.widthForFont(UIFont.boldSystemFont(ofSize: 17))
            let width = self.width - left - right
            var space = width - textWidth
            if space > 0 {
                space = CGFloat.minimum((space + right - left) / 2, space)
                left = CGFloat.maximum(left + space, left)
                labelView.frame = CGRect(x: left, y: XDSize.statusBarHeight, width: textWidth, height: XDSize.topBarHeight)
            } else {
                labelView.frame = CGRect(x: left, y: XDSize.statusBarHeight, width: width, height: XDSize.topBarHeight)
            }
            centerView = labelView
            addSubview(labelView)
        }
    }
}
