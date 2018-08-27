//
//  EditInfoView.swift
//  xxd
//
//  Created by remy on 2018/1/5.
//  Copyright © 2018年 com.smartstudy. All rights reserved.
//

protocol EditInfoData {
    func saveEditInfo() -> EditInfoResultModel?
}

class EditInfoTextView: UIView, EditInfoData {
    
    let textFieldView = XDTextFieldView()
    var textMaxCount = 0
    var defaultValue: String = "" {
        willSet {
            textFieldView.text = newValue
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.clear
        textFieldView.frame = CGRect(x: 0, y: 15, width: width, height: 44)
        textFieldView.textColor = XDColor.itemTitle
        textFieldView.fontSize = 16
        textFieldView.placeholder = "input_please".localized
        addSubview(textFieldView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func saveEditInfo() -> EditInfoResultModel? {
        let editText = textFieldView.text.trimmingCharacters(in: .whitespaces)
        if editText.isEmpty {
            XDPopView.toast("user_info_empty".localized)
            return nil
        }
        if textMaxCount > 0 && editText.count > textMaxCount {
            XDPopView.toast("不能超过\(textMaxCount)字")
            return nil
        }
        return EditInfoResultModel.yy_model(with: ["value":editText,"name":editText])
    }
}

class EditInfoListView: UIView, UITableViewDataSource, UITableViewDelegate, EditInfoData {
    
    let tableView = UITableView(frame: .null, style: .plain)
    var isMultipleSelect = false
    var dataList = [EditInfoModel]()
    var defaultValue: String = ""
    var lastIndexPath: IndexPath?
    
    required override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.clear
        tableView.frame = bounds
        tableView.backgroundColor = UIColor.clear
        tableView.separatorStyle = .none
        tableView.register(EditInfoOptionsView.self, forCellReuseIdentifier: EditInfoOptionsView.metaTypeName)
        tableView.register(EditInfoSectionHeader.self, forHeaderFooterViewReuseIdentifier: EditInfoSectionHeader.metaTypeName)
        tableView.rowHeight = 44
        tableView.contentInset = UIEdgeInsetsMake(20, 0, 0, 0)
        tableView.dataSource = self
        tableView.delegate = self
        addSubview(tableView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func saveEditInfo() -> EditInfoResultModel? {
        if isMultipleSelect {
            var values = [String]()
            var names = [String]()
            for i in 0..<tableView.numberOfSections {
                for j in 0..<tableView.numberOfRows(inSection: i) {
                    if let cell = tableView.cellForRow(at: IndexPath(row: j, section: i)) as? EditInfoOptionsView, cell.isOptionSelected {
                        values.append(cell.model.value)
                        names.append(cell.model.name)
                    }
                }
            }
            let model = EditInfoResultModel.yy_model(with: ["value":values.joined(separator: ","),"name":names.joined(separator: ",")])!
            if model.value.isEmpty {
                XDPopView.toast("user_info_at_least_one".localized)
            } else {
                return model
            }
        } else {
            if let lastIndexPath = lastIndexPath {
                let model = modelWithIndexPath(lastIndexPath)
                return EditInfoResultModel.yy_model(with: ["value":model.value,"name":model.name])
            }
        }
        return nil
    }
    
    func modelWithIndexPath(_ indexPath: IndexPath) -> EditInfoModel {
        return dataList[indexPath.row]
    }
    
    //MARK:- UITableViewDataSource
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: EditInfoOptionsView.metaTypeName, for: indexPath) as! EditInfoOptionsView
        let isLastRow = indexPath.row == tableView.numberOfRows(inSection: indexPath.section) - 1
        cell.model = modelWithIndexPath(indexPath)
        cell.topLine.isHidden = indexPath.row > 0
        cell.middleLine.isHidden = isLastRow
        cell.bottomLine.isHidden = !isLastRow
        cell.isOptionSelected = false
        if isMultipleSelect {
            cell.isSingleOption = false
            let defaultValues = defaultValue.components(separatedBy: ",")
            if defaultValues.contains(cell.model.value) {
                cell.isOptionSelected = true
            }
        } else {
            cell.isSingleOption = true
            if cell.model.value == defaultValue {
                cell.isOptionSelected = true
                lastIndexPath = indexPath
            }
        }
        return cell
    }
    
    //MARK:- UITableViewDelegate
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return modelWithIndexPath(indexPath).cellHeight
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if isMultipleSelect {
            if let cell = tableView.cellForRow(at: indexPath) as? EditInfoOptionsView {
                cell.isOptionSelected = !cell.isOptionSelected
            }
        } else {
            if lastIndexPath != indexPath {
                if let lastIndexPath = lastIndexPath, let cell = tableView.cellForRow(at: lastIndexPath) as? EditInfoOptionsView {
                    cell.isOptionSelected = false
                }
                if let cell = tableView.cellForRow(at: indexPath) as? EditInfoOptionsView {
                    cell.isOptionSelected = true
                    lastIndexPath = indexPath
                    if let model = saveEditInfo() {
                        self.routerEvent(name: "", data: ["model":model])
                    }
                }
            }
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

class EditInfoMultipleListView: EditInfoListView {

    required init(frame: CGRect) {
        super.init(frame: frame)
        tableView.contentInset = .zero
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func modelWithIndexPath(_ indexPath: IndexPath) -> EditInfoModel {
        return dataList[indexPath.section].subModels[indexPath.row]
    }
    
    //MARK:- UITableViewDataSource
    override func numberOfSections(in tableView: UITableView) -> Int {
        return dataList.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataList[section].subModels.count
    }
    
    //MARK:- UITableViewDelegate
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 48
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let sectionHeader = tableView.dequeueReusableHeaderFooterView(withIdentifier: EditInfoSectionHeader.metaTypeName) as! EditInfoSectionHeader
        sectionHeader.model = dataList[section]
        return sectionHeader
    }
}
