//
//  SmartCollegeViewController.swift
//  xxd
//
//  Created by remy on 2018/2/2.
//  Copyright © 2018年 com.smartstudy. All rights reserved.
//

class SmartCollegeViewController: SSViewController, EditInfoViewControllerDelegate {
    
    private var scrollView: XDScrollView!
    private var testInfoView: TestInfoView!
    private var selectedModel: TestItemModel!
    private var options: [String : [EditInfoModel]]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "smart_college".localized
        navigationBar.bottomLine.isHidden = true
        isCustomKeyboard = true
        
        scrollView = XDScrollView(frame: CGRect(x: 0, y: XDSize.topHeight, width: XDSize.screenWidth, height: XDSize.visibleHeight))
        scrollView.backgroundColor = UIColor.white
        view.addSubview(scrollView)
        
        let topImage = UIImageView(frame: CGRect(x: 0, y: 0, width: XDSize.screenWidth, height: 175), imageName: "smart_college_bg")!
        topImage.contentMode = .center
        scrollView.addSubview(topImage)
        
        testInfoView = TestInfoView(frame: CGRect(x: 0, y: 180, width: XDSize.screenWidth, height: 0), type: .college)
        scrollView.addSubview(testInfoView)
        
        SSNetworkManager.shared().get(XD_API_ADMISSION_TEST_COUNT, parameters: nil, success: {
            [weak self] (task, responseObject) in
            if let data = (responseObject as! [String : Any])["data"] as? Int {
                self?.testInfoView.testCount = data
            }
        }, failure: nil)
    }
    
    func reloadData(_ vc: EditInfoViewController) {
        if let options = options {
            if selectedModel.index == 0 {
                vc.dataList = options["country"]!
            } else if selectedModel.index == 1 {
                vc.dataList = options["degreeType"]!
            } else if selectedModel.index == 3 {
                vc.dataList = options["range"]!
            }
        } else {
            XDPopView.loading()
            SSNetworkManager.shared().get(XD_API_SMART_COLLEGE_OPTIONS, parameters: nil, success: {
                [weak self] (task, responseObject) in
                if let data = (responseObject as? [String : Any])!["data"] as? [String : Any], let strongSelf = self {
                    let arr1 = NSArray.yy_modelArray(with: EditInfoModel.self, json: data["country"]!) as! [EditInfoModel]
                    let arr2 = NSArray.yy_modelArray(with: EditInfoModel.self, json: data["degreeType"]!) as! [EditInfoModel]
                    let arr3 = NSArray.yy_modelArray(with: EditInfoModel.self, json: data["range"]!) as! [EditInfoModel]
                    strongSelf.options = ["country":arr1,"degreeType":arr2,"range":arr3]
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
            if let params = testInfoView.fetchTestParams() {
                if XDUser.shared.hasLogin() {
                    XDPopView.loading()
                    SSNetworkManager.shared().post(XD_API_SMART_COLLEGE, parameters: params, success: {
                        [weak self] (task, responseObject) in
                        if let data = (responseObject as! [String : Any])["data"] as? [String : Any] {
                            let arr1 = NSArray.yy_modelArray(with: SmartCollegeModel.self, json: data["top"]!) as! [SmartCollegeModel]
                            let arr2 = NSArray.yy_modelArray(with: SmartCollegeModel.self, json: data["middle"]!) as! [SmartCollegeModel]
                            let arr3 = NSArray.yy_modelArray(with: SmartCollegeModel.self, json: data["bottom"]!) as! [SmartCollegeModel]
                            self?.gotoResult([arr1,arr2,arr3], params)
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
    
    func gotoResult(_ dict: [[SmartCollegeModel]], _ params: [String : String]) {
        var shareParams = [String]()
        let paramKeys = ["countryId", "degreeId", "localRankLimit", "gpa", "scoreToefl", "scoreIelts", "scoreSat", "scoreAct", "scoreGre", "scoreGmat"]
        for key in paramKeys {
            shareParams.append(params[key] ?? "0")
        }
        let vc = SmartCollegeResultViewController()
        vc.dataList = dict
        vc.shareParams = shareParams.joined(separator: "-")
        navigationController?.pushViewController(vc, animated: true)
    }
    
    //MARK:- EditInfoViewDelegate
    func editInfoViewControllerDidSaveInfo(with model: EditInfoResultModel) {
        (selectedModel.content as! UILabel).text = model.name
        selectedModel.paramValue = model.value
        if selectedModel.index == 0 {
            // 意向国家
            testInfoView.isUS = model.value == "226"
            testInfoView.refreshView()
        } else if selectedModel.index == 1{
            // 申请项目
            testInfoView.isGraduate = model.value == "2"
            testInfoView.refreshView()
        }
        scrollView.updateContentSize(subview: testInfoView)
    }
}
