//
//  ChatPopView.swift
//  counselor_t
//
//  Created by chenyusen on 2018/2/6.
//  Copyright © 2018年 TechSen. All rights reserved.
//

import UIKit


private let buttonW: CGFloat = 59
private let buttonH: CGFloat = 36


protocol ChatPopViewDelegate: class {
    func chatPopView(didPressed buttonType: ChatPopView.ButtonType)
}

class ChatPopView: UIView {
    static let shared = ChatPopView()
    weak var delegate: ChatPopViewDelegate?
    weak var referView: UIView?
    
    class ChatPopViewButton : UIButton {
        var stateChangeBlock: ((UIControlState) -> ())?
        
        override var isHighlighted: Bool {
            didSet {
                stateChangeBlock?(state)
            }
        }
    }
    
    enum ButtonType: String {
        case copy = "复制"
        case transpond = "转发"
        case recall = "撤回"
        case delete = "删除"
        case edit = "编辑"
    }
    
    var bgView: UIImageView!
    var triangleImageView: UIImageView!
    var itemViews: [UIView] = []
    var isDimsissing = false
    var isResistant = false
    
    var isDisplaying: Bool {
        return self.superview != nil
    }
    
    override init(frame: CGRect) {
        super.init(frame: CGRect.zero)
        
        
        // 背景矩形
        var bgImage = UIImage(named: "chat_pop_view")!
        bgImage = bgImage.resizableImage(withCapInsets: UIEdgeInsetsMake(bgImage.size.height * 0.5, 10, bgImage.size.height * 0.5, 10))
        bgView = UIImageView(image: bgImage)
        bgView.isUserInteractionEnabled = true
        bgView.layer.cornerRadius = 8
        bgView.layer.masksToBounds = true
        addSubview(bgView)
        
        // 底部三角形
        let triangleImage = UIImage(named: "chat_pop_view_triangle")
        triangleImageView = UIImageView(image: triangleImage)
        let hightImage = triangleImage?.tint(UIColor(0x9d9d9d))
        triangleImageView.highlightedImage = hightImage
        triangleImageView.top = buttonH
        addSubview(triangleImageView)
        
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setButtonTypes(_ buttonTypes: [ButtonType]) {
        bgView.layer.mask = nil
        itemViews.forEach { $0.removeFromSuperview() }
        
        for (index, buttonType) in buttonTypes.enumerated() {
            let button = ChatPopViewButton()
            button.setTitle(buttonType.rawValue, for: .normal)
            button.titleLabel?.font = UIFont.systemFont(ofSize: 14)
            button.setTitleColor(.white, for: .normal)
            button.setBackgroundColor(UIColor(0x9d9d9d), for: .highlighted)
            button.addTarget(self, action: #selector(buttonPressed(_:)), for: .touchUpInside)
            button.frame = CGRect(x: CGFloat(index) * (buttonW+XDSize.unitWidth),
                                  y: 0.0,
                                  width: buttonW,
                                  height: buttonH)
            button.stateChangeBlock = { [weak self] state in
                guard let sSelf = self else { return }
                if sSelf.triangleImageView.left >= button.left && sSelf.triangleImageView.right <= button.right {
                    sSelf.triangleImageView.isHighlighted = state == .highlighted
                }
            }
            bgView.addSubview(button)
            itemViews.append(button)

            // 添加白色分割线
            if index != buttonTypes.count - 1 {
                let line = UIView()
                line.backgroundColor = .white
                line.frame = CGRect(x: button.right, y: 0.0, width: XDSize.unitWidth, height: buttonH)
                bgView.addSubview(line)
                itemViews.append(line)
            } else {
                button.width -= XDSize.unitWidth
            }
        }
        
        self.frame = CGRect(origin: CGPoint.zero, size: CGSize(width: itemViews.last?.right ?? 100, height: buttonH + 9))
        bgView.frame = CGRect(origin: CGPoint.zero, size: CGSize(width: self.width, height: buttonH))
        triangleImageView.centerX = self.width * 0.5
        
        
//        let layer = CAShapeLayer()
//        layer.frame = bgView.bounds
//
//        layer.contents = newImage.cgImage
//        layer.contentsCenter = CGRect(x: 0, y: 0, width: 1, height: 1)
//        layer.contentsScale = UIScreen.main.scale
//        bgView.layer.mask = layer
    }
    
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        if !bounds.contains(point) {
                self.dismiss()
        }
        return super.hitTest(point, with: event)
    }
    
    
    func show(referTo view: UIView) {
        referView = view
        // 参照试图相对于其最在的控制器的试图的绝对frame
        guard let referViewSuperView = view.superview else { return }
        guard let window = view.window else { return }
        let viewRect = referViewSuperView.convert(view.frame, to: window)
        
        self.centerX = viewRect.midX
        self.bottom = viewRect.minY + 3
        
        let minPadding: CGFloat = 10
        // 如果此时太贴近屏幕右侧
        let rightDelta = window.width - self.right
        if rightDelta < minPadding {
            let distance = minPadding - rightDelta
            self.right -= distance
            triangleImageView.right += distance
        }
        
        if self.left < minPadding {
            let distance = minPadding - self.left
            self.left += distance
            triangleImageView.left -= distance
        }
        
        // 如果超出了tableview的顶部范围, 则放到气泡底部显示
        if let vcView = view.viewController?.view,
            let chatView = (view.viewController as? ChatViewController)?.tableView as? ChatListView {
            let chatViewAbFrame = vcView.convert(chatView.frame, to: window)
            if self.top < chatViewAbFrame.minY {
                triangleImageView.top = 0
                bgView.top = triangleImageView.bottom
                triangleImageView.transform = CGAffineTransform(rotationAngle: CGFloat.pi)
                self.top = viewRect.maxY - 3
            } else {
                bgView.top = 0
                triangleImageView.transform = CGAffineTransform.identity
                triangleImageView.top = bgView.bottom
            }
        }
        
        
        window.addSubview(self)
        self.alpha = 0

        UIView.animate(withDuration: 0.1, delay: 0, options: .curveEaseIn, animations: {
            self.alpha = 1
        })
    }
    
    
    func dismiss() {
        if superview == nil { return }
        if isDimsissing { return }
        isDimsissing = true
        if let bubbleView = self.referView as? ChatBubbleView {
            bubbleView.showCover = false
        }
        UIView.animate(withDuration: 0.1, delay: 0, options: .curveEaseIn, animations: {
            self.alpha = 0
            
        }) { [weak self] (finished) in
            if finished {
                guard let sSelf = self else { return }
                sSelf.removeFromSuperview()
                sSelf.isDimsissing = false
                sSelf.delegate = nil
                
                if let vc = sSelf.referView?.viewController as? ChatViewController,
                    let chatView = vc.tableView as? ChatListView,
                    sSelf.isResistant {
                    chatView.scrollToBottomMessage(animated: true)
                }
                
                sSelf.referView = nil
                sSelf.isResistant = false
                
                
            }
        }
    }

    @objc func buttonPressed(_ sender: UIButton) {
        dismiss()
        let type = ButtonType(rawValue: sender.currentTitle!)
        delegate?.chatPopView(didPressed: type!)
    }
}
