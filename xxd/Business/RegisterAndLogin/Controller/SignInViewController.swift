//
//  SignInViewController.swift
//  xxd
//
//  Created by remy on 2018/1/10.
//  Copyright © 2018年 com.smartstudy. All rights reserved.
//

private let RESEND_TIME = 30
private let SOURCE_FROM_APP = "app"
private let SOURCE_ACTION_REGISTER = "ios用户注册"

class SignInViewController: SSViewController, XDTextFieldViewDelegate {
    
    var isNeedSwitch: Bool = false
    private let scrollView = XDScrollView(frame: CGRect(x: 0, y: XDSize.topHeight, width: XDSize.screenWidth, height: XDSize.visibleHeight))
    private lazy var adView: ADView = {
        let view: ADView = ADView(frame: UIScreen.main.bounds)
        view.delegate = self
        return view
    }()
    private var phoneView: XDTextFieldView!
    private var captchaView: XDTextFieldView!
    private var captchaBtn: UIButton!
    private var captchaTimer: Timer?
    private var countDown = 0
    var dismissedHandler: ((Bool) -> Void)?
    static var canCancel = true
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        removeTimer()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if !isNeedSwitch {
            phoneView.focus()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        XDStatistics.click("1_B_login")
        XDStatistics.scTrack("login_popup")
        view.backgroundColor = UIColor.white
        navigationBar.backgroundColor = UIColor.clear
        navigationBar.leftItem.image = nil
        navigationBar.leftItem.text = nil
        navigationBar.bottomLine.isHidden = true
        if SignInViewController.canCancel {
            navigationBar.rightItem.image = UIImage(named: "close")
        }
        isCustomKeyboard = true
        
        scrollView.alwaysBounceVertical = false
        view.addSubview(scrollView)
        
        let logo = UIImageView(frame: CGRect(x: (XDSize.screenWidth - 76) / 2, y: 21, width: 76, height: 76), imageName: "app_logo")!
        logo.layer.shadowOpacity = 0.3
        logo.layer.shadowColor = XDColor.main.cgColor
        logo.layer.shadowRadius = 5
        logo.layer.shadowOffset = CGSize(width: 0, height: 2)
        scrollView.addSubview(logo)
        
        phoneView = XDTextFieldView(frame: CGRect(x: 20, y: logo.bottom + 57, width: XDSize.screenWidth - 40, height: 42))
        phoneView.textColor = XDColor.itemTitle
        phoneView.fontSize = 18
        phoneView.placeholderSize = 16
        phoneView.placeholder = "input_phone".localized
        phoneView.lineType = .bottom
        phoneView.keyboardType = .numberPad
        phoneView.delegate = self
        scrollView.addSubview(phoneView)
        
        captchaView = XDTextFieldView(frame: CGRect(x: 20, y: phoneView.bottom + 11, width: XDSize.screenWidth - 40, height: 42))
        captchaView.textColor = XDColor.itemTitle
        captchaView.fontSize = 18
        captchaView.placeholderSize = 16
        captchaView.rightContentInsets = 130
        captchaView.placeholder = "input_captcha".localized
        captchaView.lineType = .bottom
        captchaView.keyboardType = .numberPad
        captchaView.delegate = self
        scrollView.addSubview(captchaView)
        
        captchaBtn = UIButton(frame: CGRect(x: captchaView.width - captchaView.rightContentInsets, y: 0, width: captchaView.rightContentInsets - 8, height: captchaView.height), title: "get_captcha".localized, fontSize: 15, titleColor: XDColor.main, target: self, action: #selector(getCaptcha(sender:)))
        captchaBtn.titleEdgeInsets = UIEdgeInsetsMake(-4, 0, 0, 0)
        captchaBtn.contentHorizontalAlignment = .right
        captchaView.addSubview(captchaBtn)
        
        let btn = UIButton(frame: CGRect(x: 20, y: captchaView.bottom + 40, width: XDSize.screenWidth - 40, height: 42), title: "sign_in".localized, fontSize: 15, titleColor: UIColor.white, target: self, action: #selector(signInTap(sender:)))!
        btn.backgroundColor = XDColor.main
        btn.layer.cornerRadius = 6
        scrollView.addSubview(btn)
        
        let label1 = UILabel(frame: CGRect(x: 0, y: scrollView.height - 77, width: XDSize.screenWidth / 2, height: 17), text: "sign_in_agreement".localized, textColor: UIColor(0x58646E), fontSize: 12)!
        label1.textAlignment = .right
        scrollView.addSubview(label1)
        
        let attr = NSAttributedString(string: "app_agreement".localized)
        let label2 = UILabel(frame: CGRect(x: XDSize.screenWidth / 2, y: scrollView.height - 77, width: XDSize.screenWidth / 2, height: 17), text: "", textColor: XDColor.main, fontSize: 12)!
        label2.attributedText = attr.underline
        label2.isUserInteractionEnabled = true
        label2.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(gotoAgreement)))
        scrollView.addSubview(label2)
        if isNeedSwitch {
            if UserGuideView.isShow() {
                let guideView: UserGuideView = UserGuideView(frame: UIScreen.main.bounds)
                view.addSubview(guideView)
            } else if ADViewController.isShow() {
                (UIApplication.shared.delegate as? AppDelegate)?.isAdShowed = true
                view.addSubview(adView)
            }
        }
    }
    
    func removeTimer() {
        captchaTimer?.invalidate()
        captchaTimer = nil
    }
    
