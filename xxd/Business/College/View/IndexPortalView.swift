//
//  IndexPortalView.swift
//  xxd
//
//  Created by remy on 2018/4/8.
//  Copyright © 2018年 com.smartstudy. All rights reserved.
//

private var kPortalItemKey: Void?
class IndexPortalView: UIView {
    
    enum PortalItemType: String {
        case college, rank, major, special, admission, smartMajor, smartCollege, gpa, qa, activity
        func info() -> (name: String, logo: String) {
            switch self {
            case .college:
                return ("院校库", "portal_college")
            case .rank:
                return ("排行榜", "portal_rank")
            case .major:
                return ("专业库", "portal_major")
            case .special:
                return ("留学专题", "portal_special")
            case .admission:
                return ("录取率测试", "portal_admission")
            case .smartMajor:
                return ("智能选专业", "portal_smart_major")
            case .smartCollege:
                return ("智能选校", "portal_smart_college")
            case .activity:
                return ("活动库", "activity")
            case .gpa:
                return ("GPA计算器", "portal_gpa")
            case .qa:
                return ("留学问答", "portal_qa")
            }
        }
    }
    
    var userType: UserTargetType? {
        didSet {
            if userType != oldValue {
                self.removeAllSubviews()
                addItems()
            }
        }
    }

    convenience init(type: UserTargetType) {
        self.init(frame: CGRect(x: 0, y: 0, width: XDSize.screenWidth, height: 0))
        defer {
            self.userType = type
        }
        backgroundColor = .white
    }
    
    private func addItems() {
        let itemInfo = portalItemInfo()
        let logoSize: CGFloat = 46
        let width = (XDSize.screenWidth * 0.25).rounded(.down)
        let logoSpace = ((width - logoSize) * 0.5).rounded(.down)
        for (index, item) in itemInfo.enumerated() {
            let info = item.info()
            let left = CGFloat(index % 4) * width
            let top = 23 + CGFloat(index / 4) * 89
            let btn = UIButton(frame: CGRect(x: left, y: top, width: width, height: 66), title: info.name, fontSize: 13, titleColor: UIColor(0x58646E), target: self, action: #selector(portalTap(sender:)))!
            btn.contentVerticalAlignment = .bottom
            objc_setAssociatedObject(btn, &kPortalItemKey, item, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            let logo = UIImageView(frame: CGRect(x: logoSpace, y: 0, width: logoSize, height: logoSize), imageName: info.logo)!
            btn.addSubview(logo)
            addSubview(btn)
        }
        height = 23 + (CGFloat(itemInfo.count) / 4).rounded(.up) * 89
    }
    
    private func portalItemInfo() -> [PortalItemType] {
        guard let type = userType else { return [] }
        switch type {
        case .us(.highschool):
            return [.college, .rank, .major, .special, .qa, .smartMajor, .activity]
        default:
            return [.college, .rank, .major, .special, .admission, .smartMajor, .smartCollege, .activity]
        }
    }

    //MARK:- Action
    @objc func portalTap(sender: UIButton) {
        let item = objc_getAssociatedObject(sender, &kPortalItemKey) as! PortalItemType
        var vc: UIViewController!
        switch item {
        case .college:
            XDStatistics.click("8_A_school_library_btn")
            switch userType! {
            case .us(.highschool):
                vc = HighSchoolViewController()
            default:
                let vc = CollegeViewController()
                XDRoute.pushToVC(vc)
                return
            }
        case .rank:
            XDStatistics.click("8_A_rank_btn")
            switch userType! {
            case .us(.highschool):
                vc = HighSchoolRankViewController()
            default:
                vc = RankViewController()
            }
        case .major:
            XDStatistics.click("8_A_professional_library_btn")
//            vc = MajorViewController()
            // 替换成新版的找专业
            vc = MajorLibraryViewController()
        case .special:
            XDStatistics.click("8_A_subject_btn")
            vc = SpecialViewController()
        case .admission:
            XDStatistics.click("8_A_acceptance_rate_btn")
            let vc = XDSearchViewController(type: .admission)
            vc.customWrap = UIView(frame: CGRect(x: 0, y: 0, width: XDSize.screenWidth, height: XDSize.visibleHeight), color: UIColor.white)
            vc.placeholder = "请输入要测评的学校"
            UIApplication.topVC()?.tabBarController?.presentModalTranslucentViewController(vc, animated: false, completion: nil)
            return
        case .smartMajor:
            XDStatistics.click("8_A_choose_professional_btn")
            vc = SmartMajorViewController()
        case .smartCollege:
            XDStatistics.click("8_A_choose_school_btn")
            vc = SmartCollegeViewController()
        case .gpa:
            XDStatistics.click("8_A_gpa_btn")
            vc = GpaTestViewController()
        case .qa:
            UIApplication.topVC()?.tabBarController?.selectedIndex = 3
            return
        case .activity:
            vc = CollegeActivityCategoryViewController()
        }
        XDRoute.pushToVC(vc)
    }
}
