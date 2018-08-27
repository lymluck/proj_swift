//
//  MasterMajorCollegeRankViewController.swift
//  xxd
//
//  Created by Lisen on 2018/7/11.
//  Copyright © 2018年 com.smartstudy. All rights reserved.
//

import UIKit

/// 研究生某个专业的院校排名
class MasterMajorCollegeRankViewController: SSTableViewController {
    
    var rankName: String = ""
    var categoryId: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = rankName
        canDragRefresh = true
        canDragLoadMore = true
        tableViewActions.attach(to: MasterMajorCollegeItem.self, tap: { (object, target, indexPath) -> Bool in
            if let item = object as? MasterMajorCollegeItem {
                let detailVC: MasterMajorProjectDetailViewController = MasterMajorProjectDetailViewController()
                detailVC.programId = item.model.majorId
                self.navigationController?.pushViewController(detailVC, animated: true)
            }
            return true
        })
    }
    
    override func createModel() {
        let model = SSURLReqeustModel(httpMethod: .get, urlString: XD_MASTER_PROGRAM_LIST, loadFromFile: false, isPaged: true)
        model?.parameters = ["categoryId": categoryId]
        self.model = model
    }
    
    override func didFinishLoad(with object: Any!) {
        if let responseObject = object as? [String: Any], let responseData = responseObject["data"] as? [String: Any], let rankData = responseData["data"] as? [[String: Any]] {
            var items: [MasterMajorCollegeItem] = [MasterMajorCollegeItem]()
            for data in rankData {
                let item: MasterMajorCollegeItem = MasterMajorCollegeItem(attributes: data)
                items.append(item)
            }
            tableViewModel.addObjects(from: items)
            tableViewModel.hasMore = (items.count>=SSConfig.defaultPageSize)
        }
    }
    
    override func showEmpty(_ show: Bool) {
        super.showEmpty(false)
    }
    
}
