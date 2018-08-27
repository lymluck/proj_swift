//
//  CollegeDetailViewController.swift
//  xxd
//
//  Created by remy on 2018/1/25.
//  Copyright © 2018年 com.smartstudy. All rights reserved.
//

import StoreKit

private let contentOffsetMinY: CGFloat = 50
private let contentOffsetMaxY: CGFloat = 130

class CollegeDetailViewController: SSTableViewController {
    
    var collegeID = 0
    private var movedOffset: CGFloat = 0.0
    private var backBtn: UIButton!
    private var topBar: CollegeTopBarView!
    private var overlayNameLabel: UILabel!
    private var tabBar: CollegeDetailTabBarView!
    private var headerView: CollegeHeaderView!
    private var lastScale: CGFloat = -1
    private var needRefresh = false
    private var introModel: CollegeDetailIntroModel!
    private var sectionItems = [CollegeDetailSectionItem]()
    private var feedbackViewHeight: CGFloat = ceil(0.97*(XDSize.screenWidth-32.0))
    private lazy var feedbackView: CollegeErrorFeedbackView = {
        let view: CollegeErrorFeedbackView = CollegeErrorFeedbackView()
        view.delegate = self
        return view
    }()
    
    override func needNavigationBar() -> Bool {
        return false
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        if topBar != nil {
            if topBar.alpha == 1 {
                return .default
            }
        }
        return .lightContent
    }
    
