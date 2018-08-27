//
//  WKWebViewController.swift
//  xxd
//
//  Created by remy on 2017/12/26.
//  Copyright © 2017年 com.smartstudy. All rights reserved.
//

import WebKit
import SwiftyJSON
import SSPhotoBrowser
import SensorsAnalyticsSDK

private let INJECT_NAME = "appAction"

enum WebViewControllerBarType: Int {
    case normal
    case gradient
}

class WKWebViewController: SSViewController, WKNavigationDelegate, WKUIDelegate, WKScriptMessageHandler, UIScrollViewDelegate {
    
    private var urlStr = ""
    private var webView: WKWebView!
    private var progress: XDWebViewProgress!
    private var isAlertShow = false
    private var isAlertTargetCountry: Bool = false
    private var barType = WebViewControllerBarType.normal
    private let userContentController = WKUserContentController()
    private var rightMoreBtn: UIButton!
    private var alertParams = [String : String]()
    private var shareParams = [String : String]()
    private var imageParams = [String : String]()
    private var isShare = true
    private lazy var targetCountryVC: EditInfoViewController = {
        let vc = EditInfoViewController(title: "意向国家", type: .list)
        vc.defaultValue = XDUser.shared.model.value(forKey: "targetCountryId") as! String
        vc.isFromInfoVC = false
        return vc
    }()
    
    override init!(query: [AnyHashable : Any]!) {
        super.init(query: query)
        let urlPath = (query[QueryKey.URLPath] as! String).trimmingCharacters(in: .whitespaces)
        urlStr = getUrlStr(urlPath)
        if let titleName = query[QueryKey.TitleName] as? String {
            title = titleName
        }
        if let barType = query["barType"] as? WebViewControllerBarType {
            self.barType = barType
        }
        if let alertCountryTarget = query["alertCountryTarget"] as? Bool {
            self.isAlertTargetCountry = alertCountryTarget
            isGesturePopEnable = false
        }
}
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationBar.leftItem.text = "back".localized
        
        // 分享
        rightMoreBtn = UIButton(frame: CGRect(x: XDSize.screenWidth - 50, y: XDSize.statusBarHeight, width: 50, height: XDSize.topBarHeight), title: "", fontSize: 0, titleColor: UIColor.clear, target: self, action: #selector(shareWebPage))!
        rightMoreBtn.setImage(UIImage(named: "more_btn"), for: .normal)
        rightMoreBtn.isHidden = isShare
        view.addSubview(rightMoreBtn)
        
        let config = WKWebViewConfiguration()
        config.userContentController = userContentController
        // 注入js的native api
        userContentController.add(self, name: INJECT_NAME)
        // 调试 cookie
//        let str = "window.alert(document.cookie);"
//        let aaa = WKUserScript(source: str, injectionTime: WKUserScriptInjectionTime.atDocumentEnd, forMainFrameOnly: false)
//        userContentController.addUserScript(aaa)
        // 注入js设置cookie
        let userScript = WKUserScript(source: fetchCookie(true), injectionTime: WKUserScriptInjectionTime.atDocumentStart, forMainFrameOnly: false)
        userContentController.addUserScript(userScript)
        webView = WKWebView(frame: CGRect(x: 0, y: XDSize.topHeight, width: XDSize.screenWidth, height: XDSize.visibleHeight), configuration: config)
        webView.backgroundColor = UIColor.clear
        webView.scrollView.bounces = true
        webView.scrollView.contentOffset = CGPoint.zero
        webView.uiDelegate = self
        view.addSubview(webView)
        
        if barType == .gradient {
            navigationBar.bottomLine.alpha = 0
            let navBgView = UIView(frame: .zero, color: UIColor.white)
            navBgView.alpha = 0
            navigationBar.backgroundView = navBgView
            webView.scrollView.delegate = self
        }
        
        progress = XDWebViewProgress(webView: webView, delegate: self)
        
        clearCache()
        reloadData()
    }
    
