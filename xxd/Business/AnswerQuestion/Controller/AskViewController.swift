//
//  AskViewController.swift
//  xxd
//
//  Created by remy on 2018/1/25.
//  Copyright © 2018年 com.smartstudy. All rights reserved.
//

class AskViewController: SSViewController {
    
    private let kViewTag: Int = 100
    private var selectedIndex: Int = -1
    private var scrollView: XDScrollView!
    private lazy var countryModels: [EditInfoModel] = []
    private lazy var degreeModels: [EditInfoModel] = []
    private lazy var countryId: String = XDUser.shared.model.targetCountryId
    private lazy var degreeId: String = XDUser.shared.model.targetDegreeId
    private lazy var countryLabel: UILabel = UILabel(frame: CGRect.zero, text: XDUser.shared.model.targetCountryName, textColor: XDColor.itemTitle, fontSize: 16.0)
    private lazy var degreeLabel: UILabel = UILabel(frame: CGRect.zero, text: XDUser.shared.model.targetDegreeName, textColor: XDColor.itemTitle, fontSize: 16.0)
    private var textView: XDTextView!
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
//        textView.focus()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initContentViews()
        requestOptions()
    }
    
    private func initContentViews() {
        XDStatistics.click("20_B_question_post")
        title = "title_ask".localized
        navigationBar.rightItem.text = "question_submit".localized
        navigationBar.leftItem.textColor = XDColor.itemText
        
        scrollView = XDScrollView(frame: CGRect(x: 0, y: XDSize.topHeight, width: XDSize.screenWidth, height: XDSize.visibleHeight))
        view.addSubview(scrollView)
        textView = XDTextView(frame: CGRect(x: 0, y: 148.0, width: XDSize.screenWidth, height: 200))
        textView.textColor = XDColor.itemTitle
        textView.placeholderLabel.numberOfLines = 0
        textView.placeholder = "ask_text_default".localized
        textView.maxTextLength = 150
        scrollView.addSubview(textView)
        addItemViews(topSpace: 0.0, title: "意向国家", valueLabel: countryLabel, viewTag: kViewTag)
        addItemViews(topSpace: 64.0, title: "申请项目", valueLabel: degreeLabel, viewTag: kViewTag + 1)
    }
    
    private func addItemViews(topSpace: CGFloat, title: String, valueLabel: UILabel, viewTag: Int) {
        let itemView: XDItemView = XDItemView(frame: CGRect(x: 0.0, y: topSpace, width: XDSize.screenWidth, height: 64.0), type: .middle)
        itemView.isRightArrow = true
        let titleLabel: UILabel = UILabel(frame: CGRect.zero, text: title, textColor: XDColor.itemText, fontSize: 16.0)
        itemView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().offset(16.0)
            make.height.equalTo(22.0)
        }
        itemView.addSubview(valueLabel)
        valueLabel.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.left.equalTo(titleLabel.snp.right).offset(20.0)
            make.height.equalTo(22.0)
        }
        itemView.tag = viewTag
        itemView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(eventItemViewTapResponse(_:))))
        scrollView.addSubview(itemView)
    }
    
    private func requestOptions() {
        SSNetworkManager.shared().get(XD_API_ASK_OPTIONS, parameters: nil, success: { [weak self](dataTask, responseData) in
            if let `self` = self, let data = responseData as? [String: Any], let serverData = data["data"] as? [String: Any] {
                if let countryOptions = serverData["targetCountry"] as? [Any], let models = NSArray.yy_modelArray(with: EditInfoModel.self, json: countryOptions) as? [EditInfoModel] {
                    self.countryModels = models
                }
                if let degreeOptions = serverData["targetDegree"] as? [Any], let models = NSArray.yy_modelArray(with: EditInfoModel.self, json: degreeOptions) as? [EditInfoModel] {
                    self.degreeModels = models
                }
            }
        }) { (dataTask, error) in
            
        }
    }
    
    //MARK:- Action
    override func rightActionTap() {
        XDStatistics.click("20_A_post_btn")
        let content = textView.text.trimmingCharacters(in: .whitespaces)
        if content.count < 15 {
            XDPopView.toast("ask_text_min".localized)
        } else {
            XDPopView.loading()
            SSNetworkManager.shared().post(XD_API_ASK_QUESTION, parameters: ["content":content, "targetCountryId": countryId, "targetDegreeId": degreeId], success: {
                [weak self] (task, responseObject) in
                self?.cancelActionTap()
                NotificationCenter.default.post(name: .XD_NOTIFY_UPDATE_QA_LIST, object: nil)
                XDPopView.toast("publish_success".localized, UIApplication.shared.keyWindow)
            }) { (task, error) in
                XDPopView.toast(error.localizedDescription)
            }
        }
    }
    
    override func cancelActionTap() {
        XDStatistics.click("20_A_cancel_btn")
        textView.blur()
        super.cancelActionTap()
    }
    
    @objc private func eventItemViewTapResponse(_ tap: UITapGestureRecognizer) {
        if let viewIndex = tap.view?.tag {
            selectedIndex = viewIndex - kViewTag
            var title = "意向国家"
            var defaultValue = countryId
            var dataList = countryModels
            if viewIndex == kViewTag + 1 {
                title = "申请项目"
                defaultValue = degreeId
                dataList = degreeModels
            }
            let vc = EditInfoViewController(title: title, type: .list)
            vc.defaultValue = defaultValue
            vc.dataList = dataList
            vc.delegate = self
            // TODO: 此举是考虑到网络不好的情况下, 防止进入选项界面没有数据
            if dataList.count > 0 {
                navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
}

// MARK: EditInfoViewControllerDelegate
extension AskViewController: EditInfoViewControllerDelegate {
    func editInfoViewControllerDidSaveInfo(with model: EditInfoResultModel) {
        if selectedIndex == 0 {
            countryLabel.text = model.name
            countryId = model.value
        } else if selectedIndex == 1 {
            degreeLabel.text = model.name
            degreeId = model.value
        }
    }
}
