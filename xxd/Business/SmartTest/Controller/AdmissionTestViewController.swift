//
//  AdmissionTestViewController.swift
//  xxd
//
//  Created by remy on 2018/2/1.
//  Copyright © 2018年 com.smartstudy. All rights reserved.
//

import Kingfisher

class AdmissionTestViewController: SSViewController, EditInfoViewControllerDelegate {
    
    var isFromList = false
    var collegeID = 0
    private var scrollView: XDScrollView!
    private var logo: UIImageView!
    private var testInfoView: TestInfoView!
    private var selectedModel: TestItemModel!
    private var chineseName: UILabel!
    private var englishName: UILabel!
    private var options: [String : [EditInfoModel]]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = XDColor.mainBackground
        title = "title_admission_test".localized
        navigationBar.bottomLine.isHidden = true
        isCustomKeyboard = true
        
        scrollView = XDScrollView(frame: CGRect(x: 0, y: XDSize.topHeight, width: XDSize.screenWidth, height: XDSize.visibleHeight))
        scrollView.backgroundColor = UIColor.white
        view.addSubview(scrollView)
        
        let height: CGFloat = isFromList ? 232 : 194
        let topLayer = CALayer()
        topLayer.backgroundColor = XDColor.mainBackground.cgColor
        topLayer.frame = CGRect(x: 0, y: -XDSize.screenHeight, width: XDSize.screenWidth, height: XDSize.screenHeight + height)
        scrollView.layer.addSublayer(topLayer)
        
        let logoWrap = UIView(frame: CGRect(x: (XDSize.screenWidth - 100) * 0.5, y: 24, width: 100, height: 100))
        logoWrap.backgroundColor = UIColor.white
        logoWrap.layer.cornerRadius = 50
        logoWrap.layer.shadowRadius = 3
        logoWrap.layer.shadowColor = UIColor.black.cgColor
        logoWrap.layer.shadowOpacity = 0.1
        logoWrap.layer.shadowOffset = CGSize(width: 0, height: 2)
        logo = UIImageView(frame: CGRect(x: 12, y: 12, width: 76, height: 76))
        logo.layer.cornerRadius = 38
        logo.layer.masksToBounds = true
        logoWrap.addSubview(logo)
        scrollView.addSubview(logoWrap)
        
        chineseName = UILabel(frame: CGRect(x: 0, y: logoWrap.bottom + 12, width: XDSize.screenWidth, height: 25), text: "", textColor: XDColor.itemTitle, fontSize: 18, bold: true)!
        chineseName.textAlignment = .center
        scrollView.addSubview(chineseName)
        englishName = UILabel(frame: CGRect(x: 0, y: chineseName.bottom, width: XDSize.screenWidth, height: 16), text: "", textColor: XDColor.itemText, fontSize: 13)!
        englishName.textAlignment = .center
        scrollView.addSubview(englishName)
        
