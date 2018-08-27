//
//  IndexViewController.swift
//  xxd
//
//  Created by remy on 2018/2/22.
//  Copyright © 2018年 com.smartstudy. All rights reserved.
//

import SDCycleScrollView
import DeviceKit

class IndexViewController: SSTableViewController, SDCycleScrollViewDelegate {
    
    private lazy var successViewWidth: CGFloat = {
        if Device().diagonal == 4.0 {
            return XDSize.screenWidth-32.0
        }
        return XDSize.screenWidth-64.0
    }()
    private var topSearchView: UIView?
    private var searchBtn: UIButton!
    private var topSection: IndexTopSectionView!
    
    private var tableHeaderView: UIView!
    private var bannerSection: SDCycleScrollView!
    private var bannerDataList = [[String : Any]]()
    private var portalSection: IndexPortalView!
    private var recommendSection: IndexRecommendView!
    private var rankSection: IndexRankView!
    /// 美高热门学校
    private var collegeSection: IndexCollegeView!
    /// 浏览热度分区
    private var viewedHotSection: IndexCollegeView!
    /// 选校热度分区
    private var selectedHotSection: IndexCollegeView!
    /// 热门专业分区(只有申请项目为研究生时才有)
    private var popularMajorSection: IndexMajorView!
    /// 专栏分区
    private var columnSection: IndexColumnView!
    /// 广告视图
    private lazy var adView: ADView = {
        let view: ADView = ADView(frame: UIScreen.main.bounds)
        view.delegate = self
        return view
    }()
    /// 浏览历史
    private var recentViewedSection: IndexSpecialView!
    private var hasData = false
    private var recommendImage: String?
    /// 记录意向地推荐卡片是否被用户删除了
    private var isTargetCountryRecommendDeleted: Bool = false

    var userType: UserTargetType!
    
