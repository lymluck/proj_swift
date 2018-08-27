//
//  TableViewController.swift
//  TSKitDemo
//
//  Created by chenyusen on 2017/9/30.
//  Copyright © 2017年 TechSen. All rights reserved.
//

import UIKit
import DeviceKit

open class TableViewController: BaseViewController {
    
    var tableViewClass: UITableView.Type?
    var tableView: UITableView!
    var tableViewModel: TableViewModel = TableViewModel()
    var tableViewAction: TableViewAction = TableViewAction()
    var autoAdjustiPhoneX = true
    private var tableViewHasAdapteriPhoneX = false
    
    override var topOffset: CGFloat {
        didSet {
            tableView?.frame = UIEdgeInsetsInsetRect(view.bounds, UIEdgeInsetsMake(topOffset, 0, 0, 0))
        }
    }
    
    public var tableViewStyle: UITableViewStyle = .plain
    
    override open func loadView() {
        super.loadView()
        let tableViewClass = self.tableViewClass ?? UITableView.self
        tableView = tableViewClass.init(frame: UIEdgeInsetsInsetRect(view.bounds, UIEdgeInsetsMake(topOffset, 0, 0, 0)), style: tableViewStyle)
       
        tableView.tableFooterView = UIView()
        tableView.backgroundView = nil
        tableView.backgroundColor = .clear
        tableView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
//        tableView.emptyDataSetDelegate = self
//        tableView.emptyDataSetSource = self
        
        if #available(iOS 11.0, *) {
            tableView.contentInsetAdjustmentBehavior = .never
            tableView.estimatedRowHeight = 0
        } else {
            self.automaticallyAdjustsScrollViewInsets = false
        }
        view.addSubview(tableView)
        tableViewAction.delegate = tableViewModel
        tableView.delegate = tableViewAction
        tableView.dataSource = tableViewModel
    }

    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        
        // 对于iPhoneX,底部增加34的inset
        if autoAdjustiPhoneX && UIDevice.isIPhoneX && !tableViewHasAdapteriPhoneX {
            tableView.contentInset = UIEdgeInsetsMake(tableView.contentInset.top, tableView.contentInset.left, tableView.contentInset.bottom + 34, tableView.contentInset.right)
            
            tableView.scrollIndicatorInsets = UIEdgeInsetsMake(tableView.scrollIndicatorInsets.top, tableView.scrollIndicatorInsets.left, tableView.scrollIndicatorInsets.bottom + 34, tableView.scrollIndicatorInsets.right)
            tableViewHasAdapteriPhoneX = true
        }
    }


}

extension TableViewController {
    public func reloadData(_ completion: (() -> Void)? = nil) {
        if let completion = completion {
            tableView.reloadData(completion)
        } else {
            tableView.reloadData()
        }
    }
}

//extension TableViewController: DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {
//    public func image(forEmptyDataSet scrollView: UIScrollView!) -> UIImage! {
//        return DefaultConfig.Image.empty
//    }
//
//    public func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
////        return NSAttributedString(string: DefaultConfig.Text.empty)
//        return NSAttributedString(string: "")
//    }
//}

