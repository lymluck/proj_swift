//
//  CollegeHotRankViewController.swift
//  xxd
//
//  Created by Lisen on 2018/6/12.
//  Copyright © 2018年 com.smartstudy. All rights reserved.
//

import UIKit


class CollegeHotRankViewController: SSTableViewController {
    
    // 区分是浏览热度还是选择热度
    var categoryType: CollegeCategoryType = .viewed
    // 区分哪个国家的排名
    var countryId: String = ""
    private var isNoData: Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        canDragLoadMore = true
        tableView.showsVerticalScrollIndicator = false
        tableViewActions.attach(to: CollegeItem.self, tap: { (object, target, indexPath) -> Bool in
            if let item = object as? CollegeItem {
                let vc = CollegeDetailViewController()
                vc.collegeID = item.model.collegeID
                XDRoute.pushToVC(vc)
            }
            return true
        })
    }
   
    override func needNavigationBar() -> Bool {
        return false
    }
    
    override func createModel() {
        let model = SSURLReqeustModel(httpMethod: .get, urlString: XD_API_COLLEGE_LIST, loadFromFile: false, isPaged: true)
        let params: [String: Any] = ["order": categoryType.rawValue, "withOrderRank": true, "simple": true, "countryId": countryId]
        model?.parameters = params
        self.model = model
    }
    
    override func didFinishLoad(with object: Any!) {
        if let responseObject = object as? [String: Any], let responseData = responseObject["data"] as? [String: Any], let serverData = responseData["data"] as? [[String: Any]], serverData.count > 0 {
            var cellItems: [CollegeItem] = []
            for data in serverData {
                let item: CollegeItem = CollegeItem(attributes: data)
                item.isRankHidden = false
                item.rankBackgroundColor = categoryType.attributedColor
                cellItems.append(item)
            }
            tableViewModel.addObjects(from: cellItems)
            tableViewModel.hasMore = cellItems.count >= SSConfig.defaultPageSize
            isNoData = false
        } else {
            isNoData = true
        }
    }
    
    override func showEmpty(_ show: Bool) {
        if show && !isNoData {
            super.showEmpty(false)
        } else {
            super.showEmpty(show)
        }
    }
    
}
