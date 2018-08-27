//
//  OtherUserInfoViewController.swift
//  xxd
//
//  Created by Lisen on 2018/8/2.
//  Copyright © 2018 com.smartstudy. All rights reserved.
//

import UIKit

/// 问答详情中查看其他用户的信息
class OtherUserInfoViewController: SSTableViewController {
    
    var otherUserId: Int = 0
    var otherUserName: String = ""
    private lazy var targetKeys: [String] = ["admissionTime", "targetCountry", "targetDegree", "budget", "targetSchoolRank", "targetMajorDirection"]
    private lazy var backgroundkeys: [String] = ["currentSchool", "score", "scoreLanguage", "scoreStandard", "activityInternship", "activitySocial", "activityResearch", "activityCommunity", "activityExchange"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = otherUserName + "基本信息"
        tableView.contentInset = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 20.0, right: 0.0)
    }
    
    override func createModel() {
        let urlString = String(format: XD_API_OTHER_PERSONAL_INFO, otherUserId)
        model = SSURLReqeustModel(httpMethod: .get, urlString: urlString, loadFromFile: false, isPaged: false)
    }
    
    override func didFinishLoad(with object: Any!) {
        if let responseObject = object as? [String: Any], let responseData = responseObject["data"] as? [String: Any] {
            var sections = [NITableViewModelSection]()
            if let targetData = responseData["targetSection"] as? [String: Any] {
                var cellItems: [OtherUserInfoItem] = []
                let targetSection = NITableViewModelSection.section() as! NITableViewModelSection
                for targetKey in targetKeys {
                    if let data = targetData[targetKey] as? [String: Any] {
                        let item = OtherUserInfoItem(attributes: data)
                        cellItems.append(item!)
                    }
                }
                targetSection.rows = cellItems
                sections.append(targetSection)
            }            
            if let backgroundData = responseData["backgroundSection"] as? [String: Any] {
                var cellItems: [OtherUserInfoItem] = []
                let backgroundSection = NITableViewModelSection.section() as! NITableViewModelSection
                for backgroundKey in backgroundkeys {
                    if let data = backgroundData[backgroundKey] as? [String: Any] {
                        let item = OtherUserInfoItem(attributes: data)
                        cellItems.append(item!)
                    }
                }
                backgroundSection.rows = cellItems
                sections.append(backgroundSection)
            }
            tableViewModel.sections = NSMutableArray(array: sections)
        }
    }
    
    override func showEmpty(_ show: Bool) {
        super.showEmpty(false)
    }
    
}

extension OtherUserInfoViewController {
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView(frame: CGRect(x: 0.0, y: 0.0, width: XDSize.screenWidth, height: 16.0), color: UIColor(0xF7F7F7))
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 0.0
        }
        return 16.0
    }
}
