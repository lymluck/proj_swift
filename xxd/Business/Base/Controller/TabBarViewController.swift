//
//  TabBarViewController.swift
//  xxd
//
//  Created by remy on 2017/12/18.
//  Copyright © 2017年 com.smartstudy. All rights reserved.
//

class TabBarViewController: UITabBarController, UITabBarControllerDelegate {
    
    lazy var maskView = UIView(frame: UIScreen.main.bounds, color: .white)
    /// 我的未读消息
    lazy var badgeMine: UIView = {
        let percentX: CGFloat = (4 + 0.65) / 5
        let tabFrame = tabBar.frame
        let x: CGFloat = (percentX * tabFrame.size.width).rounded(.up)
        let y: CGFloat = (0.1 * tabFrame.size.height).rounded(.up)
        let view = UIView(frame: CGRect(x: x, y: y, width: 6, height: 6), color: UIColor(0xF6511D))
        view.layer.cornerRadius = 3
        tabBar.addSubview(view)
        return view
    }()
    /// 问答未读消息
    lazy var badgeQA: UIView = {
        let percentX: CGFloat = (3 + 0.7) / 5
        let tabFrame = tabBar.frame
        let x: CGFloat = (percentX * tabFrame.size.width).rounded(.up)
        let y: CGFloat = (0.1 * tabFrame.size.height).rounded(.up)
        let view = UIView(frame: CGRect(x: x, y: y, width: 6, height: 6), color: UIColor(0xF6511D))
        view.layer.cornerRadius = 3
        tabBar.addSubview(view)
        return view
    }()
    
    lazy var indexVC: UIViewController = {
        let vc = IndexViewController()
        let img1 = UIImage(named: "tab_item_college")
        let img2 = UIImage(named: "tab_item_college_selected")
        vc.tabBarItem = UITabBarItem(title: "tab_item_college".localized, image: img1, selectedImage: img2)
        return vc
    }()
    
    lazy var courseVC: UIViewController = {
        let vc = CourseListViewController()
        let img1 = UIImage(named: "tab_item_course")
        let img2 = UIImage(named: "tab_item_course_selected")
        vc.tabBarItem = UITabBarItem(title: "tab_item_course".localized, image: img1, selectedImage: img2)
        return vc
    }()
    
    lazy var infoVC: UIViewController = {
        let vc = IndexInformationViewController()
        let img1 = UIImage(named: "tab_item_info")
        let img2 = UIImage(named: "tab_item_info_selected")
        vc.tabBarItem = UITabBarItem(title: "tab_item_info".localized, image: img1, selectedImage: img2)
        return vc
    }()
    
    lazy var qaVC: UIViewController = {
        let vc = IndexQAViewController()
        let img1 = UIImage(named: "tab_item_qa")
        let img2 = UIImage(named: "tab_item_qa_selected")
        vc.tabBarItem = UITabBarItem(title: "tab_item_qa".localized, image: img1, selectedImage: img2)
        return vc
    }()
    
    lazy var userVC: UIViewController = {
        let vc = UserViewController()
        let img1 = UIImage(named: "tab_item_user")
        let img2 = UIImage(named: "tab_item_user_selected")
        vc.tabBarItem = UITabBarItem(title: "tab_item_user".localized, image: img1, selectedImage: img2)
        return vc
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        delegate = self
        
        let tabBar = XDTabBar()
        setValue(tabBar, forKey: "tabBar")
        tabBar.isTranslucent = false
        XDTabBar.appearance().tintColor = UIColor.white
        
        if #available(iOS 10.0, *) {
            tabBar.unselectedItemTintColor = XDColor.itemText
            tabBar.tintColor = XDColor.main
        } else {
            UITabBarItem.appearance().setTitleTextAttributes([.foregroundColor: XDColor.itemText], for: .normal)
            UITabBarItem.appearance().setTitleTextAttributes([.foregroundColor: XDColor.main], for: .selected)
        }
        
        let nc1 = SSNavigationController(rootViewController: indexVC)
        let nc2 = SSNavigationController(rootViewController: courseVC)
        let nc3 = SSNavigationController(rootViewController: infoVC)
        let nc4 = SSNavigationController(rootViewController: qaVC)
        let nc5 = SSNavigationController(rootViewController: userVC)
        viewControllers = [nc1, nc2, nc3, nc4, nc5]
        
//        someFun()
        
