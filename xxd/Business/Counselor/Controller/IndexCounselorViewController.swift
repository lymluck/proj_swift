//
//  IndexCounselorViewController.swift
//  xxd
//
//  Created by chenyusen on 2018/3/2.
//  Copyright © 2018年 com.smartstudy. All rights reserved.
//

import UIKit
import WMPageController

class IndexCounselorViewController: SSViewController {

    private var chatListVC: CounselorChatListViewController!
    private var teacherListVC: CounselorTeacherListViewController!
    private var segmentControl: CounseleorSegmentControl!
    
    private lazy var pageController: WMPageController = {
        let vc = WMPageController()
        vc.delegate = self
        vc.dataSource = self
        vc.menuViewStyle = .line
        vc.pageAnimatable = true
        vc.bounces = true
        return vc
    }()
    
    var viewControllers: [UIViewController]!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "留学顾问"
        navigationBar.bottomLine.isHidden = true
        
        let segmentControlBGView = UIView(frame: CGRect(x: 0, y: navigationBar.height, width: view.width, height: 41), color: .white)
        view.addSubview(segmentControlBGView)
        
        let bottomLine = UIView(frame: CGRect(x: 0, y: segmentControlBGView.height - XDSize.unitWidth, width: segmentControlBGView.width, height: XDSize.unitWidth), color: UIColor(0xE4E5E6))
        segmentControlBGView.addSubview(bottomLine)
        
        segmentControl = CounseleorSegmentControl(titles: ["聊天列表", "顾问列表"])
        segmentControl.delegate = self
        segmentControlBGView.addSubview(segmentControl)
        segmentControl.centerX = segmentControlBGView.width * 0.5
        segmentControl.top = 2
        
        chatListVC = CounselorChatListViewController(query: nil)
        teacherListVC = CounselorTeacherListViewController(query: nil)
        viewControllers = [chatListVC, teacherListVC]
  
        
        view.insertSubview(pageController.view, belowSubview: navigationBar)
        
        addChildViewController(pageController)
        
        pageController.menuView?.isHidden = true
        pageController.menuView?.height = 0
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
//        pageController.selectIndex = CounselorIM.shared.conversationList().count > 0 ? 0 : 1
    }
}

extension IndexCounselorViewController: WMPageControllerDelegate {
    func pageController(_ pageController: WMPageController, didEnter viewController: UIViewController, withInfo info: [AnyHashable : Any]) {
        let index = viewControllers.index(of: viewController)!
        segmentControl.selectedIndex = index
    }
}

extension IndexCounselorViewController: WMPageControllerDataSource {
    func numbersOfChildControllers(in pageController: WMPageController) -> Int {
        return 2
    }
    
    func pageController(_ pageController: WMPageController, viewControllerAt index: Int) -> UIViewController {
        return viewControllers[index]
    }
    
    func pageController(_ pageController: WMPageController, preferredFrameForContentView contentView: WMScrollView) -> CGRect {
        return CGRect(x: 0, y: segmentControl.superview!.bottom, width: view.width, height: view.height - segmentControl.superview!.bottom)
    }
    
    func pageController(_ pageController: WMPageController, preferredFrameFor menuView: WMMenuView) -> CGRect {
        return CGRect.zero
    }
}

extension IndexCounselorViewController: CounseleorSegmentControlDelegate {
    func segmentControl(_ segmentControl: CounseleorSegmentControl, didPressed index: Int, title: String) {
        pageController.selectIndex = Int32(index)
    }
}

