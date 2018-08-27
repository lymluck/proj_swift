//
//  IndexSearchController.swift
//  xxd
//
//  Created by remy on 2018/2/21.
//  Copyright © 2018年 com.smartstudy. All rights reserved.
//

class IndexSearchController: XDSearchViewController {
    
    private var sectionItems = [IndexSearchSectionItem]()
    
    override func addSearchList() {
        apiName = XD_API_SEARCH
        canDragLoadMore = false
        if UIDevice.isIPhoneX {
            tableView.contentInset = UIEdgeInsetsMake(0, 0, 20, 0)
        }
        tableView.register(IndexSearchSectionHeader.self, forHeaderFooterViewReuseIdentifier: IndexSearchSectionHeader.metaTypeName)
        // 大学
        tableViewActions.attach(to: CollegeSearchItem.self, tap: { (object, target, indexPath) -> Bool in
            if let object = object as? CollegeSearchItem {
                let vc = CollegeDetailViewController()
                vc.collegeID = object.model.collegeID
                XDRoute.pushToVC(vc)
            }
            return true
        })
        // 高中
        tableViewActions.attach(to: HighschoolSearchItem.self, tap: { (object, target, indexPath) -> Bool in
            if let object = object as? HighschoolSearchItem {
                let vc = HighschoolDetailViewController()
                vc.highschoolID = object.model.collegeID
                XDRoute.pushToVC(vc)
            }
            return true
        })
        // 新闻
        tableViewActions.attach(to: InformationItem.self, tap: { (object, target, indexPath) -> Bool in
            if let object = object as? InformationItem {
                let query: [String : Any] = [QueryKey.URLPath:object.model.URLPath, "barType":WebViewControllerBarType.gradient]
                XDRoute.pushWebVC(query)
            }
            return true
        })
        // 问答
        tableViewActions.attach(to: QuestionItem.self, tap: { (object, target, indexPath) -> Bool in
            if let object = object as? QuestionItem {
                let vc = QuestionDetailViewController()
                vc.questionID = object.model.questionID
                XDRoute.pushToVC(vc)
            }
            return true
        })
        // 课程
        tableViewActions.attach(to: CourseSearchItem.self, tap: { (object, target, indexPath) -> Bool in
            if let object = object as? CourseSearchItem {
                let vc = CourseDetailViewController()
                vc.courseID = object.model.courseID
                XDRoute.pushToVC(vc)
            }
            return true
        })
        // 更多结果
        tableViewActions.attach(to: IndexSearchSectionFooterItem.self, tap: {
            [weak self] (object, target, indexPath) -> Bool in
            if let object = object as? IndexSearchSectionFooterItem {
                self?.detailSearch(object.item)
            }
            return true
        })
    }
    
    override func didFinishLoad(with object: Any!) {
        if let data = (object as! [String : Any])["data"] as? [String : Any] {
            let total = data["total"] as! [String : Any]
            sectionItems = [IndexSearchSectionItem]()
            var sections = [NITableViewModelSection]()
            let keys = ["schools", "highschools", "courses", "questions", "news"]
            let titleKeys = ["tab_item_university", "tab_item_highschool", "tab_item_course", "tab_item_qa", "tab_item_info"]
            let itemClass = [CollegeSearchItem.self, HighschoolSearchItem.self, CourseSearchItem.self, QuestionItem.self, InformationItem.self]
            for (index, key) in keys.enumerated() {
                let items = data[key] as! [[String : Any]]
                if items.count > 0 {
                    let sectionItem = IndexSearchSectionItem()
                    sectionItem.title = titleKeys[index].localized
                    sectionItem.showCount = items.count
                    sectionItem.resultCount = total[key] as! Int
                    sectionItem.type = IndexSearchType(rawValue: index)
                    sectionItems.append(sectionItem)
                    var cellItems = [SSCellItem]()
                    let cls = itemClass[index]
                    for (index, item) in items.enumerated() {
                        let cellItem = cls.init(attributes: item)!
                        cellItems.append(cellItem)
                        if index == sectionItem.resultCount - 1 {
                            cellItem.bottomLineType = .none
                        } else {
                            cellItem.bottomLineType = .center
                        }
                    }
                    if cls is QuestionItem.Type {
                        let _ = cellItems.map {
                            ($0 as! QuestionItem).type = .search
                        }
                    }
                    if sectionItem.resultCount > items.count {
                        let footerItem = IndexSearchSectionFooterItem(attributes: nil)!
                        footerItem.item = sectionItem
                        cellItems.append(footerItem)
                    }
                    sectionItem.cellItems = cellItems
                    let section = NITableViewModelSection.section() as! NITableViewModelSection
                    section.rows = cellItems
                    sections.append(section)
                }
            }
            tableViewModel.sections = NSMutableArray(array: sections)
        }
    }
    
    private func detailSearch(_ sectionItem: IndexSearchSectionItem) {
        var vc: XDSearchViewController!
        if sectionItem.type == .qa {
            vc = QASearchController()
            vc.extraParams = ["answered":true]
            (vc as! QASearchController).type = QAListType.search
        } else {
            switch sectionItem.type {
            case .college:
                vc = XDSearchViewController(type: .college)
            case .highschool:
                vc = XDSearchViewController(type: .highschool)
            case .course:
                vc = XDSearchViewController(type: .course)
            case .info:
                vc = XDSearchViewController(type: .information)
            default:
                break
            }
        }
        vc.customWrap = UIView(frame: CGRect(x: 0, y: 0, width: XDSize.screenWidth, height: XDSize.visibleHeight), color: UIColor.white)
        vc.isBackWhenCancel = true
        vc.keyword = keyword
        vc.cancelFirstResponder = true
        navigationController?.pushViewController(vc, animated: true)
    }
    
    //MARK:- UITableViewDelegate
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 32
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let item = sectionItems[section]
        let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: IndexSearchSectionHeader.metaTypeName) as! IndexSearchSectionHeader
        view.item = item
        return view
    }
}
