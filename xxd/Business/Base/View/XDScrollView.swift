//
//  XDScrollView.swift
//  xxd
//
//  Created by remy on 2018/1/10.
//  Copyright © 2018年 com.smartstudy. All rights reserved.
//

class XDScrollView: UIScrollView {
    
    var bottomSpace: CGFloat = 0
    private var scrollContentBottom: CGFloat = 0
    private var keyboardMask: CGFloat = 0
    var contentBottom: CGFloat {
        return contentSize.height - bottomSpace
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.clear
        showsHorizontalScrollIndicator = false
        showsVerticalScrollIndicator = false
        alwaysBounceVertical = true
        scrollsToTop = false
        keyboardDismissMode = .onDrag
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func addSubview(_ view: UIView) {
        super.addSubview(view)
        if view.bottom > contentBottom {
            scrollContentBottom = view.bottom + bottomSpace
            contentSize = CGSize(width: width, height: scrollContentBottom)
        }
    }
    
    func scrollToViewOnFocus(view: UIView) {
        var bottom = view.bottom
        var superview = view
        while true {
            if let view = superview.superview {
                if view == self {
                    DispatchQueue.main.async(execute: {
                        let offsetY = self.keyboardMask - (self.height - (bottom - self.contentOffset.y))
                        if self.keyboardMask > 0 && offsetY > 0 {
                            self.contentOffset = CGPoint(x: 0, y: offsetY + self.contentOffset.y)
                        }
                    })
                    break
                } else {
                    bottom += view.top
                }
                superview = view
                continue
            }
            break
        }
    }
    
    func updateContentSize(subview: UIView) {
        scrollContentBottom = subview.bottom + bottomSpace
        contentSize = CGSize(width: width, height: scrollContentBottom)
    }
    
    //MARK:- Notification
    @objc private func keyboardWillShow(notification: Notification) {
        if let topVC = UIApplication.topVC() as? SSViewController, topVC === self.viewController() {
            let rect = notification.userInfo![UIKeyboardFrameEndUserInfoKey] as! CGRect
            keyboardMask = screenViewY + height - rect.origin.y
            if topVC.isCustomKeyboard {
                keyboardMask += topVC.keyboardTopView!.height
            }
            if keyboardMask > 0 && keyboardMask > height - scrollContentBottom {
                contentSize = CGSize(width: width, height: scrollContentBottom + keyboardMask)
            }
        }
    }
    
    @objc private func keyboardWillHide(notification: Notification) {
        if let topVC = UIApplication.topVC() as? SSViewController, topVC === self.viewController() {
            contentSize = CGSize(width: width, height: scrollContentBottom)
        }
    }
}
