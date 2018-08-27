//
//  MasterMajorDetailViewController.swift
//  xxd
//
//  Created by Lisen on 2018/7/11.
//  Copyright © 2018年 com.smartstudy. All rights reserved.
//

import UIKit

/// 研究生专业详情
class MasterMajorDetailViewController: SSTableViewController {
    var majorName: String?
    var majorId: Int = 0
    private var lastView: UIView?
    private lazy var tableHeaderView: UIView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: XDSize.screenWidth, height: 0.0))
    
    convenience init() {
        self.init(query: nil)
        tableViewStyle = .grouped
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = majorName
        tableViewActions.attach(to: MasterMajorCollegeItem.self, tap: { (object, target, indexPath) -> Bool in
            if let item = object as? MasterMajorCollegeItem {
                let detailVC: MasterMajorProjectDetailViewController = MasterMajorProjectDetailViewController()
                detailVC.programId = item.model.majorId
                self.navigationController?.pushViewController(detailVC, animated: true)
            }
            return true
        })
    }
    
    override func createModel() {
        let urlString = String(format: XD_MASTER_MAJOR_DETAITL, majorId)
        self.model = SSURLReqeustModel(httpMethod: .get, urlString: urlString, loadFromFile: false, isPaged: false)
    }
    
    override func didFinishLoad(with object: Any!) {
        if let responseObject = object as? [String: Any], let responseData = responseObject["data"] as? [String: Any] {
            if let featureContent = responseData["features"] as? String, !featureContent.isEmpty {
                self.addToTableHeaderView(title: "专业特点", content: featureContent)
            }
            if let factorContent = responseData["factors"] as? String, !factorContent.isEmpty {
                self.addToTableHeaderView(title: "择校因素", content: factorContent)
            }
            if let employmentContent = responseData["employment"] as? String, !employmentContent.isEmpty {
                self.addToTableHeaderView(title: "就业概况", content: employmentContent)
            }
            if let adviceContent = responseData["advices"] as? String, !adviceContent.isEmpty {
                self.addToTableHeaderView(title: "申请建议", content: adviceContent)
            }
            self.tableHeaderView.layoutIfNeeded()
            if let lastView = lastView {
                self.tableHeaderView.height = lastView.bottom
            } else {
                self.tableHeaderView.height = 0.0
            }
            self.tableView.tableHeaderView = self.tableHeaderView
            if let programData = responseData["programs"] as? [[String: Any]] {
                var items: [MasterMajorCollegeItem] = [MasterMajorCollegeItem]()
                for data in programData {
                    let item: MasterMajorCollegeItem = MasterMajorCollegeItem(attributes: data)
                    item.isTopThree = true
                    items.append(item)
                }
                items.last?.isLast = true
                tableViewModel.addObjects(from: items)
            }
        }
    }
    
    private func addToTableHeaderView(title: String, content: String) {
        let detailTextView: HighschoolDetailTextView = HighschoolDetailTextView(title: title, fontSize: 19.0)
        detailTextView.configureDetailContent(content, numberOfLines: 4.0, isNeedLinebreak: false)
        detailTextView.isHiddenSeparatorView = false
        tableHeaderView.addSubview(detailTextView)
        detailTextView.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            if lastView == nil {
                make.top.equalToSuperview()
            } else {
                make.top.equalTo(lastView!.snp.bottom)
            }
        }
        lastView = detailTextView
    }
    
    override func showEmpty(_ show: Bool) {
        super.showEmpty(false)
    }
    
    override func routerEvent(name: String, data: Dictionary<String, Any>) {
        if name == kTextUnfoldButtonTap, let increasedHeight = data["increasedHeight"] as? CGFloat {
            tableHeaderView.height += increasedHeight
            tableView.tableHeaderView = tableHeaderView
        }
    }
    
    @objc private func eventMoreButtonResponse(_ sender: UIButton) {
        let majorRankVC: MasterMajorCollegeRankViewController = MasterMajorCollegeRankViewController()
        majorRankVC.categoryId = majorId
        majorRankVC.rankName = majorName! + "排名"
        navigationController?.pushViewController(majorRankVC, animated: true)
    }
}

extension MasterMajorDetailViewController {
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 62.0
    }

    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 68.0
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView: UIView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: XDSize.screenWidth, height: 62.0), color: UIColor.white)
        let titleLabel: UILabel = UILabel(frame: CGRect(x: 16.0, y: 24.0, width: XDSize.screenWidth-32.0, height: 26.0), text: "看看有哪些项目可申请", textColor: XDColor.itemTitle, fontSize: 19.0, bold: true)
        headerView.addSubview(titleLabel)
        return headerView
    }

    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footerView: UIView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: XDSize.screenWidth-32.0, height: 68.0), color: UIColor.white)
        let moreBtn: UIButton = UIButton(frame: CGRect(x: 16.0, y: 8.0, width: XDSize.screenWidth-32.0, height: 40.0), title: "查看更多", fontSize: 15.0, titleColor: UIColor.white, backgroundColor: UIColor(0x078CF1), target: self, action: #selector(eventMoreButtonResponse(_:)))
        moreBtn.setImage(UIImage(named: "college_more_icon"), for: .normal)
        moreBtn.titleEdgeInsets = UIEdgeInsetsMake(0, -2, 0, -2)
        moreBtn.imageEdgeInsets = UIEdgeInsetsMake(0, 70.0, 0, -70)
        moreBtn.layer.cornerRadius = 6.0
        moreBtn.layer.masksToBounds = true
        footerView.addSubview(moreBtn)
        return footerView
    }
}
