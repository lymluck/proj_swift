//
//  TargetCollegeOthersViewController.swift
//  xxd
//
//  Created by Lisen on 2018/6/4.
//  Copyright © 2018年 com.smartstudy. All rights reserved.
//

import UIKit

class TargetCollegeOthersViewController: SSTableViewController {
    
    var collegeId: Int = 0
    private var isNoData: Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "他们选择了该校"
        canDragRefresh = true
        canDragLoadMore = true
        
        tableViewActions.attach(to: TargetCollegeStatUserCellItem.self, tap: { (object, target, indexPath) -> Bool in
            if let item = object as? TargetCollegeStatUserCellItem {
                if XDUser.shared.model.isPrivacy {
                    XDPopView.toast("要查看别人的选校，需要先设置自己的选校可见", self.view)                    
                } else {
                    let vc = TargetCollegeOtherDetailViewController()
                    vc.userId = item.model.userId
                    vc.userName = item.model.name
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }
            return true
        })
    }
    
    override func createModel() {
        let urlString = String(format: XD_TARGET_COLLEGE_OTHERS, collegeId)
        let model = SSURLReqeustModel(httpMethod: .get, urlString: urlString, loadFromFile: false, isPaged: true)
        self.model = model
    }
    
    override func didFinishLoad(with object: Any!) {
        if let responseObject = (object as! [String: Any])["data"] as? [String: Any], let serverDatas = responseObject["data"] as? [[String: Any]] {
            var cellItems: [TargetCollegeStatUserCellItem] = []
            for data in serverDatas {
                let item: TargetCollegeStatUserCellItem = TargetCollegeStatUserCellItem(attributes: data)
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
