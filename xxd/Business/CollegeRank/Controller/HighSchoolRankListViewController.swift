//
//  HighSchoolRankListViewController.swift
//  xxd
//
//  Created by Lisen on 2018/4/4.
//  Copyright © 2018年 com.smartstudy. All rights reserved.
//

import UIKit

class HighSchoolRankListViewController: SSTableViewController {

    // MARK: properties
    var categoryID: Int = -1
    var rankTitle: String = ""
    private var isNoData: Bool = true
    
    // MARK: life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = rankTitle
        canDragRefresh = true
        canDragLoadMore = true
        
        tableView.showsVerticalScrollIndicator = false
        tableViewActions.attach(to: HighSchoolRankItem.self, tap: { (object, target, indexPath) -> Bool in
            if let item = object as? HighSchoolRankItem {
                let detailVC: HighschoolDetailViewController = HighschoolDetailViewController()
                detailVC.highschoolID = item.model.schoolId
                XDRoute.pushToVC(detailVC)
            }
            return true
        })
    }
    
    override func createModel() {
        if categoryID != -1 {
            let urlString = String(format: XD_HSAPI_SPEC_RANK_LIST, categoryID)
            let model = SSURLReqeustModel(httpMethod: .get, urlString: urlString, loadFromFile: false, isPaged: true)
            self.model = model
        }
    }
    
    override func didFinishLoad(with object: Any!) {
        let response = (object as! [String: Any])
        if let responseData = response["data"] as? [String: Any], let rData = responseData["data"] as? [[String: Any]] {
            var models: [HighSchoolRankItem] = [HighSchoolRankItem]()
            for data in rData {
                let item: HighSchoolRankItem = HighSchoolRankItem(attributes: data)
                models.append(item)
            }
            tableViewModel.addObjects(from: models)
            tableViewModel.hasMore = models.count >= SSConfig.defaultPageSize
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
