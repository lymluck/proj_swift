//
//  CourseDetailEvaluationViewController.swift
//  xxd
//
//  Created by remy on 2018/1/19.
//  Copyright © 2018年 com.smartstudy. All rights reserved.
//

class CourseDetailEvaluationViewController: SSTableViewController, CourseDetailEvaluationHeaderDelegate {
    
    private var evaluationHeader: CourseEvaluationHeader?
    private var evaluationSectionHeader: CourseEvaluationSectionHeader?
    private var canComment = false
    private var hasCommented = false
    private var needRefresh = false
    private var localCanCommentFlag = false
    var courseID = 0
    
    override func needNavigationBar() -> Bool {
        return false
    }
    
    convenience init() {
        self.init(query: nil)
        tableViewStyle = .grouped
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reloadIfNeeded()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        canDragLoadMore = true

        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableViewAutomaticDimension
        
        NotificationCenter.default.addObserver(self, selector: #selector(hasWatchVideo(notification:)), name: NSNotification.Name(rawValue: XD_NOTIFY_HAS_WATCH_VIDEO), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(hasEvaluateCourse(notification:)), name: NSNotification.Name(rawValue: XD_NOTIFY_EVALUATE_COURSE_SUC), object: nil)
    }
    
    override func shouldReload() -> Bool {
        return super.shouldReload() || needRefresh
    }
    
    override func canShowModel() -> Bool {
        return true
    }
    
    override func createModel() {
        let urlStr = String(format: XD_API_COURSE_EVALUATION, courseID)
        model = SSURLReqeustModel(httpMethod: .get, urlString: urlStr, loadFromFile: false, isPaged: canDragLoadMore)
    }
    
    override func didFinishLoad(with object: Any!) {
        needRefresh = false
        if evaluationSectionHeader == nil {
            evaluationSectionHeader = CourseEvaluationSectionHeader()
        }
        #if TEST_MODE
            let switchOn = UserDefaults.standard.bool(forKey: "kUnlimitedEvaluateCourseKey")
            if switchOn {
                canComment = true
            }
        #endif
        if let data = (object as! [String : Any])["data"] as? [String : Any] {
            if let meta = data["meta"] as? [String : Any] {
                canComment = meta["canComment"] as! Bool
                hasCommented = meta["commented"] as! Bool
            }
            if canComment || !hasCommented {
                // 符合评价资格或未评价过,都展示评价入口
                if evaluationHeader == nil {
                    evaluationHeader = CourseEvaluationHeader(frame: CGRect(x: 0, y: 0, width: view.width, height: 142))
                    evaluationHeader?.delegate = self
                }
                tableView.tableHeaderView = evaluationHeader
            } else {
                tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: CGFloat.leastNonzeroMagnitude))
            }
            if let pagination = data["pagination"] as? [String : Any] {
                evaluationSectionHeader?.evaluationCount = pagination["count"] as! Int
            }
            if let datas = data["data"] as? [[String : Any]]{
                var items = [CourseEvaluationItem]()
                for (index, data) in datas.enumerated() {
                    let item = CourseEvaluationItem(attributes: data)!
                    item.isHiddenBottomLine = index == datas.count - 1
                    items.append(item)
                }
                if items.count > 0 {
                    items.last!.isHiddenBottomLine = false
                    tableView.tableFooterView = nil
                } else {
                    let footer = CourseEvaluationSectionHeader(frame: CGRect(x: 0, y: 0, width: XDSize.screenWidth, height: 46))
                    footer.evaluationCount = 0
                    tableView.tableFooterView = footer
                }
                canDragLoadMore = items.count > 0
                tableViewModel.addObjects(from: items)
                tableViewModel.hasMore = items.count >= SSConfig.defaultPageSize
            }
        }
    }
    
    //MARK:- Notification
    @objc func hasWatchVideo(notification: Notification) {
        if (notification.userInfo![QueryKey.CourseID] as! Int) == courseID && (notification.userInfo!["currentTime"] as! Double) > 30 {
            needRefresh = true
        }
    }
    
    @objc func hasEvaluateCourse(notification: Notification) {
        if (notification.userInfo![QueryKey.CourseID] as! Int) == courseID {
            if isViewAppearing {
                // 如果当前页面正在展示,则直接刷新,否则标记需要刷新
                reload()
            } else {
                needRefresh = false
            }
        }
    }
    
    //MARK:- UITableviewDelegate
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.leastNonzeroMagnitude
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return evaluationSectionHeader
    }
    
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return nil
    }
    
    //MARK:- CourseDetailEvaluationHeaderDelegate
    func courseDetailEvaluationHeaderDidStarBarPressed() {
        if XDUser.shared.hasLogin() {
            if !canComment && !hasCommented {
                return XDPopView.toast("course_evaluation_view_to_evaulate".localized)
            }
            view.isUserInteractionEnabled = false
            let vc = CourseDetailEvaluationBoardViewController()
            vc.courseID = courseID
            presentModalTranslucentViewController(vc, animated: false, completion: {
                [weak self] in
                self?.view.isUserInteractionEnabled = true
            })
        } else {
            let vc = SignInViewController()
            presentModalViewController(vc, animated: true, completion: nil)
        }
    }
}
