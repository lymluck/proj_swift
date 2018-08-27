//
//  CollegeDetailTabBarView.swift
//  xxd
//
//  Created by remy on 2018/3/2.
//  Copyright © 2018年 com.smartstudy. All rights reserved.
//

private let kBtnWidth: CGFloat = 80
private let kConsultBtnWidth: CGFloat = 95

class CollegeDetailTabBarView: UIView, CollegeTypeSelectorViewDelegate {
    
    private var targetBtn: UIView!
    var model: CollegeDetailIntroModel! {
        didSet {
            targetStatus(model.selected)
        }
    }
    
    convenience init() {
        self.init(frame: CGRect(x: 0, y: XDSize.screenHeight - XDSize.tabbarHeight, width: XDSize.screenWidth, height: XDSize.tabbarHeight))
        backgroundColor = UIColor.white
        
        addSubview(UIView(frame: CGRect(x: 0, y: 0, width: XDSize.screenWidth, height: XDSize.unitWidth), color: UIColor(0xDDDDDD)))
        
        let space: CGFloat = ((XDSize.screenWidth - kBtnWidth * 3 - kConsultBtnWidth) / 6).rounded()
        
        let shareBtn = itemBtn("share".localized, "smart_college_share")
        shareBtn.left = space
        shareBtn.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(shareResult)))
        
        targetBtn = itemBtn("加入选校", "smart_college_add")
        targetBtn.left = shareBtn.right + space * 2
        targetBtn.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(autoAddTarget)))
        
        let testBtn = itemBtn("title_admission_test".localized, "school_detail_bottom_bar_test_icon")
        testBtn.left = targetBtn.right + space * 2
        testBtn.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(admissionTest)))
        
        let consultBtn = UIView(frame: CGRect(x: 0, y: 0, width: kConsultBtnWidth, height: 49))
        consultBtn.right = XDSize.screenWidth
        consultBtn.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(gotoChat)))
        addSubview(consultBtn)
        
        let layer = CAGradientLayer()
        layer.frame = consultBtn.bounds
        layer.startPoint = CGPoint(x: 0, y: 0)
        layer.endPoint = CGPoint(x: 1, y: 1)
        layer.colors = [UIColor(0x23B3FF).cgColor, UIColor(0x0C83FA).cgColor]
        consultBtn.layer.addSublayer(layer)
        
        let consultLabel = UILabel(text: "online_consult".localized, textColor: UIColor.white, fontSize: 14)!
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
        let imageView = targetBtn.viewWithTag(100) as! UIImageView
        let label = targetBtn.viewWithTag(200) as! UILabel
        if isAdd {
            imageView.image = UIImage(named: "school_detail_bottom_bar_added_icon")
            label.text = "已加入"
        } else {
            imageView.image = UIImage(named: "smart_college_add")
            label.text = "加入选校"
        }
    }
    
    private func showCollegeTypeView() {
        let view = CollegeTypeSelectorView()
        view.delegate = self
        XDPopView.topView(view: view, isMaskHide: true, alpha: 0.4)
    }
    
    private func hideCollegeTypeView() {
        XDPopView.hideTopView()
    }
    
    //MARK:- CollegeTypeSelectorViewDelegate
    func collegeTypeDidSelected(typeId: String) {
        hideCollegeTypeView()
        let list = [["schoolId":model.collegeID,"matchTypeId":typeId]]
        let params = [
            "data": (list as NSArray).yy_modelToJSONString(),
            "source": "auto-match"
        ]
        XDPopView.loading()
        SSNetworkManager.shared().post(XD_API_MY_COLLEGE_EDIT, parameters: params, success: {
            [weak self] (task, responseObject) in
            if let strongSelf = self {
                strongSelf.model.selected = true
                strongSelf.targetStatus(true)
            }
            XDPopView.toast("add_my_target_success".localized)
        }) { (task, error) in
            XDPopView.toast(error.localizedDescription)
        }
    }
    
    //MARK:- Action
    @objc func shareResult() {
        XDStatistics.click("10_A_add_btn")
        var urlStr = "\(XDEnvConfig.webHost)/\(String(format: XD_WEB_COLLEGE_DETAIL, model.collegeID))"
        urlStr += "?_from=app_ios_\(UIApplication.shared.appVersion!)"
        XDShareView.shared.showSharePanel(shareURL: urlStr, shareInfo: [
            "title": model.chineseName,
            "description": model.collegeIntro,
            "coverUrl": model.coverURL + "?x-oss-process=image/resize,m_pad,h_200,w_200/interlace,1/quality,q_75"
            ])
    }
    
    @objc func autoAddTarget() {
        XDStatistics.click("10_A_share_btn")
        if XDUser.shared.hasLogin() {
            if model.selected {
                XDPopView.loading()
                let urlStr = String(format: XD_API_MY_COLLEGE_REMOVE, model.collegeID)
                SSNetworkManager.shared().delete(urlStr, parameters: nil, success: {
                    [weak self] (task, responseObject) in
                    if let strongSelf = self {
                        strongSelf.model.selected = false
                        strongSelf.targetStatus(false)
                    }
                    // 可能从我的选校进来,所以要发通知
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: XD_NOTIFY_REMOVE_MY_TARGET), object: self)
                    XDPopView.toast("remove_my_target_success".localized)
                }) { (task, error) in
                    XDPopView.toast(error.localizedDescription)
                }
            } else {
                showCollegeTypeView()
            }
        } else {
            let vc = SignInViewController()
            XDRoute.presentToVC(vc)
        }
    }
    
    @objc func gotoChat() {
        XDStatistics.click("10_A_consul_btn")
        XDRoute.pushMQChatVC()
    }
    
    @objc func admissionTest() {
        XDStatistics.click("10_A_acceptance_rate_btn")
        let vc = AdmissionTestViewController()
        vc.collegeID = model.collegeID
        XDRoute.pushToVC(vc)
    }
}