        if isFromList {
            let backView = UIView(frame: .zero, color: XDColor.itemLine)
            backView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(backActionTap)))
            backView.layer.cornerRadius = 12
            scrollView.addSubview(backView)
            backView.snp.makeConstraints({ (make) in
                make.centerX.equalTo(scrollView)
                make.top.equalTo(englishName.snp.bottom).offset(12)
                make.size.equalTo(CGSize(width: 107, height: 24))
            })
            
            let label = UILabel(text: "切换测试学校", textColor: XDColor.itemText, fontSize: 12)!
            scrollView.addSubview(label)
            label.snp.makeConstraints({ (make) in
                make.centerY.equalTo(backView)
                make.left.equalTo(backView).offset(14)
            })
            
            let imageView = UIImageView(frame: .zero, imageName: "back_to_admission_list")!
            scrollView.addSubview(imageView)
            imageView.snp.makeConstraints({ (make) in
                make.centerY.equalTo(backView)
                make.right.equalTo(backView).offset(-11)
            })
        }
        
        testInfoView = TestInfoView(frame: CGRect(x: 0, y: height, width: XDSize.screenWidth, height: 0), type: .admission)
        scrollView.addSubview(testInfoView)
        
        SSNetworkManager.shared().get(XD_API_COLLEGE_INTRO, parameters: ["id":collegeID], success: {
            [weak self] (task, responseObject) in
            if let data = (responseObject as! [String : Any])["data"] as? [String : Any], let strongSelf = self {
                let logoUrl = UIImage.OSSImageURLString(urlStr: data["logo"] as! String, size: strongSelf.logo.size, policy: .pad)
                strongSelf.logo.kf.setImage(with: URL(string: logoUrl), placeholder: UIImage(named: "default_college_logo"))
                strongSelf.chineseName.text = data["chineseName"] as? String
                strongSelf.englishName.text = data["englishName"] as? String
                strongSelf.testInfoView.isUS = (data["countryId"] as! String) == "COUNTRY_226"
                strongSelf.testInfoView.refreshView()
                strongSelf.scrollView.updateContentSize(subview: strongSelf.testInfoView)
            }
        }) { (task, error) in
            XDPopView.toast(error.localizedDescription)
        }
        SSNetworkManager.shared().get(XD_API_ADMISSION_TEST_COUNT, parameters: nil, success: {
            [weak self] (task, responseObject) in
            if let data = (responseObject as! [String : Any])["data"] as? Int {
                self?.testInfoView.testCount = data
            }
        }, failure: nil)
    }
    
    func reloadData(_ vc: EditInfoViewController) {
        if let options = options {
            if selectedModel.index == 1 {
                vc.dataList = options["degreeType"]!
            } else if selectedModel.index == 2 {
                vc.dataList = options["gradeType"]!
            }
        } else {
            XDPopView.loading()
            SSNetworkManager.shared().get(XD_API_ADMISSION_RATE_OPTIONS, parameters: nil, success: {
                [weak self] (task, responseObject) in
                if let data = (responseObject as? [String : Any])!["data"] as? [String : Any], let strongSelf = self {
                    let arr1 = NSArray.yy_modelArray(with: EditInfoModel.self, json: data["degreeType"]!) as! [EditInfoModel]
                    let arr2 = NSArray.yy_modelArray(with: EditInfoModel.self, json: data["gradeType"]!) as! [EditInfoModel]
                    strongSelf.options = ["degreeType":arr1,"gradeType":arr2]
                    strongSelf.reloadData(vc)
                }
                XDPopView.hide()
            }) { (task, error) in
                XDPopView.toast(error.localizedDescription)
            }
        }
    }
    
    //MARK:- Action
    override func routerEvent(name: String, data: Dictionary<String, Any>) {
        if name == kEventTestInfoTextFieldFocus {
            let view = data["item"] as! UIView
            scrollView.scrollToViewOnFocus(view: view)
        } else if name == kEventTestInfoSelectorTap {
            selectedModel = data["model"] as! TestItemModel
            let vc = EditInfoViewController(title: selectedModel.title.text!, type: .list)
            vc.defaultValue = selectedModel.paramValue
            vc.delegate = self
            reloadData(vc)
            navigationController?.pushViewController(vc, animated: true)
        } else if name == kEventTestInfoSubmit {
            if var params = testInfoView.fetchTestParams() {
                if XDUser.shared.hasLogin() {
                    XDPopView.loading()
                    params["schoolId"] = "\(collegeID)"
                    SSNetworkManager.shared().post(XD_API_ADMISSION_RATE, parameters: params, success: {
                        [weak self] (task, responseObject) in
                        if let data = (responseObject as! [String : Any])["data"] as? Int {
                            self?.gotoResult(data)
                        }
                        XDPopView.hide()
                    }) { (task, error) in
                        XDPopView.toast(error.localizedDescription)
                    }
                } else {
                    let vc = SignInViewController()
                    presentModalViewController(vc, animated: true, completion: nil)
                }
            }
        }
    }
    
    func gotoResult(_ resultId: Int) {
        SSNetworkManager.shared().get(XD_API_ADMISSION_RATE, parameters: ["id":resultId], success: {
            [weak self] (task, responseObject) in
            if let data = (responseObject as! [String : Any])["data"] as? [String : Any], let strongSelf = self {
                let vc = AdmissionResultViewController()
                vc.isUS = strongSelf.testInfoView.isUS
                vc.model = AdmissionResultModel.yy_model(with: data)
                strongSelf.navigationController?.pushViewController(vc, animated: true)
            }
            XDPopView.hide()
        }) { (task, error) in
            XDPopView.toast(error.localizedDescription)
        }
    }
    
    //MARK:- EditInfoViewDelegate
    func editInfoViewControllerDidSaveInfo(with model: EditInfoResultModel) {
        (selectedModel.content as! UILabel).text = model.name
        selectedModel.paramValue = model.value
        if selectedModel.index == 1{
            // 申请项目
            testInfoView.isGraduate = model.value == "MDT_MASTER"
            testInfoView.refreshView()
        }
        scrollView.updateContentSize(subview: testInfoView)
    }
}
