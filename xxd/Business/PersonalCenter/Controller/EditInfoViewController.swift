//
//  EditInfoViewController.swift
//  xxd
//
//  Created by remy on 2018/1/4.
//  Copyright © 2018年 com.smartstudy. All rights reserved.
//

enum EditInfoType: String {
    case textField
    case list
    case multipleList
}

protocol EditInfoViewControllerDelegate: class {
    func editInfoViewControllerDidSaveInfo(with model: EditInfoResultModel)
}

class EditInfoViewController: SSViewController {
    
    weak var delegate: EditInfoViewControllerDelegate?
    var type: EditInfoType = .textField
    var textMaxCount = 0
    var defaultValue: String = ""
    var isMultipleSelect = false
    var stageView: (UIView & EditInfoData)?
    /// 用于判断是否返回上一层控制器还是直接跳转到首页. 如果需要跳转到首页, 需要设置为false
    var isFromInfoVC: Bool = true
    private var titleName = ""
    var footerView: UIView? {
        willSet {
            if let stageView = stageView as? EditInfoListView, type != .textField {
                stageView.tableView.tableFooterView = newValue
            }
        }
    }
    var dataList = [EditInfoModel]() {
        willSet {
            if let stageView = stageView as? EditInfoListView, type != .textField {
                stageView.dataList = newValue
                stageView.tableView.reloadData()
            }
        }
    }
    lazy var multipleSelectTipView: UIView = {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: XDSize.screenWidth, height: 64), color: UIColor.clear)
        let desc = UILabel(text: "user_info_multiple_options".localized, textColor: UIColor(0xF33C18), fontSize: 14)!
        view.addSubview(desc)
        desc.snp.makeConstraints({ (make) in
            make.top.left.equalTo(view).offset(16)
        })
        return view
    }()

    convenience init(title: String, type: EditInfoType) {
        self.init()
        titleName = title
        self.type = type
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if type == .textField {
            (stageView as! EditInfoTextView).textFieldView.focus()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = titleName
        if type == .textField {
            navigationBar.rightItem.text = "save".localized
            let view = EditInfoTextView(frame: CGRect(x: 0, y: XDSize.topHeight, width: XDSize.screenWidth, height: XDSize.visibleHeight))
            view.defaultValue = defaultValue
            view.textMaxCount = textMaxCount
            stageView = view
            self.view.addSubview(view)
        } else {
            let cls: EditInfoListView.Type = type == .list ? EditInfoListView.self : EditInfoMultipleListView.self
            let view = cls.init(frame: CGRect(x: 0, y: XDSize.topHeight, width: XDSize.screenWidth, height: XDSize.visibleHeight))
            view.defaultValue = defaultValue
            view.dataList = dataList
            view.isMultipleSelect = isMultipleSelect
            if isMultipleSelect {
                navigationBar.rightItem.text = "save".localized
            }
            if let footerView = footerView {
                view.tableView.tableFooterView = footerView
            } else {
                if isMultipleSelect {
                    view.tableView.tableFooterView = multipleSelectTipView
                }
            }
            view.tableView.reloadData()
            stageView = view
            self.view.addSubview(view)
        }
    }
    
    override func rightActionTap() {
        if let model = stageView?.saveEditInfo() {
            delegate?.editInfoViewControllerDidSaveInfo(with: model)
            navigationController?.popViewController(animated: true)
        }
    }
    
    // TODO: 点击左侧按钮时直接返回上一层
    // TODO: 首页数据及时更新
    override func backActionTap() {
        if !isFromInfoVC {
            navigationController?.popToRootViewController(animated: true)
        } else {
            super.backActionTap()
        }
    }
    
    override func routerEvent(name: String, data: Dictionary<String, Any>) {
        if let model = data["model"] as? EditInfoResultModel {            
            if isFromInfoVC {
                delegate?.editInfoViewControllerDidSaveInfo(with: model)
                navigationController?.popViewController(animated: true)
            } else {
                // TODO: 判断是否发生了变化
//                if model.value !=
                    SSNetworkManager.shared().put(XD_API_PERSONAL_INFO_V2, parameters: ["targetCountry": model.value], success: { (task, responseObject) in
                        if let responseData = (responseObject as? [String : Any])!["data"] as? [String : Any] {
                        XDUser.shared.setUserInfo(userInfo: responseData)
                        XDPopView.toast("update_success".localized, UIApplication.shared.keyWindow)
                        }
                    }) { (task, error) in
                        XDPopView.toast(error.localizedDescription, UIApplication.shared.keyWindow)
                }
                navigationController?.popToRootViewController(animated: true)
            }
        }
    }
}
