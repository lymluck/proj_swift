//
//  IndexTopSectionView.swift
//  xxd
//
//  Created by remy on 2018/5/9.
//  Copyright © 2018年 com.smartstudy. All rights reserved.
//

class IndexTopSectionView: UIView {
    
    var searchBtn: UIButton!
    var scanBtn: UIButton!
    var messageBtn: UIButton!
    var darkStyle: Bool? {
        didSet {
            guard darkStyle != oldValue, let darkStyle = darkStyle else { return }
            if darkStyle {
                scanBtn.setImage(UIImage(named: "scan_blue"), for: .normal)
                messageBtn.setImage(UIImage(named: "message_blue"), for: .normal)
            } else {
                scanBtn.setImage(UIImage(named: "scan_white"), for: .normal)
                messageBtn.setImage(UIImage(named: "message_white"), for: .normal)
            }
        }
    }
    /// 我的未读消息
    private lazy var badgeMessage: UIView = {
        let view = UIView(frame: .zero, color: UIColor(0xF6511D))
        view.layer.cornerRadius = 4
        messageBtn.addSubview(view)
        view.snp.makeConstraints({ (make) in
            make.top.equalToSuperview().offset(2)
            make.right.equalToSuperview().offset(-7)
            make.size.equalTo(CGSize(width: 8, height: 8))
        })
        return view
    }()

    init() {
        let topSpace: CGFloat = UIDevice.isIPhoneX ? 45 : 26
        super.init(frame: CGRect(x: 0, y: topSpace, width: XDSize.screenWidth, height: 30))
        
        // 搜索
        searchBtn = UIButton(frame: CGRect(x: 40, y: 0, width: XDSize.screenWidth - 80, height: height), title: "search".localized, fontSize: 14, titleColor: XDColor.itemText, target: self, action: #selector(topSearchTap(_:)))!
        searchBtn.backgroundColor = UIDevice.isIPhoneX ? XDColor.itemLine : UIColor(0xFFFFFF, 0.95)
        searchBtn.layer.cornerRadius = 15
        searchBtn.layer.masksToBounds = true
        searchBtn.titleEdgeInsets = UIEdgeInsetsMake(0, 15, 0, 0)
        searchBtn.setImage(UIImage(named: "text_field_search"), for: .normal)
        addSubview(searchBtn)
        
        // 扫描
        scanBtn = UIButton(frame: CGRect(x: 0, y: 0, width: 40, height: height), title: "", fontSize: 0, titleColor: .clear, target: self, action: #selector(scanTap(_:)))!
        addSubview(scanBtn)
        
        // 消息
        messageBtn = UIButton(frame: CGRect(x: XDSize.screenWidth - 40, y: 0, width: 40, height: height), title: "", fontSize: 0, titleColor: .clear, target: self, action: #selector(messageTap(_:)))!
        addSubview(messageBtn)
        
        defer {
            darkStyle = UIDevice.isIPhoneX
        }
        
        // 更新我的消息未读状态
        updateMessageBadge()
        NotificationCenter.default.addObserver(self, selector: #selector(updateMessageBadge), name: .XD_NOTIFY_UPDATE_UNREAD_MESSAGE, object: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK:- Notification
    @objc func updateMessageBadge() {
        badgeMessage.isHidden = !XDUser.shared.hasUnreadMessage()
    }
    
    //MARK:- Action
    @objc func topSearchTap(_ sender: UIButton) {
        XDStatistics.click("8_A_search_btn")
        let vc = IndexSearchController()
        UIApplication.topVC()?.tabBarController?.presentModalTranslucentViewController(vc, animated: false, completion: nil)
    }
    
    @objc func scanTap(_ sender: UIButton) {
        let authStatus: AVAuthorizationStatus = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
        if authStatus == .authorized {
            let vc = ScanViewController()
            XDRoute.pushToVC(vc)
        } else if authStatus == .notDetermined {
            AVCaptureDevice.requestAccess(for: AVMediaType.video) { (isGranted: Bool) in
                if isGranted {
                    DispatchQueue.main.async {
                        let vc = ScanViewController()
                        XDRoute.pushToVC(vc)
                    }
                }
            }
        } else {
            let alertController:UIAlertController = UIAlertController(title: "是否允许访问您的相机", message: nil, preferredStyle: UIAlertControllerStyle.alert)
            let okAction:UIAlertAction = UIAlertAction(title: "设置", style: UIAlertActionStyle.destructive,handler: { (action:UIAlertAction) in
                if let settingURL = URL(string: UIApplicationOpenSettingsURLString)
                {
                    if #available(iOS 10.0, *) {
                        UIApplication.shared.open(settingURL, options: [:], completionHandler: nil)
                    } else {
                        UIApplication.shared.openURL(settingURL)
                    }
                }
            })
            let cancelAction:UIAlertAction = UIAlertAction(title: "取消", style: UIAlertActionStyle.cancel, handler: nil)
            alertController.addAction(okAction)
            alertController.addAction(cancelAction)
            UIApplication.shared.topViewController()?.present(alertController, animated: true, completion: nil)
        }
    }
    
    @objc func messageTap(_ sender: UIButton) {
        if XDUser.shared.hasLogin() {
            let vc = MessageCenterViewController()
            XDRoute.pushToVC(vc)
        } else {
            let vc = SignInViewController()
            XDRoute.presentToVC(vc)
        }
    }
}
