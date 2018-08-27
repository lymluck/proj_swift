//
//  UserViewController.swift
//  xxd
//
//  Created by remy on 2018/2/5.
//  Copyright © 2018年 com.smartstudy. All rights reserved.
//

import SSRobot_swift

private var kToolInfoKey: UInt8 = 0

class UserViewController: SSViewController, SRClientUserInfoDataSource {
    
    private var scrollView: UIScrollView!
    private var itemList = [XDItemView]()
    private var nameLabel: UILabel!
    private var avatar: UIImageView!
    private var badgeViewList = [UIView]()
    private var userDescLabel: UILabel!
    private var itemTools: XDItemView!
    private var toolSpace: CGFloat = (XDSize.screenWidth-32.0-240.0)/3.0
    private var toolWidth: CGFloat = XDSize.screenWidth/4.0
    private lazy var toolNames: [String] = ["智能选专业", "智能选校", "GPA计算器", "留学规划", "意向国家对比", "考试时间查询"]
    private lazy var toolImages: [String] = ["zhuanye", "xuanxiao", "GPA", "guihua", "mudidi", "time"]
    override func needNavigationBar() -> Bool {
        return false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        XDStatistics.click("22_B_my")
        edgesForExtendedLayout = []
        initView()
        NotificationCenter.default.addObserver(self, selector: #selector(reloadData), name: NSNotification.Name(rawValue: XD_NOTIFY_SIGN_OUT), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(reloadData), name: NSNotification.Name.XD_NOTIFY_UPDATE_PERSONAL_INFO, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(invokeScheme(notification:)), name: NSNotification.Name(rawValue: "kNotificationMessageInvokeScheme"), object: nil)
        // 我的消息,用于更新红点
//        NotificationCenter.default.addObserver(self, selector: #selector(updateMyMessageBadge), name: .XD_NOTIFY_UPDATE_UNREAD_MESSAGE, object: nil)
        // 接收美洽消息,用于更新红点
        NotificationCenter.default.addObserver(self, selector: #selector(updateMQMessageBadge), name: NSNotification.Name(rawValue: MQ_RECEIVED_NEW_MESSAGES_NOTIFICATION), object: nil)
        // 退出美洽聊天,用于更新红点
        NotificationCenter.default.addObserver(self, selector: #selector(updateMQMessageBadge), name: NSNotification.Name(rawValue: MQ_NOTIFICATION_CHAT_END), object: nil)
    }
    
    private func initView() {
        scrollView = UIScrollView(frame: CGRect(x: 0, y: 0, width: XDSize.screenWidth, height: XDSize.screenHeight - XDSize.tabbarHeight))
        scrollView.backgroundColor = UIColor.clear
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.scrollsToTop = false
        scrollView.alwaysBounceVertical = true
        if #available(iOS 11.0, *) {
            scrollView.contentInsetAdjustmentBehavior = .never;
        }
        view.addSubview(scrollView)
        
        let topStatusBg = CALayer()
        topStatusBg.backgroundColor = UIColor.white.cgColor
        topStatusBg.frame = CGRect(x: 0, y: 0, width: XDSize.screenWidth, height: XDSize.statusBarHeight)
        view.layer.addSublayer(topStatusBg)
        
        // 个人信息
        let itemUser = XDItemView(frame: CGRect(x: 0, y: 0, width: XDSize.screenWidth, height: 175), type: .plain)//.bottom)
        itemUser.rightArrow.top = 95
        
        let topWrap = CALayer()
        topWrap.backgroundColor = UIColor.white.cgColor
        topWrap.frame = CGRect(x: 0, y: -XDSize.screenHeight, width: XDSize.screenWidth, height: XDSize.screenHeight)
        itemUser.layer.addSublayer(topWrap)
        
        avatar = UIImageView(frame: CGRect(x: 20, y: 70, width: 64, height: 64))
        avatar.layer.cornerRadius = 32
        avatar.layer.masksToBounds = true
        itemUser.addSubview(avatar)
        
        nameLabel = UILabel(frame: CGRect(x: 108, y: 0, width: XDSize.screenWidth - 149, height: 30), text: "", textColor: XDColor.itemTitle, fontSize: 26)!
        itemUser.addSubview(nameLabel)
        
        userDescLabel = UILabel(frame: .zero, text: "user_info_desc".localized, textColor: UIColor(0xC4C9CC), fontSize: 14)!
        itemUser.addSubview(userDescLabel)
        userDescLabel.snp.makeConstraints({ (make) in
            make.left.right.equalTo(nameLabel)
            make.top.equalTo(nameLabel.snp.bottom).offset(4)
        })
        
        // 常用工具
        let itemUsefulTools = XDItemView(frame: CGRect(x: 0.0, y: itemUser.bottom + 12.0, width: XDSize.screenWidth, height: 252.0), type: .plain)
        itemUsefulTools.isRightArrow = false
        itemUsefulTools.addSubview(UILabel(frame: CGRect(x: 16.0, y: 20.0, width: 68.0, height: 24.0), text: "常用工具", textColor: UIColor(0x26343F), fontSize: 16.0)!)
        itemUsefulTools.addSubview(UIView(frame: CGRect(x: 16.0, y: 63.0, width: XDSize.screenWidth-16.0, height: XDSize.unitWidth), color: XDColor.itemLine))
        for (index, tool) in toolNames.enumerated() {
            let toolBackgroundView: UIView = UIView(frame: CGRect(x: CGFloat(index%4)*toolWidth, y: CGFloat((index)/4)*94.0+64.0, width: toolWidth, height: 94.0), color: UIColor.white)
            let imageView: UIImageView = UIImageView(image: UIImage(named: toolImages[index]))
            let label: UILabel = UILabel(frame: CGRect.zero, text: tool, textColor: UIColor(0x58646E), fontSize: 12.0)
            label.textAlignment = .center
            toolBackgroundView.addSubview(imageView)
            toolBackgroundView.addSubview(label)
            imageView.snp.makeConstraints { (make) in
                make.top.equalToSuperview().offset(18.0)
                make.centerX.equalToSuperview()
            }
            label.snp.makeConstraints { (make) in
                make.bottom.equalToSuperview().offset(-20.0)
                make.centerX.equalToSuperview()
            }
            let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UserViewController.eventToolTapResponse(_:)))
            toolBackgroundView.tag = index
            toolBackgroundView.addGestureRecognizer(tapGesture)
            itemUsefulTools.addSubview(toolBackgroundView)
        }
        
        // 留学服务
        let studyService = XDItemView(frame: CGRect(x: 0.0, y: itemUsefulTools.bottom+12.0, width: XDSize.screenWidth, height: 90.0), type: .plain)
        studyService.isRightArrow = false
        studyService.addSubview(UIImageView(frame: CGRect(x: XDSize.screenWidth-154.0, y: 10.0, width: 154.0, height: 80.0), imageName: "study_service"))
        studyService.addSubview(UIImageView(frame: CGRect(x: 16.0, y: 26.0, width: 138.0, height: 28.0), imageName: "enter"))
        studyService.addSubview(UILabel(frame: CGRect(x: 16.0, y: 57.0, width: 150.0, height: 18.0), text: "一站式美国留学专家", textColor: XDColor.itemText, fontSize: 13.0))
        
        // 我的留学时间规划轴 itemUser
        let itemStudyPlan = XDItemView(frame: CGRect(x: 0, y: studyService.bottom + 12.0, width: XDSize.screenWidth, height: 66), type: .middle)
        itemStudyPlan.addSubview(UILabel(frame: CGRect(x: 16, y: 21, width: XDSize.screenWidth, height: 24), text: "user_study_plan".localized, textColor: XDColor.itemTitle, fontSize: 17))
        
        // 我的选校
        let itemMyTarget = XDItemView(frame: CGRect(x: 0, y: itemStudyPlan.bottom, width: XDSize.screenWidth, height: 66), type: .middle)
        if itemStudyPlan.isHidden {
            itemMyTarget.top = itemUser.bottom + 20
//            itemMyTarget.lineType = .top
            itemMyTarget.lineType = .plain
        }
        itemMyTarget.addSubview(UILabel(frame: CGRect(x: 16, y: 21, width: XDSize.screenWidth, height: 24), text: "user_target".localized, textColor: XDColor.itemTitle, fontSize: 17))
        
        // 我的收藏
        let itemMyFavorite = XDItemView(frame: CGRect(x: 0, y: itemMyTarget.bottom, width: XDSize.screenWidth, height: 66), type: .plain)
        itemMyFavorite.addSubview(UILabel(frame: CGRect(x: 16, y: 21, width: XDSize.screenWidth, height: 24), text: "user_favorite".localized, textColor: XDColor.itemTitle, fontSize: 17))
        
        // 我的消息
//        let itemMyMessage = XDItemView(frame: CGRect(x: 0, y: itemMyFavorite.bottom, width: XDSize.screenWidth, height: 66), type: .bottom)
//        addLabelBadgeView("user_message".localized, itemMyMessage)
        
        // 更多工具
        itemTools = XDItemView(frame: CGRect(x: 0, y: itemMyFavorite.bottom + 12.0, width: XDSize.screenWidth, height: 140), type: .middle) //.single)
        itemTools.isRightArrow = false
        itemTools.addSubview(UILabel(frame: CGRect(x: 16, y: 0, width: XDSize.screenWidth, height: 56), text: "user_more_tools".localized, textColor: XDColor.itemTitle, fontSize: 17))
        addToolView()
        
        // 一键加群
        let itemGroup = XDItemView(frame: CGRect(x: 0, y: itemTools.bottom, width: XDSize.screenWidth, height: 66), type: .middle)
        itemGroup.addSubview(UILabel(frame: CGRect(x: 16, y: 21, width: XDSize.screenWidth, height: 24), text: "user_add_group".localized, textColor: XDColor.itemTitle, fontSize: 17))
        itemGroup.isHidden = !canOpenApp(XDUser.shared.userCountryType().qq_group_scheme_url)
        
        // 客服咨询
        let itemConsult = XDItemView(frame: CGRect(x: 0, y: itemGroup.bottom, width: XDSize.screenWidth, height: 66), type: .middle)
        addLabelBadgeView("user_consult".localized, itemConsult)
        if itemGroup.isHidden {
            itemConsult.top = itemTools.bottom
        }
        
        // 设置
        let itemSetting = XDItemView(frame: CGRect(x: 0, y: itemConsult.bottom, width: XDSize.screenWidth, height: 66), type: .plain)
        itemSetting.addSubview(UILabel(frame: CGRect(x: 16, y: 21, width: XDSize.screenWidth, height: 24), text: "user_setting".localized, textColor: XDColor.itemTitle, fontSize: 17))
        
        itemList = [itemUser, itemUsefulTools, studyService, itemStudyPlan, itemMyTarget, itemMyFavorite, itemTools, itemGroup, itemConsult, itemSetting]
        for (index, item) in itemList.enumerated() {
            if item != itemTools  || item != itemUsefulTools || item != studyService {
                item.isRightArrow = true
                item.info = ["index": index]
                item.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(itemTap(gestureRecognizer:))))
            }
            scrollView.addSubview(item)
        }
        
        reloadData()
