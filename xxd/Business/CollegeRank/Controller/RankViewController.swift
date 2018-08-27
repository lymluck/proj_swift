//
//  RankViewController.swift
//  xxd
//
//  Created by remy on 2018/1/24.
//  Copyright © 2018年 com.smartstudy. All rights reserved.
//

private let kSearchBarHeight: CGFloat = 44
private let kSectionHeight: CGFloat = 66

/// 排名大全
class RankViewController: SSTableViewController, RankSectionItemDelegate {
    
    private var sectionItems = [RankSectionItem]()
    private var selectedItem: RankSectionItem?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        XDStatistics.click("11_B_rank_list")
        canDragRefresh = true
        clearTableViewWhenLoadingNew = true
        minStayOffsetY = kSearchBarHeight
        title = "title_rank".localized
        
        let topSearchView = UIView(frame: CGRect(x: 0, y: 0, width: XDSize.screenWidth, height: 44), color: XDColor.mainBackground)
        let searchBtn = UIButton(frame: CGRect(x: 8, y: 8, width: XDSize.screenWidth - 16, height: 28), title: "search".localized, fontSize: 15, titleColor: XDColor.textPlaceholder, target: self, action: #selector(topSearchTap(sender:)))!
        searchBtn.backgroundColor = UIColor.white
        searchBtn.layer.cornerRadius = 4
        searchBtn.layer.masksToBounds = true
        searchBtn.titleEdgeInsets = UIEdgeInsetsMake(0, 15, 0, 0)
        searchBtn.setImage(UIImage(named: "text_field_search"), for: .normal)
        topSearchView.addSubview(searchBtn)
        
        tableView.tableHeaderView = topSearchView
        tableView.register(RankSectionView.self, forHeaderFooterViewReuseIdentifier: RankSectionView.metaTypeName)
        tableViewActions.attach(to: RankItem.self, tap: { (object, target, indexPath) -> Bool in
            if let object = object as? RankItem {
                XDStatistics.click("11_A_specific_rank_btn")
                let vc = RankListViewController()
                vc.rankCategoryID = object.model.categoryID
                vc.titleName = object.model.pureName
                XDRoute.pushToVC(vc)
            }
            return true
        })
    }
    
    override func createModel() {
        model = SSURLReqeustModel(httpMethod: .get, urlString: XD_API_RANK_CATEGORIES, loadFromFile: true, isPaged: false)
    }
    
    override func didFinishLoad(with object: Any!) {
        if let data = (object as! [String : Any])["data"] as? [String : Any] {
            let integratedRankings = data["integratedRankings"] as! [[String : Any]]
            var arr = [[String : Any]]()
            arr += integratedRankings
            arr += (data["majorRankings"] as! [[String : Any]])
            sectionItems = [RankSectionItem]()
            selectedItem = nil
            var sections = [NITableViewModelSection]()
            for (index, dict) in arr.enumerated() {
                let section = NITableViewModelSection.section() as! NITableViewModelSection
                sections.append(section)
                let sectionItem = RankSectionItem()
                if index == integratedRankings.count - 1 {
                    sectionItem.hasSeparate = true
                }
                sectionItem.model = RankModel.yy_model(with: dict)
                sectionItem.delegate = self
                sectionItem.index = index
                sectionItems.append(sectionItem)
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
    }
    
    //MARK:- UITableViewDelegate
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return kSectionHeight
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return sectionItems[section].hasSeparate ? 16 : CGFloat.leastNonzeroMagnitude
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let item = sectionItems[section]
        let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: RankSectionView.metaTypeName) as! RankSectionView
        view.item = item
        return view
    }
    
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let identifier = "sectionFooterView"
        var view: UITableViewHeaderFooterView! = tableView.dequeueReusableHeaderFooterView(withIdentifier: identifier)
        if view == nil {
            view = UITableViewHeaderFooterView(reuseIdentifier: identifier)
            let wrap = UIView(frame: view.bounds, color: XDColor.mainBackground)
            view.backgroundView = wrap
        }
        return view
    }
    
    //MARK:- RankSectionItemDelegate
    func sectionItemDidSelected(item: RankSectionItem) {
        if let selectedItem = selectedItem, selectedItem.isSelected, selectedItem !== item {
            selectedItem.isSelected = false
            let section = tableViewModel.sections[selectedItem.index] as! NITableViewModelSection
            var indexPaths = [IndexPath]()
            for i in 0..<section.rows.count {
                indexPaths.append(IndexPath(row: i, section: selectedItem.index))
            }
            section.rows = [RankSectionItem]()
            tableView.deleteRows(at: indexPaths, with: .automatic)
        }
        selectedItem = item
        if item.isSelected {
            XDStatistics.click("11_A_row_expand_btn")
            let subModels = item.model.subModels
            var subItems = [RankItem]()
            var indexPaths = [IndexPath]()
            for (i, model) in subModels.enumerated() {
                let cellItem = RankItem()!
                cellItem.whiteBGColor = false
                cellItem.model = model
                subItems.append(cellItem)
                indexPaths.append(IndexPath(row: i, section: item.index))
            }
            let section = tableViewModel.sections[item.index] as! NITableViewModelSection
            section.rows = subItems
            tableView.insertRows(at: indexPaths, with: .automatic)
        } else {
            XDStatistics.click("11_A_row_shrink_btn")
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
        XDStatistics.click("11_A_search_btn")
        let vc = XDSearchViewController(type: .rankCategory)
        addChildViewController(vc)
        view.addSubview(vc.view)
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
