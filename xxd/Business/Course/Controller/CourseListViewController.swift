//
//  CourseListViewController.swift
//  xxd
//
//  Created by remy on 2018/1/18.
//  Copyright © 2018年 com.smartstudy. All rights reserved.
//

class CourseListViewController: SSTableViewController {
    
    private var sectionItems = [CourseGroupSectionItem]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        XDStatistics.click("15_B_course_list")
        clearTableViewWhenLoadingNew = true
        navigationBar.centerTitle = "study_abroad_course".localized
        
        tableView.backgroundColor = UIColor.white
        tableView.register(CourseGroupSectionHeader.self, forHeaderFooterViewReuseIdentifier: CourseGroupSectionHeader.metaTypeName)
        tableViewActions.attach(to: CourseGroupListItem.self, tap: { (object, target, indexPath) -> Bool in
            if let object = object as? CourseGroupListItem {
                XDStatistics.click("15_A_course_cell")
                let vc = CourseDetailViewController()
                vc.courseID = object.model.courseID
                XDRoute.pushToVC(vc)
            }
            return true
        })
    }
    
    override func createModel() {
        model = SSURLReqeustModel(httpMethod: .get, urlString: XD_API_COURSE_GROUP_LIST, loadFromFile: false, isPaged: false)
    }
    
    override func didFinishLoad(with object: Any!) {
        if let data = (object as! [String : Any])["data"] as? [[String : Any]], data.count > 0 {
            var sections = [NITableViewModelSection]()
            sectionItems = [CourseGroupSectionItem]()
            for dict in data {
                let sectionItem = CourseGroupSectionItem()
                sectionItem.title = dict["group"] as! String
                sectionItems.append(sectionItem)
                var cellItems = [CourseGroupListItem]()
                if let list = dict["list"] as? [[String : Any]], list.count > 0 {
                    for course in list {
                        let item = CourseGroupListItem(attributes: course)!
                        cellItems.append(item)
                    }
                    cellItems.last?.isLast = true
                }
                let section = NITableViewModelSection.section() as! NITableViewModelSection
                section.rows = cellItems
                sections.append(section)
            }
            (sections.last?.rows.last as! CourseGroupListItem).isLast = false
            tableViewModel.sections = NSMutableArray(array: sections)
        }
    }
    
    //MARK:- UITableViewDelegate
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 48
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let item = sectionItems[section]
        let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: CourseGroupSectionHeader.metaTypeName) as! CourseGroupSectionHeader
        view.item = item
        return view
    }
}
