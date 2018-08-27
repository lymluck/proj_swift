//
//  ADViewController.swift
//  xxd
//
//  Created by remy on 2018/1/15.
//  Copyright © 2018年 com.smartstudy. All rights reserved.
//

import Kingfisher

class ADViewController: SSViewController {
    
    var isADBack = false
    var model: ADModel!
    var timer: Timer?
    var timerView: UILabel!
    var countDown = 3
    
    override func needNavigationBar() -> Bool {
        return false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        isADBack = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if isADBack {
            jumpTap()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let info = Preference.LAUNCH_AD_INFO.get() else {
            return jumpTap()
        }
        model = ADModel.yy_model(with: info)
        
        let day = "\(NSDate().day)"
        Preference.LAUNCH_AD_DATE.set(day)
        
        guard let image = KingfisherManager.shared.cache.retrieveImageInDiskCache(forKey: model.imageURL) else {
            // 屏蔽由于第一次打开切换环境导致第二次打开crash
            return jumpTap()
        }
        let imageView = UIImageView(image: image)
        let height = (view.width * imageView.height / imageView.width).rounded()
        imageView.frame = CGRect(x: 0, y: 0, width: view.width, height: height)
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(adTap)))
        view.addSubview(imageView)
        
        let adLabel = UILabel(frame: .zero, text: "广告", textColor: UIColor.white, fontSize: 10)!
        adLabel.textAlignment = .center
        adLabel.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        imageView.addSubview(adLabel)
        adLabel.snp.makeConstraints({ (make) in
            make.right.bottom.equalTo(imageView)
            make.size.equalTo(CGSize(width: 31, height: 16))
        })
        
        timerView = UILabel(frame: .zero, text: "", textColor: UIColor.white, fontSize: 15)!
        timerView.textAlignment = .center
        timerView.backgroundColor = UIColor.black.withAlphaComponent(0.25)
        timerView.layer.cornerRadius = 13
        timerView.layer.masksToBounds = true
        timerView.isUserInteractionEnabled = true
        timerView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(jumpTap)))
        imageView.addSubview(timerView)
        timerView.snp.makeConstraints({ (make) in
            make.top.equalTo(imageView).offset(24)
            make.right.equalTo(imageView).offset(-16)
            make.size.equalTo(CGSize(width: 67, height: 26))
        })
        
        let bottomView = UIView(frame: CGRect(x: 0, y: height, width: view.width, height: view.height - height), color: UIColor.white)
        view.addSubview(bottomView)
        
        let logoView = UIImageView(frame: .zero, imageName: "launch_ad_logo")!
        bottomView.addSubview(logoView)
        logoView.snp.makeConstraints({ (make) in
            make.center.equalTo(bottomView)
        })
        
        timer = Timer.scheduledTimer(timeInterval: 1.5, target: self, selector: #selector(refreshTimer), userInfo: nil, repeats: true)
        timer?.fire()
    }
    
    @objc func refreshTimer() {
        timerView.text = "跳过 \(countDown)"
        countDown -= 1
        if countDown < 0 {
            jumpTap()
        }
    }
    
    func removeTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    static func checkADState() {
        SSNetworkManager.shared().get(XD_API_LAUNCH_AD, parameters: nil, success: { (task, responseObject) in
            let dict = responseObject as? [String : Any]
            if let data = dict?["data"] as? [String : Any] {
                if let id = data["id"] as? Int {
                    let info = Preference.LAUNCH_AD_INFO.get()
                    if !checkImageExist() || info == nil || id != (info!["id"] as! Int) {
                        Preference.LAUNCH_AD_INFO.set(data)
                        downADImages(urlStr: data["imgUrl"] as! String)
                    }
                } else {
                    // 广告到期无数据
                    Preference.LAUNCH_AD_INFO.set([:])
                }
            }
        }) { (task, error) in
        }
    }
    
    static func downADImages(urlStr: String) {
        if let url = URL(string: urlStr) {
            KingfisherManager.shared.downloader.downloadImage(with: url, completionHandler: { (image, error, url, data) in
                if let image = image {
                    KingfisherManager.shared.cache.store(image, forKey: urlStr)
                }
            })
        }
    }
    
    static func checkImageExist() -> Bool {
        var isExist = false
        if let info = Preference.LAUNCH_AD_INFO.get(), let url = info["imgUrl"] as? String {
            isExist = KingfisherManager.shared.cache.imageCachedType(forKey: url) == .disk
        }
        return isExist
    }
    
    static func isShow() -> Bool {
        let lastDay = Preference.LAUNCH_AD_DATE.get()
        let nowDay = "\(NSDate().day)"
        var isShowAD = lastDay != nowDay
        if isShowAD {
            isShowAD = checkImageExist()
        }
        #if TEST_MODE
            var switchOn = UserDefaults.standard.bool(forKey: "kUnlimitedAD")
            if switchOn {
                switchOn = checkImageExist()
                return switchOn
            }
        #endif
        return isShowAD
    }
    
    //MARK:- Action
    @objc func adTap() {
        removeTimer()
        XDRoute.pushWebVC([QueryKey.URLPath:model.adURL,QueryKey.TitleName:model.name])
    }
    
    @objc func jumpTap() {
        removeTimer()
        if XDUser.shared.hasLogin() {
            dismiss(animated: false, completion: nil)
        } else {
            let vc = SignInViewController()
            navigationController?.pushViewController(vc, animated: true)
        }
    }
}