    override func needNavigationBar() -> Bool {
        return false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.statusBarStyle = .lightContent
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        UIApplication.shared.statusBarStyle = .default
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        XDStatistics.click("8_B_home_page")
        canDragRefresh = true
        edgesForExtendedLayout = []
        let topShadow: UIImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: XDSize.screenWidth, height: XDSize.topHeight), imageName: "top_shadow")!
        tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: XDSize.screenWidth, height: 0), color: XDColor.mainBackground)
        view.addSubview(topShadow)
        // 获取用户意向数据
        userType = XDUser.shared.userTargetType()

        // 广告
        bannerSection = SDCycleScrollView(frame: CGRect(x: 0, y: 0, width: XDSize.screenWidth, height: XDSize.screenWidth * 0.5), delegate: self, placeholderImage: UIImage(named: "default_placeholder"))
        bannerSection.bannerImageViewContentMode = .scaleAspectFit
        bannerSection.autoScrollTimeInterval = 3
        bannerSection.backgroundColor = UIColor(0xEEEEEE)
        tableHeaderView.addSubview(bannerSection)
        
        // 首页入口项
        portalSection = IndexPortalView(type: userType)
        portalSection.top = bannerSection.bottom
        tableHeaderView.addSubview(portalSection)
        
        // 推荐入口
        recommendSection = IndexRecommendView(type: userType)
        recommendSection.delegate = self
        recommendSection.countryType = XDUser.shared.userCountryType()
        recommendSection.top = portalSection.bottom + 12
        tableHeaderView.addSubview(recommendSection)
        
        // 排行
        rankSection = IndexRankView(type: userType)
        rankSection.top = recommendSection.bottom
        tableHeaderView.addSubview(rankSection)
        
        // 美高院校
        collegeSection = IndexCollegeView(type: userType)
        collegeSection.top = rankSection.bottom
        tableHeaderView.addSubview(collegeSection)
        
        // 浏览热度选校
        viewedHotSection = IndexCollegeView(type: userType)
        viewedHotSection.titleName = "浏览热度"
        viewedHotSection.moreType = .viewed
        viewedHotSection.top = rankSection.bottom
        tableHeaderView.addSubview(viewedHotSection)
        
        // 选校热度选校
        selectedHotSection = IndexCollegeView(type: userType)
        selectedHotSection.titleName = "选校热度"
        selectedHotSection.moreType = .selected
        selectedHotSection.top = viewedHotSection.bottom
        tableHeaderView.addSubview(selectedHotSection)
        if userType == .us(.highschool) {
            collegeSection.isHidden = false
            viewedHotSection.isHidden = true
            selectedHotSection.isHidden = true
        } else {
            collegeSection.isHidden = true
            viewedHotSection.isHidden = false
            selectedHotSection.isHidden = false
        }
        
        // 热门专业
        popularMajorSection = IndexMajorView()
        popularMajorSection.top = selectedHotSection.bottom
        tableHeaderView.addSubview(popularMajorSection)
        
        // 专栏
        columnSection = IndexColumnView()
        tableHeaderView.addSubview(columnSection)
        
        // 最近浏览的学校
        recentViewedSection = IndexSpecialView()
        recentViewedSection.userType = userType
        tableHeaderView.addSubview(recentViewedSection)

        let top: CGFloat = UIDevice.isIPhoneX ? 88 : 0
        let height = XDSize.screenHeight - XDSize.tabbarHeight - top
        tableView.frame = CGRect(x: 0, y: top, width: XDSize.screenWidth, height: height)
        tableView.backgroundColor = UIColor.white
        // 清除autoresizingMask,不然会引起布局问题
        tableView.autoresizingMask = []
        
        // 头部操作区背景
        if UIDevice.isIPhoneX {
            let topWrap = CALayer()
            topWrap.backgroundColor = UIColor.white.cgColor
            topWrap.frame = CGRect(x: 0, y: 0, width: XDSize.screenWidth, height: 88)
            view.layer.addSublayer(topWrap)
        } else {
            let topView = UIView(frame: CGRect(x: 0, y: 0, width: XDSize.screenWidth, height: 64), color: UIColor.white)
            topView.addSubview(UIView(frame: CGRect(x: 0, y: topView.height - XDSize.unitWidth, width: XDSize.screenWidth, height: XDSize.unitWidth), color: UIColor(0xCCCCCC)))
            topView.alpha = 0
            topView.isHidden = true
            view.addSubview(topView)
            topSearchView = topView
        }
        
        // 头部操作区
        topSection = IndexTopSectionView()
        topSection.isHidden = true
        view.addSubview(topSection)
        if UserGuideView.isShow() {
            let guideView: UserGuideView = UserGuideView(frame: UIScreen.main.bounds)
            UIApplication.shared.keyWindow?.addSubview(guideView)
        } else if ADView.isShow() {
            if let appDelegate = UIApplication.shared.delegate as? AppDelegate, !appDelegate.isAdShowed {
                UIApplication.shared.keyWindow?.addSubview(adView)
            }
        }
        
        showPlanViewController()
        // 更改意向国家或申请项目
        NotificationCenter.default.addObserver(self, selector: #selector(reloadUserTarget), name: NSNotification.Name.XD_NOTIFY_UPDATE_PERSONAL_INFO, object: nil)
    }
    
    /// 监听用户的选校和意向地是否发生了变化
    @objc func reloadUserTarget() {
        let type = XDUser.shared.userTargetType()
        if type != userType {
            portalSection.userType = type
            recommendSection.userType = type
            recommendSection.isTargetCountryRecommendDeleted = false
            recommendSection.countryType = XDUser.shared.userCountryType()
            rankSection.userType = type
            collegeSection.userType = type
            viewedHotSection.userType = type
            selectedHotSection.userType = type
            recentViewedSection.userType = type
            userType = type
            createModel()
        }
        tableView.tableHeaderView = tableHeaderView
    }

    override func showEmpty(_ show: Bool) {
        if show && hasData {
            super.showEmpty(false)
        } else {
            super.showEmpty(show)
        }
    }
    
    override func createModel() {
        switch userType! {
        case .us(.highschool):
            if let model = SSURLReqeustModel(httpMethod: .get, urlString: XD_API_INDEX_HIGHSCHOOL, loadFromFile: true, isPaged: false) {
                model.addExtraRequest(with: .get, urlString: XD_API_HOME_BANNER, parameters: nil)
                self.model = model
            }
        default:
            if let model = SSURLReqeustModel(httpMethod: .get, urlString: XD_API_INDEX, loadFromFile: true, isPaged: false) {
                model.addExtraRequest(with: .get, urlString: XD_API_HOME_BANNER, parameters: nil)
                self.model = model
            }
        }
    }
    
    override func didFinishLoad(with object: Any!) {
        if let data = (object as! [String : Any])["main"] as? [String : Any] {
            if let data = data["data"] as? [String : Any] {
                recommendSection.reloadData(data["recommendedCourse"])
                rankSection.reloadData(data["hotRanks"])
                columnSection.reloadData(data["columnNews"])
                switch userType! {
                case .us(.highschool):
                    collegeSection.isHidden = false
                    viewedHotSection.isHidden = true
                    selectedHotSection.isHidden = true
                    popularMajorSection.isHidden = true
                    recentViewedSection.isHidden = true
                    collegeSection.reloadData(data["schools"])
                default:
                    collegeSection.isHidden = true
                    viewedHotSection.isHidden = false
                    selectedHotSection.isHidden = false
                    popularMajorSection.isHidden = false
                    recentViewedSection.isHidden = false
                    viewedHotSection.reloadData(data["hotSchools"])
                    selectedHotSection.reloadData(data["mostSelectedSchools"])
                    popularMajorSection.reloadData(data["hotMajors"])
                    recentViewedSection.reloadData(data["recentViewedSchools"])
                }
                refreshViewsLayout()
            }
            hasData = true
        } else {
            hasData = false
        }
        if let data = (object as! [String : Any])["extra"] as? [[String : Any]] {
            bannerDataList = data[0]["data"] as! [[String : Any]]
            var URLList = [String]()
            for dict in bannerDataList {
                URLList.append(UIImage.OSSImageURLString(urlStr: dict["imageUrl"] as! String, size: bannerSection.size, policy: .fillAndClip))
            }
            bannerSection.imageURLStringsGroup = URLList
        }
        topSearchView?.isHidden = false
        topSection.isHidden = false
    }
    
    override func didFailLoadWithError(_ error: Error!) {
        XDPopView.toast(error.localizedDescription)
    }
    
    //MARK:- SDCycleScrollViewDelegate
    func cycleScrollView(_ cycleScrollView: SDCycleScrollView!, didSelectItemAt index: Int) {
        XDStatistics.click("8_A_banner_btn")
        let data = bannerDataList[index]
        XDRoute.pushWebVC([QueryKey.URLPath: data["adUrl"]!, QueryKey.TitleName: data["name"]!])
    }
    
    //MARK:- UIScrollViewDelegate
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard !UIDevice.isIPhoneX else { return }
        let limit = XDSize.screenWidth * 0.5
        let offset = min(limit, scrollView.contentOffset.y) / limit
        topSection.darkStyle = offset > 0.5
        topSearchView?.alpha = offset
        let gap1 = (0xE4 - 0xFF) * offset
        let gap2 = (0xE5 - 0xFF) * offset
        let gap3 = (0xE6 - 0xFF) * offset
        let alpha = 0.95 + 0.05 * offset
        let color = UIColor(red: (0xFF + gap1) / 0xFF, green: (0xFF + gap2) / 0xFF, blue: (0xFF + gap3) / 0xFF, alpha: alpha)
        topSection.searchBtn.backgroundColor = color
        if let topSearchView = topSearchView {
            if topSearchView.alpha > 0.5 {
                UIApplication.shared.statusBarStyle = .default
            } else {
                UIApplication.shared.statusBarStyle = .lightContent
            }
        }
    }
    
    /// 主要用于推荐视图被删除之后的布局更新
    private func refreshViewsLayout() {
        rankSection.top = recommendSection.bottom
        collegeSection.top = rankSection.bottom
        viewedHotSection.top = rankSection.bottom
        selectedHotSection.top = viewedHotSection.bottom
        if userType == .us(.highschool) {
            columnSection.top = collegeSection.bottom
            tableHeaderView.height = columnSection.bottom
        } else {
            popularMajorSection.top = selectedHotSection.bottom
            if XDUser.shared.userDegreeType() == .master {
                columnSection.top = popularMajorSection.bottom
                recentViewedSection.top = columnSection.bottom
            } else {
                columnSection.top = selectedHotSection.bottom
                recentViewedSection.top = columnSection.bottom
            }
            tableHeaderView.height = recentViewedSection.bottom
        }
        tableView.tableHeaderView = tableHeaderView
    }
    
    private func showPlanViewController() {
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
    
}

