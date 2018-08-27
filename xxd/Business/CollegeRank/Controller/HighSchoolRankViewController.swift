//
//  HighSchoolRankViewController.swift
//  xxd
//
//  Created by Lisen on 2018/4/4.
//  Copyright © 2018年 com.smartstudy. All rights reserved.
//

import UIKit

// MARK: 美高排名分类
class HighSchoolRankViewController: SSTableViewController {
    // MARK: properties
    
    // MARK: life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initContentViews()
    }
    
    override func createModel() {
        let model = SSURLReqeustModel(httpMethod: .get, urlString: XD_HSAPI_RANK_CATEGORIES, loadFromFile: false, isPaged: false)
        self.model = model
    }
    
    override func didFinishLoad(with object: Any!) {
        let response = (object as! [String: Any])
        if let responseData = response["data"] as? [String: Any], let rData = responseData["data"] as? [[String: Any]] {
            var models: [HighSchoolCategoryItem] = [HighSchoolCategoryItem]()
            for data in rData {
                let item: HighSchoolCategoryItem = HighSchoolCategoryItem(attributes: data)
                models.append(item)
            }
            tableViewModel.addObjects(from: models)
            tableViewModel.hasMore = models.count >= SSConfig.defaultPageSize
        }
    }
    
    // MARK: event response
    
    // MARK: public methods
    
    // MARK: private methods
    private func initContentViews() {
        title = "title_highSchool_rank".localized
        canDragRefresh = true
        tableViewActions.attach(to: HighSchoolCategoryItem.self, tap: { (object, target, indexPath) -> Bool in
            if let item = object as? HighSchoolCategoryItem {
                let rankListVC: HighSchoolRankListViewController = HighSchoolRankListViewController()
                rankListVC.categoryID = item.model.categoryId
                rankListVC.rankTitle = item.model.pureName
                XDRoute.pushToVC(rankListVC)
            }            
            return true
        })
    }
}
