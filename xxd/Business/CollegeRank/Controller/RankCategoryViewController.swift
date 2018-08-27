//
//  RankCategoryViewController.swift
//  xxd
//
//  Created by remy on 2018/4/18.
//  Copyright © 2018年 com.smartstudy. All rights reserved.
//

class RankCategoryViewController: SSTableViewController {

    var titleName = ""
    var dataList = [[String : Any]]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = titleName
        
        var items = [RankCategoryItem]()
        for data in dataList {
            let item = RankCategoryItem(attributes: data)!
            items.append(item)
        }
        tableViewModel.addObjects(from: items)
        
        tableViewActions.attach(to: RankCategoryItem.self, tap: { (object, target, indexPath) -> Bool in
            if let object = object as? RankCategoryItem {
                let vc = RankListViewController()
                vc.rankCategoryID = object.model.categoryID
                vc.titleName = object.model.pureName
                XDRoute.pushToVC(vc)
            }
            return true
        })
    }
}
