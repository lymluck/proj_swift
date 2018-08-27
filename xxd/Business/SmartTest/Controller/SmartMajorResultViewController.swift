//
//  SmartMajorResultViewController.swift
//  xxd
//
//  Created by remy on 2018/2/6.
//  Copyright © 2018年 com.smartstudy. All rights reserved.
//

class SmartMajorResultViewController: SSViewController, UIScrollViewDelegate, SmartMajorListViewDelegate, CollegeTypeSelectorViewDelegate {
    
    var shareID: Int!
    var scores: [String : Any]!
    var conclusion = [[String : Any]]()
    var dataList: [SmartMajorModel]?
    private var scrollView: UIScrollView!
    private var listView: SmartMajorListView!
    private var webView: XDWebView!
    private var batchTargetList = [SmartMajorModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "smart_major_result".localized
        
        guard let dataList = dataList else { return }
        
        scrollView = UIScrollView(frame: CGRect(x: 0, y: XDSize.topHeight, width: XDSize.screenWidth, height: XDSize.contentHeight))
        scrollView.backgroundColor = UIColor.clear
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.scrollsToTop = false
        scrollView.alwaysBounceVertical = true
        scrollView.isHidden = true
        view.addSubview(scrollView)
        
        listView = SmartMajorListView()
        listView.dataList = dataList
        listView.delegate = self
        scrollView.addSubview(listView)
        listView.snp.makeConstraints({ (make) in
            make.top.left.bottom.equalTo(scrollView)
            make.width.equalTo(XDSize.screenWidth)
        })
        if let hasGuide = Preference.SMART_MAJOR_GUIDE.get(), !hasGuide {
            scrollView.delegate = self
        }
        
        addTopView()
        addDescView()
        addButtonView()
        reloadData()
        
        NotificationCenter.default.addObserver(self, selector: #selector(addTargetFromOtherPage(notification:)), name: NSNotification.Name(rawValue: XD_NOTIFY_ADD_MY_TARGET), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(removeTargetFromOtherPage(notification:)), name: NSNotification.Name(rawValue: XD_NOTIFY_REMOVE_MY_TARGET), object: nil)
    }
    
    private func addTopView() {
        let webViewTop: CGFloat = 106
        let webViewSize: CGFloat = XDSize.screenWidth - 50
        let topLayer = CALayer()
        topLayer.backgroundColor = UIColor.white.cgColor
        topLayer.frame = CGRect(x: 0, y: -XDSize.screenHeight, width: XDSize.screenWidth, height: XDSize.screenHeight + webViewTop + webViewSize + 22)
        scrollView.layer.addSublayer(topLayer)
        
        let titleLabel = UILabel(frame: CGRect(x: 0, y: 28, width: 0, height: 38), text: "smart_major_my_test".localized, textColor: UIColor.white, fontSize: 22, bold: true)!
        let titleWidth = titleLabel.text!.widthForFont(titleLabel.font) + 30
        titleLabel.width = titleWidth
        titleLabel.left = (XDSize.screenWidth - titleWidth) * 0.5
        titleLabel.backgroundColor = UIColor(0xFFBB00)
        titleLabel.textAlignment = .center
        scrollView.addSubview(titleLabel)
        
        scrollView.addSubview(UIImageView(frame: CGRect(x: titleLabel.left - 32, y: 42, width: 28, height: 30), imageName: "smart_major_title_left"))
        scrollView.addSubview(UIImageView(frame: CGRect(x: titleLabel.right + 4, y: 42, width: 28, height: 30), imageName: "smart_major_title_right"))
        
        XDPopView.loading()
        let query: [String : Any] = ["fileName":"hollandRadar","params":scores]
        webView = XDWebView(frame: CGRect(x: 25, y: webViewTop, width: webViewSize, height: webViewSize), query: query)
        webView.completionHandler = {
            [weak self] in
            self?.scrollView.isHidden = false
            XDPopView.hide()
        }
        scrollView.addSubview(webView)
    }
    
    private func addDescView() {
        let colorDict = ["a":"F6611D","r":"C5A1F2","i":"00ACA2","e":"639CEF","c":"FFB400","s":"03BD52"]
        var itemViewTop = webView.bottom + 38
        var itemView: UIView!
        for (index, data) in conclusion.enumerated() {
            let type = data["type"] as! String
            let intro = data["introduction"] as! String
            let desc = data["majorFavor"] as! String
            var descArr = desc.components(separatedBy: "\n\n")
            let descTitle = descArr.first!
            descArr.removeFirst()
            let descContent = descArr.joined(separator: "\n\n")
            let typeColor = UIColor(colorDict[data["key"] as! String]!)
            itemView = UIView(frame: CGRect(x: 0, y: itemViewTop, width: XDSize.screenWidth, height: 0), color: UIColor.white)
            scrollView.addSubview(itemView)
            
            // 标题
            let titleLabel = UILabel(frame: CGRect(x: 16, y: 24, width: XDSize.screenWidth - 32, height: 26), text: "", textColor: XDColor.itemTitle, fontSize: 18, bold: true)!
            titleLabel.attributedText = "smart_major_suitable".localized + NSAttributedString(string: type).color(typeColor)
            itemView.addSubview(titleLabel)
            itemView.addSubview(UIView(frame: CGRect(x: 0, y: 27, width: 4, height: 20), color: typeColor))
            
            // 简介
            let introLabel = UILabel(frame: CGRect(x: 16, y: titleLabel.bottom + 30, width: XDSize.screenWidth - 32, height: 0), text: "", textColor: XDColor.itemTitle, fontSize: 15)!
            introLabel.numberOfLines = 0
            introLabel.setText(intro, lineHeight: 27)
            introLabel.height = intro.heightForFont(introLabel.font, introLabel.width, 27)
            itemView.addSubview(introLabel)
            
            // 内容标题
            let descTitleLabel = UILabel(frame: CGRect(x: 16, y: introLabel.bottom + 30, width: XDSize.screenWidth - 32, height: 26), text: descTitle, textColor: XDColor.itemTitle, fontSize: 15, bold: true)!
            itemView.addSubview(descTitleLabel)
            
            // 内容
            let descLabel = UILabel(frame: CGRect(x: 16, y: descTitleLabel.bottom + 26, width: XDSize.screenWidth - 32, height: 0), text: "", textColor: XDColor.itemTitle, fontSize: 15)!
            descLabel.numberOfLines = 0
            descLabel.setText(descContent, lineHeight: 27)
            descLabel.height = descContent.heightForFont(descLabel.font, descLabel.width, 27)
            itemView.addSubview(descLabel)
            
            itemView.height = descLabel.bottom + 24
            itemViewTop += itemView.height
            if index < conclusion.count - 1 {
                itemView.addSubview(UIView(frame: CGRect(x: 16, y: itemView.height - XDSize.unitWidth, width: itemView.width - 16, height: XDSize.unitWidth), color: UIColor(0xDDDDDD)))
            }
        }
        if itemView != nil {
            listView.snp.updateConstraints({ (make) in
                make.top.equalTo(scrollView).offset(itemView.bottom + 16)
            })
        } else {
            listView.snp.updateConstraints({ (make) in
                make.top.equalTo(scrollView).offset(webView.bottom + 16)
            })
        }
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
    
    private func batchAddMyTarget(_ matchTypeId: String) {
        var list = [[String : Any]]()
        for model in batchTargetList {
            list.append(["schoolId":model.collegeID,"matchTypeId":matchTypeId])
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
            XDPopView.toast("add_my_target_success".localized)
        }) { (task, error) in
            XDPopView.toast(error.localizedDescription)
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
    
    //MARK:- Notification
    @objc func addTargetFromOtherPage(notification: Notification) {
        if notification.object is SmartMajorResultViewController { return }
        listView.selectedModel.isSelected = true
        reloadData()
    }
    
    @objc func removeTargetFromOtherPage(notification: Notification) {
        if notification.object is SmartMajorResultViewController { return }
        listView.selectedModel.isSelected = false
        reloadData()
    }
    
    //MARK:- Action
    @objc func autoAddTarget() {
        if let dataList = dataList {
            batchTargetList = dataList
            showCollegeTypeView()
        }
    }
    
    @objc func shareResult() {
        let urlStr = "\(XDEnvConfig.webHost)/\(String(format: XD_WEB_SMART_MAJOR_RESULT, shareID))"
        XDShareView.shared.showSharePanel(shareURL: urlStr, shareInfo: [
            "title": "share_desc".localized,
            "description": "smart_major_result".localized
        ])
    }
    
    @objc func gotoChat() {
        XDRoute.pushMQChatVC()
    }
    
    override func backActionTap() {
        XDRoute.popWithCount(2)
    }
    
    //MARK:- CollegeTypeSelectorViewDelegate
    func collegeTypeDidSelected(typeId: String) {
        hideCollegeTypeView()
        batchAddMyTarget(typeId)
    }
    
    //MARK:- SmartMajorListViewDelegate
    func didSelectItem(model: SmartMajorModel) {
        let vc = CollegeDetailViewController()
        vc.collegeID = model.collegeID
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func didEditMyTarget(model: SmartMajorModel) {
        if model.isSelected {
            XDPopView.loading()
            let urlStr = String(format: XD_API_MY_COLLEGE_REMOVE, model.collegeID)
            SSNetworkManager.shared().delete(urlStr, parameters: nil, success: {
                [weak self] (task, responseObject) in
                if let strongSelf = self {
                    model.isSelected = false
                    strongSelf.reloadData()
                }
                XDPopView.toast("remove_my_target_success".localized)
            }) { (task, error) in
                XDPopView.toast(error.localizedDescription)
            }
        } else {
            batchTargetList = [model]
            showCollegeTypeView()
        }
    }
    
    //MARK:- UIScrollViewDelegate
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y > listView.top {
            scrollView.setContentOffset(CGPoint(x: 0, y: listView.top), animated: false)
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let limit: CGFloat = scrollView.contentOffset.y + XDSize.contentHeight - listView.top
        if scrollView.isScrollEnabled && limit > 0 {
            scrollView.isScrollEnabled = false
            UIView.animate(withDuration: 0.6, delay: 0, options: .curveEaseInOut, animations: {
                [weak self] in
                if let strongSelf = self {
                    scrollView.contentOffset = CGPoint(x: 0, y: strongSelf.listView.top)
                }
            }, completion: {
                [weak self] (finished) in
                if let strongSelf = self {
                    strongSelf.listView.showGuideView()
                    scrollView.isScrollEnabled = true
                }
            })
        }
    }
}