        /// 我的tab红点显示只受美洽消息影响
        // 更新我的消息未读状态
        updateMineBadge()
//        NotificationCenter.default.addObserver(self, selector: #selector(updateMineBadge), name: .XD_NOTIFY_UPDATE_UNREAD_MESSAGE, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateMineBadge), name: NSNotification.Name(rawValue: MQ_RECEIVED_NEW_MESSAGES_NOTIFICATION), object: nil)
        // 退出美洽聊天,用于更新红点
        NotificationCenter.default.addObserver(self, selector: #selector(updateMineBadge), name: NSNotification.Name(rawValue: MQ_NOTIFICATION_CHAT_END), object: nil)
        // 更新问答tab未读状态
        NotificationCenter.default.addObserver(self, selector: #selector(updateQABadge(_:)), name: .XD_NOTIFY_UPDATE_QA_UNREAD, object: nil)
        // 退出登录
        NotificationCenter.default.addObserver(self, selector: #selector(signOut(notification:)), name: NSNotification.Name(rawValue: XD_NOTIFY_SIGN_OUT), object: nil)
    }
    
    private func startRoute() {
        if ADViewController.isShow() {
            perform(#selector(launchAD), with: nil, afterDelay: 0)
        } else if GuideViewController.isShow() {
            perform(#selector(userGuide), with: nil, afterDelay: 0)
        } else {
            if XDUser.shared.hasLogin() {
                perform(#selector(someFun), with: nil, afterDelay: 0)
            } else {
                perform(#selector(forceToSignIn), with: nil, afterDelay: 0)
            }
        }
    }
    
    @objc private func launchAD() {
        let vc = ADViewController()
        presentModalViewController(vc, animated: false) {
            [unowned self] in
            self.maskView.removeFromSuperview()
        }
    }
    
    @objc private func userGuide() {
        let vc = GuideViewController()
        vc.modalTransitionStyle = .flipHorizontal
        presentModalViewController(vc, animated: false) {
            [unowned self] in
            self.maskView.removeFromSuperview()
        }
    }
    
    @objc private func someFun() {
        self.maskView.removeFromSuperview()
        var isShow = false
        let userType = XDUser.shared.userTargetType()
        if case let .us(degree) = userType {
            if degree != .highschool {
                // 意向国家为美国非高中,才判断是否显示留学规划
                isShow = !(Preference.SHOW_STUDY_PLAN.get() ?? false)
            }
        }
        #if TEST_MODE
            let switchOn = UserDefaults.standard.bool(forKey: "kUnlimitedStudyPlan")
            if switchOn {
                isShow = true
            }
        #endif
        if isShow {
            let vc = StudyPlanViewController()
            presentModalTranslucentViewController(vc, animated: false, completion: nil)
        }
    }
    
    // 1.新用户强制登录
    // 2.ticket,token获取信息失败强制登录
    @objc private func forceToSignIn() {
        let vc = SignInViewController()
        presentModalViewController(vc, animated: false) {
            [unowned self] in
            self.maskView.removeFromSuperview()
            (self.selectedViewController as! UINavigationController).popToRootViewController(animated: false)
            self.selectedIndex = 0
        }
    }
    
    //MARK:- Notification
    @objc func updateMineBadge() {
//        badgeMine.isHidden = !XDUser.shared.hasUnreadMessage()
        MQManager.getUnreadMessages {
            [weak self] (messages, error) in
            self?.badgeMine.isHidden = (messages?.count == 0)
        }
    }
    
    @objc func updateQABadge(_ notification: Notification) {
        badgeQA.isHidden = !((notification.userInfo?["unread"] as? Bool) ?? false)
    }
    
    @objc func signOut(notification: Notification) {
        // 如果已经present了控制器(广告或引导),则不弹出登录
        if presentedViewController == nil {
            forceToSignIn()
        }
    }
    
    //MARK:- UITabBarControllerDelegate
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        return true
    }
    
    #if TEST_MODE
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    override func motionEnded(_ motion: UIEventSubtype, with event: UIEvent?) {
        if event?.subtype == .motionShake {
            if let vc = UIApplication.topVC(), !(vc is DebugViewController) {
                vc.presentModalViewController(DebugViewController(), animated: true, completion: nil)
            }
        }
    }
    #endif
}

class XDTabBar: UITabBar {
    
    override var frame: CGRect {
        didSet {
            if self.height != XDSize.tabbarHeight {
                self.height = XDSize.tabbarHeight
            }
        }
    }
}