    private func reloadData() {
        webView.stopLoading()
        // 先decode再encode
        if let encodedStr = urlStr.removingPercentEncoding?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
            let url = URL(string: encodedStr)!
            // 每次跳转都重新loadRequest并设置请求的cookie和缓存策略,所以暂时不用考虑 1.请求时不带cookie 2.缓存清理
            var request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 15)
            request.addValue(fetchCookie(false), forHTTPHeaderField: "Cookie")
            webView.load(request)
        }
    }
    
    private func reloadDataAfterSignIn() {
        // 暂时用刷新页面解决登录后cookie问题,直接设置cookie前端的业务逻辑不支持
        webView.reload()
    }
    
    private func clearCache() {
        // ios9以下没有清除缓存的api
        if #available(iOS 9.0, *) {
            let websiteDataTypes = WKWebsiteDataStore.allWebsiteDataTypes()
            let dateFrom = Date(timeIntervalSince1970: 0)
            WKWebsiteDataStore.default().removeData(ofTypes: websiteDataTypes, modifiedSince: dateFrom, completionHandler: {
            })
        }
    }
    
    private func fetchCookie(_ isJsCode: Bool) -> String {
        let format = isJsCode ? "document.cookie=`%@=%@`;" : "%@=%@;"
        var cookieArr = [String]()
        let cs = HTTPCookieStorage.shared
        let url = URL(string: urlStr)!
        let appUrl = URL(string: XDEnvConfig.webHost)!
        let model = XDUser.shared.model
        if url.host == appUrl.host {
            for cookie in cs.cookies! {
                // 执行document.cookie会发生错误, "`" 前加 "\" 防冲突
                let value = cookie.value.replacingOccurrences(of: "%60", with: "%25%60")
                let str = String(format: format, cookie.name, value)
                cookieArr.append(str)
            }
            if !model.ticket.isEmpty {
                // 由于WKWebView取不到cookie的问题,所以手动取用户信息设置
                cookieArr.append(String(format: format, "xxd_ticket", model.ticket))
                // 只对 name 转码
                let name = model.nickname.addingPercentEncoding(withAllowedCharacters: CharacterSet())!
                let userInfo = ["id": model.ID, "userId": model.userID, "name": name, "avatarUrl": model.avatarURL]
                let jsonStr = JSON(userInfo).rawString([.jsonSerialization:JSONSerialization.WritingOptions()])!
                cookieArr.append(String(format: format, "xxd_user", jsonStr))
            }
        }
        if !model.ssUser.isEmpty {
            // 只对 name 转码
            var jsonDict = JSON(parseJSON: model.ssUser)
            let name = jsonDict["name"].stringValue.addingPercentEncoding(withAllowedCharacters: CharacterSet())!
            if var dict = jsonDict.dictionaryObject {
                dict["name"] = name
                let jsonStr = JSON(dict).rawString([.jsonSerialization:JSONSerialization.WritingOptions()])!
                cookieArr.append(String(format: format, "ss_user", jsonStr))
            }
        }
        return cookieArr.joined()
    }
    
    private func gotoLogin() {
        if !isAlertShow {
            isAlertShow = true
            let alertView = UIAlertController(title: "sign_in_alert".localized, message: nil, preferredStyle: .alert)
            alertView.addAction(UIAlertAction(title: "cancel".localized, style: .cancel, handler: {
                [unowned self] (action) in
                self.isAlertShow = false
            }))
            alertView.addAction(UIAlertAction(title: "sign_in_right".localized, style: .destructive, handler: {
                [unowned self] (action) in
                self.isAlertShow = false
                let vc = SignInViewController()
                self.presentModalViewController(vc, animated: true, completion: nil)
                
            }))
            self.present(alertView, animated: true, completion: nil)
        }
    }
    
    private func alertAction() {
        let confirmCallback = alertParams["positive_callback"] ?? ""
        let cancelCallback = alertParams["negative_callback"] ?? ""
        let title = alertParams["title"]?.removingPercentEncoding ?? ""
        let msg = alertParams["msg"]?.removingPercentEncoding ?? ""
        if confirmCallback != "" || cancelCallback != "" {
            if !isAlertShow {
                isAlertShow = true
                let alertView = UIAlertController(title: title, message: msg, preferredStyle: .alert)
                if cancelCallback != "" {
                    let cancelText = alertParams["txt_negative"] ?? ""
                    alertView.addAction(UIAlertAction(title: cancelText, style: .cancel, handler: {
                        [unowned self] (action) in
                        self.isAlertShow = false
                    }))
                }
                if confirmCallback != "" {
                    let confirmText = alertParams["txt_positive"] ?? ""
                    alertView.addAction(UIAlertAction(title: confirmText, style: .destructive, handler: {
                        [unowned self] (action) in
                        self.isAlertShow = false
                    }))
                }
                self.present(alertView, animated: true, completion: nil)
            }
        } else {
            if !msg.isEmpty {
                //FIXME: hud失效,原因不明,暂时替换容器解决
                // 在其他webview中前进后退的而操作会导致本webview的hud失效,,容器不用keyWindow可以解决
                XDPopView.toast(msg, self.view)
                isAlertShow = false
            }
        }
    }
    
    override func backActionTap() {
        webView.stopLoading()
        if webView.canGoBack {
            if navigationBar.leftItem.subText != nil {
                navigationBar.subLeftText = "close".localized
            }
            webView.goBack()
            //TODO: 解决二级界面返回之后分享路径仍为上一个路径的问题; 但是要对其他界面进行测试
            if let url = webView.url?.absoluteString {
                urlStr = url
            }
        } else {
            subLeftActionTap()
        }
    }
    
    // 返回时修改弹框
    override func subLeftActionTap() {
        // addScriptMessageHandler强引用问题,在dealloc之前remove
        userContentController.removeScriptMessageHandler(forName: INJECT_NAME)
        if isAlertTargetCountry {
            let alertVC: UIAlertController = UIAlertController(title: "要修改目前的意向国家吗", message: nil, preferredStyle: UIAlertControllerStyle.alert)
            let doneAction: UIAlertAction = UIAlertAction(title: "修改", style: UIAlertActionStyle.default) { (_) in
                self.isAlertTargetCountry = false
                self.requestTargetCountryData()
                XDRoute.pushToVC(self.targetCountryVC)
            }
            alertVC.addAction(doneAction)
            let cancelAction: UIAlertAction = UIAlertAction(title: "不修改", style: UIAlertActionStyle.cancel) { (_) in
                self.isAlertTargetCountry = false
                self.backActionTap()
            }
            alertVC.addAction(cancelAction)
            self.present(alertVC, animated: true, completion: nil)
        }

        super.backActionTap()
    }
    
    private func getUrlStr(_ str: String) -> String {
        var baseURL = str
        if !str.hasPrefix("http") {
            baseURL = XDEnvConfig.webHost
            if !baseURL.hasSuffix("/") {
                baseURL += "/"
            }
            baseURL += str.hasPrefix("/") ? str.substring(from: 1) : str
        }
        if baseURL.range(of: "appName=com.smartstudy.xxd") == nil {
            let flag = baseURL.range(of: "?") == nil ? "?" : "&"
            baseURL = baseURL + flag + "appName=com.smartstudy.xxd&app-type=iOS&appVersion=" + UIApplication.shared.appVersion!
        }
        return baseURL
    }
    
    private func statistics(_ name: String, _ params: [String : Any]) {
        if urlStr.range(of: "/news/") != nil {
            // 资讯页统计
            if name == "app_meiqia" {
                // 在线咨询
                XDStatistics.click("18_A_consult_btn")
            } else if name == "app_toast" {
                // 收藏
                if let msg = params["msg"] as? String, msg.range(of: "收藏") != nil {
                    XDStatistics.click("18_A_favorit_btn")
                }
            } else if name == "app_share" {
                // 分享
                XDStatistics.click("18_A_share_btn")
            } else if name == "app_link" {
                // 相关资讯
                if let url = params["url"] as? String, url.range(of: "/news/") != nil {
                    XDStatistics.click("18_A_news_about_cell")
                }
            }
        }
    }
    
    private func requestTargetCountryData() {
        XDPopView.loading()
        SSNetworkManager.shared().get(XD_API_PERSONAL_INFO_V2, parameters: nil, success: {
            [weak self] (task, responseObject) in
            if let data = (responseObject as? [String : Any])!["data"] as? [String : Any], let strongSelf = self {
                if let tartgetSection = data["targetSection"] as? [String: Any], let targetCountry = tartgetSection["targetCountry"] as? [String: Any], let targetCountryOptions = targetCountry["options"] as? [[String: Any]] {
                    print(targetCountryOptions)
                    if let dataList = NSArray.yy_modelArray(with: EditInfoModel.self, json: targetCountryOptions) as? [EditInfoModel] {
                        strongSelf.targetCountryVC.dataList = dataList
                    }
                }
            }
            XDPopView.hide()
        }) { (task, error) in
            XDPopView.toast(error.localizedDescription)
        }
    }
    
    //MARK:- WKScriptMessageHandler
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        let data = message.body as! [String : Any]
        let name = data["actionType"] as! String
        let params = (data["params"] as! NSString).translateToDictionary() as! [String : Any]
        DispatchQueue.main.async {
            [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.statistics(name, params)
            switch name {
            case "app_add_my_school_callback":
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: XD_NOTIFY_ADD_MY_TARGET), object: nil)
                XDRoute.popToVC("TargetListViewController")
            case "app_del_my_school_callback":
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: XD_NOTIFY_REMOVE_MY_TARGET), object: nil)
                XDRoute.popToVC("TargetListViewController")
            case "app_school":
                let vc = CollegeDetailViewController()
                vc.collegeID = params["id"] as! Int
                XDRoute.pushToVC(vc)
            case "app_meiqia":
                XDRoute.pushMQChatVC()
            case "app_login":
                strongSelf.gotoLogin()
            case "app_toast":
                XDPopView.toast(params["msg"] as! String)
            case "app_link":
                let urlPath = params["url"] as! String
                strongSelf.urlStr = strongSelf.getUrlStr(urlPath)
                strongSelf.reloadData()
            case "app_program":
                let vc = ProgramViewController()
                vc.titleName = params["name"] as! String
                vc.programID = params["id"] as! Int
                XDRoute.pushToVC(vc)
            case "app_share":
                XDShareView.shared.showSharePanel(shareURL: strongSelf.urlStr, shareInfo: params)
            case "app_ask_question":
                let vc = AskViewController()
                XDRoute.presentToVC(vc)
            case "app_admission_rate":
                if let collegeID = params["schoolId"] as? Int {
                    let vc = AdmissionTestViewController()
                    vc.collegeID = collegeID
                    XDRoute.pushToVC(vc)
                }
            default:
                break
            }
        }
    }
    
    //MARK:- WKUIDelegate
    func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
        let alertView = UIAlertController(title: "", message: message, preferredStyle: .alert)
        alertView.addAction(UIAlertAction(title: "确定", style: .cancel, handler: { (action) in
            completionHandler()
        }))
        self.present(alertView, animated: true, completion: nil)
    }
    
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        // 不同域跳转直接在当前webview加载
        if let frameInfo = navigationAction.targetFrame {
            if !frameInfo.isMainFrame {
                webView.load(navigationAction.request)
            }
        } else {
            webView.load(navigationAction.request)
        }
        return nil
    }
    
    //MARK:- WKNavigationDelegate
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        // 神策打通App,H5
        if SensorsAnalyticsSDK.sharedInstance().showUpWebView(webView, with: navigationAction.request) {
            decisionHandler(WKNavigationActionPolicy.cancel)
            return
        }
        if let url = navigationAction.request.url, let scheme = url.scheme {
            if scheme == "http" || scheme == "https" {
                decisionHandler(WKNavigationActionPolicy.allow)
            } else {
                if scheme == "tel" || scheme == "map" || scheme == "itms-apps" {
                    UIApplication.shared.openURL(url)
                } else if scheme == "xuanxiaodi" {
                    XDRoute.schemeRoute(url: url)
                } else if scheme == "mobile" {
                    // 智课所有产品通用交互
                    if let type = url.host {
                        var query = [String: String]()
                        if let urlComponents = url.query?.components(separatedBy: "&") {
                            let _ = urlComponents.map {
                                let arr = $0.components(separatedBy: "=")
                                // 解决因为字符串拆分导致分享出去的图片无法显示的问题
                                if arr.count > 2 {
                                    var urlAddress = ""
                                    for (index, value) in arr.enumerated() {
                                        if index >= 1 {
                                            urlAddress += value
                                        }
                                    }
                                    query[arr[0]] = urlAddress
                                } else {
                                    query[arr[0]] = arr[1]
                                }
                            }
                        }
                        if type == "show_share" {
                            isShare = query["isShow"] == "true"
                            shareParams = query
                        } else if type == "share" {
                            shareParams = query
                            shareWebPage()
                        } else if type == "navigate" {
                            imageParams = query
                            navigateWebImage()
                        } else if type == "actions" {
                            alertParams = query
                            alertAction()
                        }
                    }
                }
                decisionHandler(WKNavigationActionPolicy.cancel)
            }
        }
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        guard !webView.isLoading else { return }
        if webView.canGoBack {
            if navigationBar.leftItem.subText != nil {
                navigationBar.subLeftText = "close".localized
            }
        }
        if barType == .normal {
            if let title = webView.title, !title.isEmpty {
                navigationBar.centerTitle = title
            }
        } else if title == nil && !webView.canGoBack {
            navigationBar.centerTitle = webView.title
        }
        if barType == .gradient {
            navigationBar.layoutIfNeeded()
            navigationBar.centerView?.alpha = 0
        }
        rightMoreBtn.isHidden = !isShare
    }
    
    func webViewWebContentProcessDidTerminate(_ webView: WKWebView) {
        // WKWebview白屏问题
        webView.reload()
    }
    
    //MARK:- UIScrollViewDelegate
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let alpha = min(1, max(scrollView.contentOffset.y / 120, 0))
        navigationBar.backgroundView?.alpha = alpha
        navigationBar.bottomLine.alpha = alpha
        navigationBar.centerView?.alpha = alpha
    }
}

