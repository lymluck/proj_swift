//
//  TeacherReportViewController.swift
//  xxd
//
//  Created by chenyusen on 2018/3/9.
//  Copyright © 2018年 com.smartstudy. All rights reserved.
//

import UIKit
import SwiftyJSON

class TeacherReportViewController: TableViewController {
    
    var rightButtonItem: NavigationBarButtonItem!
    var selectedCellItem: TeacherReportCellItem? {
        didSet {
            oldValue?.isSelected = false
            selectedCellItem?.isSelected = true
            rightButtonItem.enable = selectedCellItem != nil
        }
    }
    
    var userId: String!
    

    override init(query: [String : Any]?) {
        super.init(query: query)
        
        userId = query?[IMUserID] as? String
        assert(userId != nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        title = "举报原因"
        
        rightButtonItem = NavigationBarButtonItem(title: "提交",
                                                  target: self,
                                                  action: #selector(submitButtonPressed))
        rightButtonItem.enable = false
        navigationBar?.rightButtonItems = [rightButtonItem]
        
        
        
//        let cellItems: [TeacherReportCellItem] = reportTypes.map {
//            let cellItem = TeacherReportCellItem()
//            cellItem.title = $0
//            return cellItem
//        }
        
        tableView.separatorColor = UIColor(0xe4e5e6)
//        tableView.reloadData()
        
        tableViewAction.tap(to: TeacherReportCellItem.self) { [weak self] (cellItem, _) -> (Bool) in
            if let cellItem = cellItem as? TeacherReportCellItem {
                self?.selectedCellItem = cellItem
            }
            return true
        }
        
        SSNetworkManager.shared().get(XD_FETCH_REPORT_REASONS,
                                      parameters: nil,
                                      success: { [weak self] (_, response) in
                                        if let response = response {
                                            let json = JSON(response)
                                            self?.createCellItems(json: json["data"])
                                        }
                                        
                                        
        }) { (_, error) in
            SSLog(error.localizedDescription)
        }
        
    }

    
    
    @objc func submitButtonPressed() {
        
        SSNetworkManager.shared().post(XD_SUBMIT_REPORT, parameters: ["targetId": userId, "reasonId": selectedCellItem!.id], success: { [weak self] (_, response) in
            XDPopView.toast("您的举报已提交,我们将会尽快处理")
                        delay(2, task: {
                            self?.navigationController?.popViewController(animated: true)
                        })
        }) { (_, error) in
            SSLog(error.localizedDescription)
        }
        
        
//        SSNetworkManager.shared().post(XD_SUBMIT_REPORT,
//                                       parameters: ["targetId": userId, "resonId": selectedCellItem!.id],
//                                       XDPopView.toast("您的举报已提交,我们将会尽快处理")
//            delay(2, task: {
//                self?.navigationController?.popViewController(animated: true)
//            })
//
//        )
    }
    
    private func createCellItems(json: JSON) {
        
        let cellItems: [TeacherReportCellItem] = json.arrayValue.map { ajson in
            let cellItem = TeacherReportCellItem()
            cellItem.title = ajson["name"].stringValue
            cellItem.id = ajson["id"].stringValue
            return cellItem
        }
        tableViewModel.add(cellItems)
        tableView.reloadData()
    }
}
