//
//  XDPickerView.swift
//  xxd
//
//  Created by remy on 2018/1/31.
//  Copyright © 2018年 com.smartstudy. All rights reserved.
//

private let kViewHeight: CGFloat = 244
private let kPickerHeight: CGFloat = 200
private let kPickerBtnHeight: CGFloat = 44
private let kPickerSelectHeight: CGFloat = 40
private let kTitleDefaultText = "请选择"

protocol XDPickerViewDelegate: class {
    
    func pickerSelected(picker: XDPickerView, isConfirm: Bool)
}

class XDPickerView: UIView, UIPickerViewDataSource, UIPickerViewDelegate {
    
    private var kPickerWidth = XDSize.screenWidth
    private var picker: UIPickerView!
    private var title: UILabel!
    weak var delegate: XDPickerViewDelegate?
    var dataList = [[String]]() {
        didSet {
            kPickerWidth = (XDSize.screenWidth / CGFloat(dataList.count)).rounded()
            picker.reloadAllComponents()
        }
    }
    
    convenience init() {
        self.init(frame: CGRect(x: 0, y: XDSize.screenHeight - kViewHeight, width: XDSize.screenWidth, height: kViewHeight))
        backgroundColor = UIColor.white
        
        picker = UIPickerView(frame: CGRect(x: 0, y: kPickerBtnHeight, width: width, height: kPickerHeight))
        picker.showsSelectionIndicator = true
        picker.dataSource = self
        picker.delegate = self
        addSubview(picker)
        
        title = UILabel(frame: CGRect(x: 80, y: 0, width: width - 160, height: kPickerBtnHeight), text: kTitleDefaultText, textColor: XDColor.itemTitle, fontSize: 18)
        title.textAlignment = .center
        addSubview(title)
        
        let cancelBtn = UIButton(frame: CGRect(x: 16, y: 0, width: 80, height: kPickerBtnHeight), title: "cancel".localized, fontSize: 16, titleColor: XDColor.itemText, target: self, action: #selector(pickerCancelTap(sender:)))!
        cancelBtn.contentHorizontalAlignment = .left
        addSubview(cancelBtn)
    
        let confirmBtn = UIButton(frame: CGRect(x: width - 96, y: 0, width: 80, height: kPickerBtnHeight), title: "confirm".localized, fontSize: 16, titleColor: XDColor.main, target: self, action: #selector(pickerConfirmTap(sender:)))!
        confirmBtn.contentHorizontalAlignment = .right
        addSubview(confirmBtn)
        
        addSubview(UIView(frame: CGRect(x: 0, y: 0, width: width, height: XDSize.unitWidth), color: XDColor.itemLine))
        addSubview(UIView(frame: CGRect(x: 0, y: kPickerBtnHeight - XDSize.unitWidth, width: width, height: XDSize.unitWidth), color: XDColor.itemLine))
    }
    
    func show() {
        XDPopView.topView(view: self, isMaskHide: true, alpha: 0.4)
    }
    
    func selectedRow(inComponent: Int) -> Int {
        return picker.selectedRow(inComponent: inComponent)
    }
    
    func selectedValue(inComponent: Int) -> String {
        let row = picker.selectedRow(inComponent: inComponent)
        return dataList[inComponent][row]
    }
    
    //MARK:- Action
    @objc func pickerConfirmTap(sender: UIButton) {
        delegate?.pickerSelected(picker: self, isConfirm: true)
        XDPopView.hideTopView()
    }
    
    @objc func pickerCancelTap(sender: UIButton) {
        delegate?.pickerSelected(picker: self, isConfirm: false)
        XDPopView.hideTopView()
    }
    
    //MARK:- UIPickerViewDataSource
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return dataList.count
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return dataList[component].count
    }
    
    //MARK:- UIPickerViewDelegate
    func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        return kPickerWidth
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return kPickerSelectHeight
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return dataList[component][row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {}
}
