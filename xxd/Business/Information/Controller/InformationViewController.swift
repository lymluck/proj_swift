//
//  InformationViewController.swift
//  xxd
//
//  Created by remy on 2018/1/18.
//  Copyright © 2018年 com.smartstudy. All rights reserved.
//

enum InformationListStyle {
    case tag
    case college
}

class InformationViewController: SSTableViewController {
    
    private var tagID = 0
    private var collegeID = 0
    private var type: InformationListStyle!
    var titleName = ""
    
    override func needNavigationBar() -> Bool {
        return type != .tag
    }
    
    convenience init(tagID: Int) {
        self.init()
        self.tagID = tagID
        type = .tag
    }
    
    convenience init(collegeID: Int) {
        self.init()
        self.collegeID = collegeID
        type = .college
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        canDragRefresh = true
        canDragLoadMore = true
        title = titleName
        
        tableViewActions.attach(to: InformationItem.self, tap: { (object, target, indexPath) -> Bool in
            if let object = object as? InformationItem {
                XDStatistics.click("17_A_news_details_cell")
                XDStatistics.click("18_B_news_detail")
                XDRoute.pushWebVC([QueryKey.URLPath: object.model.URLPath, "barType": WebViewControllerBarType.gradient])
            }
            return true
        })
    }
    
    override func createModel() {
        let model = SSURLReqeustModel(httpMethod: .get, urlString: XD_API_INFO_WITH_TAG, loadFromFile: false, isPaged: canDragLoadMore)
        var params: [String : Any] = ["enabled": true, "deleted": false]
        if type == .tag {
            if tagID > 0 {
                params["tagIds"] = "[\(tagID)]"
            }
        } else if type == .college {
            params["schoolId"] = "\(collegeID)"
        }
        model?.parameters = params
        self.model = model
    }
    
    override func didFinishLoad(with object: Any!) {
        if let data = ((object as! [String : Any])["data"] as! [String : Any])["data"] as? [[String : Any]] {
            var items = [InformationItem]()
            for dict in data {
                items.append(InformationItem(attributes: dict))
            }
            tableViewModel.addObjects(from: items)
            tableViewModel.hasMore = items.count >= SSConfig.defaultPageSize
        }
    }
}
