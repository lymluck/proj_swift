//
//  AppDelegate.swift
//  xxd
//
//  Created by remy on 2017/12/18.
//  Copyright © 2017年 com.smartstudy. All rights reserved.
//

import UIKit
import RealReachability
import SSRobot_swift
import UserNotifications
import IQKeyboardManagerSwift
import SensorsAnalyticsSDK

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var isAdShowed: Bool = false
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        #if TEST_MODE
            XDEnvConfig.debugEnv()
        #endif
        XDEnvConfig.customUserAgent()
        
        // 记录当前版本号,跨版本更新判断
        Preference.CURRENT_APP_VERSION.set(UIApplication.shared.appVersion!)
        
        // 配置二方库
        initSSKitConfig()
        // 配置三方库
        initThirdLib(launchOptions)
        
        // 键盘监听
        IQKeyboardManager.shared.enable = false
        IQKeyboardManager.shared.enableAutoToolbar = false
        IQKeyboardManager.shared.toolbarTintColor = XDColor.main
        IQKeyboardManager.shared.toolbarDoneBarButtonItemText = "完成"
        
        // 更新用户数据
        XDUser.shared.update()
        // 连接IM服务器
//        XDUser.shared.connectIMServer()
//        CounselorIM.shared.delegate = self
//        CounselorIM.shared.connectDelegate = self
        // 广告数据更新
        ADView.checkADState()
        // 请求是否强制登录
        requestWhetherForceToLogin()
        
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.makeKeyAndVisible()
        if XDUser.shared.hasLogin() {
            window?.rootViewController = TabBarViewController()
        } else {
            let signVC: SignInViewController = SignInViewController()
            signVC.isNeedSwitch = true
            let signNav: SSNavigationController = SSNavigationController(rootViewController: signVC)
            window?.rootViewController = signNav
        }
        return true
    }
    
    func initSSKitConfig() {
        SSNetworkManager.setBaseURL(XDEnvConfig.apiHost)
        SSNetworkManager.requestSerializer = XDHTTPRequestSerializer()
        SSNetworkManager.responseSerializer = XDJSONResponseSerializer()
        
        SSConfig.defaultNavigationBarHidden = true
        SSConfig.defaultNoNetworkImage = UIImage(named: "status_no_network")
        SSConfig.defaultNoNetworkString = "status_no_network".localized
        
        SSConfig.defaultErrorImage = UIImage(named: "status_default_error")
        SSConfig.defaultErrorString = "status_default_error".localized
        
        SSConfig.defaultEmptyImage = UIImage(named: "status_default_empty")
        SSConfig.defaultEmptyString = "status_default_error".localized
        
        SSConfig.defaultLoadingViewClass = XDLoadingView.self
        SSConfig.defaultViewControllerBGColor = XDColor.mainBackground
        SSConfig.defaultCenterYOffset = -100
        SSConfig.defaultPageSize = 15
        
        SSTableViewController.setRefreshHeaderClass(XDRefreshHeader.self)
        SSTableViewController.setRefreshFooterClass(XDRefreshFooter.self)
        
        DefaultConfig.Color.background = UIColor(0xF5F6F7)
        DefaultConfig.Style.navigationBar = .custom
        DefaultConfig.Color.navigationBarItemTitle = XDColor.main
        DefaultConfig.Image.navBack = UIImage(named: "nav_back_arrow")!
    }
    
    func initThirdLib(_ launchOptions: [UIApplicationLaunchOptionsKey: Any]?) {
        // 网络状态
        if let netShared = RealReachability.sharedInstance() {
            netShared.startNotifier()
            netShared.hostForPing = "www.baidu.com"
            netShared.autoCheckInterval = 0.3
            NotificationCenter.default.addObserver(self, selector: #selector(networkChanged(notification:)), name: NSNotification.Name.realReachabilityChanged, object: nil)
        }
        // 初始化机器人
        #if TEST_MODE
            SRClient.setConfig(host: "172.17.7.102", port: "3120")
        #else
            SRClient.setConfig(host: "123.56.253.247", port: "3120")
        #endif
        // 初始化美洽
        MQManager.initWithAppkey(XDEnvConfig.MeiqiaAppKey, completion: nil)
        // 初始化友盟
        umengWithIDFACheck()
        // 初始化神策
        initialSensorsSDKConfiguration()
        // 初始化社交分享
        registerUSharePlatforms()
        // 注册极光推送
        setupJPushService(launchOptions)
        NotificationCenter.default.addObserver(self, selector: #selector(JPushReceiveMessage(notification:)), name: NSNotification.Name.jpfNetworkDidReceiveMessage, object: nil)
        // 测试环境关闭统计,打开调试,生产环境相反
        #if DEBUG
        #else
//            JPUSHService.setLogOFF()
        #endif
    }
    
    func initialSensorsSDKConfiguration() {
        #if TEST_MODE
        SensorsAnalyticsSDK.sharedInstance(withServerURL: "http://sea.smartstudy.com/sa?project=default", andDebugMode: .off)
        #else
        SensorsAnalyticsSDK.sharedInstance(withServerURL: "http://sea.smartstudy.com/sa?project=production", andDebugMode: .off)
        #endif
        // 神策替换默认匿名ID
        SensorsAnalyticsSDK.sharedInstance().identify(UIDevice.UDID)
        //神策采集应用名称, 添加product属性
        SensorsAnalyticsSDK.sharedInstance().registerSuperProperties(["app_name": UIApplication.shared.appBundleName ?? "", "product": "选校帝-APP", "platform": "iOSApp", "pid": "c2kp5ioe", "$latest_utm_source": "appstore", "$latest_utm_medium": "", "$latest_utm_term": "", "$latest_utm_content": "选校帝-appstore", "$latest_utm_campaign": ""])
        // 神策开启自动追踪
        SensorsAnalyticsSDK.sharedInstance().enableAutoTrack([.eventTypeAppStart, .eventTypeAppEnd, .eventTypeAppViewScreen, .eventTypeAppClick])
        // 神策追踪渠道
        SensorsAnalyticsSDK.sharedInstance().trackInstallation("AppInstall")
        // 神策打通App,H5
        SensorsAnalyticsSDK.sharedInstance().addWebViewUserAgentSensorsDataFlag()
        // crash
        SensorsAnalyticsSDK.sharedInstance().trackAppCrash()
    }
    
    /// 设置分享平台的相关key
    func registerUSharePlatforms() {
        UMSocialManager.default().setPlaform(.wechatSession, appKey: UMShareKey.wxAppKey, appSecret: UMShareKey.wxAppSecret, redirectURL: nil)
        UMSocialManager.default().setPlaform(.wechatTimeLine, appKey: UMShareKey.wxAppKey, appSecret: UMShareKey.wxAppSecret, redirectURL: nil)
        UMSocialManager.default().setPlaform(.QQ, appKey: UMShareKey.qqAppKey, appSecret: UMShareKey.qqAppSecret, redirectURL: nil)
        UMSocialManager.default().setPlaform(.qzone, appKey: UMShareKey.qqAppKey, appSecret: UMShareKey.qqAppSecret, redirectURL: nil)
        UMSocialManager.default().setPlaform(.sina, appKey: UMShareKey.wbAppKey, appSecret: UMShareKey.wbAppSecret, redirectURL: nil)
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        MQManager.closeMeiqiaService()
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        MQManager.openMeiqiaService()
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        // 统计三方回调本app
        let result = UMSocialManager.default().handleOpen(url, options: options)
        // 三方回调路由
        XDRoute.schemeRoute(url: url)
        return result
    }
    
    func umengWithIDFACheck() {
        SSNetworkManager.shared().post(XD_API_IDFA_CHECK, parameters: ["idfa":UIDevice.IDFA], success: {
            [weak self] (task, responseObject) in
            if let data = (responseObject as! [String : Any])["data"] as? [String : Any] {
                if let isFromASO = data["isFromASO"] as? Bool, !isFromASO {
                    UMConfigure.initWithAppkey(XDEnvConfig.UmengAppKey, channel: "App Store")
                    #if DEBUG
                        MobClick.setCrashReportEnabled(false)
                    #endif
                }
            }
            if let strongSelf = self {
                NotificationCenter.default.removeObserver(strongSelf, name: NSNotification.Name.realReachabilityChanged, object: nil)
            }
        }) { (task, error) in
        }
    }
    
    // 是否开启强制登录
    private func requestWhetherForceToLogin() {
        let urlStr = String(format: XD_API_VERSION_CHECK, UIApplication.shared.appVersion!)
        SSNetworkManager.shared().get(urlStr, parameters: nil, success: { (task, responseObject) in
            if let data = (responseObject as! [String : Any])["data"] as? [String : Any] {
                if let last = data["newest"] as? String,
                    let lastVersion = Int(last.components(separatedBy: ".").joined()),
                    let current = data["current"] as? String,
                    let currentVersion = Int(current.components(separatedBy: ".").joined()) {
                    SignInViewController.canCancel = currentVersion > lastVersion
                }
            }
        }, failure: { (task, error) in
            
        })
    }
    
    //MARK:- Notification
    @objc func JPushReceiveMessage(notification: Notification) {
        if let info = notification.userInfo {
            if let type = info["content_type"] as? String, type == "session_kickout" {
                // 单点登录
                XDUser.shared.logout()
                XDPopView.toast(info["content"] as! String)
            } else if let type = info["content_type"] as? String, type == "unread_answers_count" {
                // 我的问答状态
                if let data = info["extras"] as? [String : Any] {
                    if let num = data["unreadAnswersCount"] as? Int {
                        // 更新问答tab未读状态
                        NotificationCenter.default.post(name: .XD_NOTIFY_UPDATE_QA_UNREAD, object: nil, userInfo: ["unread": num > 0])
                        // 更新问答列表
                        NotificationCenter.default.post(name: .XD_NOTIFY_UPDATE_QA_LIST, object: nil)
                    }
                }
            }
        }
    }
    
    @objc func networkChanged(notification: Notification) {
        // 打开app时无网络,等有网络后初始化一些操作
        if let reachability = notification.object as? RealReachability {
            let status = reachability.currentReachabilityStatus()
            if status == .RealStatusViaWiFi || status == .RealStatusViaWWAN {
                umengWithIDFACheck()
            }
        }
    }
}

// 推送相关
extension AppDelegate: JPUSHRegisterDelegate {
    
    // 初始化极光
    func setupJPushService(_ launchOptions: [UIApplicationLaunchOptionsKey: Any]?) {
        let entity = JPUSHRegisterEntity()
        if #available(iOS 10.0, *) {
            entity.types = Int(UNAuthorizationOptions.alert.rawValue | UNAuthorizationOptions.badge.rawValue | UNAuthorizationOptions.sound.rawValue)
            JPUSHService.register(forRemoteNotificationConfig: entity, delegate: self)
        } else {
            let types = UIUserNotificationType.alert.rawValue | UIUserNotificationType.badge.rawValue | UIUserNotificationType.sound.rawValue
            JPUSHService.register(forRemoteNotificationTypes: types, categories: nil)
        }
        let isDistributionEnv = XDEnvConfig.appEnv == EnvType.distribution
        JPUSHService.setup(withOption: launchOptions, appKey: XDEnvConfig.JPushAppKey, channel: "APP Store", apsForProduction: isDistributionEnv)
        JPUSHService.registrationIDCompletionHandler { (resCode, registrationID) in
            if let registrationID = registrationID {
                XDEnvConfig.jpushRegistrationID = registrationID
            }
        }
    }
    
    // 向JPush注册deviceToken
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        JPUSHService.registerDeviceToken(deviceToken)
        CounselorIM.shared.setDeviceToken(deviceToken)
    }
    
    // iOS 7 Support
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        JPUSHService.handleRemoteNotification(userInfo)
        // 是否前台接收
        let isForeground = application.applicationState == UIApplicationState.active
        XDPushManager.handlePush(userInfo, isForeground: isForeground)
        completionHandler(UIBackgroundFetchResult.newData)
    }
    
    // iOS 10 Support, 前台响应
    @available(iOS 10.0, *)
    func jpushNotificationCenter(_ center: UNUserNotificationCenter!, willPresent notification: UNNotification!, withCompletionHandler completionHandler: ((Int) -> Void)!) {
        let userInfo = notification.request.content.userInfo
        if notification.request.trigger?.isKind(of: UNPushNotificationTrigger.self) ?? false {
            JPUSHService.handleRemoteNotification(userInfo)
            XDPushManager.handlePush(userInfo, isForeground: true)
        }
        completionHandler(Int(UNAuthorizationOptions.alert.rawValue))
    }
    
    // iOS 10 Support, 点击通知响应
    @available(iOS 10.0, *)
    func jpushNotificationCenter(_ center: UNUserNotificationCenter!, didReceive response: UNNotificationResponse!, withCompletionHandler completionHandler: (() -> Void)!) {
        let userInfo = response.notification.request.content.userInfo
        if response.notification.request.trigger?.isKind(of: UNPushNotificationTrigger.self) ?? false {
            JPUSHService.handleRemoteNotification(userInfo)
            XDPushManager.handlePush(userInfo, isForeground: false)
        }
        completionHandler()
    }
}

