//
//  HighschoolTabbarView.swift
//  xxd
//
//  Created by remy on 2018/4/4.
//  Copyright © 2018年 com.smartstudy. All rights reserved.
//

private let kBtnWidth: CGFloat = 80

class HighschoolTabbarView: UIView {
    
    private var favoriteBtn: UIView!
    var model: HighschoolDetailModel! {
        didSet {
            targetStatus(model.isCollected)
        }
    }
    
    convenience init() {
        self.init(frame: CGRect(x: 0, y: XDSize.screenHeight - XDSize.tabbarHeight, width: XDSize.screenWidth, height: XDSize.tabbarHeight))
        backgroundColor = UIColor.white
        
        addSubview(UIView(frame: CGRect(x: 0, y: 0, width: XDSize.screenWidth, height: XDSize.unitWidth), color: UIColor(0xDDDDDD)))
        
        let consultWidth = XDSize.screenWidth * 0.618
        let favoriteWidth = XDSize.screenWidth - consultWidth
        
        // 收藏
        favoriteBtn = itemBtn("收藏", "favorite")
        favoriteBtn.left = (favoriteWidth - kBtnWidth) * 0.5
        favoriteBtn.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(favoriteTap)))
        
        // 咨询
        let consultBtn = UIView(frame: CGRect(x: 0, y: 0, width: consultWidth, height: 49))
        consultBtn.right = XDSize.screenWidth
        consultBtn.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(gotoChat)))
        addSubview(consultBtn)
        
        let layer = CAGradientLayer()
        layer.frame = consultBtn.bounds
        layer.startPoint = CGPoint(x: 0, y: 0.5)
        layer.endPoint = CGPoint(x: 1, y: 0.5)
        layer.colors = [UIColor(0x23B3FF).cgColor, UIColor(0x0C83FA).cgColor]
        consultBtn.layer.addSublayer(layer)
        
        let consultLabel = UILabel(text: "咨询该学校", textColor: UIColor.white, fontSize: 17)!
        consultBtn.addSubview(consultLabel)
        consultLabel.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.centerX.equalToSuperview().offset(-6)
        }
        
        let triangle = UIImageView(frame: .zero, imageName: "triangle")!
        consultBtn.addSubview(triangle)
        triangle.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.left.equalTo(consultLabel.snp.right).offset(6)
        }
    }
    
    private func itemBtn(_ text: String, _ imageName: String) -> UIView {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: kBtnWidth, height: XDSize.tabbarHeight))
        addSubview(view)
        let imageView = UIImageView(frame: CGRect(x: 28, y: 6, width: 24, height: 24), imageName: imageName)!
        imageView.tag = 100
        imageView.contentMode = .center
        view.addSubview(imageView)
        let label = UILabel(frame: CGRect(x: 0, y: 31, width: 80, height: 14), text: text, textColor: XDColor.main, fontSize: 10)!
        label.tag = 200
        label.textAlignment = .center
        view.addSubview(label)
        return view
    }
    
    private func targetStatus(_ isAdd: Bool) {
        if let imageView = favoriteBtn.viewWithTag(100) as? UIImageView {
            if isAdd {
                imageView.image = UIImage(named: "my_favorite")
            } else {
                imageView.image = UIImage(named: "favorite")
            }
        }
    }
    
    //MARK:- Action
    @objc func favoriteTap() {
        if XDUser.shared.hasLogin() {
            XDPopView.loading()
            let urlStr = String(format: XD_API_ADD_FAVORITE, "highschool", "\(model.highschoolID)")
            if model.isCollected {
                SSNetworkManager.shared().delete(urlStr, parameters: nil, success: {
                    [weak self] (task, responseObject) in
                    if let strongSelf = self {
                        strongSelf.model.isCollected = false
                        strongSelf.targetStatus(false)
                    }
                    XDPopView.toast("取消收藏")
                }) { (task, error) in
                    XDPopView.toast(error.localizedDescription)
                }
            } else {
                SSNetworkManager.shared().post(urlStr, parameters: nil, success: {
                    [weak self] (task, responseObject) in
                    if let strongSelf = self {
                        strongSelf.model.isCollected = true
                        strongSelf.targetStatus(true)
                    }
                    XDPopView.toast("收藏成功")
                }) { (task, error) in
                    XDPopView.toast(error.localizedDescription)
                }
            }
        } else {
            let vc = SignInViewController()
            XDRoute.presentToVC(vc)
        }
    }
    
    @objc func gotoChat() {
        XDRoute.pushMQChatVC()
    }
}
