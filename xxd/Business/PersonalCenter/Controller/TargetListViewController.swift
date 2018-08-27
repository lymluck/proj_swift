//
//  TargetListViewController.swift
//  xxd
//
//  Created by remy on 2018/2/2.
//  Copyright © 2018年 com.smartstudy. All rights reserved.
//

/// 我的选校
class TargetListViewController: SSTableViewController, TargetCollegeItemDelegate, TargetCollegeTypeSelectorViewDelegate, EditInfoViewControllerDelegate {
    
    private var needRefresh = false
    private var predicate: NSPredicate!
    private var options: [EditInfoModel]?
    private var dataList = [TargetCollegeItem]()
    private var selectorView: TargetCollegeTypeSelectorView!
    private var noticeView: TargetCollegeNoticeView!

    private lazy var privacySettingView: PrivacySettingView = {
        let view: PrivacySettingView = PrivacySettingView(frame: CGRect.zero)
        view.size = CGSize(width: 295.0, height: 393.0)
        view.center = CGPoint(x: XDSize.screenWidth/2.0, y: XDSize.screenHeight/2.0)
        view.delegate = self
        return view
    }()
    private lazy var privacyButton: UIButton = {
        let button: UIButton = UIButton(frame: CGRect(x: 0.0, y: 0.0, width: 143.0, height: 49.0), title: "user_privacy_setting".localized, fontSize: 15.0, titleColor: UIColor(0x078CF1), target: self, action: #selector(addTargetTap(sender:)))
        button.tag = 1
        button.backgroundColor = UIColor.white
        button.titleEdgeInsets = UIEdgeInsetsMake(0, 7, 0, 0)
        button.setImage(UIImage(named: "unlock"), for: .normal)
        button.setImage(UIImage(named: "lock"), for: .selected)
        return button
    }()
    private lazy var sampleCollegeItem: TargetCollegeItem = {
        let dict: [String : Any] = [
            "id":"4",
            "countryId":"",
            "isMyTargetCountry":true,
            "matchTypeId":"MS_MATCH_TYPE_TOP",
            "chineseName":"哈佛大学(Sample)",
            "englishName":"Harvard University（Sample）",
            "worldRank":"1"
        ]
        let item = TargetCollegeItem(attributes: dict)!
        item.isSample = true
        item.delegate = self
        return item
    }()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reloadIfNeeded()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "user_target".localized
        let rightTitle = XDUser.shared.model.targetCountryName
        navigationBar.rightItem.text = rightTitle.isEmpty ? "target_place".localized : rightTitle
        
        let regStr = "^(\(XDUser.mainCountryIDs.joined(separator: "|")))$"
        predicate = NSPredicate(format: "SELF MATCHES %@", regStr)
        
        noticeView = TargetCollegeNoticeView(frame: CGRect(x: 0, y: topOffset, width: XDSize.screenWidth, height: 44))
        view.addSubview(noticeView)
        noticeView.isHidden = true
        let btnBackgroundView: UIView = UIView(frame: CGRect(x: 0.0, y: XDSize.screenHeight - XDSize.tabbarHeight, width: XDSize.screenWidth, height: XDSize.tabbarHeight), color: UIColor.white)
        let btn = UIButton(frame: CGRect(x: 143.0, y: 0.0, width: XDSize.screenWidth-143.0, height: 49.0), title: "user_target_add".localized, fontSize: 15, titleColor: UIColor.white, target: self, action: #selector(addTargetTap(sender:)))!
        btn.backgroundColor = XDColor.main
        btn.titleEdgeInsets = UIEdgeInsetsMake(0, 7, 0, 0)
        btn.setImage(UIImage(named: "target_add"), for: .normal)
        btn.setImage(UIImage(named: "target_add"), for: .highlighted)
        btnBackgroundView.addSubview(privacyButton)
        btnBackgroundView.addSubview(btn)
        view.addSubview(btnBackgroundView)
        
        tableViewActions.tableViewCellSelectionStyle = .none
        tableViewActions.attach(to: TargetCollegeItem.self, tap: { (object, target, indexPath) -> Bool in
            if let object = object as? TargetCollegeItem {
                let vc = TargetCollegeStatisticsController()
                vc.collegeId = object.model.collegeId
                if object.isSample {
                    vc.collegeName = "哈佛大学"
                } else {
                    vc.collegeName = object.model.chineseName
                }
                XDRoute.pushToVC(vc)
            }
            return true
        })
        
        NotificationCenter.default.addObserver(self, selector: #selector(changeTargetFromOthers(notification:)), name: NSNotification.Name(rawValue: XD_NOTIFY_ADD_MY_TARGET), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(changeTargetFromOthers(notification:)), name: NSNotification.Name(rawValue: XD_NOTIFY_REMOVE_MY_TARGET), object: nil)
    }
    
    override func shouldReload() -> Bool {
        return super.shouldReload() || needRefresh
    }
    
    override func createModel() {
        model = SSURLReqeustModel(httpMethod: .get, urlString: XD_API_MY_COLLEGE, loadFromFile: false, isPaged: false)
    }
    
    override func didFinishLoad(with object: Any!) {
        needRefresh = false
        var items = [TargetCollegeItem]()
        let targetCountryId = XDUser.shared.model.targetCountryId
        // 如果没设意向国家默认不显示提示
        let targetCountryIsEmpty = targetCountryId.isEmpty
        if let data = (object as! [String : Any])["data"] as? [String : Any] {
            if let isVisible = data["selectionVisible"] as? Bool {
                self.privacyButton.isSelected = !isVisible
                self.privacySettingView.isSelectionVisible = isVisible
                XDUser.shared.model.isPrivacy = !isVisible
            }
            let tops = data["top"] as! [[String : Any]]
            let middles = data["middle"] as! [[String : Any]]
            let bottoms = data["bottom"] as! [[String : Any]]
            let arr = [tops, middles, bottoms]
            for type in arr {
                for dict in type {
                    var info = dict["school"] as! [String: Any]
                    info["matchTypeId"] = dict["matchTypeId"] as! String
                    if targetCountryIsEmpty {
                        info["isMyTargetCountry"] = true
                    } else if targetCountryId == "OTHER" {
                        info["isMyTargetCountry"] = predicate.evaluate(with: info["countryId"] as! String)
                    } else {
                        info["isMyTargetCountry"] = targetCountryId == (info["countryId"] as! String)
                    }
                    let item = TargetCollegeItem(attributes: info)!
                    item.delegate = self
                    items.append(item)
                }
            }
            if items.count == 0 {
                // 如果没有选择的学校,则显示一个默认的
                tableViewModel.add(sampleCollegeItem)
            } else {
                tableViewModel.addObjects(from: items)
            }
            var flag = false
            for item in items {
                guard item.model.isMyTargetCountry else {
                    flag = true
                    break
                }
            }
            tableView.contentInset = UIEdgeInsetsMake(flag ? 58 : 14, 0, XDSize.tabbarHeight, 0)
            tableView.scrollIndicatorInsets = UIEdgeInsetsMake(flag ? 44 : 0, 0, XDSize.tabbarHeight, 0)
            noticeView.isHidden = !flag
            dataList = items
        }
    }
    
    private func refreshAfterChangeMyTarget() {
        navigationBar.rightItem.text = XDUser.shared.model.targetCountryName
        navigationBar.setNeedsLayout()
        if dataList.count > 0 {
            let targetCountryId = XDUser.shared.model.targetCountryId
            var flag = false
            for item in dataList {
                if targetCountryId == "OTHER" {
                    item.model.isMyTargetCountry = !predicate.evaluate(with: item.model.countryId)
                } else {
                    item.model.isMyTargetCountry = targetCountryId == item.model.countryId
                }
                if !item.model.isMyTargetCountry {
                    flag = true
                }
            }
            tableView.contentInset = UIEdgeInsetsMake(flag ? 58 : 14, 0, XDSize.tabbarHeight, 0)
            tableView.scrollIndicatorInsets = UIEdgeInsetsMake(flag ? 44 : 0, 0, XDSize.tabbarHeight, 0)
            noticeView.isHidden = !flag
            noticeView.noticeDesc.text = String(format: "user_target_notice".localized, XDUser.shared.model.targetCountryName)
            tableView.reloadData()
            tableView.setContentOffset(CGPoint(x: 0, y: -tableView.contentInset.top), animated: false)
        }
    }
    
    private func reloadData(_ vc: EditInfoViewController) {
        if let options = options {
            vc.dataList = options
        } else {
            XDPopView.loading()
            SSNetworkManager.shared().get(XD_API_PERSONAL_INFO_V2, parameters: nil, success: {
                [weak self] (task, responseObject) in
                if let data = (responseObject as? [String : Any])!["data"] as? [String : Any], let strongSelf = self {
                    let ops = ((data["targetSection"] as! [String : Any])["targetCountry"] as! [String : Any])["options"]!
                    strongSelf.options = NSArray.yy_modelArray(with: EditInfoModel.self, json: ops) as? [EditInfoModel]
                    strongSelf.reloadData(vc)
                }
                XDPopView.hide()
            }) { (task, error) in
                XDPopView.toast(error.localizedDescription)
            }
        }
    }
    
    //MARK:- Notification
    @objc func changeTargetFromOthers(notification: Notification) {
        needRefresh = true
    }
    
    //MARK:- Action
    override func rightActionTap() {
        let vc = EditInfoViewController(title: "target_place_select".localized, type: .list)
        vc.defaultValue = XDUser.shared.model.targetCountryId
        vc.delegate = self
        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: XDSize.screenWidth, height: 64))
        footerView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(gotoTargetRefer(gestureRecognizer:))))
        vc.footerView = footerView
        let desc = UILabel(text: "target_place_refer".localized, textColor: XDColor.main, fontSize: 13)!
        footerView.addSubview(desc)
        desc.snp.makeConstraints({ (make) in
            make.centerX.equalTo(footerView).offset(12)
            make.bottom.equalTo(footerView).offset(-10)
            make.top.equalTo(footerView).offset(36)
        })
        let logo = UIImageView(frame: .zero, imageName: "smart_major_info")!
        footerView.addSubview(logo)
        logo.snp.makeConstraints({ (make) in
            make.right.equalTo(desc.snp.left)
            make.top.equalTo(footerView).offset(36)
        })
        reloadData(vc)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func gotoTargetRefer(gestureRecognizer: UIGestureRecognizer) {
        let vc = TargetReferViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func addTargetTap(sender: UIButton) {
        if sender.tag == 1 {
            // 弹出隐私设置视图
            privacySettingView.showAlertViewWithAnimation()
        } else {
            let vc = TargetSearchViewController()
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    //MARK:- EditInfoViewDelegate
    func editInfoViewControllerDidSaveInfo(with model: EditInfoResultModel) {
        let params = ["targetCountry": model.value]
        SSNetworkManager.shared().put(XD_API_PERSONAL_INFO_V2, parameters: params, success: {
            [weak self] (task, responseObject) in
            if let data = (responseObject as? [String : Any])!["data"] as? [String : Any], let strongSelf = self {
                XDUser.shared.setUserInfo(userInfo: data)
                strongSelf.refreshAfterChangeMyTarget()
            }
            XDPopView.toast("update_success".localized)
        }) { (task, error) in
            XDPopView.toast(error.localizedDescription)
        }
    }
    
    //MARK:- TargetCollegeItemDelegate
    func targetCollegeItem(item: TargetCollegeItem, typeView: UIImageView) {
        if selectorView == nil {
            selectorView = TargetCollegeTypeSelectorView()
            selectorView.frame = CGRect(x: 0, y: 0, width: 120, height: 180)
            selectorView.delegate = self
        }
        let tmpPoint = typeView.convert(CGPoint.zero, toViewOrWindow: nil)
        selectorView.right = view.width - 38
        selectorView.top = tmpPoint.y + 10
        if selectorView.bottom - view.height > 0 {
            // 修正点击了靠屏幕低端的cell的offsetY
            selectorView.bottom = view.height
        }
        selectorView.model = item.model
        XDPopView.topView(view: selectorView, isMaskHide: true, alpha: 0.2)
    }
    
    //MARK:- TargetCollegeTypeSelectorViewDelegate
    func targetCollegeTypeSelectorView(model: TargetCollegeModel, type: TargetCollegeType) {
        if type == .remove {
            let alertView = UIAlertController(title: "remove_confirm".localized, message: nil, preferredStyle: .alert)
            alertView.addAction(UIAlertAction(title: "cancel".localized, style: .cancel, handler: nil))
            alertView.addAction(UIAlertAction(title: "confirm".localized, style: .destructive, handler: { [unowned self] (action) in
                self.removeTargetCollegeItem(model.collegeId)
            }))
            self.present(alertView, animated: true, completion: nil)
        } else {
            editTargetCollegeItem(model.collegeId, type)
        }
        XDPopView.hideTopView()
    }
    
    private func removeTargetCollegeItem(_ collegeID: Int) {
        let urlStr = String(format: XD_API_MY_COLLEGE_REMOVE, collegeID)
        SSNetworkManager.shared().delete(urlStr, parameters: nil, success: {
            [weak self] (task, responseObject) in
            self?.reload()
        }) { (task, error) in
            XDPopView.toast(error.localizedDescription)
        }
    }
    
    private func editTargetCollegeItem(_ collegeID: Int, _ type: TargetCollegeType) {
        let params: [String : Any] = [
            "schoolId":collegeID,
            "source":"manual-select",
            "matchTypeId":TargetCollegeModel.targetCollegeStringWithType(type: type)
        ]
        SSNetworkManager.shared().post(XD_API_MY_COLLEGE_EDIT, parameters: params, success: {
            [weak self] (task, responseObject) in
            self?.reload()
        }) { (task, error) in
            XDPopView.toast(error.localizedDescription)
        }
    }
}

// MARK: PrivacySettingViewDelegate
extension TargetListViewController: PrivacySettingViewDelegate {
    func privacySettingDidSet(_ visible: Bool) {
        SSNetworkManager.shared().put(XD_TARGET_COLLEGE_SET_PRIVACY, parameters: ["visible": visible], success: { (dataTask, responseObject) in
            XDUser.shared.model.isPrivacy = !visible
            self.privacySettingView.isSelectionVisible = visible
            self.privacyButton.isSelected = !visible
        }) { (dataTask, error) in
            XDPopView.toast(error.localizedDescription, self.view)
        }
    }
}