extension AppDelegate: CounselorIMDelegate {
    func received(message: Message, left: Int) {
        if UIApplication.shared.applicationState == .background { // 如果应用在后台运行,如果收到推送,则以本地通知的形式展现
            TeacherInfoHelper.shared.teacherInfo(message.targetId, completion: { (studentInfo) in
                LocalNotificationManager.shared.add(notification: "",
                                                    body: (studentInfo?.name ?? "message.targetId") + ":" + message.content.displayContent,
                                                    date: Date().adding(.second, value: 1),
                                                    identifier: "newMessage")
            })
        }
        NotificationCenter.default.post(name: .IMReceiveMessage, object: nil, userInfo: [UserInfo.Message: message])
    }

    func onMessageRecalled(_ messageId: Int) {
        NotificationCenter.default.post(name: .IMMessageRecalled, object: nil, userInfo: [UserInfo.MessageId: messageId])
    }
}

extension AppDelegate: CounselorConnectDelegate {
    func connectionStatusChanged(_ status: ConnectionStatus) {
        DispatchQueue.main.async {
            if status == .kickedOfflineByOtherClient { // 用户被踢下线
                XDPopView.toast("账号在其他设备登录")
            }
            NotificationCenter.default.post(name: .IMConnectStatusChanged, object: nil, userInfo: [UserInfo.ConnectStatus: status])
        }
    }
}
