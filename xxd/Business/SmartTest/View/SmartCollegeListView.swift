//
//  SmartCollegeListView.swift
//  xxd
//
//  Created by remy on 2018/2/8.
//  Copyright © 2018年 com.smartstudy. All rights reserved.
//

private let kCellHeight: CGFloat = 110
private let kScetionHeaderHeight: CGFloat = 48

protocol SmartCollegeListViewDelegate: class {
    
    func didSelectItem(model: SmartCollegeModel)
    func didEditMyTarget(model: SmartCollegeModel)
}

class SmartCollegeListView: UIView, UITableViewDataSource, UITableViewDelegate {
    
    weak var delegate: SmartCollegeListViewDelegate?
    var tableView: UITableView!
    var selectedModel: SmartCollegeModel!
    var dataList = [[SmartCollegeModel]]() {
        didSet {
            var height: CGFloat = 0
            let _ = dataList.map {
                height += 48 + CGFloat($0.count * 110)
            }
            tableView.height = height
        }
    }
    
    convenience init() {
        self.init(frame: .zero)
        self.backgroundColor = UIColor.clear
        tableView = UITableView(frame: CGRect(x: 0, y: 0, width: XDSize.screenWidth, height: 0), style: .plain)
        tableView.backgroundColor = XDColor.mainBackground
        tableView.separatorStyle = .none
        tableView.rowHeight = kCellHeight
        tableView.dataSource = self
        tableView.delegate = self
        tableView.isScrollEnabled = false
        tableView.register(SmartCollegeListCellView.self, forCellReuseIdentifier: SmartCollegeListCellView.metaTypeName)
        addSubview(tableView)
        
        let tip = UILabel(text: "test_disclaimer".localized, textColor: XDColor.itemText, fontSize: 13)!
        addSubview(tip)
        tip.numberOfLines = 3
        tip.snp.makeConstraints({ (make) in
            make.top.equalTo(tableView.snp.bottom).offset(16)
            make.left.equalTo(self).offset(16)
            make.right.equalTo(self).offset(-16)
            make.bottom.equalTo(self).offset(-24)
        })
    }
    
    func showGuideView() {
        let view = UIView(frame: UIScreen.main.bounds)
        
        let hideBtn = UIButton(frame: CGRect(x: (XDSize.screenWidth - 227) * 0.5, y: XDSize.screenHeight - 118, width: 227, height: 40), title: "known".localized, fontSize: 15, titleColor: UIColor.white, target: self, action: #selector(hideGuideView))!
        hideBtn.layer.cornerRadius = 20
        hideBtn.layer.borderWidth = 1
        hideBtn.layer.borderColor = UIColor.white.cgColor
        view.addSubview(hideBtn)
        
        let btnImage = UIImageView(frame: CGRect(x: XDSize.screenWidth - 50, y: 147, width: 40, height: 40), imageName: "add_my_target")!
        btnImage.backgroundColor = UIColor.white
        btnImage.layer.cornerRadius = 20
        btnImage.contentMode = .center
        view.addSubview(btnImage)
        
        let descImage = UIImageView(frame: CGRect(x: XDSize.screenWidth - 261, y: 185, width: 248, height: 55), imageName: "smart_guide_desc")!
        view.addSubview(descImage)
        
        XDPopView.topView(view: view, isMaskHide: false, alpha: 0.7)
    }
    
    @objc func hideGuideView() {
        XDPopView.hideTopView()
        Preference.SMART_COLLEGE_GUIDE.set(true)
    }
    
    //MARK:- Action
    @objc func selectItem(gestureRecognizer: UIGestureRecognizer) {
        let section = gestureRecognizer.view!.tag / 100
        let row = gestureRecognizer.view!.tag % 100
        let model = dataList[section][row]
        selectedModel = model
        delegate?.didSelectItem(model: model)
    }
    
    @objc func addMyTarget(gestureRecognizer: UIGestureRecognizer) {
        let section = gestureRecognizer.view!.tag / 100
        let row = gestureRecognizer.view!.tag % 100
        let model = dataList[section][row]
        delegate?.didEditMyTarget(model: model)
    }
    
    //MARK:- UITableViewDataSource
    func numberOfSections(in tableView: UITableView) -> Int {
        return dataList.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataList[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: SmartCollegeListCellView.metaTypeName, for: indexPath) as! SmartCollegeListCellView
        cell.model = dataList[indexPath.section][indexPath.row]
        cell.stageView.tag = indexPath.section * 100 + indexPath.row
        cell.addToMyTarget.tag = indexPath.section * 100 + indexPath.row
        if (cell.stageView.gestureRecognizers?.count ?? 0) == 0 {
            cell.stageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(selectItem(gestureRecognizer:))))
            cell.addToMyTarget.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(addMyTarget(gestureRecognizer:))))
        }
        return cell
    }
    
    //MARK:- UITableViewDelegate
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return dataList[section].count > 0 ? kScetionHeaderHeight : 0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard dataList[section].count > 0 else { return nil }
        var imageName = "smart_college_top"
        if section == 1 {
            imageName = "smart_college_middle"
        } else if section == 2 {
            imageName = "smart_college_bottom"
        }
        let view = UIImageView(frame: CGRect(x: 0, y: 0, width: XDSize.screenWidth, height: kScetionHeaderHeight), imageName: imageName)!
        view.contentMode = .left
        return view
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {}
}
