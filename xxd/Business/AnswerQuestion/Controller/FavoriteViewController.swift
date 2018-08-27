//
//  FavoriteViewController.swift
//  xxd
//
//  Created by remy on 2018/1/25.
//  Copyright © 2018年 com.smartstudy. All rights reserved.
//

class FavoriteViewController: SSTableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        canDragRefresh = true
        canDragLoadMore = true
        title = "user_favorite".localized
        
        tableViewActions.attach(to: FavoriteItem.self, tap: { (object, target, indexPath) -> Bool in
            if let object = object as? FavoriteItem {
                if object.model.favoriteType == .program {
                    let vc = ProgramViewController()
                    vc.titleName = object.model.name
                    vc.programID = object.model.favoriteID
                    XDRoute.pushToVC(vc)
                } else if object.model.favoriteType == .schoolIntro {
                    let vc = CollegeDetailViewController()
                    vc.collegeID = object.model.favoriteID
                    XDRoute.pushToVC(vc)
                } else if object.model.favoriteType == .question {
                    let vc = QuestionDetailViewController()
                    vc.questionID = object.model.favoriteID
                    XDRoute.pushToVC(vc)
                } else if object.model.favoriteType == .highschool {
                    let vc = HighschoolDetailViewController()
                    vc.highschoolID = object.model.favoriteID
                    XDRoute.pushToVC(vc)
                } else if object.model.favoriteType == .columnNews {
                    let vc = ColumnDetailViewController()
                    vc.columnId = object.model.favoriteID
                    XDRoute.pushToVC(vc)
                } else if !object.model.urlPath.isEmpty {
                    XDRoute.pushWebVC([QueryKey.URLPath: object.model.urlPath, QueryKey.TitleName: "user_favorite".localized])
                }
            }
            return true
        })
    }
    
    override func createModel() {
        model = SSURLReqeustModel(httpMethod: .get, urlString: XD_API_MY_FAVORITE_LIST, loadFromFile: false, isPaged: canDragLoadMore)
    }
    
    override func didFinishLoad(with object: Any!) {
        if let data = (object as! [String : Any])["data"] as? [String : Any] {
            if let arr = data["data"] as? [[String : Any]] {
                var items = [FavoriteItem]()
                for dict in arr {
                    let item = FavoriteItem(attributes: dict)!
                    items.append(item)
                }
                tableViewModel.addObjects(from: items)
                tableViewModel.hasMore = items.count >= SSConfig.defaultPageSize
            }
        }
    }
}
