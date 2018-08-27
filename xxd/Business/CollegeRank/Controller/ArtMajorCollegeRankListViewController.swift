//
//  ArtMajorCollegeRankListViewController.swift
//  xxd
//
//  Created by Lisen on 2018/7/4.
//  Copyright © 2018年 com.smartstudy. All rights reserved.
//

import UIKit

/// 艺术专业院校排名列表
class ArtMajorCollegeRankListViewController: SSTableViewController {
    
    var majorId: String = ""
    var titleName: String = ""
    private lazy var optionParams: [String: Any] = ["majorId": majorId]
    private lazy var topFilterView: ArtMajorFilterView = ArtMajorFilterView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = titleName
        minStayOffsetY = XDSize.topBarHeight
        canDragRefresh = true
        canDragLoadMore = true
        clearTableViewWhenLoadingNew = true
        topFilterView.delegate = self
        view.insertSubview(topFilterView, aboveSubview: tableView)
        tableView.frame = CGRect(x: 0.0, y: topFilterView.bottom, width: XDSize.screenWidth, height: XDSize.screenHeight-topFilterView.bottom)
        tableViewActions.attach(to: ArtMajorCollegeRankItem.self, tap: { (object, target, indexPath) -> Bool in
            if let item = object as? ArtMajorCollegeRankItem {
                if item.model.website.isEmpty {
                    XDPopView.toast("暂无该专业信息")
                } else {
                    XDRoute.pushWebVC([QueryKey.URLPath: item.model.website])
                }
            }
            return true
        })
    }
    
    override func createModel() {
        let model = SSURLReqeustModel(httpMethod: .get, urlString: XD_API_ART_MAJOR_COLLEGE_RANKS, loadFromFile: false, isPaged: true)
        model?.parameters = optionParams
        self.model = model
    }
    
    override func didFinishLoad(with object: Any!) {
        if let responseObject = object as? [String: Any], let responseData = responseObject["data"] as? [String: Any] {
            if let countryOptions = responseData["countries"] as? [[String: Any]] {
                let parseResult = parseOptionParams(countryOptions)
                topFilterView.countryOptions = parseResult.0
                topFilterView.selectedCountry = parseResult.1
            }
            if let degreeOptions = responseData["degrees"] as? [[String: Any]] {
                let parseResult = parseOptionParams(degreeOptions)
                topFilterView.degreeOptions = parseResult.0
                topFilterView.selectedDegree = parseResult.1
            }
            if let serverData = responseData["programs"] as? [[String: Any]] {
                var items: [ArtMajorCollegeRankItem] = []
                for data in serverData {
                    let item: ArtMajorCollegeRankItem = ArtMajorCollegeRankItem(attributes: data)
                    items.append(item)
                }
                tableViewModel.addObjects(from: items)
            }
        }
    }
    
    override func showEmpty(_ show: Bool) {
        super.showEmpty(false)
    }
    
    /// 解析服务器返回的筛选项
    private func parseOptionParams(_ optionData: [[String: Any]]) -> ([[String]], String) {
        var options: [[String]] = [[String]]()
        var selectedValue = ""
        for data in optionData {
            var option: [String] = [String]()
            guard let optionName = data["name"] as? String else { return (options, selectedValue) }
            guard let optionId = data["id"] as? String else { return (options, selectedValue) }
            option.append(optionName)
            option.append(optionId)
            options.append(option)
            if let isSelected = data["selected"] as? Bool, isSelected {
                selectedValue = optionId
            }
        }
        return (options, selectedValue)
    }
    
}

// MARK: ArtMajorFilterViewDelegate
extension ArtMajorCollegeRankListViewController: ArtMajorFilterViewDelegate {
    func artMajorFilterViewDidSelect(option: [String: String]) {
        for key in option.keys.enumerated() {
            if let selectedValue = option[key.element] {
                optionParams[key.element] = selectedValue
            }
        }
        createModel()
    }
}
