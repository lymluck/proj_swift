//
//  CourseDetailViewController.swift
//  xxd
//
//  Created by remy on 2018/1/18.
//  Copyright © 2018年 com.smartstudy. All rights reserved.
//

import WMPageController

private let kCoverImageViewHeight = (XDSize.screenWidth * 211 / 375).rounded(.up)
private let kTagBarHeight: CGFloat = 44

class CourseDetailViewController: SSViewController, WMPageControllerDataSource {
    
    var courseID = 0
    private let coverView = UIImageView(frame: CGRect(x: 0, y: 0, width: XDSize.screenWidth, height: kCoverImageViewHeight))
    private var canComment = false
    private var hasCommented = false
    private lazy var pageController: WMPageController = {
        let space = Float((XDSize.screenWidth - 3 * 48) / 6).rounded(.up)
        let m1 = NSNumber(value: space)
        let m2 = NSNumber(value: space * 2)
        let vc = WMPageController()
        vc.dataSource = self
        vc.selectIndex = 1
        vc.titleColorSelected = XDColor.main
        vc.titleColorNormal = XDColor.itemTitle
        vc.titleSizeNormal = 15
        vc.titleSizeSelected = 15
        vc.menuViewStyle = .line
        vc.progressHeight = 2
        vc.progressWidth = 48
        vc.progressColor = XDColor.main
        vc.itemsMargins = [m1, m2, m2, m1]
        vc.automaticallyCalculatesItemWidths = true
        // 进入横屏后会调用WMPageControllerDataSource代理更新组件导致宽度变高度
        // 通过预加载确认前一个page的尺寸可以避免横屏问题
//        vc.preloadPolicy = .near
        return vc
    }()
    private lazy var subControllerInfos: [[String : Any]] = {
        let arr = [
            ["title":"course_tab_intro".localized],
            ["title":"course_tab_outline".localized],
            ["title":"course_tab_evaluation".localized]
        ]
        return arr
    }()
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // 纠正iphoneX视频返回出现的位置偏移
//        if UIDevice.isIPhoneX {
//            let left = CGFloat(pageController.selectIndex) * XDSize.screenWidth
//            pageController.scrollView?.setContentOffset(CGPoint(x: left, y: 0), animated: false)
//        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        XDStatistics.click("16_B_course_detail")
        navigationBar.leftItem.image = navigationBar.leftItem.image?.tint(UIColor.white)
        navigationBar.bottomLine.isHidden = true
        navigationBar.backgroundColor = UIColor.clear
        
        view.insertSubview(pageController.view, belowSubview: navigationBar)
        addChildViewController(pageController)
        
        let bottomLine = UIView(frame: CGRect(x: 0, y: kTagBarHeight - XDSize.unitWidth, width: XDSize.screenWidth, height: XDSize.unitWidth), color: UIColor(0xCCCCCC))
        pageController.menuView?.insertSubview(bottomLine, at: 0)
        
        coverView.backgroundColor = UIColor.white
        view.insertSubview(coverView, belowSubview: navigationBar)
        
        fetchDataWithComplection(nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(hasEvaluateCourse(notification:)), name: NSNotification.Name(rawValue: XD_NOTIFY_EVALUATE_COURSE_SUC), object: nil)
    }
    
    private func fetchDataWithComplection(_ completion: (() -> Void)?) {
        let urlStr = String(format: XD_API_COURSE_BRIEF, courseID)
        SSNetworkManager.shared().get(urlStr, parameters: nil, success: { [weak self] (task, responseObject) in
            let dict = (responseObject as? [String : Any])!["data"] as! [String : Any]
            if let strongSelf = self {
                strongSelf.coverView.setAutoOSSImage(urlStr: dict["coverUrl"] as! String, policy: .fill)
                strongSelf.canComment = dict["canComment"] as! Bool
                strongSelf.hasCommented = dict["commented"] as! Bool
                if let completion = completion {
                    completion()
                }
            }
            XDPopView.hide()
        }) { (task, error) in
            XDPopView.toast(error.localizedDescription)
        }
    }
    
    func tryPopCommentBoard() {
        fetchDataWithComplection {
            [weak self] in
            self?.popCommentBoard()
        }
    }
    
    private func popCommentBoard() {
        #if TEST_MODE
            let switchOn = UserDefaults.standard.bool(forKey: "kUnlimitedEvaluateCourseKey")
            if switchOn {
                canComment = true
            }
        #endif
        if XDUser.shared.hasLogin() {
            guard canComment else { return }
            view.isUserInteractionEnabled = false
            let vc = CourseDetailEvaluationBoardViewController()
            vc.courseID = courseID
            presentModalTranslucentViewController(vc, animated: false, completion: {
                [weak self] in
                self?.view.isUserInteractionEnabled = true
            })
        } else {
            let vc = SignInViewController()
            presentModalViewController(vc, animated: true, completion: nil)
        }
    }
    
    //MARK:- Notification
    @objc func hasEvaluateCourse(notification: Notification) {
        if (notification.userInfo![QueryKey.CourseID] as! Int) == courseID {
            hasCommented = true
            canComment = false
        }
    }
    
    //MARK:- WMPageControllerDataSource
    func pageController(_ pageController: WMPageController, preferredFrameFor menuView: WMMenuView) -> CGRect {
        return CGRect(x: 0, y: kCoverImageViewHeight, width: XDSize.screenWidth, height: kTagBarHeight)
    }
    
    func pageController(_ pageController: WMPageController, preferredFrameForContentView contentView: WMScrollView) -> CGRect {
        let top = kCoverImageViewHeight + kTagBarHeight
        return CGRect(x: 0, y: top, width: XDSize.screenWidth, height: view.height - top)
    }
    
    func numbersOfChildControllers(in pageController: WMPageController) -> Int {
        return subControllerInfos.count
    }
    
    func pageController(_ pageController: WMPageController, viewControllerAt index: Int) -> UIViewController {
        if index == 0 {
            XDStatistics.click("16_A_intro_btn")
            let vc = CourseDetailIntroduceViewController()
            vc.topSpace = kCoverImageViewHeight + kTagBarHeight
            vc.courseID = courseID
            return vc
        } else if index == 2 {
            XDStatistics.click("16_A_evaluation_btn")
            let vc = CourseDetailEvaluationViewController()
            vc.courseID = courseID
            return vc
        } else {
            let vc = CourseDetailOutlineViewController()
            vc.courseID = courseID
            return vc
        }
    }
    
    func pageController(_ pageController: WMPageController, titleAt index: Int) -> String {
        return " \(subControllerInfos[index]["title"] as! String) "
    }
}
