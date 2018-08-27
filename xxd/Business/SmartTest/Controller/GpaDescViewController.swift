//
//  GpaDescViewController.swift
//  xxd
//
//  Created by remy on 2018/1/30.
//  Copyright © 2018年 com.smartstudy. All rights reserved.
//

private let kSectionHeight: CGFloat = 64

class GpaDescViewController: SSTableViewController {
    
    private var sectionItems = [GpaDescSectionItem]()
    private var selectedItem: GpaDescSectionItem?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "GPA计算"
        
        tableView.estimatedRowHeight = 320
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.register(GpaDescSectionItemHeader.self, forHeaderFooterViewReuseIdentifier: GpaDescSectionItemHeader.metaTypeName)
    }
    
    override func createModel() {
        model = SSURLReqeustModel(httpMethod: .get, urlString: XD_API_GPA_ALGORITHMS, loadFromFile: false, isPaged: false)
    }
    
    override func didFinishLoad(with object: Any!) {
        if let data = (object as! [String : Any])["data"] as? [[String : Any]] {
            var sections = [NITableViewModelSection]()
            sectionItems = [GpaDescSectionItem]()
            for (index, dict) in data.enumerated() {
                let section = NITableViewModelSection.section() as! NITableViewModelSection
                sections.append(section)
                let sectionItem = GpaDescSectionItem()
                sectionItem.model = GpaDescModel.yy_model(with: dict)
                sectionItem.index = index
                sectionItems.append(sectionItem)
            }
            tableViewModel.sections = NSMutableArray(array: sections)
        }
    }
    
    //MARK:- UITableViewDelegate
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return kSectionHeight
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let item = sectionItems[section]
        let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: GpaDescSectionItemHeader.metaTypeName) as! GpaDescSectionItemHeader
        view.item = item
        return view
    }
    
    //MARK:- Action
    override func routerEvent(name: String, data: Dictionary<String, Any>) {
        if name == kEventFormulaSectionTap {
            let sectionItem = data["item"] as! GpaDescSectionItem
            if let selectedItem = selectedItem, selectedItem.isSelected, selectedItem !== sectionItem {
                selectedItem.isSelected = false
                let section = tableViewModel.sections[selectedItem.index] as! NITableViewModelSection
                var indexPaths = [IndexPath]()
                for i in 0..<section.rows.count {
                    indexPaths.append(IndexPath(row: i, section: selectedItem.index))
                }
                section.rows = [GpaDescSectionItem]()
                tableView.deleteRows(at: indexPaths, with: .automatic)
            }
            selectedItem = sectionItem
            if sectionItem.isSelected {
                let item = GpaDescItem()!
                item.model = sectionItem.model
                let section = tableViewModel.sections[sectionItem.index] as! NITableViewModelSection
                section.rows = [item]
                let indexPath = IndexPath(row: 0, section: sectionItem.index)
                tableView.insertRows(at: [indexPath], with: .automatic)
            } else {
                let section = tableViewModel.sections[sectionItem.index] as! NITableViewModelSection
                section.rows = [GpaDescSectionItem]()
                let indexPath = IndexPath(row: 0, section: sectionItem.index)
                tableView.deleteRows(at: [indexPath], with: .automatic)
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                [weak self] in
                if let strongSelf = self, strongSelf.tableView.contentSize.height > strongSelf.tableView.height {
                    if let cell = strongSelf.tableView.visibleCells.first {
                        strongSelf.tableView.setContentOffset(CGPoint(x: 0, y: cell.top - kSectionHeight), animated: true)
                    }
                }
            }
        }
    }
}
