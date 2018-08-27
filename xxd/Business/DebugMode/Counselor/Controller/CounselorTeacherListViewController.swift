//
//  CounselorTeacherListViewController.swift
//  xxd
//
//  Created by chenyusen on 2018/3/2.
//  Copyright © 2018年 com.smartstudy. All rights reserved.
//

import UIKit
import SwiftyJSON

class CounselorTeacherListViewController: SSTableViewController {

    override init!(query: [AnyHashable : Any]!) {
        super.init(query: query)
        
        canDragLoadMore = true
        canDragRefresh = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationBar.isHidden = true
        tableView.frame = view.bounds
        tableView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        tableView.rowHeight = 126
       
        
        
//        tableViewActions.attach(to: TeacherListItem.self) { (cellItem, _, _) -> Bool in
//            print("hehe")
//            return true
//        }
        tableViewActions.attach(to: TeacherListItem.self, tap: { [weak self] (object, target, indexPath) -> Bool in
            guard CounselorIM.shared.connectionStatus == .connected else { return false }
            if let cellItem = object as? TeacherListItem {
                self?.navigationController?.pushViewController(ChatViewController(query: [IMUserID: cellItem.model.imUserId]), animated: true)
                
            }
            
            return true
        })
        
        
        if UIDevice.isIPhoneX {
            tableView.contentInset = UIEdgeInsetsMake(tableView.contentInset.top, tableView.contentInset.left, tableView.contentInset.bottom + 34, tableView.contentInset.right)
            
            tableView.scrollIndicatorInsets = tableView.contentInset
        }
        
        createModel()
    }
    
    
    override func createModel() {
        model = SSURLReqeustModel(httpMethod: .get,
                                  urlString: XD_IM_TEACHER_LIST,
                                  loadFromFile: false,
                                  isPaged: true)
    }
    
    override func didFinishLoad(with object: Any!) {
        if let data = (object as? [String : Any])!["data"] as? [String : Any] {
            
            let models = (NSArray.yy_modelArray(with: TeacherListModel.self, json: data["data"]!) as? [TeacherListModel])!
            let teacherListItems: [TeacherListItem] = models.map { model in
                let item = TeacherListItem()!
                item.model = model
                return item
            }
            tableViewModel.addObjects(from: teacherListItems)
            tableViewModel.hasMore = teacherListItems.count >= SSConfig.defaultPageSize
        }
    }
    
    override func showEmpty(_ show: Bool) {
        
    }
    
    override func showError(_ show: Bool) {
        
    }
}
