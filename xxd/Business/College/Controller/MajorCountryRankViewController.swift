//
//  MajorCountryRankViewController.swift
//  xxd
//
//  Created by Lisen on 2018/7/2.
//  Copyright © 2018年 com.smartstudy. All rights reserved.
//

import UIKit

enum MajorTotalRankType: Int {
    /// 全球专业排名
    case global
    /// 美国本科专业排名
    case usa_bachelor
    /// 美国研究生专业排名
    case usa_master
    /// 艺术专业排名
    case art
    
    var apiName: String {
        switch self {
        case .global:
            return XD_API_MAJOR_GLOBAL
        case .usa_bachelor:
            return XD_API_MAJOR_USA_BACHELOR
        case .usa_master:
            return XD_API_MAJOR_USA_MASTER
        default:
            return XD_API_ART_RANKS
        }
    }
}

/// 负责全球,美本, 美研, 艺术专业排名显示
class MajorCountryRankViewController: SSTableViewController {
    
    var name: String = ""
    var rankType: MajorTotalRankType = .global
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = name
        initTopSearchView()
        minStayOffsetY = XDSize.topBarHeight
        tableViewActions.attach(to: MajorCountryRankItem.self, tap: { (object, target, indexPaht) -> Bool in
            if let object = object as? MajorCountryRankItem {
                XDStatistics.click("11_A_specific_rank_btn")
                if self.rankType == .art {
                    let vc = ArtMajorCollegeRankListViewController()
                    vc.majorId = object.model.artCategoryId
                    vc.titleName = object.model.pureName
                    XDRoute.pushToVC(vc)
                } else {
                    let vc = RankListViewController()
                    vc.rankCategoryID = object.model.categoryID
                    vc.titleName = object.model.pureName
                    XDRoute.pushToVC(vc)
                }
            }
            return true
        })
    }
    
    override func createModel() {
        model = SSURLReqeustModel(httpMethod: .get, urlString: rankType.apiName, loadFromFile: true, isPaged: false)
    }
    
    override func didFinishLoad(with object: Any!) {
        if let responseObject = object as? [String: Any], let responseData = responseObject["data"] as? [[String: Any]] {
            var items: [MajorCountryRankItem] = []
            for dict in responseData {
                let item: MajorCountryRankItem = MajorCountryRankItem(attributes: dict)
                items.append(item)
            }
            tableViewModel.addObjects(from: items)
        }
    }
    
    override func didShowModel(_ firstTime: Bool) {
        super.didShowModel(firstTime)
        if firstTime {
            if tableView.contentSize.height - tableView.height > XDSize.topBarHeight {
                tableView.setContentOffset(CGPoint(x: 0, y: XDSize.topBarHeight), animated: false)
            }
        }
    }
    
    override func showEmpty(_ show: Bool) {
        super.showEmpty(false)
    }
    
    //MARK:- UIScrollViewDelegate
    override func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        let contentOffsetY = scrollView.contentOffset.y
        if contentOffsetY < minStayOffsetY && contentOffsetY > 0 {
            let y = contentOffsetY > minStayOffsetY * 0.5 ? minStayOffsetY : 0
            tableView.setContentOffset(CGPoint(x: 0, y: y), animated: true)
        }
    }
    
    @objc private func eventTopSearchButtonResponse(_ sender: UIButton) {
        XDStatistics.click("11_A_search_btn")
        var searchType: XDSearchDataType = .rankCategory
        if rankType == .art {
            searchType = .artMajor
        }
        let vc = XDSearchViewController(type: searchType)
        addChildViewController(vc)
        view.addSubview(vc.view)
    }
    
    private func initTopSearchView() {
        let topSearchView = UIView(frame: CGRect(x: 0, y: 0, width: XDSize.screenWidth, height: 44), color: XDColor.mainBackground)
        let searchBtn = UIButton(frame: CGRect(x: 8, y: 8, width: XDSize.screenWidth - 16, height: 28), title: "search".localized, fontSize: 15, titleColor: XDColor.textPlaceholder, target: self, action: #selector(eventTopSearchButtonResponse(_:)))!
        searchBtn.backgroundColor = UIColor.white
        searchBtn.layer.cornerRadius = 4
        searchBtn.layer.masksToBounds = true
        searchBtn.titleEdgeInsets = UIEdgeInsetsMake(0, 15, 0, 0)
        searchBtn.setImage(UIImage(named: "text_field_search"), for: .normal)
        topSearchView.addSubview(searchBtn)
        tableView.tableHeaderView = topSearchView
    }
    
}
