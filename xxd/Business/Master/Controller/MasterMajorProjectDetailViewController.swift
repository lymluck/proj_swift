//
//  MasterMajorProjectDetailViewController.swift
//  xxd
//
//  Created by Lisen on 2018/7/11.
//  Copyright © 2018年 com.smartstudy. All rights reserved.
//

import UIKit


/// 研究生专业项目详情
class MasterMajorProjectDetailViewController: SSTableViewController {
    
    var programId: Int = 0
    
    private var lastView: UIView?
    private lazy var tableHeaderView: UIScrollView = {
        let scrollView: UIScrollView = UIScrollView(frame: self.tableView.bounds)
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.scrollsToTop = false
        scrollView.alwaysBounceVertical = true
        scrollView.backgroundColor = XDColor.mainBackground
        let whiteView: UIView = UIView(frame: CGRect(x: 0.0, y: -XDSize.screenHeight, width: XDSize.screenWidth, height: XDSize.screenHeight), color: UIColor.white)
        scrollView.insertSubview(whiteView, at: 0)
        return scrollView
    }()
    private lazy var headerView: MasterMajorProgramHeaderView = MasterMajorProgramHeaderView(frame: CGRect(x: 0.0, y: 0.0, width: XDSize.screenWidth, height: 0.0))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationBar.bottomLine.isHidden = true
        tableView.backgroundColor = UIColor.white
        tableView.isScrollEnabled = false
    }
    
    override func createModel() {
        let urlString = String(format: XD_MASTER_PROGRAM_DETAIL, programId)
        self.model = SSURLReqeustModel(httpMethod: .get, urlString: urlString, loadFromFile: false, isPaged: false)
    }
    
    override func didFinishLoad(with object: Any!) {
        if let responseObject = object as? [String: Any], let responseData = responseObject["data"] as? [String: Any] {
            if let schoolDict = responseData["school"] as? [String: Any] {
                if let logoStr = schoolDict["logo"] as? String {
                    self.headerView.logoURL = logoStr
                }
                self.headerView.schoolName = schoolDict["chineseName"] as? String
            }
            self.headerView.chineseName = responseData["chineseName"] as? String
            self.headerView.englishName = responseData["englishName"] as? String
            self.headerView.rank = (responseData["categoryRank"] as? Int) ?? 0
            tableHeaderView.addSubview(headerView)
            self.tableHeaderView.layoutIfNeeded()
            headerView.height = ceil(headerView.rankLabel.bottom) + 36.0
            lastView = headerView
            if let introContent = responseData["introduction"] as? String, !introContent.isEmpty {
                addToTableHeaderView(title: "专业特点", content: introContent)
            }
            if let requireContent = responseData["requirements"] as? String, !requireContent.isEmpty {
                addToTableHeaderView(title: "申请要求", content: requireContent)
            }
            if let courseContent = responseData["courses"] as? String, !courseContent.isEmpty {
                addToTableHeaderView(title: "课程设置", content: courseContent, isCourseContent: true)
            }
            let stickView = UIView()
            tableHeaderView.addSubview(stickView)
            stickView.snp.makeConstraints { (make) in
                make.top.equalTo(lastView!.snp.bottom)
                make.left.bottom.equalToSuperview()
            }
            self.tableView.tableHeaderView = self.tableHeaderView
        }
    }
    
    override func showEmpty(_ show: Bool) {
        super.showEmpty(false)
    }
    
    private func addToTableHeaderView(title: String, content: String, isCourseContent: Bool = false) {
        let detailTextView: HighschoolDetailTextView = HighschoolDetailTextView(title: title, fontSize: 17.0)
        detailTextView.configureDetailContent(content, numberOfLines: 2.0, isNeedLinebreak: isCourseContent)
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
    
}
