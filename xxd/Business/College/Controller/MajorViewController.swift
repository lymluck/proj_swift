//
//  MajorViewController.swift
//  xxd
//
//  Created by remy on 2018/2/19.
//  Copyright © 2018年 com.smartstudy. All rights reserved.
//

private let kCellHeight: CGFloat = 56
private let kSearchBarHeight: CGFloat = 44
private let kSectionHeight: CGFloat = 64

/// 专业库
class MajorViewController: SSTableViewController, MajorSectionItemDelegate {
    
    var selectedCategoryId: String?
    private var sectionItems = [MajorSectionItem]()
    private var selectedItem: MajorSectionItem?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        XDStatistics.click("13_B_professional_list")
        clearTableViewWhenLoadingNew = true
        minStayOffsetY = kSearchBarHeight
        title = "major_lib".localized
        
        let topSearchView = UIView(frame: CGRect(x: 0, y: 0, width: XDSize.screenWidth, height: 44), color: XDColor.mainBackground)
        let searchBtn = UIButton(frame: CGRect(x: 8, y: 8, width: XDSize.screenWidth - 16, height: 28), title: "search".localized, fontSize: 15, titleColor: XDColor.textPlaceholder, target: self, action: #selector(topSearchTap(sender:)))!
        searchBtn.backgroundColor = UIColor.white
        searchBtn.layer.cornerRadius = 4
        searchBtn.layer.masksToBounds = true
        searchBtn.titleEdgeInsets = UIEdgeInsetsMake(0, 15, 0, 0)
        searchBtn.setImage(UIImage(named: "text_field_search"), for: .normal)
        topSearchView.addSubview(searchBtn)
        
        tableView.tableHeaderView = topSearchView
        tableView.rowHeight = kCellHeight
        tableView.scrollIndicatorInsets = UIEdgeInsetsMake(kSearchBarHeight, 0, 0, 0)
        tableView.register(MajorSectionView.self, forHeaderFooterViewReuseIdentifier: MajorSectionView.metaTypeName)
        tableViewActions.attach(to: MajorItem.self, tap: { (object, target, indexPath) -> Bool in
            if let object = object as? MajorItem {
                XDStatistics.click("13_A_professional_cell")
                XDRoute.pushWebVC([QueryKey.URLPath: object.model.URLPath, QueryKey.TitleName: object.model.name])
            }
            return true
        })
    }
    
    override func createModel() {
        let model = SSURLReqeustModel(httpMethod: .get, urlString: XD_API_MAJOR_LIB_LIST, loadFromFile: false, isPaged: false)
        model?.parameters = ["hierarchy":true]
        self.model = model
    }
    
    override func didFinishLoad(with object: Any!) {
        if let data = (object as! [String : Any])["data"] as? [[String : Any]] {
            let models = NSArray.yy_modelArray(with: MajorModel.self, json: data) as! [MajorModel]
            var sections = [NITableViewModelSection]()
            for (index, model) in models.enumerated() {
                let section = NITableViewModelSection.section() as! NITableViewModelSection
                sections.append(section)
                let sectionItem = MajorSectionItem()
                sectionItem.model = model
                sectionItem.delegate = self
                sectionItem.index = index
                sectionItems.append(sectionItem)
                if let categoryId = selectedCategoryId, categoryId == model.categoryID {
                    sectionItem.isSelected = true
                    selectedItem = sectionItem
                }
            }
            tableViewModel.sections = NSMutableArray(array: sections)
        }
    }
    
    override func didShowModel(_ firstTime: Bool) {
        super.didShowModel(firstTime)
        if firstTime {
            if tableView.contentSize.height - tableView.height > kSearchBarHeight {
                tableView.setContentOffset(CGPoint(x: 0, y: kSearchBarHeight), animated: false)
            }
        }
        if let item = selectedItem {
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+0.1) {
                self.sectionItemDidSelected(item: item)
            }
        }
    }
    
    //MARK:- UITableViewDelegate
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return kSectionHeight
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let item = sectionItems[section]
        let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: MajorSectionView.metaTypeName) as! MajorSectionView
        view.item = item
        return view
    }
    
    //MARK:- MajorSectionItemDelegate
    func sectionItemDidSelected(item: MajorSectionItem) {
        if let selectedItem = selectedItem, selectedItem !== item {
            selectedItem.isSelected = false
            let section = tableViewModel.sections[selectedItem.index] as! NITableViewModelSection
            var indexPaths = [IndexPath]()
            for i in 0..<section.rows.count {
                indexPaths.append(IndexPath(row: i, section: selectedItem.index))
            }
            section.rows = [MajorSectionItem]()
            tableView.deleteRows(at: indexPaths, with: .automatic)
        }
        selectedItem = item
        if item.isSelected {
            let subModels = item.model.subModels
            var subItems = [MajorItem]()
            var indexPaths = [IndexPath]()
            for (i, model) in subModels.enumerated() {
                let cellItem = MajorItem()!
                cellItem.whiteBGColor = false
                cellItem.model = model
                subItems.append(cellItem)
                indexPaths.append(IndexPath(row: i, section: item.index))
            }
            let section = tableViewModel.sections[item.index] as! NITableViewModelSection
            section.rows = subItems
            tableView.insertRows(at: indexPaths, with: .automatic)
        } else {
            let section = tableViewModel.sections[item.index] as! NITableViewModelSection
            var indexPaths = [IndexPath]()
            for i in 0..<section.rows.count {
                indexPaths.append(IndexPath(row: i, section: item.index))
            }
            section.rows = [RankSectionItem]()
            tableView.deleteRows(at: indexPaths, with: .automatic)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            [weak self] in
            if let strongSelf = self {
                if let cell = strongSelf.tableView.visibleCells.first {
                    strongSelf.tableView.setContentOffset(CGPoint(x: 0, y: cell.top - kSectionHeight), animated: true)
                } else if item.isSelected, let view = item.sectionView {
                    strongSelf.tableView.setContentOffset(CGPoint(x: 0, y: view.top), animated: true)
                }
            }
        }
        
    }
    
    //MARK:- Action
    @objc func topSearchTap(sender: UIButton) {
        XDStatistics.click("13_A_professional_search_btn")
        let vc = XDSearchViewController(type: .major)
        tabBarController?.presentModalTranslucentViewController(vc, animated: false, completion: nil)
    }
    
    //MARK:- UIScrollViewDelegate
    override func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        let contentOffsetY = scrollView.contentOffset.y
        if contentOffsetY < minStayOffsetY && contentOffsetY > 0 {
            let y = contentOffsetY > minStayOffsetY * 0.5 ? minStayOffsetY : 0
            tableView.setContentOffset(CGPoint(x: 0, y: y), animated: true)
        }
    }
}
