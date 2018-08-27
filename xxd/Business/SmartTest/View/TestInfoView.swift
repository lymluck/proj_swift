//
//  TestInfoView.swift
//  xxd
//
//  Created by remy on 2018/1/31.
//  Copyright © 2018年 com.smartstudy. All rights reserved.
//

enum TestInfoType {
    case admission  // 录取率测试
    case college    // 智能选校
}

let kEventTestInfoSelectorTap = "kEventTestInfoSelectorTap"
let kEventTestInfoTextFieldFocus = "kEventTestInfoTextFieldFocus"
let kEventTestInfoSubmit = "kEventTestInfoSubmit"
private let kItemHeight: CGFloat = 64
private var kItemModelKey: UInt8 = 0

class TestInfoView: UIView, XDTextFieldViewDelegate, XDPickerViewDelegate {
    
    private var itemList = [XDItemView]()
    private var type: TestInfoType!
    private var middleSection: UIView!
    private var bottomSection: UIView!
    private var testCountLabel: UILabel!
    private var textFieldItem: XDItemView?
    private var typeKeys = ""
    var isUS = false
    var isGraduate = false
    var testCount = 0 {
        didSet {
            let text = String(format: "test_user_count".localized, testCount)
            let width = text.widthForFont(testCountLabel.font) + 30
            testCountLabel.left = (XDSize.screenWidth - width) * 0.5
            testCountLabel.width = width
            testCountLabel.text = text
        }
    }
    
    convenience init(frame: CGRect, type: TestInfoType) {
        self.init(frame: frame)
        self.backgroundColor = UIColor.clear
        self.type = type
        addMiddleSection()
        addBottomSection()
        refreshView()
    }
    
