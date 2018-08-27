//
//  HighSchoolViewController.swift
//  xxd
//
//  Created by Lisen on 2018/4/4.
//  Copyright © 2018年 com.smartstudy. All rights reserved.
//

import UIKit

// 美高院校库
class HighSchoolViewController: SSTableViewController {
    
    // MARK: properties
    private var isNoData: Bool = true
    private var optionParams = [String: String]()
    private lazy var filterView: HighSchoolFilterView = {
        let view: HighSchoolFilterView = HighSchoolFilterView()
        view.delegate = self
        return view
    }()
    
    // MARK: life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "title_highSchool".localized
        canDragRefresh = true
        canDragLoadMore = true
        clearTableViewWhenLoadingNew = true
        view.insertSubview(filterView, aboveSubview: tableView)
        tableView.frame = CGRect(x: 0.0, y: filterView.bottom, width: view.width, height: view.height - filterView.bottom)
        tableView.showsVerticalScrollIndicator = false
        tableViewActions.attach(to: HighSchoolListItem.self, tap: { (object, target, indexPath) -> Bool in
            if let item = object as? HighSchoolListItem {
                let detailVC: HighschoolDetailViewController = HighschoolDetailViewController()
                detailVC.highschoolID = item.model.schoolId
                XDRoute.pushToVC(detailVC)
            }
            return true
        })
    }
    
    override func createModel() {
        let model = SSURLReqeustModel(httpMethod: .get, urlString: XD_HSAPI_RANK_LIST, loadFromFile: false, isPaged: true)
        model?.parameters = optionParams
        self.model = model
        tableView.ss_scrollToTop(animated: false)
    }
    
    override func didFinishLoad(with object: Any!) {
        let response = (object as! [String: Any])
        if let responseData = response["data"] as? [String: Any] {
            if let rData = responseData["data"] as? [[String: Any]] {
                var models: [HighSchoolListItem] = [HighSchoolListItem]()
                if rData.count > 0 {
                    isNoData = false
                } else {
                    isNoData = true
                    if let _ = tableViewModel.sections {
                        tableViewModel.sections.removeAllObjects()
                        tableView.mj_footer = nil
                        tableView.reloadData()
                    }
                }
                for data in rData {
                    let item: HighSchoolListItem = HighSchoolListItem(attributes: data)
                    models.append(item)
                }
                tableViewModel.addObjects(from: models)
                tableViewModel.hasMore = models.count >= SSConfig.defaultPageSize
            }
            if let optionData = responseData["options"] as? [String: Any] {
                let rankData = optionData["ranks"] as! [String: Any]
                let rankModel = HighSchoolRankCategoryModel.yy_model(with: rankData)
                self.filterView.rankFilterView.leftDataSources = rankModel
                let tuitionData = optionData["feeRange"] as! [String: Any]
                let tuitionModel = HighSchoolRankCategoryModel.yy_model(with: tuitionData)
                self.filterView.tuitionFilterView.tuitionModel = tuitionModel
                var optionsModel = [HighSchoolRankCategoryModel]()
                let sexualData = optionData["sexualTypes"] as! [String: Any]
                let sexualModel = HighSchoolRankCategoryModel.yy_model(with: sexualData)
                optionsModel.append(sexualModel!)
                let boardData = optionData["boarderTypes"] as! [String: Any]
                let boardModel = HighSchoolRankCategoryModel.yy_model(with: boardData)
                optionsModel.append(boardModel!)
                self.filterView.optionsFilterView.dataModel = optionsModel
            }
        } else {
            isNoData = true
        }
    }
    
    override func showEmpty(_ show: Bool) {
        if show && !isNoData {
            super.showEmpty(false)
        } else {
            super.showEmpty(show)
        }
    }
}

// MARK: HighSchoolFilterViewDelegate
extension HighSchoolViewController: HighSchoolFilterViewDelegate {
    func highSchoolFilterView(select params: Dictionary<String, Any>) {
        for key in params.keys.enumerated() {
            if let str = params[key.element] as? String {
                optionParams[key.element] = str
            }
        }
        createModel()
    }
}
