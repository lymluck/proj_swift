//
//  CounsellorDetailViewController.swift
//  xxd
//
//  Created by remy on 2018/3/9.
//  Copyright © 2018年 com.smartstudy. All rights reserved.
//

import SwiftyJSON

let TeacherName = "TeacherName"

class TeacherAnsweredListViewController: SSTableViewController {

    private var counsellorID: String = ""
    private var teacherName: String = ""
//    var infoView: CounsellorInfoView!
    var infoModel: CounsellorDetailModel!
    
    override init!(query: [AnyHashable : Any]!) {
        super.init(query: query)
        
        counsellorID = query?[IMUserID] as? String ?? ""
        teacherName = query?[TeacherName] as? String ?? ""
        canDragRefresh = true
        canDragLoadMore = true
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationBar.centerTitle = teacherName + "的回答"
        
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
        if show && infoModel != nil {
            super.showEmpty(false)
        } else {
            super.showEmpty(show)
        }
    }
    
    override func createModel() {
        let model = SSURLReqeustModel(httpMethod: .get, urlString: XD_API_QUESTION_LIST, loadFromFile: false, isPaged: canDragLoadMore)
        if let indexId = Int(counsellorID.components(separatedBy: "#").last!) {
            model?.parameters = ["answeredCounsellorId": indexId, "answered": true]
            self.model = model
        }
    }
    
    override func didFinishLoad(with object: Any!) {
        let json = JSON(object)
        
        if let data = json["data"]["data"].arrayObject as? [[AnyHashable : Any]] {
            var items = [QuestionItem]()
            for dict in data {
                let item = QuestionItem(model: QuestionModel.yy_model(with: dict)!, type: .search)
                items.append(item)
            }
//                infoView.answerCount = items.count
            tableViewModel.addObjects(from: items)
            tableViewModel.hasMore = items.count >= SSConfig.defaultPageSize
        }
    }
}