//MARK: IndexRecommendViewDelegate
extension IndexViewController: IndexRecommendViewDelegate {    
    func indexRecommendViewDidTapCheckinView(_ view: ExamPlanSignInView) {
        let examPlanController: ExamQueryViewController = ExamQueryViewController(query: ["hasMyPlan": true])
        navigationController?.pushViewController(examPlanController, animated: true)
    }
    
    func indexRecommendViewConfimDeleteCardView(_ cardView: CardView) {
        if let courseId = cardView.cardModel?.courseID, cardView.isCourseRecommend {
            alertDialog(title: "确定要跳过当前课程", leftActionHandler: nil, rightActionHandler: {
                let urlString = String(format: XD_API_COURSE_CLOSE_RECOMMEND, courseId)
                SSNetworkManager.shared().delete(urlString, parameters: nil, success: { (task, responseObject) in
                    if let responseData = responseObject as? [String: Any] {
                        self.recommendSection.reloadData(responseData["data"])
                        self.refreshViewsLayout()
                    }
                }) { (task, error) in
                    XDPopView.toast(error.localizedDescription)
                }
            })
        } else {
            if Preference.TARGET_COUNTRY_GUIDE.get() ?? true {
                let guideView: IndexToolGuideView = IndexToolGuideView(frame: UIScreen.main.bounds)
                guideView.delegate = self
                UIApplication.shared.keyWindow?.addSubview(guideView)
                guideView.showGuideView()
            } else {
                alertDialog(title: "确定要删除", leftActionHandler: nil, rightActionHandler: {
                    self.recommendSection.isTargetCountryRecommendDeleted = true
                    self.recommendSection.removeCardViewFromScreen(cardView)
                    self.refreshViewsLayout()
                })
            }
        }
    }
    
