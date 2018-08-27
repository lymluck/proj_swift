//
//  ColumnListViewController.swift
//  xxd
//
//  Created by Lisen on 2018/7/17.
//  Copyright © 2018年 com.smartstudy. All rights reserved.
//

import UIKit

/// 专栏列表
class ColumnListViewController: SSTableViewController {
    
    private var isNoData: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        canDragRefresh = true
        canDragLoadMore = true
        title = "专栏"
    }
    
    override func createModel() {
        model = SSURLReqeustModel(httpMethod: .get, urlString: XD_COLUMN_LIST, loadFromFile: false, isPaged: true)
    }
    
    override func didFinishLoad(with object: Any!) {
        if let responseObject = object as? [String: Any], let responseData = responseObject["data"] as? [String: Any], let pageDatas = responseData["data"] as? [[String: Any]], pageDatas.count > 0  {
            var cellItems: [ColumnItem] = []
            for data in pageDatas {
                let item: ColumnItem = ColumnItem(attributes: data)
                cellItems.append(item)
            }
            isNoData = false
            tableViewModel.addObjects(from: cellItems)
            tableViewModel.hasMore = (cellItems.count>=SSConfig.defaultPageSize)
        } else {
            isNoData = true
        }
    }
    
    override func showEmpty(_ show: Bool) {
        if show && !isNoData {
            super.showEmpty(false)
        } else {
            super.showEmpty(true)
        }
    }
}
