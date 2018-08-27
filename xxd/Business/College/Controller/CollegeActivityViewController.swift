//
//  CollegeActivityViewController.swift
//  xxd
//
//  Created by Lisen on 2018/6/28.
//  Copyright © 2018年 com.smartstudy. All rights reserved.
//

import UIKit

/// 院校活动列表
class CollegeActivityViewController: SSTableViewController {
    
    var majorName: String = "工科"
    private var isNoData = true
    override func viewDidLoad() {
        super.viewDidLoad()
        initContentViews()
    }
    
    override func needNavigationBar() -> Bool {
        return false
    }
    
    override func createModel() {
        let model = SSURLReqeustModel(httpMethod: .get, urlString: XD_API_ACTIVITY_LIST, loadFromFile: false, isPaged: true)
        model?.parameters = ["major": majorName]
        self.model = model
    }
    
    override func didFinishLoad(with object: Any!) {
        if let responseObject = object as? [String: Any], let responseData = responseObject["data"] as? [String: Any], let serverData = responseData["data"] as? [[String: Any]] {
            var cellItems: [CollegeActivityItem] = []
            for data in serverData {
                let item: CollegeActivityItem = CollegeActivityItem(attributes: data)
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
    
    private func initContentViews() {
        canDragRefresh = true
        canDragLoadMore = true
        tableViewActions.attach(to: CollegeActivityItem.self, tap: { (object, indexPath, target) -> Bool in
            if let item = object as? CollegeActivityItem {
                let vc: CollegeActivityDetailViewController = CollegeActivityDetailViewController()
                vc.activityId = item.model.activityId
                self.navigationController?.pushViewController(vc, animated: true)
            }
            return true
        })
    }
    
}
