//
//  XDSearchViewController.swift
//  xxd
//
//  Created by remy on 2018/1/24.
//  Copyright © 2018年 com.smartstudy. All rights reserved.
//

enum XDSearchDataType: Int {
    case custom
    case college
    case highschool
    case admission
    case rank
    case rankCategory
    case target
    case information
    case major
    case project
    case course
    /// 艺术院校
    case artMajor
}

@objc protocol XDSearchViewDelegate: class {
    
    @objc optional func didReturnAfterInput(text: String)
    @objc optional func didCancelSearch(vc: XDSearchViewController)
}

class XDSearchViewController: SSTableViewController, XDTextFieldViewDelegate {
    
    weak var delegate: XDSearchViewDelegate?
    var isKeepSearch = true
    var isBackWhenCancel = false
    var cancelFirstResponder = false
    var keyword = ""
    var placeholder = "" {
        didSet {
            textFieldView.placeholder = placeholder
        }
    }
    var customWrap: UIView? {
        didSet {
            if isViewLoaded {
                customWrap?.removeFromSuperview()
                if let customWrap = customWrap {
                    customWrap.frame = CGRect(x: 0, y: XDSize.topHeight, width: XDSize.screenWidth, height: XDSize.visibleHeight)
                    view.insertSubview(customWrap, at: 0)
                }
            }
        }
    }
    var extraParams: [String : Any]?
    var apiName = ""
    var itemClass: SSCellItem.Type!
    private var type: XDSearchDataType!
    private var bgView: UIView!
    private var topView: UIView!
    private lazy var textFieldView: XDTextFieldView = {
        let view = XDTextFieldView(frame: CGRect(x: 8, y: XDSize.statusBarHeight + 8, width: XDSize.screenWidth - 58, height: XDSize.topBarHeight - 16))
        view.backgroundColor = UIColor.white
        view.roundCorner = true
        view.textColor = XDColor.itemTitle
        view.fontSize = 15
        view.placeholder = "search".localized
        view.layer.borderWidth = 0.5
        view.layer.borderColor = XDColor.itemLine.cgColor
        view.delegate = self
        view.text = keyword
        return view
    }()
    
    convenience init(type: XDSearchDataType) {
        self.init(query: nil)
        self.type = type
        canDragLoadMore = true
        clearTableViewWhenLoadingNew = true
    }
    
