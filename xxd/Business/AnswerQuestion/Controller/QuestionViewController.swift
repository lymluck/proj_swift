//
//  QuestionViewController.swift
//  xxd
//
//  Created by remy on 2018/1/25.
//  Copyright © 2018年 com.smartstudy. All rights reserved.
//

enum QAListType {
    /// 推荐问答列表
    case recommend
    /// 最新问答列表
    case latest
    /// 我的问答列表
    case mine
    /// 搜索问答列表
    case search
}

class QuestionViewController: SSTableViewController {
    
    var isTag: Bool = false
    var type: QAListType = .latest
    var titleName = ""
    var keyword = ""
    private lazy var askBtn: UIButton = {
        let btn = UIButton(frame: .zero, title: "我要提问", fontSize: 16, titleColor: .white, target: self, action: #selector(askTap))!
        btn.backgroundColor = XDColor.main
        btn.layer.cornerRadius = 20
        return btn
    }()

    override func needNavigationBar() -> Bool {
        return !isTag
    }
    
    convenience init(type: QAListType, isTag: Bool = false) {
        self.init()
        self.type = type
        self.isTag = isTag
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        canDragRefresh = true
        canDragLoadMore = true
        title = titleName
        tableViewActions.attach(to: QuestionItem.self, tap: {
            [weak self] (object, target, indexPath) -> Bool in
            XDStatistics.click("19_A_question_detail_cell")
            if let object = object as? QuestionItem, let sSelf = self {
                let vc = QuestionDetailViewController()
                vc.questionID = object.model.questionID
                if sSelf.type == .mine && object.model.hasUnreadAnswers > 0 {
                    // 我的问答列表更新未读状态,列表项自己更新,tab状态通过通知获取状态更新
                    object.model.hasUnreadAnswers = 0
                    sSelf.tableView.reloadData()
                }
                XDRoute.pushToVC(vc)
            }
            return true
        })
        if type == .mine {
            // 更新问答列表
            NotificationCenter.default.addObserver(self, selector: #selector(createModel), name: .XD_NOTIFY_UPDATE_QA_LIST, object: nil)
        }
    }
    
    override func showEmpty(_ show: Bool) {
        super.showEmpty(show)
        if emptyView != nil {
            emptyView.top += 40
            emptyView.addSubview(askBtn)
            let titleLabel = (emptyView as! SSStateView).titleLabel!
            if type == .mine {
                titleLabel.text = "你还没有提过问题哦"
            }
            askBtn.snp.makeConstraints { (make) in
                make.top.equalTo(titleLabel.snp.bottom).offset(120)
                make.centerX.equalTo(emptyView)
                make.size.equalTo(CGSize(width: 200, height: 40))
            }
        }
    }
    
    override func createModel() {
        var urlStr = XD_API_QUESTION_LIST
        var params = [String : Any]()
        switch type {
        case .mine:
            urlStr = XD_API_MY_QUESTION_LIST
        case .recommend:
            urlStr = XD_API_RECOMMEND_QUESTION_LIST
        default:
            break
        }
        let model = SSURLReqeustModel(httpMethod: .get, urlString: urlStr, loadFromFile: false, isPaged: canDragLoadMore)
        if !keyword.isEmpty {
            params["keyword"] = keyword
        }
        // 只有最新和搜索需要传是否回答过
        if type == .latest || type == .search {
            params["answered"] = true
        }
        model?.parameters = params
        self.model = model
    }
    
    override func didFinishLoad(with object: Any!) {
        if let data = (object as! [String : Any])["data"] as? [String : Any] {
            if let arr = data["data"] as? [[String : Any]] {
                var items = [QuestionItem]()
                for dict in arr {
                    let item = QuestionItem(model: QuestionModel.yy_model(with: dict)!, type: type)
                    items.append(item)
                }
                tableViewModel.addObjects(from: items)
                tableViewModel.hasMore = items.count >= SSConfig.defaultPageSize
            }
        }
    }
    
    //MARK:- Action
    @objc private func askTap() {
        if XDUser.shared.hasLogin() {
            let vc = AskViewController()
            presentModalViewController(vc, animated: true, completion: nil)
        } else {
            let vc = SignInViewController()
            presentModalViewController(vc, animated: true, completion: nil)
        }
    }
}
