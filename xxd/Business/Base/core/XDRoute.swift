//
//  XDRoute.swift
//  xxd
//
//  Created by remy on 2017/12/26.
//  Copyright © 2017年 com.smartstudy. All rights reserved.
//



class XDRoute {
    
    static func pushMQChatVC() {
        guard let messageCount = Int(XDUser.shared.model.unreadMessageCount) else {
            let signVC: SignInViewController = SignInViewController()
            presentToVC(signVC)
            return
        }
        if XDEnvConfig.userBadgeCount > messageCount {
            let leftCount = messageCount
            JPUSHService.setBadge(leftCount)
            UIApplication.shared.applicationIconBadgeNumber = leftCount
        }
        if let vc = UIApplication.topVC() {
            if !vc.isKind(of: MQChatViewController.self) {
                let chat = MQChatViewManager()
                chat.chatViewStyle.navBarTintColor = XDColor.main
                chat.pushMQChatViewController(in: vc)
            }
        }
    }

    static func pushWebVC(_ query:[AnyHashable : Any]) {
        let vc = WKWebViewController(query: query)
        UIApplication.topVC()?.navigationController?.pushViewController(vc!, animated: true)
    }
    
    static func popToVC(_ name: String) {
        let names = name.components(separatedBy: ",")
        if let topVC = UIApplication.topVC(), let vcs = topVC.navigationController?.viewControllers {
            if names.count > 1 {
                for name in names {
                    for vc in vcs {
                        if vc.metaTypeName == name {
                            topVC.navigationController?.popToViewController(vc, animated: true)
                            return
                        }
                    }
                }
            } else {
                for vc in vcs {
                    if vc.metaTypeName == name {
                        topVC.navigationController?.popToViewController(vc, animated: true)
                        return
                    }
                }
            }
        }
    }
    
    static func popWithCount(_ count: Int) {
        let topVC = UIApplication.topVC()
        if let list = topVC?.navigationController?.viewControllers, count > 0 && count < list.count {
            let vc = list[list.count - count - 1]
            topVC?.navigationController?.popToViewController(vc, animated: true)
        }
    }
    
    static func popAndPushToVC(_ vc: UIViewController) {
        if let nc = UIApplication.topVC()?.navigationController {
            nc.popViewController(animated: false)
            nc.pushViewController(vc, animated: true)
        }
    }
    
    static func pushToVC(_ vc: UIViewController) {
        if let nc = UIApplication.topVC()?.navigationController {
            nc.pushViewController(vc, animated: true)
        }
    }
    
    static func presentToVC(_ vc: UIViewController) {
        if let topVC = UIApplication.topVC() {
            topVC.presentModalViewController(vc, animated: true, completion: nil)
        }
    }
    
    /**
     *
     *  录取率 xuanxiaodi://tool/admission_rate?schoolId=XXX
     *  智能选校 xuanxiaodi://tool/match_school
     *  智能选专业 xuanxiaodi://tool/match_major
     *  课程列表 xuanxiaodi://course/list
     *  录播课 xuanxiaodi://course?id=XXX
     *  学校详情 xuanxiaodi://school?id=XXX
     *  排名 xuanxiaodi://rank?id=XXX
     *  美恰 xuanxiaodi://customer_service
     *  消息中心 xuanxiaodi://notifications
     *  问答 xuanxiaodi://question?id=XXX
     *  webview [http/https]://XXX
     *
     */
//    static let classFromName: [String: AnyClass] = [
//
//        "tool/admission_rate": AdmissionTestViewController.self,
//        "tool/match_school": SmartCollegeViewController.self,
//        "tool/match_major": SmartMajorViewController.self,
//        "course": CourseDetailViewController.self,
//        "course/list": CourseListViewController.self,
//        "school": CollegeDetailViewController.self,
//        "school/list": CollegeViewController.self,
//        "rank": RankListViewController.self,
//        "notifications": MessageCenterViewController.self
//    ]
    
    /**
     *
     *  路由来源:
     *  1.app间,h5页面的协议链接跳转
     *  2.推送通知
     *  3.消息中心
     *
     */
    static func schemeRoute(url: URL?) {
        if let url = url, let scheme = url.scheme {
            if scheme == "xuanxiaodi" {
                let type = "\(url.host ?? "")\(url.path)"
                if type == "customer_service" {
                    pushMQChatVC()
                } else {
                    var query = [String: String]()
                    if let arr = url.query?.components(separatedBy: "&") {
                        let _ = arr.map {
                            let arr = $0.components(separatedBy: "=")
                            query[arr[0]] = arr[1]
                        }
                    }
                    switch type {
                    case "tool/admission_rate":
                        let vc = AdmissionTestViewController()
                        vc.collegeID = Int(query["schoolId"] ?? "0")!
                        pushToVC(vc)
                    case "tool/match_school":
                        let vc = SmartCollegeViewController()
                        pushToVC(vc)
                    case "tool/match_major":
                        let vc = SmartMajorViewController()
                        pushToVC(vc)
                    case "course":
                        let vc = CourseDetailViewController()
                        vc.courseID = Int(query["id"] ?? "0")!
                        pushToVC(vc)
                    case "course/list":
                        let vc = CourseListViewController()
                        pushToVC(vc)
                    case "school":
                        let vc = CollegeDetailViewController()
                        vc.collegeID = Int(query["id"] ?? "0")!
                        pushToVC(vc)
                    case "school/list":
                        let vc = CollegeViewController()
                        pushToVC(vc)
                    case "rank":
                        let vc = RankListViewController()
                        vc.rankCategoryID = Int(query["id"] ?? "0")!
                        vc.titleName = "tab_item_college_rank".localized
                        pushToVC(vc)
                    case "notifications":
                        let vc = MessageCenterViewController()
                        pushToVC(vc)
                    case "question":
                        let vc = QuestionDetailViewController()
                        vc.questionID = Int(query["id"] ?? "0")!
                        pushToVC(vc)
                    default:
                        break
                    }
                }
            } else if scheme == "http" || scheme == "https" {
                pushWebVC([QueryKey.URLPath: url.absoluteString])
            }
        }
    }
}