//        updateMyMessageBadge()
        updateMQMessageBadge()
    }
 
    private func addToolView() {
        let texts = ["tool_toefl", "tool_ielts", "tool_zkmsk"]
        let imageNames = ["app_toefl", "app_ielts", "app_zkmsk"]
        // 斩雅思,智课名师课没有定义scheme,用其微信的
        let schemes = ["zhikezhantoefl://", "wxeaa742ca4d706345://", "wx9c73ece74d5ddd60://"]
        let downloadUrls = [XD_WEB_TOEFL_DOWNLOAD_URL, XD_WEB_IELTS_DOWNLOAD_URL, XD_WEB_ZKMSK_DOWNLOAD_URL]
        let clickNames = ["22_A_down_toefl_cell", "22_A_down_ielts_cell", "22_A_down_class_cell"]
        
        let scrollView = UIScrollView(frame: CGRect(x: 0, y: 56, width: XDSize.screenWidth, height: 84))
        scrollView.backgroundColor = UIColor.clear
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.scrollsToTop = false
        scrollView.alwaysBounceHorizontal = true
        itemTools.addSubview(scrollView)
        
        let toolView = UIView(frame: .zero)
        scrollView.addSubview(toolView)
        toolView.snp.makeConstraints({ (make) in
            make.left.right.equalTo(scrollView)
            make.top.equalTo(scrollView).offset(10)
            make.height.equalTo(64)
        })
        
        var lastView: UIView!
        for (index, text) in texts.enumerated() {
            var flag = "app_download"
            var appAction = #selector(downloadAppTap(gestureRecognizer:))
            if canOpenApp(schemes[index]) {
                flag = "app_open"
                appAction = #selector(openAppTap(gestureRecognizer:))
            }
            let view = UIView(frame: .zero, color: XDColor.mainBackground)
            view.layer.cornerRadius = 6
            objc_setAssociatedObject(view, &kToolInfoKey, ["scheme": schemes[index], "url": downloadUrls[index], "click": clickNames[index]], .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: appAction))
            toolView.addSubview(view)
            view.snp.makeConstraints({ (make) in
                make.left.equalTo(lastView == nil ? toolView : lastView.snp.right).offset(16)
                make.top.equalTo(toolView)
                if index == texts.count - 1 {
                    make.right.equalTo(toolView).offset(-16)
                }
                make.height.equalTo(toolView)
            })
            lastView = view
            
            let logo = UIImageView(frame: .zero, imageName: imageNames[index])!
            view.addSubview(logo)
            logo.snp.makeConstraints({ (make) in
                make.centerY.equalTo(view)
                make.left.equalTo(view).offset(10)
                make.size.equalTo(CGSize(width: 46, height: 46))
            })
            
            let label = UILabel(frame: .zero, text: text.localized, textColor: XDColor.itemTitle, fontSize: 14)!
            view.addSubview(label)
            label.snp.makeConstraints({ (make) in
                make.centerY.equalTo(view)
                make.left.equalTo(logo.snp.right).offset(10)
            })
            
            let download = UIImageView(frame: .zero, imageName: flag)!
            view.addSubview(download)
            download.snp.makeConstraints({ (make) in
                make.centerY.equalTo(view)
                make.left.equalTo(label.snp.right).offset(10)
                make.right.equalTo(view).offset(-10)
                make.size.equalTo(CGSize(width: 18, height: 18))
            })
        }
        
    }
    
    private func addLabelBadgeView(_ text: String, _ superView: UIView) {
        let label = UILabel(frame: .zero, text: text.localized, textColor: XDColor.itemTitle, fontSize: 17)!
        superView.addSubview(label)
        label.snp.makeConstraints({ (make) in
            make.top.equalTo(superView).offset(21)
            make.left.equalTo(superView).offset(16)
        })
        
        let badge = UIView(frame: .zero, color: UIColor(0xF6511D))
        badge.layer.cornerRadius = 3
        superView.addSubview(badge)
        badgeViewList.append(badge)
        badge.snp.makeConstraints({ (make) in
            make.top.equalTo(label).offset(-2)
            make.left.equalTo(label.snp.right)
            make.size.equalTo(CGSize(width: 6, height: 6))
        })
    }
    
    private func canOpenApp(_ urlStr: String) -> Bool {
        return UIApplication.shared.canOpenURL(URL(string: urlStr)!)
    }
    
    
    //MARK:- Notification
    @objc func reloadData() {
        if XDUser.shared.hasLogin() {
            nameLabel.text = XDUser.shared.model.nickname
            nameLabel.top = avatar.top + 9
            userDescLabel.isHidden = false
            avatar.setOSSImage(urlStr: XDUser.shared.model.avatarURL, size: CGSize(width: 64, height: 64), policy: .fill, placeholderImage: UIImage(named: "default_avatar")!)
        } else {
            nameLabel.text = "user_sign_in".localized
            nameLabel.top = avatar.top + 18
            userDescLabel.isHidden = true
            avatar.image = UIImage(named: "default_avatar")
        }
        let userType = XDUser.shared.userTargetType()
        var isUSA = false
        var isUSAHighschool = false
        var isHiddenTargetPlan = false
        if case let .us(degree) = userType {
            isUSA = true
            if degree == .highschool {
                isUSAHighschool = true
            }
            if degree == .other {
                isHiddenTargetPlan = true
            }
        }
        var offsetY: [CGFloat] = [12,12,12,0,0,12,0,0,0,0]
        // 美高隐藏留学规划,我的选校,机器人
        // 意向国家为美国非高中显示留学规划
//        itemList[1].isHidden = isUSAHighschool || !isUSA
//        itemList[2].isHidden = isUSAHighschool
//        itemList[6].isHidden = isUSAHighschool
        itemList[3].isHidden = isUSAHighschool || !isUSA || isHiddenTargetPlan
        itemList[4].isHidden = isUSAHighschool
        var lastView = itemList[0]
        for (index, item) in itemList[1...].enumerated() {
            let space = offsetY[index]
            if item.isHidden {
                if space > 0 && index < offsetY.count - 1 {
                    offsetY[index + 1] = space
                }
            } else {
                item.top = lastView.bottom + space
                if index == 4 || index == 9 {
                    // 每块区域最后一项
                    item.lineType = .bottom
                } else {
                    item.lineType = space > 0 ? .top : .middle
                }
                lastView = item
            }
        }
        scrollView.contentSize = CGSize(width: XDSize.screenWidth, height: lastView.bottom + 10)
    }
    
