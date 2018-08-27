//
//  ProgramViewController.swift
//  xxd
//
//  Created by remy on 2018/1/29.
//  Copyright © 2018年 com.smartstudy. All rights reserved.
//

// 专业推荐院校
class ProgramViewController: SSTableViewController, ProgramCollegeItemDelegate, CollegeTypeSelectorViewDelegate {
    
    var titleName = ""
    var programID = 0
    private var selectedItem: ProgramCollegeItem?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        canDragRefresh = true
        canDragLoadMore = true
        clearTableViewWhenLoadingNew = true
        title = String(format: "program_recommend_college".localized, titleName)
        
        tableViewActions.attach(to: ProgramCollegeItem.self, tap: { (object, target, indexPath) -> Bool in
            if let object = object as? ProgramCollegeItem {
                let vc = CollegeDetailViewController()
                vc.collegeID = object.model.collegeID
                XDRoute.pushToVC(vc)
            }
            return true
        })
    }
    
    override func createModel() {
        let urlStr = String(format: XD_API_PROGRAM_COLLEGE_LIST, programID)
        model = SSURLReqeustModel(httpMethod: .get, urlString: urlStr, loadFromFile: false, isPaged: canDragLoadMore)
    }
    
    override func didFinishLoad(with object: Any!) {
        if let data = (object as! [String : Any])["data"] as? [String : Any] {
            let arr = data["data"] as! [[String : Any]]
            var items = [ProgramCollegeItem]()
            for dict in arr {
                let item = ProgramCollegeItem(attributes: dict)!
                item.delegate = self
                items.append(item)
            }
            tableViewModel.addObjects(from: items)
            tableViewModel.hasMore = items.count >= SSConfig.defaultPageSize
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
    
    //MARK:- CollegeTypeSelectorViewDelegate
    func collegeTypeDidSelected(typeId: String) {
        hideCollegeTypeView()
        if let selectedItem = selectedItem {
            let params: [String : Any] = [
                "schoolId": selectedItem.model.collegeID,
                "matchTypeId": typeId,
                "source": "manual-select"
            ]
            XDPopView.loading()
            SSNetworkManager.shared().post(XD_API_MY_COLLEGE_EDIT, parameters: params, success: {
                [weak self] (task, responseObject) in
                if let strongSelf = self {
                    selectedItem.model.isSelected = true
                    strongSelf.tableView.reloadData()
                }
                XDPopView.toast("add_my_target_success".localized)
            }) { (task, error) in
                XDPopView.toast(error.localizedDescription)
            }
        }
    }
    
    //MARK:- ProgramCollegeItemDelegate
    func programCollegeItemDidSelected(item: ProgramCollegeItem) {
        if XDUser.shared.hasLogin() {
            XDPopView.loading()
            if item.model.isSelected {
                let urlStr = String(format: XD_API_MY_COLLEGE_REMOVE, item.model.collegeID)
                SSNetworkManager.shared().delete(urlStr, parameters: nil, success: {
                    [weak self] (task, responseObject) in
                    if let strongSelf = self {
                        item.model.isSelected = false
                        strongSelf.tableView.reloadData()
                    }
                    XDPopView.toast("remove_my_target_success".localized)
                }) { (task, error) in
                    XDPopView.toast(error.localizedDescription)
                }
            } else {
                selectedItem = item
                showCollegeTypeView()
            }
        } else {
            let vc = SignInViewController()
            presentModalViewController(vc, animated: true, completion: nil)
        }
    }
}
