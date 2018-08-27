//
//  MessageCenterViewController.swift
//  xxd
//
//  Created by remy on 2018/1/12.
//  Copyright © 2018年 com.smartstudy. All rights reserved.
//

class MessageCenterViewController: SSTableViewController {
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        clearBadge()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        canDragRefresh = true
        isDragRefreshForMore = true
        title = "message_center_title".localized
        view.backgroundColor = XDColor.mainBackground
        tableView.contentInset = UIEdgeInsetsMake(0, 0, 22, 0)
        clearBadge()
    }
    
    func clearBadge() {
        XDUser.shared.model.unreadMessageCount = "0"
        JPUSHService.setBadge(0)
        UIApplication.shared.applicationIconBadgeNumber = 0
        XDUser.shared.writeToFile()
        NotificationCenter.default.post(name: .XD_NOTIFY_UPDATE_UNREAD_MESSAGE, object: nil)
    }
    
    override func createModel() {
        model = SSURLReqeustModel(httpMethod: .get, urlString: XD_API_MESSAGE_CENTER_LIST, loadFromFile: false, isPaged: true)
    }
    
    override func didFinishLoad(with object: Any!) {
        if let array = ((object as? [String : Any])?["data"] as? [String : Any])?["data"] as? [[String : Any]] {
            var items = [MessageItem]()
            for dict in array.reversed() {
                if let item = MessageItem(attributes: dict) {
                    guard item.model.type != .unknown else { continue }
                    items.append(item)
                }
            }
            if tableViewModel.sections == nil {
                let section = NITableViewModelSection.section() as! NITableViewModelSection
                section.rows = [MessageItem]()
                tableViewModel.sections = NSMutableArray(array:  [section])
            }
            let section = tableViewModel.sections.lastObject as! NITableViewModelSection
            items += (section.rows as! [MessageItem])
            section.rows = items
            if items.count < SSConfig.defaultPageSize {
                tableView.mj_header = nil
            }
        }
    }
    
    override func refreshHeaderClass() -> AnyClass! {
        return XDLoadMoreRrefreshHeader.self
    }
    
    override func showModel(_ show: Bool) {
        let canAdjustPosition = tableView.visibleCells.count == 0
        let contentOffsetHeight: CGFloat = tableView.contentSize.height
        super.showModel(show)
        let newContentOffsetHeight: CGFloat = tableView.contentSize.height
        let delta = newContentOffsetHeight - contentOffsetHeight
        if show {
            if canAdjustPosition {
                // 说明从无到有(第一次刷新)
                let items = (tableViewModel.sections.lastObject as! NITableViewModelSection).rows!
                let indexPath = IndexPath(row: items.count - 1, section: 0)
                tableView.scrollToRow(at: indexPath, at: .bottom, animated: false)
            } else {
                // 不是第一次刷新
                tableView.setContentOffset(CGPoint(x: 0, y: tableView.contentOffset.y + delta), animated: false)
            }
        }
    }
}
