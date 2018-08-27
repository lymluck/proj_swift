//
//  SSViewControllerEx.swift
//  xxd
//
//  Created by remy on 2018/1/3.
//  Copyright © 2018年 com.smartstudy. All rights reserved.
//

private var topBarViewKey: UInt8 = 0
private var keyboardTopViewKey: UInt8 = 0
private var customKeyboardKey: UInt8 = 0

extension SSViewController {
    
    var navigationBar: XDTopBarView! {
        get {
            return objc_getAssociatedObject(self, &topBarViewKey) as? XDTopBarView
        }
        set {
            objc_setAssociatedObject(self, &topBarViewKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    override open func loadView() {
        super.loadView()
        view.backgroundColor = XDColor.mainBackground
        if needNavigationBar() {
            createNavigationBar()
            topOffset = XDSize.topHeight
        }
    }
    
    @objc func needNavigationBar() -> Bool {
        return true
    }
    
    private func createNavigationBar() {
        let navigationBar = XDTopBarView()
        navigationBar.autoresizingMask = [.flexibleBottomMargin, .flexibleWidth]
        let num = navigationController?.viewControllers.count ?? 0
        if isModal() && num <= 1 {
            navigationBar.leftItem.text = "cancel".localized
            navigationBar.leftItem.target = self
            navigationBar.leftItem.action = #selector(cancelActionTap)
            navigationBar.leftItem.subAction = #selector(subLeftActionTap)
        } else {
            if num > 1 {
                navigationBar.leftItem.image = UIImage(named: "top_left_arrow")
                navigationBar.leftItem.target = self
                navigationBar.leftItem.action = #selector(backActionTap)
                navigationBar.leftItem.subAction = #selector(subLeftActionTap)
            }
        }
        
        navigationBar.rightItem.target = self
        navigationBar.rightItem.action = #selector(rightActionTap)
        view.addSubview(navigationBar)
        self.navigationBar = navigationBar
    }
    
    override open var title: String? {
        didSet {
            if navigationBar != nil {
                navigationBar.centerTitle = title
            }
        }
    }
    
    // http://stackoverflow.com/questions/23620276/check-if-view-controller-is-presented-modally-or-pushed-on-a-navigation-stack
    func isModal() -> Bool {
        if let _ = presentingViewController {
            return true
        }
        if navigationController?.presentingViewController?.presentedViewController == navigationController {
            return true
        }
        if tabBarController?.presentingViewController is UITabBarController {
            return true
        }
        return false
    }
    
    @objc func backActionTap() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc func cancelActionTap() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc func rightActionTap() {}
    
    @objc func subLeftActionTap() {}
    
    //MARK:- custom keyboard top view
    
    private func createKeyboardTopView() {
        if keyboardTopView == nil {
            let view = UIView(frame: CGRect(x: 0, y: XDSize.screenHeight, width: XDSize.screenWidth, height: 40), color: XDColor.mainBackground)
            self.view.addSubview(view)
            
            let cancelText = "cancel".localized
            let cancelBtn: UIButton! = UIButton(frame: CGRect(x: 16, y: 0, width: XDSize.screenWidth, height: view.height), title: cancelText, fontSize: 15, titleColor: XDColor.itemTitle, target: self, action: #selector(keyboardTopViewCancelTap))
            cancelBtn.contentHorizontalAlignment = .left
            cancelBtn.width = cancelText.widthForFont(cancelBtn.titleLabel!.font) + 10
            view.addSubview(cancelBtn)
            
            let confirmText = "confirm".localized
            let confirmBtn: UIButton! = UIButton(frame: CGRect(x: 0, y: 0, width: XDSize.screenWidth, height: view.height), title: confirmText, fontSize: 15, titleColor: XDColor.main, target: self, action: #selector(keyboardTopViewConfirmTap))
            confirmBtn.contentHorizontalAlignment = .right
            confirmBtn.width = confirmText.widthForFont(confirmBtn.titleLabel!.font) + 10
            confirmBtn.left = XDSize.screenWidth - confirmBtn.width - 16
            view.addSubview(confirmBtn)
            
            keyboardTopView = view
        }
    }
    
    @objc func keyboardTopViewCancelTap() {
        view.endEditing(true)
    }
    
    @objc func keyboardTopViewConfirmTap() {
        view.endEditing(true)
    }
    
    var isCustomKeyboard: Bool {
        get {
            return (objc_getAssociatedObject(self, &customKeyboardKey) as? Bool) ?? false
        }
        set {
            if newValue {
                createKeyboardTopView()
                NotificationCenter.default.addObserver(self, selector: #selector(__keyboardWillShow(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
                NotificationCenter.default.addObserver(self, selector: #selector(__keyboardWillHide(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
            } else {
                NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
                NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
            }
            objc_setAssociatedObject(self, &customKeyboardKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    var keyboardTopView: UIView? {
        get {
            return objc_getAssociatedObject(self, &keyboardTopViewKey) as? UIView
        }
        set {
            objc_setAssociatedObject(self, &keyboardTopViewKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    func __keyboardWillAppear(_ animated: Bool, withBounds bounds: CGRect) {
        if let view = keyboardTopView, isCustomKeyboard {
            self.view.bringSubview(toFront: view)
            view.top = XDSize.screenHeight - bounds.size.height - view.height
        }
    }
    
    func __keyboardWillDisappear(_ animated: Bool, withBounds bounds: CGRect) {
        if let view = keyboardTopView, isCustomKeyboard {
            view.top = XDSize.screenHeight
        }
    }
    
    //MARK:- Notification
    @objc func __keyboardWillShow(notification: Notification) {
        guard isViewAppearing else { return }
        let rect = notification.userInfo![UIKeyboardFrameEndUserInfoKey] as! CGRect
        UIView.beginAnimations(nil, context: nil)
        let curve = notification.userInfo![UIKeyboardAnimationCurveUserInfoKey] as! Int
        UIView.setAnimationCurve(UIViewAnimationCurve(rawValue: curve)!)
        UIView.setAnimationDuration(notification.userInfo![UIKeyboardAnimationDurationUserInfoKey] as! Double)
        __keyboardWillAppear(true, withBounds: rect)
        UIView.commitAnimations()
    }
    
    @objc func __keyboardWillHide(notification: Notification) {
        guard isViewAppearing else { return }
        let rect = notification.userInfo![UIKeyboardFrameEndUserInfoKey] as! CGRect
        UIView.beginAnimations(nil, context: nil)
        let curve = notification.userInfo![UIKeyboardAnimationCurveUserInfoKey] as! Int
        UIView.setAnimationCurve(UIViewAnimationCurve(rawValue: curve)!)
        UIView.setAnimationDuration(notification.userInfo![UIKeyboardAnimationDurationUserInfoKey] as! Double)
        __keyboardWillDisappear(true, withBounds: rect)
        UIView.commitAnimations()
    }
}
