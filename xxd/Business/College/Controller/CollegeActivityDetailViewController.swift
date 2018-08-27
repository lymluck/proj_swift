//
//  CollegeActivityDetailViewController.swift
//  xxd
//
//  Created by Lisen on 2018/6/28.
//  Copyright © 2018年 com.smartstudy. All rights reserved.
//

import UIKit

private let contentViewWidth: CGFloat = XDSize.screenWidth-32.0
/// 院校活动详情界面
class CollegeActivityDetailViewController: SSTableViewController {
    
    var activityId: Int = 0
    private var isNoData: Bool = false
    private var phoneNum: String = "15810425405"
    private var itemTitles = [("项目预期成果", "expectedOutcome"), ("适合专业", "major"), ("活动时间", "activityTime"), ("活动地点", "place"), ("备注", "note")]
    private lazy var tableHeaderView: UIView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: XDSize.screenWidth, height: 0.0), color: UIColor(0xF5F6F7))
    private lazy var topBackgroundView: UIView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: XDSize.screenWidth, height: 0.0), color: UIColor.white)
    private lazy var nameLabel: UILabel = {
        let label: UILabel = UILabel(frame: CGRect(x: 16.0, y: 32.0, width: contentViewWidth, height: 0.0), text: "", textColor: XDColor.itemTitle, fontSize: 23.0, bold: true)
        label.numberOfLines = 0
        return label
    }()
    private lazy var topSeparatorView: UIView = UIView(frame: CGRect(x: 16.0, y: 0.0, width: 30.0, height: 1.0), color: XDColor.itemTitle)
    private lazy var introLabel: UILabel = {
        let label: UILabel = UILabel(frame: CGRect(x: 16.0, y: 0.0, width: contentViewWidth, height: 0.0), text: "", textColor: XDColor.itemTitle, fontSize: 16.0)
        label.numberOfLines = 0
        return label
    }()
    private lazy var introSeparatorView: UIView = UIView(frame: CGRect(x: 16.0, y: 0.0, width: contentViewWidth, height: 0.5), color: XDColor.itemLine)
    private lazy var consultBtn: UIButton =  {
        let button: UIButton = UIButton(frame: CGRect(x: 0.0, y: XDSize.screenHeight-XDSize.tabbarHeight, width: XDSize.screenWidth, height: XDSize.tabbarHeight), title: "我有兴趣, 电话咨询", fontSize: 16.0, titleColor: UIColor.white, backgroundColor: XDColor.main, target: self, action: #selector(eventButtonResponse(_:)))
        button.setBackgroundColor(UIColor(0x067DD8), for: .highlighted)
        button.titleEdgeInsets = UIEdgeInsets(top: UIDevice.isIPhoneX ? -34.0:0.0, left: 0.0, bottom: 0.0, right: 0.0)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "活动"
        view.addSubview(consultBtn)
    }
    
    override func createModel() {
        let urlString = String(format: XD_API_ACTIVITY_DETAIL, activityId)
        let model = SSURLReqeustModel(httpMethod: .get, urlString: urlString, loadFromFile: false, isPaged: false)
        self.model = model
    }
    
    override func didFinishLoad(with object: Any!) {
        if let responseObject = object as? [String: Any], let responseData = responseObject["data"] as? [String: Any] {
            isNoData = false
            loadResponseData(data: responseData)
        } else {
            isNoData = true
        }
    }
    
    override func showEmpty(_ show: Bool) {
        if show && !isNoData {
            super.showEmpty(false)
        } else {
            super.showEmpty(true)
        }
    }
    
    @objc private func eventButtonResponse(_ sender: UIButton) {
        guard let phoneURL = URL(string: "tel://" + phoneNum) else { return }
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(phoneURL, options: [: ], completionHandler: nil)
        } else {
            /// 如果不做版本区分的话, 该方法会在iOS 10系统上有2s左右的弹框延迟
            UIApplication.shared.openURL(phoneURL)
        }
    }
    
    private func loadResponseData(data: [String: Any]) {
        if let phone = data["phone"] as? String {
            phoneNum = phone
        }
        if let title = data["name"] as? String {
            nameLabel.setText(title, lineSpace: 5.0)
            nameLabel.height = title.heightForFont(UIFont.boldSystemFont(ofSize: 23.0), contentViewWidth, 31.0).rounded()
            topBackgroundView.addSubview(nameLabel)
            topSeparatorView.top = nameLabel.bottom + 24.0
            topBackgroundView.addSubview(topSeparatorView)
            topBackgroundView.height = topSeparatorView.bottom
        }
        if let introduction = data["introduction"] as? String {
            introLabel.setText(introduction, lineSpace: 5.0)
            introLabel.top = topBackgroundView.bottom + 20.0
            introLabel.height = introduction.heightForFont(introLabel.font, contentViewWidth, 24.0)
            topBackgroundView.addSubview(introLabel)
            introSeparatorView.top = introLabel.bottom + 20.0
            topBackgroundView.addSubview(introSeparatorView)
            topBackgroundView.height = introSeparatorView.bottom
        }
        tableHeaderView.height = topBackgroundView.height
        tableHeaderView.addSubview(topBackgroundView)
        for value in itemTitles {
            if let content = data[value.1] as? String, !content.isEmpty {
                let itemView: ActivityItemView = ActivityItemView(frame: CGRect(x: 0.0, y: tableHeaderView.bottom, width: XDSize.screenWidth, height: 0.0))
                itemView.title = value.0
                if value.0 == "活动时间" {
                    if let time = data["registrationDeadline"] as? String, !time.isEmpty {
                        itemView.content = "报名截止时间: " + time
                        itemView.time = "活动起止时间: " + content
                    } else {
                        itemView.content = "活动起止时间: " + content
                    }
                } else {
                    itemView.content = content
                }
                tableHeaderView.addSubview(itemView)
                tableHeaderView.height = itemView.bottom
            }
        }
        (tableHeaderView.subviews.last as? ActivityItemView)?.hideSeparatorView = true
        tableHeaderView.height += XDSize.tabbarHeight
        tableView.tableHeaderView = tableHeaderView
    }
    
}