//    @objc func updateMyMessageBadge() {
//        badgeViewList[0].isHidden = !XDUser.shared.hasUnreadMessage()
//    }
    
    @objc func updateMQMessageBadge() {
        MQManager.getUnreadMessages {
            [weak self] (messages, error) in
            self?.badgeViewList[0].isHidden = messages?.count == 0
        }
    }
    
    @objc func invokeScheme(notification: Notification) {
        if let shemeURL = URL(string: notification.userInfo!["scheme"] as! String) {
            XDRoute.schemeRoute(url: shemeURL)
        }
    }
    
    //MARK:- Action
    @objc private func joinGroup() {
        if canOpenApp(XDUser.shared.userCountryType().qq_group_scheme_url) {
            UIApplication.shared.openURL(URL(string: XDUser.shared.userCountryType().qq_group_scheme_url)!)
        }
    }
    
    @objc private func downloadAppTap(gestureRecognizer: UIGestureRecognizer) {
        let data = objc_getAssociatedObject(gestureRecognizer.view!, &kToolInfoKey) as! [String : String]
        UIApplication.shared.openURL(URL(string: data["url"]!)!)
        XDStatistics.click(data["click"]!)
    }
    
    @objc private func openAppTap(gestureRecognizer: UIGestureRecognizer) {
        let data = objc_getAssociatedObject(gestureRecognizer.view!, &kToolInfoKey) as! [String : String]
        UIApplication.shared.openURL(URL(string: data["scheme"]!)!)
    }
    
    @objc private func enterStudyPlan() {
        XDPopView.loading()
        SSNetworkManager.shared().get(XD_API_ABROAD_TIMELINES, parameters: nil, success: {
            [weak self] (task, responseObject) in
            self?.gotoPlan(responseObject as? [String : Any])
            XDPopView.hide()
        }) {
            [weak self] (task, error) in
            self?.gotoPlan(nil)
            XDPopView.hide()
        }
    }
    
    @objc private func gotoPlan(_ data: [String : Any]?) {
        if let data = data {
            let vc = StudyPlanDetailViewController()
            vc.dataList = data["data"] as! [Any]
            navigationController?.pushViewController(vc, animated: true)
        } else {
            let vc = StudyPlanGetViewController()
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    /// 常用工具的点击事件
    @objc private func eventToolTapResponse(_ gesture: UITapGestureRecognizer) {
        if let touchView = gesture.view {
            let index: Int = touchView.tag
            var otherController: UIViewController!
            switch index {
            case 0:
                otherController = SmartMajorViewController()
            case 1:
                 otherController = SmartCollegeViewController()
            case 2:
                otherController = GpaTestViewController()
            case 3:
                otherController = StudyPlanDetailViewController()
            case 4:
                otherController = TargetReferViewController()
            case 5:
                otherController = ExamQueryViewController(query: ["hasMyPlan": false])
            default:
                return
            }
            XDRoute.pushToVC(otherController)
        }
    }
    
    @objc private func itemTap(gestureRecognizer: UIGestureRecognizer) {
        let item = gestureRecognizer.view as! XDItemView
        let index = item.info["index"] as! Int
        var vc: UIViewController!
        switch index {
        case 0:
            XDStatistics.click("22_A_userinfo_cell")
            if XDUser.shared.hasLogin() {
                vc = UserInfoViewController()
            } else {
                vc = SignInViewController()
            }
        case 2:
            // TODO:跳转到留学服务
            XDRoute.pushWebVC([QueryKey.URLPath: "study-abroad-service"])
            break
        case 3:
            XDStatistics.click("22_A_abroad_plan_cell")
            if XDUser.shared.hasLogin() {
                return enterStudyPlan()
            } else {
                vc = SignInViewController()
            }
        case 4:
            XDStatistics.click("22_A_my_schools_cell")
            if XDUser.shared.hasLogin() {
                vc = TargetListViewController()
            } else {
                vc = SignInViewController()
            }
        case 5:
            XDStatistics.click("22_A_my_favorit_cell")
            if XDUser.shared.hasLogin() {
                vc = FavoriteViewController()
            } else {
                vc = SignInViewController()
            }
//        case 5:
//            XDStatistics.click("22_A_my_message_cell")
//            if XDUser.shared.hasLogin() {
//                vc = MessageCenterViewController()
//            } else {
//                vc = SignInViewController()
//            }
        case 7:
            return joinGroup()
        case 8:
            XDStatistics.click("22_A_consult_cell")
            return XDRoute.pushMQChatVC()
//            let counselor = IndexCounselorViewController(query: nil)
//            XDRoute.pushToVC(counselor!)
//            return
        case 9:
            XDStatistics.click("22_A_setting_cell")
            vc = SettingViewController()
        default:
            break
        }
        if let _ = vc {
            if vc is SignInViewController {
                presentModalViewController(vc, animated: true, completion: nil)
            } else {
                navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    
    //MARK:- SRClientUserInfoDataSource
    var srClientUserID: Int64 {
        return Int64(XDUser.shared.model.userID)!
    }
    
    var srClientUsername: String {
        return XDUser.shared.model.nickname
    }
}