    convenience init() {
        self.init(query: nil)
        tableViewStyle = .grouped
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        lastScale = -1
        reloadIfNeeded()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        XDStatistics.click("10_B_school_detail")
        canDragRefresh = true
        autoresizesForKeyboard = true
        edgesForExtendedLayout = []
        
        backBtn = UIButton(frame: CGRect(x: 0, y: XDSize.statusBarHeight, width: XDSize.topBarHeight, height: XDSize.topBarHeight), title: "", fontSize: 0, titleColor: UIColor.clear, target: self, action: #selector(backTap(sender:)))
        backBtn.setImage(UIImage(named: "top_left_arrow")?.tint(UIColor.white), for: .normal)
        view.addSubview(backBtn)
        
        topBar = CollegeTopBarView()
        
        overlayNameLabel = UILabel(frame: .zero, text: "", textColor: UIColor.white, fontSize: 23, bold: true)
        overlayNameLabel.textAlignment = .center
        
        tabBar = CollegeDetailTabBarView()
        headerView = CollegeHeaderView()
        tableView.frame = CGRect(x: 0, y: 0, width: XDSize.screenWidth, height: XDSize.screenHeight - XDSize.tabbarHeight)

        tableViewActions.attach(to: InformationItem.self, tap: { (object, target, indexPath) -> Bool in
            if let object = object as? InformationItem {
                let query: [String : Any] = [QueryKey.URLPath:object.model.URLPath, "barType":WebViewControllerBarType.gradient]
                XDRoute.pushWebVC(query)
            }
            return true
        })
        tableViewActions.attach(to: QuestionItem.self, tap: { (object, target, indexPath) -> Bool in
            if let object = object as? QuestionItem {
                let vc = QuestionDetailViewController()
                vc.questionID = object.model.questionID
                XDRoute.pushToVC(vc)
            }
            return true
        })
        showGradeView()
        scrollViewDidScroll(tableView)
        NotificationCenter.default.addObserver(self, selector: #selector(userHasLogin(notification:)), name: .XD_NOTIFY_SIGN_IN, object: nil)
    }
    
    private func showGradeView() {
        var isShow = false
        let dateStr = Date().string(format: "MMdd")
        if let lastInfo = Preference.APP_GRADE.get() {
            let arr = lastInfo.components(separatedBy: "-")
            var count = Int(arr[1])!
            let space = Int(dateStr)! - Int(arr[0])!
            if abs(space) > 3 {
                // 大于三天重置时间,次数
                Preference.APP_GRADE.set(dateStr + "-0")
            } else {
                // 三天内时间不变,次数自增,第十一次显示引导
                if count == 10 { isShow = true }
                count += 1
                Preference.APP_GRADE.set(dateStr + "-\(count)")
            }
        } else {
            // 首次重置时间,次数
            Preference.APP_GRADE.set(dateStr + "-0")
        }
        #if TEST_MODE
            let switchOn = UserDefaults.standard.bool(forKey: "kUnlimitedGrade")
            if switchOn {
                isShow = false
            }
        #endif
        if isShow {
            if #available(iOS 10.3, *) {
                SKStoreReviewController.requestReview()
            } else {
                let alertView = UIAlertController(title: "喜欢选校帝吗？", message: "你的鼓励能让更多的同学发现选校帝", preferredStyle: .alert)
                alertView.addAction(UIAlertAction(title: "不错，去鼓励下", style: .cancel, handler: { (action) in
                    let url = URL(string: XD_WEB_APP_GRADE_URL)!
                    if UIApplication.shared.canOpenURL(url) {
                        UIApplication.shared.openURL(url)
                    }
                }))
                alertView.addAction(UIAlertAction(title: "先用用再说", style: .destructive, handler: nil))
                self.present(alertView, animated: true, completion: nil)
            }
        }
    }
    
    override func shouldLoad() -> Bool {
        return super.shouldReload() || needRefresh
    }
    
    override func showEmpty(_ show: Bool) {
        if show && introModel != nil {
            super.showEmpty(false)
        } else {
            super.showEmpty(show)
        }
        // 没数据时 backBtn 被 SSStateView 挡住
        view.bringSubview(toFront: backBtn)
    }
    
    override func createModel() {
        let model = SSURLReqeustModel(httpMethod: .get, urlString: XD_API_COLLEGE_DETAIL, loadFromFile: false, isPaged: false)
        model?.parameters = ["id":collegeID]
        self.model = model
    }
    
    override func didFinishLoad(with object: Any!) {
        needRefresh = false
        if let data = (object as! [String : Any])["data"] as? [String : Any] {
            if let model = CollegeDetailModel.yy_model(with: data) {
                if model.school == nil { return }
                introModel = model.school
                
                if tableView.tableHeaderView == nil {
                    view.addSubview(topBar)
                    view.addSubview(overlayNameLabel)
                    view.addSubview(tabBar)
                    
                    topBar.title = introModel.chineseName
                    overlayNameLabel.text = introModel.chineseName
                    overlayNameLabel.sizeToFit()
                    overlayNameLabel.centerX = XDSize.screenWidth * 0.5
                    tabBar.model = introModel
                    
                    let tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: XDSize.screenWidth, height: 0))

                    // 顶部院校信息
                    headerView.model = introModel
                    tableHeaderView.addSubview(headerView)
                    
                    // 院校简介
                    var infoView: UIView!
                    let intro = CollegeDetailIntroView()
                    intro.model = introModel
                    intro.top = headerView.bottom
                    tableHeaderView.addSubview(intro)
                    infoView = intro
                    
                    // 本科申请
                    var bachelorView: CollegeDetailDegreeView?
                    if let bachelor = model.bachelor {
                        bachelorView = CollegeDetailDegreeView()
                        bachelorView!.model = bachelor
                        tableHeaderView.addSubview(bachelorView!)
                    }
                    
                    // 研究生申请
                    var masterView: CollegeDetailDegreeView?
                    if let master = model.master {
                        masterView = CollegeDetailDegreeView()
                        master.degreeType = .graduate
                        masterView!.model = master
                        tableHeaderView.addSubview(masterView!)
                    }
                    
                    // 艺术生申请
                    var artView: CollegeDetailDegreeView?
                    if let art = model.art {
                        artView = CollegeDetailDegreeView()
                        art.degreeType = .art
                        artView!.model = art
                        tableHeaderView.addSubview(artView!)
                    }
                    
                    // 申请区域展示顺序
                    var degreeViews = [CollegeDetailDegreeView?]()
                    if XDUser.shared.userDegreeType() == .master {
                        if XDUser.shared.userMajorDirection() == .art {
                            degreeViews = [artView, masterView, bachelorView]
                        } else {
                            degreeViews = [masterView, bachelorView, artView]
                        }
                    } else {
                        degreeViews = [bachelorView, masterView, artView]
                    }
                    degreeViews.forEach {
                        if let view = $0 {
                            view.top = infoView.bottom + 16
                            infoView = view
                        }
                    }
                    
                    tableHeaderView.height = infoView.bottom
                    tableView.tableHeaderView = tableHeaderView
                }
                
                // 留学问答
                var sections = [NITableViewModelSection]()
                if let questions = model.questions, questions.count > 0 {
                    let sectionItem = CollegeDetailSectionItem(type: .qa)
                    sectionItems.append(sectionItem)
                    var items = [QuestionItem]()
                    for model in questions {
                        let item = QuestionItem(model: model, type: .search)
                        items.append(item)
                    }
                    let section = NITableViewModelSection.section() as! NITableViewModelSection
                    section.rows = items
                    sections.append(section)
                }
                
                // 留学资讯
                if let informations = model.informations, informations.count > 0 {
                    let sectionItem = CollegeDetailSectionItem(type: .info)
                    sectionItems.append(sectionItem)
                    var items = [InformationItem]()
                    for model in informations {
                        let item = InformationItem(attributes: [:])!
                        item.model = model
                        items.append(item)
                    }
                    let section = NITableViewModelSection.section() as! NITableViewModelSection
                    section.rows = items
                    sections.append(section)
                }
                tableViewModel.sections = NSMutableArray(array: sections)
                scrollViewDidScroll(tableView)
            }
        }
    }
    
    //MARK:- UITableViewDelegate
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 72.0
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        let sectionItem = sectionItems[section]
        return sectionItem.footerView.height
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let sectionItem = sectionItems[section]
        return sectionItem.headerView
    }
    
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let sectionItem = sectionItems[section]
        return sectionItem.footerView
    }
    
    //MARK:- UIScrollViewDelegate
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let contentOffsetY = scrollView.contentOffset.y
        let scale = min(max((contentOffsetY - contentOffsetMinY) / (contentOffsetMaxY - contentOffsetMinY), 0), 1)
        if scale == lastScale { return }
        backBtn.alpha = 1 - scale
        topBar.alpha = scale
        topBar.centerView.isHidden = scale != 1
        topBar.isUserInteractionEnabled = scale == 1
        headerView.isHiddenName = scale != 0
        overlayNameLabel.isHidden = scale == 1 || scale == 0
        overlayNameLabel.centerY = 206 - contentOffsetMinY - (206 - contentOffsetMinY - XDSize.statusBarHeight - 20) * scale
        overlayNameLabel.font = UIFont.boldSystemFont(ofSize: 23 - (23 - 17) * scale)
        overlayNameLabel.textColor = UIColor(start: UIColor.white, end: XDColor.itemTitle, ratio: scale)
        setNeedsStatusBarAppearanceUpdate()
        lastScale = scale
    }
    
    override func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        scrollViewDidEndDecelerating(scrollView)
    }
    
    override func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let contentOffsetY = scrollView.contentOffset.y
        if contentOffsetY < contentOffsetMaxY && contentOffsetY > 0 {
            let y = contentOffsetY > 100 ? contentOffsetMaxY : 0
            scrollView.setContentOffset(CGPoint(x: 0, y: y), animated: true)
        }
    }
    
    //MARK:- Notification
    @objc func userHasLogin(notification: Notification) {
        needRefresh = true
        if isViewAppearing {
            reloadIfNeeded()
        }
    }
    
    //MARK:- Action
    override func keyboardWillAppear(_ animated: Bool, withBounds bounds: CGRect) {
        let keyboardTop: CGFloat = round(bounds.origin.y) - 10.0
        movedOffset = feedbackView.bottom - keyboardTop
        self.feedbackView.top -= movedOffset
    }
    
    override func keyboardWillDisappear(_ animated: Bool, withBounds bounds: CGRect) {
        self.feedbackView.top += movedOffset
    }
    
    @objc func backTap(sender: UIButton) {
        backActionTap()
    }
    
    override func routerEvent(name: String, data: Dictionary<String, Any>) {
        if name == kEventCollegeDetailMoreTap {
            if let type = data["type"] as? CollegeDetailSectionType {
                switch type {
                case .intro:
                    XDStatistics.click("10_B_school_detail")
                    XDRoute.pushWebVC([QueryKey.URLPath:String(format: XD_WEB_COLLEGE_DETAIL_INTRO, collegeID)])
                case .bachelor:
                    XDStatistics.click("10_A_undergraduate_more_btn")
                    XDRoute.pushWebVC([QueryKey.URLPath:String(format: XD_WEB_COLLEGE_DETAIL_BACHELOR, collegeID)])
                case .master:
                    XDStatistics.click("10_A_graduate_more_btn")
                    XDRoute.pushWebVC([QueryKey.URLPath:String(format: XD_WEB_COLLEGE_DETAIL_MASTER, collegeID)])
                case .art:
                    XDStatistics.click("10_A_art_more_btn")
                    XDRoute.pushWebVC([QueryKey.URLPath:String(format: XD_WEB_COLLEGE_DETAIL_ART, collegeID)])
                case .qa:
                    XDStatistics.click("10_A_qustion_more_btn")
                    let vc = QuestionViewController(type: .latest)
                    vc.keyword = introModel.chineseName
                    vc.titleName = "问答列表"
                    XDRoute.pushToVC(vc)
                case .info:
                    XDStatistics.click("10_A_news_more_btn")
                    let vc = InformationViewController(collegeID: collegeID)
                    vc.titleName = "information_title".localized
                    XDRoute.pushToVC(vc)
                }
            }
        } else if name == kErrorCorrectionTap {
            if let errorType = data["sectionType"] as? CollegeDetailSectionType {
                feedbackView.sectionType = errorType
                feedbackView.showWithAnimation()
            }
        }
    }
    
    private func uploadUserFeedbackContent(section: String, content: String) {
        let params = ["schoolId": "\(collegeID)", "section": section, "content": content]
        XDPopView.loading()
        SSNetworkManager.shared().post(XD_API_COLLEGE_CORRECTION, parameters: params, success: { [weak self](data, responseObject) in
            if let strongSelf = self {
                strongSelf.feedbackView.dismissWithAnimation()
                XDPopView.toast("submit_success".localized, UIApplication.shared.keyWindow)
            }
        }) { (data, error) in
            XDPopView.toast(error.localizedDescription)
        }
    }
    
}

// MARK: CollegeErrorFeedbackViewDelegate
extension CollegeDetailViewController: CollegeErrorFeedbackViewDelegate {
    func collegeErrorFeedbackViewDidCommit(section: String, content: String) {
        if content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            XDPopView.toast("输入内容不能为空", UIApplication.shared.keyWindow)
        } else {
            uploadUserFeedbackContent(section: section, content: content)
        }
    }
}
