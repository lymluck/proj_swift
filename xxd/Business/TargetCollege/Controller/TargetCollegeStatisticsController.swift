//
//  TargetCollegeStatisticsController.swift
//  xxd
//
//  Created by Lisen on 2018/6/4.
//  Copyright © 2018年 com.smartstudy. All rights reserved.
//

import UIKit

/// 意向大学数据统计
class TargetCollegeStatisticsController: SSTableViewController {
    var collegeId: Int = 0
    var collegeName: String?
    private let sectionTitles: [String] = ["他们都选择了该校", "他们还选择了这些学校"]
    private lazy var buttonBackgroundView: UIView = UIView(frame: CGRect(x: 0.0, y: tableView.bottom, width: XDSize.screenWidth, height: XDSize.tabbarHeight), color: UIColor(0x0C83FA))
    private lazy var detailButton: UIButton = UIButton(frame: CGRect(x: 0.0, y: 0.0, width: XDSize.screenWidth, height: 49.0), title: "查看该校申请信息", fontSize: 16.0, titleColor: UIColor.white, backgroundColor: UIColor(0x0C83FA), target: self, action: #selector(eventButtonResponse(_:)))
    private lazy var sectionFooterView: UIView = {
        let view: UIView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: XDSize.screenWidth, height: 96.0), color: UIColor.white)
        let button: UIButton = UIButton(frame: CGRect.zero, title: "查看全部同学", fontSize: 14.0, titleColor: UIColor.white, backgroundColor: UIColor(0x0C83FA), target: self, action: #selector(eventButtonResponse(_:)))
        button.tag = 1
        let bottomLine: UIView = UIView(frame: CGRect(x: 0.0, y: 84.0, width: XDSize.screenWidth, height: 12.0), color: XDColor.mainBackground)
        button.layer.cornerRadius = 6.0
        button.layer.masksToBounds = true
        view.addSubview(button)
        view.addSubview(bottomLine)
        button.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
            make.width.equalTo(180.0)
            make.height.equalTo(36.0)
        }
        return view
    }()
    
    convenience init() {
        self.init(query: nil)
        tableViewStyle = .grouped
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = collegeName
        tableView.frame = CGRect(x: 0, y: XDSize.topHeight, width: XDSize.screenWidth, height: XDSize.screenHeight - XDSize.tabbarHeight - XDSize.topHeight)
        detailButton.setBackgroundColor(UIColor(0x0C83FA), for: UIControlState.highlighted)
        buttonBackgroundView.addSubview(detailButton)
        view.addSubview(buttonBackgroundView)
        tableViewActions.attach(to: TargetCollegeStatUserCellItem.self, tap: { (object, target, indexPath) -> Bool in
            if let item = object as? TargetCollegeStatUserCellItem {
                if XDUser.shared.model.isPrivacy {
                    XDPopView.toast("要查看别人的选校，需要先设置自己的选校可见", self.view)
                } else {
                    let vc = TargetCollegeOtherDetailViewController()
                    vc.userId = item.model.userId
                    vc.userName = item.model.name
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }
            return true
        })
        tableViewActions.attach(to: TargetCollegeStatSchoolCellItem.self, tap: { (object, target, indexPath) -> Bool in
            if let item = object as? TargetCollegeStatSchoolCellItem {
                let vc = CollegeDetailViewController()
                vc.collegeID = item.model.collegeId
                self.navigationController?.pushViewController(vc, animated: true)
            }
            return true
        })
    }
    
    override func createModel() {
        super.createModel()
        let urlString = String(format: XD_TARGET_COLLEGE_STAT, collegeId)
        let model = SSURLReqeustModel(httpMethod: .get, urlString: urlString, loadFromFile: false, isPaged: false)
        self.model = model
    }
    
    override func didFinishLoad(with object: Any!) {
        if let data = (object as! [String: Any])["data"] as? [String: Any] {
            if let statModel: TargetCollegeStatModel = TargetCollegeStatModel.yy_model(with: data) {
                if tableView.tableHeaderView == nil {
                    let tableHeaderView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: XDSize.screenWidth, height: 0.0))
                    let numberView: TargetCollegePeopleNumView = TargetCollegePeopleNumView(frame: CGRect(x: 0.0, y: 0.0, width: XDSize.screenWidth, height: 193.0), models: statModel.matchTypes!)
                    tableHeaderView.addSubview(numberView)
                    let abroadTimeChartView: TargetCollegeTimeView = TargetCollegeTimeView(frame: CGRect(x: 0.0, y: numberView.bottom+12.0, width: XDSize.screenWidth, height: 336.0))
                    abroadTimeChartView.models = statModel.years
                    tableHeaderView.addSubview(abroadTimeChartView)
                    tableHeaderView.height = abroadTimeChartView.bottom + 12.0
                    tableView.tableHeaderView = tableHeaderView
                    var sections = [NITableViewModelSection]()
                    
                    if let users = statModel.watchers, users.count > 0 {
                        var cellItems: [TargetCollegeStatUserCellItem] = []
                        let userSection = NITableViewModelSection.section() as! NITableViewModelSection
                        for watcher in users {
                            let item = TargetCollegeStatUserCellItem(model: watcher)
                            cellItems.append(item)
                        }
                        userSection.rows = cellItems
                        sections.append(userSection)
                    }
                    
                    if let schools = statModel.topSchools, schools.count > 0 {
                        var cellItems: [TargetCollegeStatSchoolCellItem] = []
                        let schoolSection = NITableViewModelSection.section() as! NITableViewModelSection
                        for school in schools {
                            let item: TargetCollegeStatSchoolCellItem = TargetCollegeStatSchoolCellItem(model: school)
                            cellItems.append(item)
                        }
                        cellItems.last?.isLast = true
                        schoolSection.rows = cellItems
                        sections.append(schoolSection)
                    }
                    tableViewModel.sections = NSMutableArray(array: sections)
                }
            }
        }
    }
    
    override func showEmpty(_ show: Bool) {
        super.showEmpty(false)
    }
    
    @objc private func eventButtonResponse(_ sender: UIButton) {
        if sender.tag == 1 {
            let vc: TargetCollegeOthersViewController = TargetCollegeOthersViewController()
            vc.collegeId = self.collegeId
            navigationController?.pushViewController(vc, animated: true)
        } else {
            let vc = CollegeIntroduceViewController()
            vc.collegeID = collegeId
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
}

// MARK: UITableViewDelegate
extension TargetCollegeStatisticsController {
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50.0
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == 0 {
            return 96.0
        }
        return 12.0
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView: UIView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: XDSize.screenWidth, height: 50.0), color: UIColor.white)
        let titleLabel: UILabel = UILabel(frame: CGRect(x: 16.0, y: 24.0, width: XDSize.screenWidth-32.0, height: 18.0), text: "", textColor: UIColor(0x26343F), fontSize: 18.0, bold: true)
        titleLabel.text = sectionTitles[section]
        headerView.addSubview(titleLabel)
        return headerView
    }
    
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if section == 0 {
            return sectionFooterView
        }
        return nil
    }
}
