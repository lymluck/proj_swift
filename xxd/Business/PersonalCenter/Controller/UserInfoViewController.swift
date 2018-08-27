//
//  UserInfoViewController.swift
//  xxd
//
//  Created by remy on 2018/2/5.
//  Copyright © 2018年 com.smartstudy. All rights reserved.
//


/// 用户的个人信息
class UserInfoViewController: SSViewController, EditInfoViewControllerDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    private var scrollView: XDScrollView!
    private var userInfoView: UserInfoView!
    private var selectedItem: XDItemView!
    private var options: [String : [EditInfoModel]]?
    private lazy var targetCountryFooterView: UIView = {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: XDSize.screenWidth, height: 64), color: UIColor.clear)
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(gotoTargetRefer)))
        let desc = UILabel(text: "target_place_refer".localized, textColor: XDColor.main, fontSize: 13)!
        view.addSubview(desc)
        desc.snp.makeConstraints({ (make) in
            make.top.equalTo(view).offset(32)
            make.centerX.equalTo(view).offset(12)
        })
        let infoLogo = UIImageView(frame: .null, imageName: "smart_major_info")!
        view.addSubview(infoLogo)
        infoLogo.snp.makeConstraints({ (make) in
            make.centerY.equalTo(desc)
            make.right.equalTo(desc.snp.left).offset(-6)
        })
        return view
    }()
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        edgesForExtendedLayout = []
        title = "title_user_info".localized
        navigationBar.backgroundColor = UIColor.clear
        navigationBar.leftItem.image = UIImage(named: "top_left_arrow_white")
        navigationBar.centerItem.textColor = UIColor.white
        navigationBar.bottomLine.isHidden = true
        
        let topShadow = UIImageView(frame: CGRect(x: 0, y: 0, width: XDSize.screenWidth, height: XDSize.topHeight), imageName: "top_shadow")!
        view.insertSubview(topShadow, belowSubview: navigationBar)
        
        scrollView = XDScrollView(frame: CGRect(x: 0, y: 0, width: XDSize.screenWidth, height: XDSize.screenHeight))
        scrollView.backgroundColor = UIColor.clear
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.scrollsToTop = false
        scrollView.alwaysBounceVertical = true
        if #available(iOS 11.0, *) {
            scrollView.contentInsetAdjustmentBehavior = .never;
        }
        view.insertSubview(scrollView, belowSubview: topShadow)
        userInfoView = UserInfoView(frame: CGRect(x: 0, y: 0, width: XDSize.screenWidth, height: 0), isFromQA: false)
        scrollView.addSubview(userInfoView)
        scrollView.contentSize = CGSize(width: XDSize.screenWidth, height: userInfoView.bottom)
    }
    
    private func reloadData(_ vc: EditInfoViewController) {
        if let options = options {
            let paramKey = selectedItem.info["paramKey"] as! String
            if let dataList = options[paramKey] {
                vc.dataList = dataList
            }
        } else {
            XDPopView.loading()
            SSNetworkManager.shared().get(XD_API_PERSONAL_INFO_V2, parameters: nil, success: {
                [weak self] (task, responseObject) in
                if let data = (responseObject as? [String : Any])!["data"] as? [String : Any], let strongSelf = self {
                    strongSelf.options = [:]
                    for sectionKey in ["targetSection","backgroundSection"] {
                        if let section = data[sectionKey] as? [String : [String : Any]] {
                            for (rowKey, rowData) in section {
                                if let val1 = rowData["options"] {
                                    strongSelf.options![rowKey] = NSArray.yy_modelArray(with: EditInfoModel.self, json: val1) as? [EditInfoModel]
                                } else if let val2 = rowData["groupedOptions"] {
                                    strongSelf.options![rowKey] = NSArray.yy_modelArray(with: EditInfoModel.self, json: val2) as? [EditInfoModel]
                                }
                            }
                        }
                    }
                    strongSelf.reloadData(vc)
                }
                XDPopView.hide()
            }) { (task, error) in
                XDPopView.toast(error.localizedDescription)
            }
        }
    }
    
    @discardableResult
    private func gotoEditInfoText(_ title: String, _ value: String) -> EditInfoViewController {
        let vc = EditInfoViewController(title: title, type: .textField)
        vc.defaultValue = value
        vc.delegate = self
        navigationController?.pushViewController(vc, animated: true)
        return vc
    }
    
    @discardableResult
    private func gotoEditInfoList(_ title: String, _ value: String, _ type: EditInfoType) -> EditInfoViewController {
        let vc = EditInfoViewController(title: title, type: type)
        vc.defaultValue = value
        vc.delegate = self
        navigationController?.pushViewController(vc, animated: true)
        return vc
    }
    
    //MARK:- Action
    override func routerEvent(name: String, data: Dictionary<String, Any>) {
        if name == kEventUserInfoAvatarTap {
            let alertView = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            alertView.addAction(UIAlertAction(title: "cancel".localized, style: .cancel, handler: nil))
            alertView.addAction(UIAlertAction(title: "take_photo".localized, style: .`default`, handler: { [unowned self] (action) in
                let vc = UIImagePickerController()
                vc.delegate = self
                vc.allowsEditing = true
                if UIImagePickerController.isSourceTypeAvailable(.camera) {
                    vc.sourceType = .camera
                }
                self.present(vc, animated: true, completion: nil)
            }))
            alertView.addAction(UIAlertAction(title: "select_photo".localized, style: .`default`, handler: { [unowned self] (action) in
                let vc = UIImagePickerController()
                vc.delegate = self
                vc.allowsEditing = true
                self.present(vc, animated: true, completion: nil)
            }))
            let view = data["item"] as! UIView
            self.presentVC(alertView, sourceView: view)
        } else if name == kEventUserInfoItemTap {
            selectedItem = data["item"] as! XDItemView
            let index = selectedItem.info["index"] as! Int
            let title = (selectedItem.info["title"] as! UILabel).text!
            let value = XDUser.shared.model.value(forKey: selectedItem.info["valueKey"] as! String) as! String
            switch index {
            case 0:
                // 昵称
                let vc = gotoEditInfoText(title, value)
                vc.textMaxCount = 32
            case 7:
                // 学校
                gotoEditInfoText(title, value)
            case 9,10:
                // 语言成绩,标准化考试
                let vc = gotoEditInfoList(title, value, .multipleList)
                reloadData(vc)
            default:
                let vc = gotoEditInfoList(title, value, .list)
                if index == 2 {
                    // 意向国家
                    vc.footerView = targetCountryFooterView
                } else if index == 11 {
                    // 社会活动多选
                    vc.isMultipleSelect = true
                }
                reloadData(vc)
                break
            }
        }
    }
    
    @objc func gotoTargetRefer(gestureRecognizer: UIGestureRecognizer) {
        let vc = TargetReferViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    //MARK:- EditInfoViewDelegate
    func editInfoViewControllerDidSaveInfo(with model: EditInfoResultModel) {
        let paramKey = selectedItem.info["paramKey"] as! String
        let params = [paramKey: model.value]
        SSNetworkManager.shared().put(XD_API_PERSONAL_INFO_V2, parameters: params, success: {
            [weak self] (task, responseObject) in
            if let data = (responseObject as? [String : Any])!["data"] as? [String : Any], let strongSelf = self {
                XDUser.shared.setUserInfo(userInfo: data)
                if paramKey == "targetCountry" || paramKey == "targetDegree" {
                    strongSelf.options = nil
                    strongSelf.userInfoView.refreshView()
                    strongSelf.scrollView.contentSize = CGSize(width: XDSize.screenWidth, height: strongSelf.userInfoView.bottom)
                } else {
                    strongSelf.userInfoView.refreshItem(strongSelf.selectedItem)
                }
            }
            XDPopView.toast("update_success".localized, UIApplication.shared.keyWindow)
        }) { (task, error) in
            XDPopView.toast(error.localizedDescription, UIApplication.shared.keyWindow)
        }
    }
    
    //MARK:- UINavigationControllerDelegate UIImagePickerControllerDelegate
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        picker.dismiss(animated: true, completion: nil)
        let image = info[UIImagePickerControllerEditedImage] as! UIImage
        XDPopView.loading()
        SSNetworkManager.shared().put(XD_API_PERSONAL_INFO_V2, parameters: nil, constructingBodyWith: { (formData) in
            if let data = UIImagePNGRepresentation(image){
                formData.appendPart(withFileData: data, name: "avatar", fileName: "avatar.png", mimeType: "image/png")
            }
        }, success: {
            [weak self] (task, responseObject) in
            if let data = (responseObject as? [String : Any])!["data"] as? [String : Any], let strongSelf = self {
                XDUser.shared.setUserInfo(userInfo: data)
                strongSelf.userInfoView.avatar.image = image
            }
            XDPopView.toast("update_success".localized)
        }) { (task, error) in
            XDPopView.toast(error.localizedDescription)
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}