    convenience init() {
        self.init(type: XDSearchDataType.custom)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        view.endEditing(true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if !cancelFirstResponder {
            textFieldView.textField.becomeFirstResponder()
            cancelFirstResponder = true
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        
        if let customWrap = customWrap {
            customWrap.frame = CGRect(x: 0, y: XDSize.topHeight, width: XDSize.screenWidth, height: XDSize.visibleHeight)
            customWrap.isHidden = !keyword.isEmpty
            view.addSubview(customWrap)
        }
        bgView = UIView(frame: view.bounds)
        bgView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        bgView.backgroundColor = UIColor.white
        view.insertSubview(bgView, at: 0)
        
        topView = UIView(frame: CGRect(x: 0, y: 0, width: XDSize.screenWidth, height: XDSize.topHeight), color: XDColor.mainBackground)
        view.addSubview(topView)
        
        topView.addSubview(textFieldView)
        
        let cancelBtn = UIButton(frame: CGRect(x: XDSize.screenWidth - 50, y: XDSize.statusBarHeight, width: 42, height: XDSize.topBarHeight))
        cancelBtn.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        cancelBtn.setTitleColor(XDColor.main, for: .normal)
        cancelBtn.contentHorizontalAlignment = .right
        cancelBtn.setTitle("cancel".localized, for: .normal)
        cancelBtn.addTarget(self, action: #selector(cancelTap(sender:)), for: .touchUpInside)
        topView.addSubview(cancelBtn)
        topView.addSubview(UIView(frame: CGRect(x: 0, y: XDSize.topHeight - XDSize.unitWidth, width: XDSize.screenWidth, height: XDSize.unitWidth), color: XDColor.mainLine))
        
        tableView.keyboardDismissMode = .onDrag
        addSearchList()
    }
    
    func addSearchList() {
        switch type {
        case .college:
            apiName = XD_API_COLLEGE_LIST
            itemClass = CollegeItem.self
            tableViewActions.attach(to: CollegeItem.self, tap: { (object, target, indexPath) -> Bool in
                if let object = object as? CollegeItem {
                    let vc = CollegeDetailViewController()
                    vc.collegeID = object.model.collegeID
                    XDRoute.pushToVC(vc)
                }
                return true
            })
        case .highschool:
            apiName = XD_HSAPI_RANK_LIST
            itemClass = HighSchoolListItem.self
            tableViewActions.attach(to: HighSchoolListItem.self, tap: { (object, target, indexPath) -> Bool in
                if let object = object as? HighSchoolListItem {
                    let vc = HighschoolDetailViewController()
                    vc.highschoolID = object.model.schoolId
                    XDRoute.pushToVC(vc)
                }
                return true
            })
        case .admission:
            apiName = XD_API_COLLEGE_LIST
            itemClass = CollegeItem.self
            tableViewActions.attach(to: CollegeItem.self, tap: { (object, target, indexPath) -> Bool in
                if let object = object as? CollegeItem {
                    let vc = AdmissionTestViewController()
                    vc.collegeID = object.model.collegeID
                    vc.isFromList = true
                    XDRoute.pushToVC(vc)
                }
                return true
            })
        case .rank:
            apiName = XD_API_COLLEGE_RANKS
            itemClass = RankCollegeItem.self
            tableViewActions.attach(to: RankCollegeItem.self, tap: { (object, target, indexPath) -> Bool in
                if let object = object as? RankCollegeItem, object.model.collegeID > 0 {
                    let vc = CollegeDetailViewController()
                    vc.collegeID = object.model.collegeID
                    XDRoute.pushToVC(vc)
                }
                return true
            })
        case .rankCategory:
            apiName = XD_API_RANK_CATEGORIES_SEARCH
            itemClass = RankItem.self
            tableViewActions.attach(to: RankItem.self, tap: { (object, target, indexPath) -> Bool in
                if let object = object as? RankItem {
                    let vc = RankListViewController()
                    vc.rankCategoryID = object.model.categoryID
                    vc.titleName = object.model.name
                    XDRoute.pushToVC(vc)
                }
                return true
            })
        case .target:
            apiName = XD_API_COLLEGE_LIST
            itemClass = RankCollegeItem.self
            tableViewActions.attach(to: RankCollegeItem.self, tap: { (object, target, indexPath) -> Bool in
                if let object = object as? RankCollegeItem, object.model.targetID > 0 {
                    let vc = CollegeDetailViewController()
                    vc.collegeID = object.model.targetID
                    XDRoute.pushToVC(vc)
                }
                return true
            })
        case .information:
            apiName = XD_API_INFO_WITH_TAG
            itemClass = InformationItem.self
            tableViewActions.attach(to: InformationItem.self, tap: { (object, target, indexPath) -> Bool in
                if let object = object as? InformationItem {
                    let query: [String : Any] = [QueryKey.URLPath:object.model.URLPath, "barType":WebViewControllerBarType.gradient]
                    XDRoute.pushWebVC(query)
                }
                return true
            })
        case .major:
            apiName = XD_API_MAJOR_LIB_LIST
            itemClass = MajorItem.self
            tableViewActions.attach(to: MajorItem.self, tap: { (object, target, indexPath) -> Bool in
                if let object = object as? MajorItem {
                    let query: [String : Any] = [QueryKey.URLPath:object.model.URLPath, QueryKey.TitleName:object.model.name]
                    XDRoute.pushWebVC(query)
                }
                return true
            })
        case .course:
            apiName = XD_API_COURSE_LIST
            itemClass = CourseSearchItem.self
            tableViewActions.attach(to: CourseSearchItem.self, tap: { (object, target, indexPath) -> Bool in
                if let object = object as? CourseSearchItem {
                    let vc = CourseDetailViewController()
                    vc.courseID = object.model.courseID
                    XDRoute.pushToVC(vc)
                }
                return true
            })
        case .artMajor:
            apiName = XD_API_ART_RANKS
            itemClass = MajorCountryRankItem.self
            tableViewActions.attach(to: MajorCountryRankItem.self, tap: { (object, target, indexPath) -> Bool in
                if let item = object as? MajorCountryRankItem {
                    let vc = ArtMajorCollegeRankListViewController()
                    vc.majorId = item.model.artCategoryId
                    vc.titleName = item.model.pureName
                    XDRoute.pushToVC(vc)
                }
                return true
            })
        case .project:
            // 项目列表暂时没入口
            break
        default:
            break
        }
    }
    
    override func createModel() {
        if !keyword.isEmpty, let model = SSURLReqeustModel(httpMethod: .get, urlString: apiName, loadFromFile: true, isPaged: canDragLoadMore) {
            var params: [String: Any] = ["keyword":keyword]
            if let extraParams = extraParams {
                for (key, value) in extraParams {
                    params[key] = value
                }
            }
            model.parameters = params
            self.model = model
        }
    }
    
    override func didFinishLoad(with object: Any!) {
        if let data = object as? [String : Any] {
            var arr: [[String : Any]]!
            if type == .course || type == .artMajor {
                arr = data["data"] as! [[String : Any]]
            } else {
                arr = (data["data"] as! [String : Any])["data"] as! [[String : Any]]
            }
            var items = [SSCellItem]()
            for dict in arr {
                let item = itemClass.init(attributes: dict)!
                items.append(item)
            }
            if !keyword.isEmpty {
                tableViewModel.addObjects(from: items)
                tableViewModel.hasMore = items.count >= SSConfig.defaultPageSize
            }
        }
    }
    
    override func showLoading(_ show: Bool) {}
    
    override func showError(_ show: Bool) {}
    
    override func showEmpty(_ show: Bool) {
        if keyword.isEmpty {
            super.showEmpty(false)
        } else {
            super.showEmpty(show)
        }
    }
    
    private func changeAfterInput(_ text: String) {
        let text = text.trimmingCharacters(in: .whitespaces)
        guard text != keyword else { return }
        keyword = text
        clearTableView()
        // 没搜索词且没数据时,才透明
        bgView.isHidden = text.isEmpty
        customWrap?.isHidden = !text.isEmpty
        // 如果关键字为空,则说明都不显示
        if !text.isEmpty {
            createModel()
        }
        invalidateModel()
        delegate?.didReturnAfterInput?(text: text)
    }
    
    private func clearTableView() {
        if tableViewModel.sections != nil {
            tableViewModel.sections.removeAllObjects()
            tableView.mj_footer = nil
            tableView.reloadData()
        }
    }
    
    //MARK:- Action
    @objc func cancelTap(sender: UIButton) {
        delegate?.didCancelSearch?(vc: self)
        if isBackWhenCancel {
            backActionTap()
        } else {
            if let _ = presentingViewController {
                dismiss(animated: false, completion: nil)
            } else {
                view.removeFromSuperview()
                removeFromParentViewController()
            }
        }
    }
    
    //MARK:- XDTextFieldViewDelegate
    func textFieldDidChanged(textField: UITextField) {
        if isKeepSearch {
            changeAfterInput(textField.text ?? "")
        }
    }
}
