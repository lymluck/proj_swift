//
//  RankListViewController.swift
//  xxd
//
//  Created by remy on 2018/1/24.
//  Copyright © 2018年 com.smartstudy. All rights reserved.
//

private let kSearchBarHeight: CGFloat = 44

class RankListViewController: SSTableViewController {
    
    var rankCategoryID = 0
    var titleName = ""
    var rankFilterView: RankFilterView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        XDStatistics.click("12_B_rank_school_list")
        canDragRefresh = true
        canDragLoadMore = true
        clearTableViewWhenLoadingNew = true
        minStayOffsetY = kSearchBarHeight
        navigationBar.centerTitle = titleName
        
        let topSearchView = UIView(frame: CGRect(x: 0, y: 0, width: XDSize.screenWidth, height: kSearchBarHeight), color: XDColor.mainBackground)
        let searchBtn = UIButton(frame: CGRect(x: 8, y: 8, width: XDSize.screenWidth - 16, height: 28), title: "search".localized, fontSize: 15, titleColor: XDColor.textPlaceholder, target: self, action: #selector(topSearchTap(sender:)))!
        searchBtn.backgroundColor = UIColor.white
        searchBtn.layer.cornerRadius = 4
        searchBtn.layer.masksToBounds = true
        searchBtn.titleEdgeInsets = UIEdgeInsetsMake(0, 15, 0, 0)
        searchBtn.setImage(UIImage(named: "text_field_search"), for: .normal)
        topSearchView.addSubview(searchBtn)
        
        tableView.tableHeaderView = topSearchView
        tableViewActions.attach(to: RankCollegeItem.self, tap: { (object, target, indexPath) -> Bool in
            if let object = object as? RankCollegeItem, object.model.collegeID > 0 {
                XDStatistics.click("12_A_school_detail_cell")
                let vc = CollegeDetailViewController()
                vc.collegeID = object.model.collegeID
                XDRoute.pushToVC(vc)
            }
            return true
        })
    }
    
    override func createModel() {
        let model = SSURLReqeustModel(httpMethod: .get, urlString: XD_API_COLLEGE_RANKS, loadFromFile: true, isPaged: canDragLoadMore)
        var params: [String : Any] = ["categoryId": rankCategoryID]
        if rankFilterView != nil {
            // 传切换的意向国家
            params["countryId"] = rankFilterView.countryID
        } else {
            // 其他和全球不一样,不能直接用
            if XDUser.shared.userCountryType() != .other {
                // 其他情况传个人意向国家,只影响全球类型排行,不会出现A国家排行显示个人意向B国家排行
                params["countryId"] = XDUser.shared.model.targetCountryId
            }
        }
        model?.parameters = params
        self.model = model
    }
    
    override func didFinishLoad(with object: Any!) {
        if let data = (object as! [String : Any])["data"] as? [String : Any] {
            if rankFilterView == nil {
                if let category = (data["meta"] as? [String : Any])?["category"] as? [String : Any] {
                    if (category["isWorldRank"] as? Bool) ?? false {
                        // 全球排名类型,添加意向国家切换
                        rankFilterView = RankFilterView()
                        rankFilterView.wrap = view
                        navigationBar.rightItem.customView = rankFilterView.filterBtn
                        navigationBar.setNeedsLayout()
                    }
                }
            }
            
            let arr = data["data"] as! [[String : Any]]
            var items = [RankCollegeItem]()
            for dict in arr {
                let item = RankCollegeItem(attributes: dict)!
                items.append(item)
            }
            tableViewModel.addObjects(from: items)
            tableViewModel.hasMore = items.count >= SSConfig.defaultPageSize
        }
    }
    
    override func didShowModel(_ firstTime: Bool) {
        super.didShowModel(firstTime)
        if firstTime {
            if tableView.contentSize.height - tableView.height > kSearchBarHeight {
                tableView.setContentOffset(CGPoint(x: 0, y: kSearchBarHeight), animated: false)
            }
        }
    }
    
    //MARK:- Action
    @objc func topSearchTap(sender: UIButton) {
        let vc = XDSearchViewController(type: .rank)
        vc.extraParams = ["categoryId":rankCategoryID]
        addChildViewController(vc)
        view.addSubview(vc.view)
    }
    
    override func routerEvent(name: String, data: Dictionary<String, Any>) {
        createModel()
    }
    
    //MARK:- UIScrollViewDelegate
    override func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        let contentOffsetY = scrollView.contentOffset.y
        if contentOffsetY < minStayOffsetY && contentOffsetY > 0 {
            let y = contentOffsetY > minStayOffsetY * 0.5 ? minStayOffsetY : 0
            tableView.setContentOffset(CGPoint(x: 0, y: y), animated: true)
        }
    }
}
