//
//  CompletionViewController.swift
//  xxd
//
//  Created by remy on 2018/1/10.
//  Copyright © 2018年 com.smartstudy. All rights reserved.
//

private var kItemModelKey: UInt8 = 0

class CompletionViewController: SSViewController {
    
    private var fieldList = [CompleteFieldModel]()
    private var dataList = [String: CompleteFieldModel]()
    private var userItems = [UIButton]()
    private var scrollView: UIScrollView!
    private var middleSection: UIView!
    private lazy var targetCountryFooterView: UIView = {
        let view = UIView(frame: CGRect(x: 0, y: XDSize.topHeight, width: XDSize.screenWidth, height: XDSize.visibleHeight), color: UIColor.clear)
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(gotoTargetRefer)))
        let desc = UILabel(text: "target_place_refer".localized, textColor: XDColor.main, fontSize: 13)!
        view.addSubview(desc)
        desc.snp.makeConstraints({ (make) in
            make.top.equalTo(view)
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
    private let eventb = ["2_B_user_identity","3_B_aboroad_time","4_B_abroad_countries","6_B_programs","7_B_school_rank"]
    private let eventa = [
        ["2_A_student_btn","2_A_parents_btn","2_A_other_btn"],
        ["3_A_first_btn","3_A_second_btn","3_A_third_btn","3_A_other_btn"],
        ["4_A_America_btn","4_A_England_btn","4_A_Canada_btn","4_A_Australia_btn","4_A_other_btn"],
        ["6_A_undergraduate_btn","6_A_graduate_btn","6_A_highschool_btn","6_A_other_btn"],
        ["7_A_first_btn","7_A_second_btn","7_A_third_btn","7_A_other_btn"],
        ["8_A_budget_forty", "8_A_budget_thirty", "8_A_budget_twenty", "8_A_budget_ten", "8_A_budget_scholarship"]
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        isGesturePopEnable = false
        navigationBar.bottomLine.isHidden = true
        navigationBar.leftItem.image = nil
        
        scrollView = UIScrollView(frame: CGRect(x: 0, y: XDSize.topHeight, width: XDSize.screenWidth, height: XDSize.visibleHeight))
        scrollView.backgroundColor = UIColor.clear
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.scrollsToTop = false
        scrollView.alwaysBounceVertical = true
        scrollView.delaysContentTouches = false
        scrollView.canCancelContentTouches = false
        view.addSubview(scrollView)
        
        addTopSection()
        
        XDPopView.loading()
        SSNetworkManager.shared().get(XD_API_COMPLETION_OPTIONS, parameters: nil, success: {
            [weak self] (task, responseObject) in
            let dict = responseObject as? [String : Any]
            if let data = dict?["data"] as? [String : Any], let strongSelf = self {
                var maxCount = 0
                for (key, info) in data {
                    var dict = info as! [String : Any]
                    dict["fieldName"] = key
                    let count = (dict["options"] as! [Any]).count
                    maxCount = count > maxCount ? count : maxCount
                    let fieldModel = CompleteFieldModel.yy_model(with: dict)
                    strongSelf.dataList[key] = fieldModel
                }
                strongSelf.addMiddleSection(maxCount)
                strongSelf.fieldList.append(strongSelf.dataList["start"]!)
                strongSelf.refreshView()
            }
            XDPopView.hide()
        }) { [weak self] (task, error) in
            self?.cancelActionTap()
            XDPopView.toast(error.localizedDescription)
        }
    }
    
    func addTopSection() {
        let titleLabel = UILabel(frame: .zero, text: "completion_title".localized, textColor: XDColor.main, fontSize: 22, bold: true)!
        scrollView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints({ (make) in
            make.top.equalTo(scrollView)
            make.centerX.equalTo(scrollView)
        })
        let subTitleLabel = UILabel(frame: .zero, text: "completion_subtitle".localized, textColor: UIColor(0xC4C9CC), fontSize: 16)!
        scrollView.addSubview(subTitleLabel)
        subTitleLabel.snp.makeConstraints({ (make) in
            make.top.equalTo(titleLabel.snp.bottom).offset(8)
            make.centerX.equalTo(titleLabel)
        })
    }
    
    func addMiddleSection(_ maxCount: Int) {
        middleSection = UIView(frame: CGRect(x: 0, y: 96, width: XDSize.screenWidth, height: 0), color: UIColor.clear)
        scrollView.addSubview(middleSection)
        for i in 0..<maxCount {
            let item = UIButton(frame: CGRect(x: 56, y: 80 * i, width: Int(XDSize.screenWidth - 112), height: 48), title: "", fontSize: 16, titleColor: XDColor.itemText, target: self, action: #selector(itemTap(sender:)))!
            item.setBackgroundColor(UIColor.clear, for: .normal)
            item.setTitleColor(XDColor.itemText, for: .normal)
            item.setBackgroundColor(XDColor.main, for: .selected)
            item.setTitleColor(UIColor.white, for: .selected)
            item.setBackgroundColor(XDColor.main, for: .highlighted)
            item.setTitleColor(UIColor.white, for: .highlighted)
            item.layer.masksToBounds = true
            item.layer.borderWidth = 1
            item.layer.cornerRadius = 24
            middleSection.addSubview(item)
            userItems.append(item)
        }
    }
    
    func refreshView() {
        if fieldList.count <= eventb.count {
            XDStatistics.click(eventb[fieldList.count - 1])
        }
        if let fieldModel = fieldList.last {
            let models = fieldModel.subModels
            for (index, item) in userItems.enumerated() {
                if index < models.count {
                    let model = models[index]
                    model.index = index
                    item.setTitle(model.name, for: .normal)
                    item.isHidden = false
                    if fieldModel.selectedValue == model.value {
                        item.isSelected = true
                        item.layer.borderColor = XDColor.main.cgColor
                    } else {
                        item.isSelected = false
                        item.layer.borderColor = XDColor.itemLine.cgColor
                    }
                    objc_setAssociatedObject(item, &kItemModelKey, model, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                } else {
                    item.isHidden = true
                }
            }
            if fieldModel.paramKey == "targetCountry" {
                middleSection.addSubview(targetCountryFooterView)
                targetCountryFooterView.top = CGFloat(models.count) * 80 + 16
                middleSection.height = targetCountryFooterView.bottom
            } else {
                targetCountryFooterView.removeFromSuperview()
                middleSection.height = CGFloat(models.count) * 80
            }
            scrollView.contentSize = CGSize(width: XDSize.screenWidth, height: middleSection.bottom)
        }
        if fieldList.count > 1 {
            navigationBar.leftItem.image = UIImage(named: "top_left_arrow")
        } else {
            navigationBar.leftItem.image = nil
        }
        navigationBar.setNeedsLayout()
    }
    
    //MARK:- Action
    @objc func gotoTargetRefer() {
        XDStatistics.click("4_A_compare_btn")
        let vc = TargetReferViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    override func backActionTap() {
        fieldList.last?.selectedValue = ""
        fieldList.removeLast()
        refreshView()
    }
    
    @objc func itemTap(sender: UIButton) {
        if let fieldModel = fieldList.last {
            let model = objc_getAssociatedObject(sender, &kItemModelKey) as! CompleteFieldOptionModel
            if fieldList.count <= eventa.count {
                let arr = eventa[fieldList.count - 1]
                if model.index < arr.count {
                    XDStatistics.click(arr[model.index])
                }
            }
            fieldModel.selectedValue = model.value
            if let model = dataList[model.nextFieldName] {
                fieldList.append(model)
                refreshView()
            }
            if model.finish {
                var params = [String : String]()
                for fieldModel in fieldList {
                    params[fieldModel.paramKey] = fieldModel.selectedValue
                }
                XDPopView.loading()
                SSNetworkManager.shared().put(XD_API_PERSONAL_INFO_V2, parameters: params, success: { [weak self] (task, responseObject) in
                    let dict = responseObject as? [String : Any]
                    if let data = dict?["data"] as? [String : Any] {
                        XDUser.shared.setUserInfo(userInfo: data)
                    }
                    self?.cancelActionTap()
                    XDPopView.hide()
                }) { [weak self] (task, error) in
                    self?.cancelActionTap()
                    XDPopView.toast(error.localizedDescription)
                }
            }
        }
    }
}
