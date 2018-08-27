//
//  CollegeViewController.swift
//  xxd
//
//  Created by remy on 2018/2/2.
//  Copyright © 2018年 com.smartstudy. All rights reserved.
//

private let PREFIX_ID = "COUNTRY_"

class CollegeViewController: SSTableViewController {
    
    private var filterView: CollegeFilterView!
    private var _countryID = ""
    private var countryID: String {
        get {
            return _countryID
        }
        set {
            _countryID = newValue
            if !newValue.hasPrefix(PREFIX_ID) && !newValue.isEmpty {
                _countryID = PREFIX_ID + newValue
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        XDStatistics.click("9_B_school_list")
        canDragRefresh = true
        canDragLoadMore = true
        clearTableViewWhenLoadingNew = true
        title = "title_college".localized
        
        filterView = CollegeFilterView()
        let model = CollegeQueryModel()
        // 其他和全球不一样,不能直接用
        if XDUser.shared.userCountryType() != .other {
            // 如果有意向国家,默认选择用户意向国家
            countryID = XDUser.shared.model.targetCountryId
        }
        model.countryID = countryID
        model.localRank = ""
        filterView.model = model
        view.insertSubview(filterView, aboveSubview: tableView)
        
        tableView.frame = CGRect(x: 0, y: filterView.bottom, width: view.width, height: view.height - filterView.bottom)
        tableViewActions.attach(to: CollegeItem.self, tap: { (object, target, indexPath) -> Bool in
            if let object = object as? CollegeItem {
                XDStatistics.click("9_A_school_detail_cell")
                let vc = CollegeDetailViewController()
                vc.collegeID = object.model.collegeID
                XDRoute.pushToVC(vc)
            }
            return true
        })
    }
    
    override func createModel() {
        if let model = SSURLReqeustModel(httpMethod: .get, urlString: XD_API_COLLEGE_LIST, loadFromFile: false, isPaged: canDragLoadMore) {
            var params = [String : String]()
            if !filterView.model.countryID.isEmpty {
                params["countryId"] = filterView.model.countryID
            }
            if !filterView.model.localRank.isEmpty {
                params["localRank"] = filterView.model.localRank
            }
            if !filterView.model.scoreToefl.isEmpty {
                params["scoreToefl"] = filterView.model.scoreToefl
            }
            if !filterView.model.scoreIelts.isEmpty {
                params["scoreIelts"] = filterView.model.scoreIelts
            }
            if !filterView.model.feeTotal.isEmpty {
                params["feeTotal"] = filterView.model.feeTotal
            }
            model.parameters = params
            self.model = model
            tableView.ss_scrollToTop(animated: false)
        }
    }
    
    override func didFinishLoad(with object: Any!) {
        if let data = (object as! [String : Any])["data"] as? [String : Any] {
            if let arr = data["data"] as? [[String : Any]] {
                var items = [CollegeItem]()
                for dict in arr {
                    let item = CollegeItem(attributes: dict)!
                    items.append(item)
                }
                tableViewModel.addObjects(from: items)
                tableViewModel.hasMore = items.count >= SSConfig.defaultPageSize
            }
        }
    }
    
    override func showEmpty(_ show: Bool) {
        super.showEmpty(show)
        if show {
            view.bringSubview(toFront: filterView)
        }
    }
    
    //MARK:- Action
    override func routerEvent(name: String, data: Dictionary<String, Any>) {
        createModel()
    }
}
