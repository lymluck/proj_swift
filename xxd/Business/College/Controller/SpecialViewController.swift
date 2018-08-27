//
//  SpecialViewController.swift
//  xxd
//
//  Created by remy on 2018/2/22.
//  Copyright © 2018年 com.smartstudy. All rights reserved.
//

// 专题中心
class SpecialViewController: SSTableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        XDStatistics.click("14_B_subject_list")
        canDragLoadMore = true
        title = "special_title".localized
        navigationBar.bottomLine.isHidden = true
        view.backgroundColor = UIColor.white
        
        tableViewActions.attach(to: SpecialItem.self, tap: { (object, target, indexPath) -> Bool in
            if let object = object as? SpecialItem {
                XDStatistics.click("14_A_subject_cell")
                XDRoute.pushWebVC([QueryKey.URLPath: object.model.specialURL])
            }
            return true
        })
    }
    
    override func createModel() {
        model = SSURLReqeustModel(httpMethod: .get, urlString: XD_API_SPECIAL_LIST, loadFromFile: false, isPaged: true)
    }
    
    override func didFinishLoad(with object: Any!) {
        if let data = (object as! [String : Any])["data"] as? [String : Any] {
            let arr = data["data"] as! [[String : Any]]
            var items = [SpecialItem]()
            for dict in arr {
                let item = SpecialItem(attributes: dict)!
                items.append(item)
            }
            tableViewModel.addObjects(from: items)
            tableViewModel.hasMore = items.count >= SSConfig.defaultPageSize
        }
    }
}
