//
//  SmartCollegeResultViewController.swift
//  xxd
//
//  Created by remy on 2018/2/6.
//  Copyright © 2018年 com.smartstudy. All rights reserved.
//

class SmartCollegeResultViewController: SSViewController, SmartCollegeListViewDelegate {
    
    var shareParams: String!
    var dataList: [[SmartCollegeModel]]?
    private var scrollView: UIScrollView!
    private var listView: SmartCollegeListView!
    private var batchTargetList = [SmartCollegeModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "smart_college_result".localized
        
        guard let dataList = dataList else { return }
        
        scrollView = UIScrollView(frame: CGRect(x: 0, y: XDSize.topHeight, width: XDSize.screenWidth, height: XDSize.contentHeight))
        scrollView.backgroundColor = UIColor.clear
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.scrollsToTop = false
        scrollView.alwaysBounceVertical = true
        view.addSubview(scrollView)
        
        listView = SmartCollegeListView()
        listView.dataList = dataList
        listView.delegate = self
        scrollView.addSubview(listView)
        listView.snp.makeConstraints({ (make) in
            make.top.left.bottom.equalTo(scrollView)
            make.width.equalTo(XDSize.screenWidth)
        })
        if let hasGuide = Preference.SMART_COLLEGE_GUIDE.get(), !hasGuide {
            listView.showGuideView()
        }
        
        addButtonView()
        reloadData()
        
        NotificationCenter.default.addObserver(self, selector: #selector(addTargetFromOtherPage(notification:)), name: NSNotification.Name(rawValue: XD_NOTIFY_ADD_MY_TARGET), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(removeTargetFromOtherPage(notification:)), name: NSNotification.Name(rawValue: XD_NOTIFY_REMOVE_MY_TARGET), object: nil)
    }
    
    private func addButtonView() {
        let bottomView = UIView(frame: CGRect(x: 0, y: XDSize.screenHeight - XDSize.tabbarHeight, width: XDSize.screenWidth, height: XDSize.tabbarHeight), color: UIColor.white)
        view.addSubview(bottomView)
        
        let space: CGFloat = ((XDSize.screenWidth - 240) / 6).rounded()
        let btn1 = bottomBtn("share".localized, "smart_college_share")
        btn1.left = space
        btn1.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(shareResult)))
        bottomView.addSubview(btn1)
        let btn2 = bottomBtn("auto_add_my_target".localized, "smart_college_add")
        btn2.left = btn1.right + space * 2
        btn2.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(autoAddTarget)))
        bottomView.addSubview(btn2)
        let btn3 = bottomBtn("online_consult".localized, "smart_college_consult")
        btn3.left = btn2.right + space * 2
        btn3.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(gotoChat)))
        bottomView.addSubview(btn3)
        
        bottomView.addSubview(UIView(frame: CGRect(x: 0, y: 0, width: XDSize.screenWidth, height: XDSize.unitWidth), color: UIColor(0xDDDDDD)))
    }
    
    private func bottomBtn(_ text: String, _ imageName: String) -> UIView {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 80, height: XDSize.tabbarHeight))
        let imageView = UIImageView(frame: CGRect(x: 28, y: 6, width: 24, height: 24), imageName: imageName)!
        imageView.contentMode = .center
        view.addSubview(imageView)
        let label = UILabel(frame: CGRect(x: 0, y: 31, width: 80, height: 14), text: text, textColor: XDColor.main, fontSize: 10)!
        label.textAlignment = .center
        view.addSubview(label)
        return view
    }
    
    private func reloadData() {
        listView.tableView.reloadData()
    }
    
    private func batchAddMyTarget() {
        var list = [[String : Any]]()
        for model in batchTargetList {
            list.append(["schoolId":model.collegeID,"matchTypeId":model.matchTypeId])
        }
        let params = [
            "data": (list as NSArray).yy_modelToJSONString(),
            "source": "auto-match"
        ]
        XDPopView.loading()
        SSNetworkManager.shared().post(XD_API_MY_COLLEGE_EDIT, parameters: params, success: {
            [weak self] (task, responseObject) in
            if let strongSelf = self {
                for model in strongSelf.batchTargetList {
                    model.isSelected = true
                }
                strongSelf.reloadData()
            }
            // 可能从我的选校进来,所以要发通知
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: XD_NOTIFY_ADD_MY_TARGET), object: self)
            XDPopView.toast("add_my_target_success".localized)
        }) { (task, error) in
            XDPopView.toast(error.localizedDescription)
        }
    }
    
    //MARK:- Notification
    @objc func addTargetFromOtherPage(notification: Notification) {
        if notification.object is SmartCollegeResultViewController { return }
        listView.selectedModel.isSelected = true
        reloadData()
    }
    
    @objc func removeTargetFromOtherPage(notification: Notification) {
        if notification.object is SmartCollegeResultViewController { return }
        listView.selectedModel.isSelected = false
        reloadData()
    }
    
    //MARK:- Action
    @objc func autoAddTarget() {
        batchTargetList = [SmartCollegeModel]()
        if let dataList = dataList {
            for arr in dataList {
                for model in arr {
                    batchTargetList.append(model)
                }
            }
            batchAddMyTarget()
        }
    }
    
    @objc func shareResult() {
        let urlStr = "\(XDEnvConfig.webHost)/\(String(format: XD_WEB_SMART_COLLEGE_RESULT, shareParams))"
        XDShareView.shared.showSharePanel(shareURL: urlStr, shareInfo: [
            "title": "share_desc".localized,
            "description": "smart_college_result".localized
        ])
    }
    
    @objc func gotoChat() {
        XDRoute.pushMQChatVC()
    }
    
    //MARK:- SmartCollegeListViewDelegate
    func didSelectItem(model: SmartCollegeModel) {
        let vc = CollegeDetailViewController()
        vc.collegeID = model.collegeID
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func didEditMyTarget(model: SmartCollegeModel) {
        if model.isSelected {
            XDPopView.loading()
            let urlStr = String(format: XD_API_MY_COLLEGE_REMOVE, model.collegeID)
            SSNetworkManager.shared().delete(urlStr, parameters: nil, success: {
                [weak self] (task, responseObject) in
                if let strongSelf = self {
                    model.isSelected = false
                    strongSelf.reloadData()
                }
                // 可能从我的选校进来,所以要发通知
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: XD_NOTIFY_REMOVE_MY_TARGET), object: self)
                XDPopView.toast("remove_my_target_success".localized)
            }) { (task, error) in
                XDPopView.toast(error.localizedDescription)
            }
        } else {
            batchTargetList = [model]
            batchAddMyTarget()
        }
    }
}
