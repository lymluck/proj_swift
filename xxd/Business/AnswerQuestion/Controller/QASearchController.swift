//
//  QASearchController.swift
//  xxd
//
//  Created by remy on 2018/1/29.
//  Copyright © 2018年 com.smartstudy. All rights reserved.
//

class QASearchController: XDSearchViewController {
    
    var type: QAListType = .latest
    private lazy var askBtn: UIView = {
        let view = UIView(frame: .zero, color: XDColor.main)
        view.layer.cornerRadius = 4
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(askTap(gestureRecognizer:))))
        let titleView = UILabel(text: "我要提问", textColor: UIColor.white, fontSize: 16)!
        view.addSubview(titleView)
        titleView.snp.makeConstraints { (make) in
            make.centerY.equalTo(view)
            make.centerX.equalTo(view).offset(11)
        }
        let imageView = UIImageView(frame: .zero, imageName: "question_add_white")!
        view.addSubview(imageView)
        imageView.snp.makeConstraints { (make) in
            make.centerY.equalTo(view)
            make.right.equalTo(titleView.snp.left).offset(-8)
        }
        return view
    }()
    
    override func addSearchList() {
        apiName = XD_API_QUESTION_LIST
        itemClass = QuestionItem.self
        tableViewActions.attach(to: QuestionItem.self, tap: { (object, target, indexPath) -> Bool in
            if let object = object as? QuestionItem {
                let vc = QuestionDetailViewController()
                vc.questionID = object.model.questionID
                XDRoute.pushToVC(vc)
            }
            return true
        })
    }
    
    override func showEmpty(_ show: Bool) {
        super.showEmpty(show)
        if emptyView != nil {
            emptyView.addSubview(askBtn)
            let titleLabel = (emptyView as! SSStateView).titleLabel!
            askBtn.snp.makeConstraints { (make) in
                make.top.equalTo(titleLabel.snp.bottom).offset(49)
                make.centerX.equalTo(emptyView)
                make.size.equalTo(CGSize(width: 164, height: 40))
            }
        }
    }
    
    override func didFinishLoad(with object: Any!) {
        if let data = (object as! [String : Any])["data"] as? [String : Any] {
            if let arr = data["data"] as? [[String : Any]] {
                var items = [QuestionItem]()
                for dict in arr {
                    let item = QuestionItem(model: QuestionModel.yy_model(with: dict)!, type: type)
                    items.append(item)
                }
                if !keyword.isEmpty {
                    navigationBar.rightItem.image = UIImage(named: "add_16")
                    navigationBar.setNeedsLayout()
                }
                tableViewModel.addObjects(from: items)
                tableViewModel.hasMore = items.count >= SSConfig.defaultPageSize
            }
        }
    }
    
    //MARK:- Action
    @objc private func askTap(gestureRecognizer: UIGestureRecognizer) {
        if XDUser.shared.hasLogin() {
            let vc = AskViewController()
            presentModalViewController(vc, animated: true, completion: nil)
        } else {
            let vc = SignInViewController()
            presentModalViewController(vc, animated: true, completion: nil)
        }
    }
}
