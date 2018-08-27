//
//  XDItemView.swift
//  xxd
//
//  Created by remy on 2017/12/19.
//  Copyright © 2017年 com.smartstudy. All rights reserved.
//

import SnapKit

enum XDLineType: Int {
    case plain, single, top, middle, bottom
}

protocol XDLineStyle: class {
    
    var topLine: UIView { get set }
    var bottomLine: UIView { get set }
    var lineType: XDLineType? { get set }
    func lineViewLayout(_ type: XDLineType?)
}

extension XDLineStyle where Self: UIView {
    var topLine: UIView {
        set {
            objc_setAssociatedObject(self, &topLineKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        get {
            if let view = objc_getAssociatedObject(self, &topLineKey) as? UIView {
                return view
            } else {
                let view = UIView(frame: .null, color: XDColor.itemLine)
                self.topLine = view
                return view
            }
        }
    }
    var bottomLine: UIView {
        set {
            objc_setAssociatedObject(self, &bottomLineKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        get {
            if let view = objc_getAssociatedObject(self, &bottomLineKey) as? UIView {
                return view
            } else {
                let view = UIView(frame: .null, color: XDColor.itemLine)
                view.autoresizingMask = .flexibleTopMargin
                self.bottomLine = view
                return view
            }
        }
    }
    var lineType: XDLineType? {
        set {
            objc_setAssociatedObject(self, &lineTypeKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            lineViewLayout(newValue)
        }
        get {
            return objc_getAssociatedObject(self, &lineTypeKey) as? XDLineType
        }
    }
    func lineViewLayout(_ type: XDLineType?) {
        topLine.removeFromSuperview()
        bottomLine.removeFromSuperview()
        guard let type = type else { return }
        switch type {
        case .single:
            addSubview(topLine)
            addSubview(bottomLine)
            topLine.snp.makeConstraints({ (make) in
                make.top.left.right.equalTo(self)
                make.height.equalTo(XDSize.unitWidth)
            })
            bottomLine.snp.makeConstraints({ (make) in
                make.bottom.left.right.equalTo(self)
                make.height.equalTo(XDSize.unitWidth)
            })
        case .top:
            addSubview(topLine)
            addSubview(bottomLine)
            topLine.snp.makeConstraints({ (make) in
                make.top.left.right.equalTo(self)
                make.height.equalTo(XDSize.unitWidth)
            })
            bottomLine.snp.makeConstraints({ (make) in
                make.bottom.right.equalTo(self)
                make.left.equalTo(self).offset(16)
                make.height.equalTo(XDSize.unitWidth)
            })
        case .middle:
            topLine.isHidden = true
            addSubview(bottomLine)
            bottomLine.snp.makeConstraints({ (make) in
                make.bottom.right.equalTo(self)
                make.left.equalTo(self).offset(16)
                make.height.equalTo(XDSize.unitWidth)
            })
        case .bottom:
            topLine.isHidden = true
            addSubview(bottomLine)
            bottomLine.snp.makeConstraints({ (make) in
                make.bottom.left.right.equalTo(self)
                make.height.equalTo(XDSize.unitWidth)
            })
        default:
            topLine.isHidden = true
            bottomLine.isHidden = true
        }
    }
}

private var topLineKey: UInt8 = 0
private var bottomLineKey: UInt8 = 0
private var lineTypeKey: UInt8 = 0

class XDItemView: UIView, XDLineStyle {
    
    var rightArrow: UIImageView!
    var info: [String: Any]!

    var enabled = true {
        didSet {
            self.alpha = enabled ? 1 : 0.5
            self.isUserInteractionEnabled = enabled
        }
    }
    
    var isRightArrow = false {
        didSet {
            if isRightArrow {
                addSubview(rightArrow)
            } else {
                rightArrow.isHidden = true
                rightArrow.removeFromSuperview()
            }
        }
    }
    
    convenience init(frame: CGRect, type: XDLineType = .plain) {
        self.init(frame: frame)
        self.backgroundColor = UIColor.white
        lineType = type
        rightArrow = UIImageView(frame: CGRect(x: width - 25, y: (height - 15) * 0.5, width: 9, height: 15), imageName: "item_right_arrow")!
    }
}
