//
//  BaseViewController.swift
//  TSKitDemo
//
//  Created by chenyusen on 2017/9/29.
//  Copyright © 2017年 TechSen. All rights reserved.
//

import UIKit

class AdjustView: UIView {
    override func addSubview(_ view: UIView) {
        super.addSubview(view)
        for view in subviews.reversed() {
            if view is NavigationBar {
                bringSubview(toFront: view)
                return
            }
        }
    }
}


/// TSKit里所有控制器的基类
open class BaseViewController: UIViewController {
    
    /// 当前控制器持有的View是否已经显示过
    private(set) var hasViewAppeared: Bool = false
    
    /// 当前控制器持有的View是否正在展示
    private(set) var isViewAppearing: Bool = false
    
    @objc dynamic var isGesturePopEnable: Bool = true
    
    
    var adjustBackButton: Bool = true

    
    /// 内容视图距离顶部的距离,例如tableview/scrollview/collectionview,默认为0
    var topOffset: CGFloat = 0 {
        didSet {
            if scrollViewCreated {
                scrollView.frame = UIEdgeInsetsInsetRect(view.bounds, UIEdgeInsetsMake(topOffset, 0, 0, 0))
                scrollView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            }
        }
    }
    
    
    /// 懒加载的一个放置于View上的一个UIScrollView
    lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView(frame: UIEdgeInsetsInsetRect(view.bounds, UIEdgeInsetsMake(topOffset, 0, 0, 0)))
        scrollView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(scrollView)
        scrollViewCreated = true
        if #available(iOS 11.0, *) {
            scrollView.contentInsetAdjustmentBehavior = .never
        } else {
            self.automaticallyAdjustsScrollViewInsets = false
        }
        return scrollView
        }()
    private var scrollViewCreated: Bool = false
    var hasAdapteriPhoneX: Bool = false
    
    /// 当 DefaultConfig.Style.navigationBar == .custom时有值
    var navigationBar: NavigationBar?
    
    /// 指定成员构造器,所有集成自BaseViewController的控制器,都需要用该方法初始化
    ///
    /// - Parameter query: 传递参数字典
    public init(query: [String: Any]?) {
        super.init(nibName: nil, bundle: nil)
        hidesBottomBarWhenPushed = true
    }
    
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        fatalError("use init(query:) replace")
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        SSLog("\(self.self) has deinit")
        NotificationCenter.default.removeObserver(self)
    }
    
    open override var title: String? {
        didSet {
            navigationBar?.title = title
        }
    }
    
    /// 是否监听键盘通知
    public var autoresizesForKeyboard = false {
        didSet {
            if autoresizesForKeyboard {
                NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillShow, object: nil)
                NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillHide, object: nil)
                NotificationCenter.default.removeObserver(self, name: .UIKeyboardDidShow, object: nil)
                NotificationCenter.default.removeObserver(self, name: .UIKeyboardDidHide, object: nil)
                NotificationCenter.default.addObserver(self,
                                                       selector: #selector(keyboardWillShow(_:)),
                                                       name: .UIKeyboardWillShow,
                                                       object: nil)
                
                NotificationCenter.default.addObserver(self,
                                                       selector: #selector(keyboardWillHide(_:)),
                                                       name: .UIKeyboardWillHide,
                                                       object: nil)
                
                NotificationCenter.default.addObserver(self,
                                                       selector: #selector(keyboardDidShow(_:)),
                                                       name: .UIKeyboardDidShow,
                                                       object: nil)
                NotificationCenter.default.addObserver(self,
                                                       selector: #selector(keyboardDidHide(_:)),
                                                       name: .UIKeyboardDidHide,
                                                       object: nil)
            } else {
                NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillShow, object: nil)
                NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillHide, object: nil)
                NotificationCenter.default.removeObserver(self, name: .UIKeyboardDidShow, object: nil)
                NotificationCenter.default.removeObserver(self, name: .UIKeyboardDidHide, object: nil)
            }
        }
    }
    
    func keyboardWillAppear(animated: Bool, withBounds bounds: CGRect) {
        // Empty default implementation.
    }
    func keyboardWillDisappear(animated: Bool, withBounds bounds: CGRect) {
        // Empty default implementation.
    }
    func keyboardDidAppear(animated: Bool, withBounds bounds: CGRect) {
        // Empty default implementation.
    }
    func keyboardDidDisappear(animated: Bool, withBounds bounds: CGRect) {
        // Empty default implementation.
    }
    
    
    /// 如果用系统默认样式的导航栏此方法才有效
    ///
    /// - Returns: 是否隐藏
    open func hiddenNavigationBarIfNeeded() -> Bool {
        return DefaultConfig.Style.navigationBar != .system // 如果是系统导航栏,则隐藏
    }
    
    open override func loadView() {
//        super.loadView()
        view = AdjustView(frame: UIScreen.main.bounds)
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.backgroundColor = DefaultConfig.Color.background
        let defaultNavigationBarHeight = UIApplication.shared.statusBarFrame.height + 44
        if DefaultConfig.Style.navigationBar == .custom {
            navigationBar = NavigationBar(frame: CGRect(x: 0, y: 0, width: view.width, height: defaultNavigationBarHeight),
                                          viewController: self)
            navigationBar?.title = title
            navigationBar?.autoresizingMask = [.flexibleBottomMargin, .flexibleWidth]
            view.addSubview(navigationBar!)
            
            // 如果当前navi栈中的控制器个数大于1,则显示返回按钮
            if let navigationController = navigationController, adjustBackButton {
                if navigationController.viewControllers.count > 1 {
                    var backButtonItem :NavigationBarButtonItem!
                    if let backImage = DefaultConfig.Image.navBack {
                        backButtonItem = NavigationBarButtonItem(image: backImage,
                                                                 target: self,
                                                                 action:#selector(backToLastController))
                    } else {
                        backButtonItem = NavigationBarButtonItem(title: "返回",
                                                                 target: self,
                                                                 action: #selector(backToLastController))
                    }
                    
                    
                    navigationBar?.leftButtonItems = [backButtonItem!]
                } else if navigationController.viewControllers.count == 1, navigationController.presentingViewController != nil {
                    let cancelButtonItem :NavigationBarButtonItem! = NavigationBarButtonItem(title: "取消",
                                                             target: self,
                                                             action: #selector(cancelToLastController))
                    navigationBar?.leftButtonItems = [cancelButtonItem]
                }
            }
        }
    
        if topOffset == 0 {
            topOffset = (self.hiddenNavigationBarIfNeeded() && DefaultConfig.Style.navigationBar == .system) || DefaultConfig.Style.navigationBar == .none ? 0 : defaultNavigationBarHeight
        }
    }
    
//    open override func viewDidLoad() {
//        super.viewDidLoad()
//    }
//
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        hasViewAppeared = true
        isViewAppearing = true
        navigationController?.setNavigationBarHidden(hiddenNavigationBarIfNeeded(), animated: false)
    }
    
    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // 对于iPhoneX,底部增加34的inset
        if UIDevice.isIPhoneX && !hasAdapteriPhoneX && scrollViewCreated {
            scrollView.contentInset = UIEdgeInsetsMake(scrollView.contentInset.top, scrollView.contentInset.left, scrollView.contentInset.bottom + 34, scrollView.contentInset.right)
            
            scrollView.scrollIndicatorInsets = UIEdgeInsetsMake(scrollView.scrollIndicatorInsets.top, scrollView.scrollIndicatorInsets.left, scrollView.scrollIndicatorInsets.bottom + 34, scrollView.scrollIndicatorInsets.right)
            hasAdapteriPhoneX = true
        }
    }
    
    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        isViewAppearing = false
    }
    open override func didReceiveMemoryWarning() {
        if hasViewAppeared && !isViewAppearing {
            hasViewAppeared = false
            super.didReceiveMemoryWarning()
        } else {
            super.didReceiveMemoryWarning()
        }
    }
    
    @objc open func backToLastController() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc open func cancelToLastController() {
        dismiss(animated: true)
    }
    
    open override var preferredStatusBarStyle: UIStatusBarStyle {
        return DefaultConfig.Style.statusBarStyle
    }
}