    private func addMiddleSection() {
        middleSection = UIView(frame: CGRect(x: 0, y: 0, width: XDSize.screenWidth, height: 0))
        addSubview(middleSection)
        // 请求参数key(可选的','分割),标题key,默认内容key
        var paramKeys: [Any] = ["countryId", "degreeId", "gradeId", "localRankLimit", "gpa", ["", "scoreToefl", "scoreIelts"], ["", "scoreToefl", "scoreIelts"], ["", "scoreToefl", "scoreIelts"]]
        if type == .admission {
            paramKeys = ["countryId", "projectId", "gradeId", "localRankLimit", "score", ["", "toefl", "ielts"], ["", "sat", "act"], ["", "gre", "gmat"]]
        }
        let keys: [[Any]] = [[paramKeys[0], "user_info_target", ""],
                             [paramKeys[1], "user_info_degree", ""],
                             [paramKeys[2], "user_info_grade", ""],
                             [paramKeys[3], "smart_college_rank", ""],
                             [paramKeys[4], "test_info_score", "test_info_score_default"],
                             [paramKeys[5], ["test_info_language", "test_info_toefl", "test_info_ielts"], ["test_info_language_default", "test_info_toefl_default", "test_info_ielts_default"]],
                             [paramKeys[6], ["test_info_standard", "test_info_sat", "test_info_act"], ["test_info_standard_default", "test_info_sat_default", "test_info_act_default"]],
                             [paramKeys[7], ["test_info_standard", "test_info_gre", "test_info_gmat"], ["test_info_standard_default", "test_info_gre_default", "test_info_gmat_default"]]
        ]
        for i in 0..<keys.count {
            let item = XDItemView(frame: CGRect(x: 0, y: 0, width: XDSize.screenWidth, height: kItemHeight), type: .middle)
            middleSection.addSubview(item)
            itemList.append(item)
            let model = TestItemModel()
            model.index = i
            if i < 4 {
                item.isRightArrow = true
                item.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(selectorTap(gestureRecognizer:))))
                let title = UILabel(frame: CGRect(x: 12, y: 21, width: 110, height: 22), text: "", textColor: XDColor.itemText, fontSize: 16)!
                item.addSubview(title)
                let content = UILabel(frame: CGRect(x: 145, y: 21, width: XDSize.screenWidth - 170, height: 22), text: "", textColor: XDColor.itemTitle, fontSize: 16)!
                item.addSubview(content)
                model.paramKey = keys[i][0] as! String
                model.titleText = (keys[i][1] as! String).localized
                model.defaultTitleText = (keys[i][2] as! String).localized
                model.title = title
                model.content = content
                model.type = .selector
                objc_setAssociatedObject(item, &kItemModelKey, model, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            } else {
                let title = UILabel(frame: CGRect(x: 16, y: 21, width: 110, height: 22), text: "", textColor: XDColor.itemText, fontSize: 16)!
                let textFieldView = XDTextFieldView(frame: CGRect(x: 130, y: 10, width: XDSize.screenWidth - 105, height: 44))
                textFieldView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(textFieldTap(gestureRecognizer:))))
                textFieldView.textColor = XDColor.itemTitle
                textFieldView.fontSize = 16
                textFieldView.placeholder = ""
                textFieldView.delegate = self
                textFieldView.keyboardType = .decimalPad
                item.addSubview(textFieldView)
                if i == 4 {
                    item.addSubview(title)
                    model.paramKey = keys[i][0] as! String
                    model.titleText = (keys[i][1] as! String).localized
                    model.defaultTitleText = (keys[i][2] as! String).localized
                } else {
                    let titleBg = UIImageView(frame: CGRect(x: 16, y: 17, width: 113, height: 31), imageName: "select_options")!
                    titleBg.isUserInteractionEnabled = true
                    titleBg.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(textFieldTap(gestureRecognizer:))))
                    item.addSubview(titleBg)
                    title.frame = CGRect(x: 6, y: 0, width: 88, height: 31)
                    title.adjustsFontSizeToFitWidth = true
                    titleBg.addSubview(title)
                    let paramKey = keys[i][0] as! [String]
                    var subModels = [TestItemModel]()
                    for (index, key) in paramKey.enumerated() {
                        let model = TestItemModel()
                        model.paramKey = key
                        model.titleText = (keys[i][1] as! [String])[index].localized
                        model.defaultTitleText = (keys[i][2] as! [String])[index].localized
                        subModels.append(model)
                    }
                    model.subModels = subModels
                }
                model.title = title
                model.content = textFieldView
                model.type = .text
                model.paramSelectIndex = 0
                objc_setAssociatedObject(item, &kItemModelKey, model, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
        }
    }
    
    private func addBottomSection() {
        bottomSection = UIView(frame: CGRect(x: 0, y: 0, width: XDSize.screenWidth, height: 0))
        addSubview(bottomSection)
        
        let tip = UILabel(frame: CGRect(x: 0, y: 0, width: XDSize.screenWidth, height: 18), text: "test_info_score_tip".localized, textColor: UIColor(0xF6611D), fontSize: 13)!
        tip.textAlignment = .center
        bottomSection.addSubview(tip)
        
        let btnTitle = type == .admission ? "start_test" : "start_smart_college"
        let btn = UIButton(frame: CGRect(x: 20, y: tip.bottom + 24, width: XDSize.screenWidth - 40, height: 42), title: btnTitle.localized, fontSize: 15, titleColor: UIColor.white, target: self, action: #selector(confirmTap(sender:)))!
        btn.setBackgroundColor(XDColor.main, for: .normal)
        btn.layer.cornerRadius = 6
        btn.layer.masksToBounds = true
        bottomSection.addSubview(btn)
        
        bottomSection.addSubview(UIView(frame: CGRect(x: 20, y: btn.bottom + 28, width: XDSize.screenWidth - 40, height: XDSize.unitWidth), color: UIColor(0xCCCCCC)))
        
        testCountLabel = UILabel(frame: CGRect(x: 0, y: btn.bottom + 20, width: 0, height: 18), text: "", textColor: UIColor(0xCCCCCC), fontSize: 12)
        testCountLabel.backgroundColor = UIColor.white
        testCountLabel.textAlignment = .center
        bottomSection.addSubview(testCountLabel)
        
        bottomSection.height = testCountLabel.bottom + 23
    }
    
    func refreshView() {
        // 0:意向国家 1:申请项目 2:当前年级 3:选校倾向 4:在校成绩 5:TOEFL/IELTS成绩 6:SAT/ACT成绩 7:GRE/GMAT成绩
        var section = "00"
        if isUS {
            section = isGraduate ? "01" : "10"
        }
        switch type {
        case .admission:
            typeKeys = "011011" + section
        default:
            typeKeys = "110111" + section
        }
        var height: CGFloat = 0
        for i in 0..<typeKeys.count {
            let item = itemList[i]
            let type = Int(typeKeys.substring(loc: i, len: 1))
            if type == 1 {
                item.isHidden = false
                item.top = height
                let model = objc_getAssociatedObject(item, &kItemModelKey) as! TestItemModel
                refreshItem(model: model)
                height += kItemHeight
            } else {
                item.isHidden = true
            }
        }
        middleSection.height = height
        bottomSection.top = middleSection.bottom + 16
        self.height = bottomSection.bottom
    }
    
    private func refreshItem(model: TestItemModel) {
        if model.type == .selector {
            model.title.text = model.titleText
        } else {
            let content = model.content as! XDTextFieldView
            if model.subModels.count > 0 {
                let subModel = model.subModels[model.paramSelectIndex]
                model.title.text = subModel.titleText
                content.placeholder = subModel.defaultTitleText
                content.textField.isEnabled = model.paramSelectIndex > 0
            } else {
                model.title.text = model.titleText
                content.placeholder = model.defaultTitleText
            }
        }
    }
    
    func fetchTestParams() -> [String : String]? {
        var params = [String : String]()
        var isScore = false
        var invalidKey = ""
        for i in 0..<typeKeys.count {
            let type = Int(typeKeys.substring(loc: i, len: 1))
            guard type != 0 else { continue }
            let item = itemList[i]
            let model = objc_getAssociatedObject(item, &kItemModelKey) as! TestItemModel
            if model.type == .selector {
                if model.paramValue.isEmpty {
                    XDPopView.toast(String(format: "info_empty".localized, model.titleText))
                    return nil
                }
                params[model.paramKey] = model.paramValue
            } else {
                let text = (model.content as! XDTextFieldView).text.trimmingCharacters(in: .whitespaces)
                var paramKey = model.paramKey
                var titleKey = model.titleText
                if model.subModels.count > 0 {
                    paramKey = model.subModels[model.paramSelectIndex].paramKey
                    titleKey = model.subModels[model.paramSelectIndex].titleText
                }
                if text.count > 0 {
                    if i == 4 {
                        // 在校成绩
                        if !isValidScore(text: text, maxScore: 100) {
                            invalidKey = titleKey
                            break
                        }
                    } else {
                        isScore = true
                        // TOEFL/IELTS成绩
                        let index = model.paramSelectIndex - 1
                        var score = Double([120, 9][index])
                        if i == 6 {
                            // SAT/ACT成绩
                            score = Double([1600, 36][index])
                        } else if i == 7 {
                            // GRE/GMAT成绩
                            score = Double([340, 800][index])
                        }
                        
                        if !isValidScore(text: text, maxScore: score) {
                            invalidKey = titleKey
                            break
                        }
                    }
                    params[paramKey] = text
                }
            }
        }
        if !invalidKey.isEmpty {
            XDPopView.toast(String(format: "info_error".localized, invalidKey.localized))
            return nil
        }
        if !isScore {
            XDPopView.toast("test_info_score_empty".localized)
            return nil
        }
        return params
    }
    
    private func isValidScore(text: String, maxScore: Double) -> Bool {
        guard let score = Double(text) else { return false }
        if score > maxScore || score <= 0 { return false }
        let predicate = NSPredicate(format: "SELF MATCHES %@", "^[0-9]+(?:\\.[0-9]+)?$")
        return predicate.evaluate(with: text)
    }
    
    //MARK:- Action
    @objc func selectorTap(gestureRecognizer: UIGestureRecognizer) {
        // 进入选择器时textField失去焦点
        endEditing(true)
        let item = gestureRecognizer.view as! XDItemView
        let model = objc_getAssociatedObject(item, &kItemModelKey) as! TestItemModel
        routerEvent(name: kEventTestInfoSelectorTap, data: ["model":model])
    }
    
    @objc func textFieldTap(gestureRecognizer: UIGestureRecognizer) {
        let view = gestureRecognizer.view
        let item = view?.superview as! XDItemView
        let model = objc_getAssociatedObject(item, &kItemModelKey) as! TestItemModel
        if view is XDTextFieldView {
            if model.subModels.count > 0 && model.paramSelectIndex == 0 {
                textFieldPicker(item)
            }
        } else {
            textFieldPicker(item)
        }
    }
    
    func textFieldPicker(_ item: XDItemView) {
        // textField切换选项时失去焦点
        endEditing(true)
        let model = objc_getAssociatedObject(item, &kItemModelKey) as! TestItemModel
        textFieldItem = item
        
        var arr = [String]()
        for model in model.subModels {
            arr.append(model.titleText)
        }
        
        let pickerView = XDPickerView()
        pickerView.dataList = [arr]
        pickerView.delegate = self
        pickerView.show()
    }
    
    @objc func confirmTap(sender: UIButton) {
        // 提交时textField失去焦点
        endEditing(true)
        routerEvent(name: kEventTestInfoSubmit, data: [:])
    }
    
    //MARK:- XDTextFieldViewDelegate
    func textFieldOnFocus(textField: XDTextFieldView) {
        let item = textField.superview as! XDItemView
        textFieldItem = item
        routerEvent(name: kEventTestInfoTextFieldFocus, data: ["item":textField])
    }
    
    //MARK:- XDPickerViewDelegate
    func pickerSelected(picker: XDPickerView, isConfirm: Bool) {
        if isConfirm, let textFieldItem = textFieldItem {
            let model = objc_getAssociatedObject(textFieldItem, &kItemModelKey) as! TestItemModel
            model.paramSelectIndex = picker.selectedRow(inComponent: 0)
            refreshItem(model: model)
            let content = model.content as! XDTextFieldView
            if model.paramSelectIndex > 0 {
                // textField切换到可输入选项时获取焦点
                content.focus()
            }
            content.text = ""
        }
    }
}
