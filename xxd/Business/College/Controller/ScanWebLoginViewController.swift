//
//  ScanWebLoginViewController.swift
//  xxd
//
//  Created by remy on 2018/5/9.
//  Copyright © 2018年 com.smartstudy. All rights reserved.
//

class ScanWebLoginViewController: SSViewController {
    
    var token: String = ""
    private lazy var loginView: UIView = {
        let view = UIView(frame: XDSize.visibleRect)
        addLoginView(view)
        self.view.addSubview(view)
        return view
    }()
    private lazy var loginErrorView: UIView = {
        let view = UIView(frame: XDSize.visibleRect)
        addLoginErrorView(view)
        self.view.addSubview(view)
        return view
    }()
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        navigationBar.backgroundColor = XDColor.itemTitle
        navigationBar.leftItem.image = UIImage(named: "top_left_arrow_white")
        navigationBar.centerTitle = "登录选校帝网页版"
        navigationBar.centerItem.textColor = .white
        navigationBar.bottomLine.isHidden = true
        
        loginView.isHidden = false
    }
    
    func addLoginView(_ view: UIView) {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "computer")
        view.addSubview(imageView)
        imageView.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-145)
        }
        
        let desc = UILabel(text: "选校帝网页版登录确认", textColor: XDColor.itemTitle, fontSize: 17)!
        view.addSubview(desc)
        desc.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.top.equalTo(imageView.snp.bottom).offset(32)
        }
        
        let loginBtn = UIButton(frame: .zero, title: "确认登录", fontSize: 16, titleColor: .white, target: self, action: #selector(confirmLoginTap))!
        loginBtn.backgroundColor = XDColor.main
        loginBtn.layer.cornerRadius = 6
        view.addSubview(loginBtn)
        loginBtn.snp.makeConstraints { (make) in
            make.height.equalTo(40)
            make.left.equalToSuperview().offset(32)
            make.right.equalToSuperview().offset(-32)
            make.bottom.equalToSuperview().offset(-102)
        }
        
        let cancelBtn = UIButton(frame: .zero, title: "取消", fontSize: 16, titleColor: XDColor.itemText, target: self, action: #selector(cancelTap))!
        view.addSubview(cancelBtn)
        cancelBtn.snp.makeConstraints { (make) in
            make.size.equalTo(CGSize(width: 50, height: 30))
            make.centerX.equalToSuperview()
            make.top.equalTo(loginBtn.snp.bottom).offset(20)
        }
    }
    
    func addLoginErrorView(_ view: UIView) {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "wrong")
        view.addSubview(imageView)
        imageView.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-145)
        }
        
        let desc = UILabel(text: "登录失败，请重新扫码登录", textColor: XDColor.itemTitle, fontSize: 17)!
        view.addSubview(desc)
        desc.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.top.equalTo(imageView.snp.bottom).offset(32)
        }
        
        let scanBtn = UIButton(frame: .zero, title: "重新扫码", fontSize: 16, titleColor: .white, target: self, action: #selector(scanTap))!
        scanBtn.backgroundColor = UIColor(0xFF4046)
        scanBtn.layer.cornerRadius = 6
        view.addSubview(scanBtn)
        scanBtn.snp.makeConstraints { (make) in
            make.height.equalTo(40)
            make.left.equalToSuperview().offset(32)
            make.right.equalToSuperview().offset(-32)
            make.bottom.equalToSuperview().offset(-102)
        }
        
        let cancelBtn = UIButton(frame: .zero, title: "取消", fontSize: 16, titleColor: XDColor.itemText, target: self, action: #selector(cancelTap))!
        view.addSubview(cancelBtn)
        cancelBtn.snp.makeConstraints { (make) in
            make.size.equalTo(CGSize(width: 50, height: 30))
            make.centerX.equalToSuperview()
            make.top.equalTo(scanBtn.snp.bottom).offset(20)
        }
    }
    
    //MARK:- Action
    @objc func confirmLoginTap(_ sender: UIButton) {
        XDPopView.loading()
        SSNetworkManager.shared().post(XD_API_QRCODE_CONFIRM_LOGIN, parameters: ["token": token], success: {
            [weak self] (_, response) in
            guard let sSelf = self else { return }
            let res = ((response as! [String : Any])["code"] as? Int) == 0
            if res {
                sSelf.cancelTap(sender)
            } else {
                sSelf.loginView.isHidden = true
                sSelf.loginErrorView.isHidden = false
            }
            XDPopView.hide()
        }, failure: {
            [weak self] (_, error) in
            guard let sSelf = self else { return }
            sSelf.loginView.isHidden = true
            sSelf.loginErrorView.isHidden = false
            XDPopView.hide()
        })
    }
    
    @objc func scanTap(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    @objc func cancelTap(_ sender: UIButton) {
        navigationController?.popToRootViewController(animated: true)
    }
}