extension WKWebViewController: IDMPhotoBrowserDelegate {

    @objc func shareWebPage() {
        let link = shareParams["link"] ?? urlStr
        let title = shareParams["title"] ?? navigationBar.centerTitle
        XDShareView.shared.showSharePanel(shareURL: link, shareInfo: [
            "title": title ?? "",
            "description": shareParams["desc"] ?? "点击查看更多",
            "coverUrl": shareParams["imgUrl"] ?? ""
            ])
    }
    
    func navigateWebImage() {
        if let page = imageParams["page"] {
            if page == "preview_img", let imgUrl = imageParams["imgUrl"]?.removingPercentEncoding, let imgArrStr = imageParams["imgArr"]?.removingPercentEncoding {
                let imgArr = JSON(parseJSON: imgArrStr).arrayObject as! [String]
                if let imageBrowser = SSPhotoBrowser(photoURLs: imgArr) {
                    imageBrowser.delegate = self
                    imageBrowser.displayToolbar = false
                    imageBrowser.displayDoneButton = false
                    imageBrowser.dismissOnTouch = true
                    imageBrowser.displayActionButton = false
                    imageBrowser.forceHideStatusBar = true
                    imageBrowser.longPressedAction = {
                        image in
                        guard let aImage = image else { return }
                        let params = [
                            "title": "",
                            "description": "",
                            "coverUrl": imgUrl
                        ]
                        XDShareView.shared.showSharePanel(shareURL: imgUrl, shareInfo: params, coverImage: aImage)
                        
                    }
                    for (index, str) in imgArr.enumerated() {
                        if imgUrl == str {
                            imageBrowser.currentPageIndex = UInt(index)
                            break
                        }
                    }
                    present(imageBrowser, animated: true, completion: nil)
                }
            }
        }
    }
}
