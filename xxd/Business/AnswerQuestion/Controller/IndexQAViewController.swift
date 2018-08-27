//
//  IndexQAViewController.swift
//  xxd
//
//  Created by remy on 2018/4/19.
//  Copyright © 2018年 com.smartstudy. All rights reserved.
//

import WMPageController

private var kTagBarHeight: CGFloat = 40

class IndexQAViewController: SSViewController {

    private var recommendQA: QuestionViewController!
    private var latestQA: QuestionViewController!
    private var myQA: QuestionViewController!
    private lazy var badgeView: UIView = {
        let view = UIView(frame: CGRect(x: 0, y: XDSize.topHeight + 8, width: 10, height: 10), color: UIColor(0xF6511D))
        view.left = (XDSize.screenWidth - (XDSize.screenWidth / 375) * 44).rounded()
        view.layer.cornerRadius = 5
        self.view.addSubview(view)
        return view
    }()
    var viewControllers: [UIViewController]!
    private lazy var tagModels: [QuestionTagModel] = {
        var arr: [QuestionTagModel] = []
        let names: [String] = ["推荐问答", "最新问答", "我的问答"]
        let type: [QAListType] = [.recommend, .latest, .mine]
        for (index, name) in names.enumerated() {
            let model = QuestionTagModel()
            model.name = name
            model.type = type[index]
            arr.append(model)
        }
        return arr
    }()
    private lazy var pageController: WMPageController = {
        let vc = WMPageController()
        vc.dataSource = self
        vc.titleColorSelected = XDColor.main
        vc.titleColorNormal = XDColor.itemText
        vc.titleSizeNormal = 15
        vc.titleSizeSelected = 15
        vc.menuViewStyle = .line
        vc.progressHeight = 2
        vc.progressColor = XDColor.main
        vc.itemMargin = 16
        vc.automaticallyCalculatesItemWidths = true
        vc.bounces = true
        return vc
    }()
    private lazy var rightActionView: UIView = {
        let view = UIView(frame: CGRect(x: XDSize.screenWidth - 80, y: XDSize.statusBarHeight, width: 80, height: XDSize.topBarHeight))
        self.view.addSubview(view)
        
        let searchBtn = UIButton(frame: CGRect(x: 0, y: 0, width: 24, height: XDSize.topBarHeight), title: "", fontSize: 0, titleColor: .clear, target: self, action: #selector(searchTap))!
        searchBtn.setImage(UIImage(named: "top_right_search"), for: .normal)
        view.addSubview(searchBtn)
        
        let askBtn = UIButton(frame: CGRect(x: 40, y: 0, width: 24, height: XDSize.topBarHeight), title: "", fontSize: 0, titleColor: .clear, target: self, action: #selector(askTap))!
        askBtn.contentHorizontalAlignment = .right
        askBtn.setImage(UIImage(named: "add_16"), for: .normal)
        view.addSubview(askBtn)
        
        return view
    }()
    /// 是否有未读问答
    private var hasUnreadQA: Bool = false {
        didSet {
            badgeView.isHidden = !hasUnreadQA
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        XDStatistics.click("19_B_question_list")
        navigationBar.centerTitle = "title_question".localized
        navigationBar.rightItem.customView = rightActionView
        navigationBar.bottomLine.isHidden = true
        
        view.insertSubview(pageController.view, belowSubview: navigationBar)
        addChildViewController(pageController)
        
        let bottomLine = UIView(frame: CGRect(x: 0, y: kTagBarHeight - XDSize.unitWidth, width: XDSize.screenWidth, height: XDSize.unitWidth), color: UIColor(0xCCCCCC))
        pageController.menuView?.insertSubview(bottomLine, at: 0)
        
        // 重新登录更新问答列表
        NotificationCenter.default.addObserver(self, selector: #selector(reloadData), name: .XD_NOTIFY_SIGN_IN, object: nil)
        // 更新问答tab未读状态
        NotificationCenter.default.addObserver(self, selector: #selector(refreshBadge(_:)), name: .XD_NOTIFY_UPDATE_QA_UNREAD, object: nil)
        // 首次未读状态从个人信息读取
        hasUnreadQA = XDUser.shared.hasUnreadQuestions()
    }
    
    //MARK:- Action
    @objc func searchTap() {
        XDStatistics.click("19_A_search_btn")
        let vc = QASearchController()
        vc.extraParams = ["answered":true]
        tabBarController?.presentModalTranslucentViewController(vc, animated: false, completion: nil)
    }
    
    @objc func askTap() {
        XDStatistics.click("19_A_post_btn")
        if XDUser.shared.hasLogin() {
            let vc = AskViewController()
            presentModalViewController(vc, animated: true, completion: nil)
        } else {
            let vc = SignInViewController()
            presentModalViewController(vc, animated: true, completion: nil)
        }
    }
    
    //MARK:- Notification
    @objc func reloadData() {
        pageController.reloadData()
    }
    
    @objc func refreshBadge(_ notification: Notification) {
        hasUnreadQA = (notification.userInfo?["unread"] as? Bool) ?? false
    }
}

extension IndexQAViewController: WMPageControllerDataSource {
    func numbersOfChildControllers(in pageController: WMPageController) -> Int {
        return tagModels.count
    }
    
    func pageController(_ pageController: WMPageController, viewControllerAt index: Int) -> UIViewController {
        let vc = QuestionViewController(type: tagModels[index].type, isTag: true)
        vc.titleName = tagModels[index].name
        return vc
    }
    
    func pageController(_ pageController: WMPageController, preferredFrameForContentView contentView: WMScrollView) -> CGRect {
        let top = topOffset + kTagBarHeight
        return CGRect(x: 0, y: top, width: XDSize.screenWidth, height: view.height - top)
    }
    
    func pageController(_ pageController: WMPageController, preferredFrameFor menuView: WMMenuView) -> CGRect {
        return CGRect(x: 0, y: topOffset, width: XDSize.screenWidth, height: kTagBarHeight)
    }
    
    func pageController(_ pageController: WMPageController, titleAt index: Int) -> String {
        return tagModels[index].name
    }
}
