//
//  HistoryCollegeViewController.swift
//  xxd
//
//  Created by Lisen on 2018/6/11.
//  Copyright © 2018年 com.smartstudy. All rights reserved.
//

import UIKit

class HistoryCollegeViewController: SSTableViewController {
    
    var sections = [NITableViewModelSection]()
    private var lastGroupName: String = ""
    private var isNoData: Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "看过的学校"
        canDragLoadMore = true
        tableView.showsVerticalScrollIndicator = false
        tableViewActions.attach(to: HistoryCollegeItem.self, tap: { (object, target, indexPath) -> Bool in
            if let item = object as? HistoryCollegeItem {
                let vc = CollegeDetailViewController()
                vc.collegeID = item.model.collegeID
                XDRoute.pushToVC(vc)
            }
            return true
        })
    }
    
    override func createModel() {
        let model = SSURLReqeustModel(httpMethod: .get, urlString: XD_API_INDEX_COLLEGE_HISTORY, loadFromFile: false, isPaged: true)
        self.model = model
    }
    
    override func didFinishLoad(with object: Any!) {
        if let responseData = object as? [String: Any], let serverData = responseData["data"] as? [String: Any], let data = serverData["data"] as? [[String: Any]], data.count > 0 {
            var cellItems = [HistoryCollegeItem]()
            for dict in data {
                let item: HistoryCollegeItem = HistoryCollegeItem(attributes: dict)
                if let groupName = dict["groupName"] as? String, lastGroupName != groupName {
                    item.isHeaderVisible = true
                    item.groupName = groupName
                    lastGroupName = groupName
                } else {
                    item.isHeaderVisible = false
                }
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