    func indexRecommendViewDidTap(_ cardView: CardView) {
        if let courseId = cardView.cardModel?.courseID {
            let vc = CourseDetailViewController()
            vc.courseID = courseId
            XDRoute.pushToVC(vc)
        } else {
            var webDic: [String: Any] = [: ]
            var titles: [String] = "target_place_refer_desc".localized.components(separatedBy: ",")
            switch XDUser.shared.userDegreeType() {
            case .highschool:
                webDic = ["kURLPath": "compare-highschool-countries.html", "kCourseID": titles[0], "alertCountryTarget": true]
            case .bachelor:
                webDic = ["kURLPath": "compare-undergraduate-countries.html", "kCourseID": titles[1], "alertCountryTarget": true]
            case .master:
                webDic = ["kURLPath": "compare-graduate-countries.html", "kCourseID": titles[2], "alertCountryTarget": true]
            default:
                let vc = TargetReferViewController()
                vc.isFromIndexVC = true
                navigationController?.pushViewController(vc, animated: true)
                return
            }
            XDRoute.pushWebVC(webDic)
        }
    }
}

// MARK: IndexToolGuideViewDelegate
extension IndexViewController: IndexToolGuideViewDelegate {
    func indexToolGuideViewDidCancel() {
        
    }
    
    func indexToolGuideViewDidDelete() {
        self.recommendSection.isTargetCountryRecommendDeleted = true
        self.recommendSection.removeCardViewFromScreen(recommendSection.targetCountryView)
        Preference.TARGET_COUNTRY_GUIDE.set(false)
        refreshViewsLayout()
    }
}

// MARK: ADViewDelegate
extension IndexViewController: ADViewDelegate {
    func adViewDidTap(_ adView: ADView, _ query: [String : String]) {
        let webVC: WKWebViewController = WKWebViewController(query: query)
        navigationController?.pushViewController(webVC, animated: true)
        adView.removeFromSuperview()
    }
}
