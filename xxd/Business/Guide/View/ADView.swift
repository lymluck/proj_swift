 //
//  ADView.swift
//  xxd
//
//  Created by Lisen on 2018/8/15.
//  Copyright © 2018 com.smartstudy. All rights reserved.
//

import UIKit
import Kingfisher

 @objc protocol ADViewDelegate {
    func adViewDidTap(_ adView: ADView, _ query: [String: String])
 }
 
/// 广告展示视图
class ADView: UIView {
    
    weak var delegate: ADViewDelegate?
    private var countDown: Int = 3
    private var model: ADModel!
    private var timer: Timer?
    private lazy var adImageView: UIImageView = UIImageView()
    private lazy var adLabel: UILabel = {
        let label: UILabel = UILabel(frame: .zero, text: "广告", textColor: UIColor.white, fontSize: 10)
        label.textAlignment = .center
        label.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        return label
    }()
    private lazy var countDownBtn: UIButton = {
        let button: UIButton = UIButton(frame: CGRect.zero, title: "", fontSize: 15.0, bold: false, titleColor: UIColor.white, backgroundColor: UIColor(white: 0.0, alpha: 0.25), target: self, action: #selector(eventJumpAdResponse))
        button.titleLabel?.textAlignment = .center
        button.layer.cornerRadius = 13.0
        button.layer.masksToBounds = true
        return button
    }()
    
    private lazy var logoImageView: UIImageView = UIImageView(frame: .zero, imageName: "launch_ad_logo")
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initContentViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    private func initContentViews() {
        backgroundColor = .white
        guard let info = Preference.LAUNCH_AD_INFO.get() else {
            eventJumpAdResponse()
            return
        }
        model = ADModel.yy_model(with: info)
        let day = "\(NSDate().day)"
        Preference.LAUNCH_AD_DATE.set(day)
        guard let image = KingfisherManager.shared.cache.retrieveImageInDiskCache(forKey: model.imageURL) else {
            eventJumpAdResponse()
            return
        }
        adImageView = UIImageView(image: image)
        let adImageHeight = (bounds.width * adImageView.height / adImageView.width).rounded()
        adImageView.frame = CGRect(x: 0.0, y: 0.0, width: bounds.width, height: adImageHeight)
        adImageView.isUserInteractionEnabled = true
        addSubview(adImageView)
        adImageView.addSubview(adLabel)
        adLabel.snp.makeConstraints({ (make) in
            make.right.bottom.equalTo(self.adImageView)
            make.size.equalTo(CGSize(width: 31, height: 16))
        })
        adImageView.addSubview(countDownBtn)
        countDownBtn.snp.makeConstraints { (make) in
            make.top.equalTo(adImageView).offset(24)
            make.right.equalTo(adImageView).offset(-16)
            make.size.equalTo(CGSize(width: 67, height: 26))
        }
        let bottomView = UIView(frame: CGRect(x: 0, y: adImageHeight, width: bounds.width, height: bounds.height - adImageHeight), color: UIColor.white)
        addSubview(bottomView)
        bottomView.addSubview(logoImageView)
        timer = Timer.scheduledTimer(timeInterval: 1.5, target: self, selector: #selector(eventTimerClick), userInfo: nil, repeats: true)
        timer?.fire()
    }
    
    //FIXME: 由于给adImageView对象添加了点击事件后没有反应, 转而在这里实现相关的点击事件处理
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        if let touchView = touches.first?.view {
            if touchView.isDescendant(of: adImageView) {
                removeTimer()
                guard let _ = delegate?.adViewDidTap(self, [QueryKey.URLPath:model.adURL,QueryKey.TitleName:model.name]) else { return }
            }
        }
    }
    
    @objc private func eventTimerClick() {
        countDownBtn.setTitle("跳过 \(countDown)", for: .normal)
        countDown -= 1
        if countDown < 0 {
            eventJumpAdResponse()
        }
    }
    
    private func removeTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    /// 检查广告数据是否有更新
    static func checkADState() {
        SSNetworkManager.shared().get(XD_API_LAUNCH_AD, parameters: nil, success: { (task, responseObject) in
            if let serverData = responseObject as? [String: Any], let data = serverData["data"] as? [String : Any] {
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
    
    /// 下载广告图片
    static func downADImages(urlStr: String) {
        if let url = URL(string: urlStr) {
            KingfisherManager.shared.downloader.downloadImage(with: url, completionHandler: { (image, error, url, data) in
                if let image = image {
                    KingfisherManager.shared.cache.store(image, forKey: urlStr)
                }
            })
        }
    }
    
    ///
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
            (UIApplication.shared.delegate as? AppDelegate)?.isAdShowed = true
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
    
    /// 跳过按钮点击事件
    @objc private func eventJumpAdResponse() {
        removeTimer()
        UIView.animate(withDuration: 0.3, animations: {
            self.transform = CGAffineTransform(scaleX: 3.0, y: 3.0)
            self.alpha = 0.0
        }, completion: { _ in
            self.removeFromSuperview()
        })
    }
}
