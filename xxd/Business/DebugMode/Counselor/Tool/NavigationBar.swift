//
//  NavigationBar.swift
//  counselor_t
//
//  Created by chenyusen on 2017/12/6.
//  Copyright © 2017年 TechSen. All rights reserved.
//

import UIKit

public class NavigationBarButtonItem: NSObject {
    var enable: Bool = true {
        didSet {
            if let contentView = contentView as? UIButton {
                contentView.isEnabled = enable
                contentView.setTitleColor(UIColor(0xC4C9CC),
                                          for:.disabled)
            }
        }
    }
    private(set) var contentView: UIView!
    var contentViewTintColor: UIColor? {
        didSet {
            if let contentView = contentView as? UIButton, let contentViewTintColor = contentViewTintColor {
                if contentView.currentTitle != nil {
                    contentView.setTitleColor(contentViewTintColor,
                                              for: .normal)
                }
                if contentView.currentImage != nil {
                    let image = contentView.currentImage!.tint(contentViewTintColor, blendMode: .destinationIn)
                    contentView.setImage(image, for: .normal)
//                    contentView.setImage(contentView.currentImage!.tint(contentViewTintColor),
//                                         for: .normal)
                }
            }
        }
    }
    public init(customView: UIView) {
        super.init()
        contentView = customView
    }
    
    public init(image: UIImage,
                target: Any,
                action: Selector,
                tintColor: UIColor? = nil
                ) {
        super.init()
        let imageView = UIImageView(image: image)
        contentView = wrapping(imageView, target: target, action: action)
        contentViewTintColor = tintColor
    }
    
    public init(title: String,
                target: Any,
                action: Selector,
                textColor: UIColor = DefaultConfig.Color.navigationBarItemTitle,
                fontSize: CGFloat = DefaultConfig.FontSize.navigationBarItemTitle,
                tintColor: UIColor? = nil
        ) {
        super.init()
        let titleLabel = UILabel()
        titleLabel.font = UIFont.systemFont(ofSize: fontSize)
        titleLabel.textColor = textColor
        titleLabel.text = title
        titleLabel.sizeToFit()
        contentView = wrapping(titleLabel, target: target, action: action)
        contentViewTintColor = tintColor
    }
    
    private func wrapping(_ view: UIView,
                          target: Any,
                          action: Selector) -> UIButton {
        let button: UIButton = UIButton()
        button.addTarget(target, action: action, for: .touchUpInside)
        if let view = view as? UIImageView, view.image != nil {
            button.setImage(view.image!, for: .normal)
        } else if let view = view as? UILabel {
            button.setTitle(view.text ?? "", for: .normal)
            button.setTitleColor(view.textColor, for: .normal)
            button.titleLabel?.font = view.font
        } else {
            button.addSubview(view)
            button.size = view.size
        }
        button.sizeToFit()
//        button.backgroundColor = UIColor.yellow.withAlphaComponent(0.5)
 
        let extendH = (35 - button.width) / 2
        let extendV = (35 - button.height) / 2
        
        button.extendTouchInsets = UIEdgeInsets(top: extendV > 0 ? extendV : 0,
                                                left: extendH > 0 ? extendH : 0,
                                                bottom: extendV > 0 ? extendV : 0,
                                                right: extendH > 0 ? extendH : 0)
        
        
        return button
    }
}

public class NavigationBar: UIView {
    public var bottomLine: UIView!
    public var centerView: UIView? {
        willSet {
            if newValue != centerView {
                centerView?.removeAllSubviews()
            }
        }
        didSet {
            contentView.addSubview(centerView!)
            centerView?.snp.makeConstraints({ (make) in
                make.center.equalToSuperview()
            })
        }
    }
    public var backgroundView: UIView!
    private weak var currentViewController: BaseViewController?
    public var itemTintColor: UIColor? {
        didSet {
            if let itemTintColor = itemTintColor {
                if let leftButtonItems = leftButtonItems {
                    leftButtonItems.forEach {
                        if $0.contentViewTintColor == nil {
                            $0.contentViewTintColor = itemTintColor
                        }
                    }
                }
                if let rightButtonItems = rightButtonItems {
                    rightButtonItems.forEach {
                        if $0.contentViewTintColor == nil {
                            $0.contentViewTintColor = itemTintColor
                        }
                    }
                }
            }
            
        }
    }
    public var transparent = false {
        didSet {
            backgroundView.isHidden = transparent
            bottomLine.isHidden = transparent
            if transparent, let viewController = self.currentViewController {
                viewController.topOffset = 0
            }
        }
    }
    private var contentView: UIView!
    var horizontalMargin: CGFloat = 16
    var horizontalPadding: CGFloat = 16
    var leftButtonItems: [NavigationBarButtonItem]? {
        didSet {
            oldValue?.forEach { $0.contentView.removeFromSuperview() }
            if let buttonItems = leftButtonItems, buttonItems.count > 0 {
                var lastView: UIView?
                buttonItems.forEach {
                    if let contentView = $0.contentView {
                        self.contentView.addSubview(contentView)
                        contentView.snp.makeConstraints({ (make) in
                            make.centerY.equalToSuperview()
                            if let lastView = lastView {
                                make.left.equalTo(lastView.snp.right).offset(horizontalPadding)
                            } else {
                                make.left.equalToSuperview().offset(horizontalMargin)
                            }
                        })
                        lastView = contentView
                    }
                }
            }
        }
    }
    var rightButtonItems: [NavigationBarButtonItem]? {
        didSet {
            oldValue?.forEach { $0.contentView.removeFromSuperview() }
            if let buttonItems = rightButtonItems, buttonItems.count > 0 {
                
                var lastView: UIView?
                buttonItems.forEach {
                    if let contentView = $0.contentView {
                        self.contentView.addSubview(contentView)
                        contentView.snp.makeConstraints({ (make) in
                            make.centerY.equalToSuperview()
                            if let lastView = lastView {
                                make.right.equalTo(lastView.snp.left).offset(-horizontalPadding)
                            } else {
                                make.right.equalToSuperview().offset(-horizontalMargin)
                            }
                        })
                        lastView = contentView
                    }
                }
            }
        }
    }
    
    var title: String? {
        didSet {
            centerView?.removeFromSuperview()
            let label = UILabel(frame: CGRect.zero, text: title, textColor: DefaultConfig.Color.navigationBarTitle, fontSize: DefaultConfig.FontSize.navigationBarTitle, bold: true)
            centerView = label
        }
    }

    init(frame: CGRect,
         viewController: BaseViewController? = nil) {
        super.init(frame: frame)
        self.currentViewController = viewController
        backgroundView = UIView()
        backgroundView.isUserInteractionEnabled = false
        backgroundView.backgroundColor = DefaultConfig.Color.navgationBarBackground
        addSubview(backgroundView)
        backgroundView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        contentView = UIView() // 内容视图区域
        addSubview(contentView)
        contentView.snp.makeConstraints { (make) in
            make.left.right.bottom.equalToSuperview()
            make.top.equalTo(UIApplication.shared.statusBarFrame.height)
        }
    
        bottomLine = UIView() // 底部分割线
        bottomLine.backgroundColor = UIColor(0xC4C9CC)
        addSubview(bottomLine)
        bottomLine.snp.makeConstraints { (make) in
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(XDSize.unitWidth)
        }
    }
    
    override public func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        for subView in contentView.subviews {
            let convertPoint = convert(point, to: subView)
            if subView.point(inside: convertPoint, with: event) {
                return subView
            }
        }
        return nil
    }
    
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