private extension BaseViewController {
    @objc private func keyboardWillShow(_ notification: Notification) {
        if isViewAppearing {
            resizeForKeyboard(notification, appearing: true)
        }
    }
    @objc private func keyboardWillHide(_ notification: Notification) {
        if isViewAppearing {
            resizeForKeyboard(notification, appearing: false)
        }
    }
    @objc private func keyboardDidShow(_ notification: Notification) {
        if let keyboardBounds = notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? CGRect {
            keyboardDidAppear(animated: false, withBounds: keyboardBounds)
        }
    }
    @objc private func keyboardDidHide(_ notification: Notification) {
        if let keyboardBounds = notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? CGRect {
            keyboardDidDisappear(animated: false, withBounds: keyboardBounds)
        }
    }
    
    
    private func resizeForKeyboard(_ notification: Notification, appearing: Bool) {
        if let keyboardEnds = notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? CGRect, let curveValue = notification.userInfo?[UIKeyboardAnimationCurveUserInfoKey] as? Int, let curve = UIViewAnimationCurve(rawValue: curveValue), let duration = notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as? TimeInterval {
            UIView.beginAnimations(nil, context: nil)
            UIView.setAnimationCurve(curve)
            UIView.setAnimationDuration(duration)
            if appearing {
                keyboardWillAppear(animated: true, withBounds: keyboardEnds)
            } else {
                keyboardWillDisappear(animated: true, withBounds: keyboardEnds)
            }
            UIView.commitAnimations()
        }
    }
}