    func signInSuccess(dict: [AnyHashable: Any]) {
        removeTimer()
        XDPopView.hide()
        phoneView.blur()
        captchaView.blur()
        var isCreated = dict["created"] as! Bool
        #if TEST_MODE
            let completionSwitchOn = UserDefaults.standard.bool(forKey: "kUnlimitedCompletionKey")
            if completionSwitchOn {
                isCreated = true
            }
        #endif
        Preference.IS_CREATED.set(isCreated)
        if isCreated {
            // 注册成功
//            XDStatistics.scTrack("sign_up", data: ["register_way": "手机号注册"])
            let vc = CompletionViewController()
            XDRoute.pushToVC(vc)
        } else {
            // 登录成功
            XDStatistics.scTrack("login_success", data: ["login_way": "验证码登录"])
            XDPopView.toast("sign_in_success".localized, UIApplication.shared.keyWindow)
            cancelActionTap()
        }
    }
    
    //MARK:- Action
    @objc func getCaptcha(sender: UIButton) {
        XDStatistics.click("1_A_verification_code_btn")
        let phone = phoneView.text.trimmingCharacters(in: .whitespaces)
        guard !phone.isEmpty else {
            return XDPopView.toast("phone_empty".localized)
        }
        if (phone as NSString).isValidMobileNumber() {
            captchaBtn.isEnabled = false
            SSNetworkManager.shared().post(XD_API_GET_CAPTCHA, parameters: ["phone":phone], success: { [weak self] (task, responseObject) in
                if let strongSelf = self {
                    strongSelf.countDown = RESEND_TIME
                    let timer = Timer.scheduledTimer(timeInterval: 1, target: strongSelf, selector: #selector(strongSelf.refreshResend), userInfo: nil, repeats: true)
                    timer.fire()
                    strongSelf.captchaTimer = timer
                }
                }, failure: { [weak self] (task, error) in
                    self?.captchaBtn.isEnabled = true
                    XDPopView.toast(error.localizedDescription)
            })
        } else {
            return XDPopView.toast("phone_invalid".localized)
        }
    }
    
    @objc func signInTap(sender: UIButton) {
        XDStatistics.click("1_A_login_btn")
        let phone = phoneView.text.trimmingCharacters(in: .whitespaces) as NSString
        let captcha = captchaView.text.trimmingCharacters(in: .whitespaces) as NSString
        guard phone.isNotEmpty else {
            return XDPopView.toast("phone_empty".localized)
        }
        guard captcha.isNotEmpty else {
            return XDPopView.toast("captcha_empty".localized)
        }
        if (phone as NSString).isValidMobileNumber() {
            let name = phone.length > 6 ? phone.replacingCharacters(in: NSMakeRange(3, 4), with: "****") : ""
            XDPopView.loading()
            let params: [String: Any] = [
                "phone":phone,
                "name":name,
                "captcha":captcha,
                "from":SOURCE_FROM_APP,
                "sourceAction":SOURCE_ACTION_REGISTER,
                "infoVersion":"v2"
            ]
            SSNetworkManager.shared().post(XD_API_USER_REGISTER, parameters: params, success: { [weak self] (task, responseObject) in
                let dict = responseObject as? [String : Any]
                if let data = dict?["data"] as? [String : Any] {
                    XDUser.shared.setUserInfo(userInfo: data)
                    if XDUser.shared.model.token != SSOpenID.id() {
                        SSOpenID.setID(XDUser.shared.model.token)
                    }
                    // 登录通知
                    NotificationCenter.default.post(name: .XD_NOTIFY_SIGN_IN, object: nil)
                    self?.signInSuccess(dict: data)
                    // 连接IM服务器
//                    XDUser.shared.connectIMServer()
                }
                }, failure: { (task, error) in
                    XDPopView.toast(error.localizedDescription)
            })
        } else {
            return XDPopView.toast("phone_invalid".localized)
        }
    }
    
    override func rightActionTap() {
        phoneView.blur()
        captchaView.blur()
        cancelActionTap()
    }
    
    override func cancelActionTap() {
        if isNeedSwitch {
            let animation: CATransition = CATransition()
            animation.duration = 0.25
            animation.type = kCATransitionReveal
            animation.subtype = kCATransitionFromBottom
            UIApplication.shared.keyWindow?.rootViewController = TabBarViewController()
            UIApplication.shared.keyWindow?.layer.add(animation, forKey: "transition")            
        } else {
            dismiss(animated: true) { [weak self] in
                if let strongSelf = self {
                    strongSelf.dismissedHandler?(XDUser.shared.hasLogin())
                }
            }
        }
    }
    
    @objc func refreshResend() {
        countDown -= 1
        if countDown > 0 {
            captchaBtn.setTitle(String(format: "countdown_captcha".localized, countDown), for: .normal)
            captchaBtn.setTitleColor(XDColor.mainLine, for: .normal)
        } else {
            captchaBtn.setTitle("resend_captcha".localized, for: .normal)
            captchaBtn.setTitleColor(XDColor.main, for: .normal)
            captchaBtn.isEnabled = true
            removeTimer()
        }
    }
    
    @objc func gotoAgreement() {
        XDRoute.pushWebVC([QueryKey.URLPath:XD_WEB_AGREEMENT,QueryKey.TitleName:"app_agreement".localized])
    }
    
    //MARK:- XDTextFieldViewDelegate
    func textFieldOnFocus(textField: XDTextFieldView) {
        scrollView.scrollToViewOnFocus(view: textField)
    }
}

// MARK: ADViewDelegate
extension SignInViewController: ADViewDelegate {
    func adViewDidTap(_ adView: ADView, _ query: [String: String]) {
        let webVC: WKWebViewController = WKWebViewController(query: query)
        navigationController?.pushViewController(webVC, animated: true)
        adView.removeFromSuperview()
    }
}


// MARK: UINavigationControllerDelegate
extension SignInViewController: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        
    }
}
