//
//  ExamOthersViewController.swift
//  xxd
//
//  Created by remy on 2018/5/29.
//  Copyright © 2018年 com.smartstudy. All rights reserved.
//

class ExamOthersViewController: SSTableViewController {
    
    private lazy var emptyPlanView: UIView = {
        let view = UIView(frame: CGRect(x: 0, y: XDSize.topHeight, width: XDSize.screenWidth, height: XDSize.visibleHeight))
        self.view.addSubview(view)
        
        let label = UILabel(frame: .zero, text: "目前还没有人备考", textColor: XDColor.itemTitle, fontSize: 16)!
        label.numberOfLines = 0
        label.textAlignment = .center
        view.addSubview(label)
        label.snp.makeConstraints({ (make) in
            make.center.equalToSuperview()
            make.width.equalTo(160)
        })
        
        return view
    }()
    var examModel: ExamDayModel!
    
    override init!(query: [AnyHashable : Any]!) {
        super.init(query: query)
        examModel = query["model"] as! ExamDayModel
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        canDragRefresh = true
        canDragLoadMore = true
        title = "备考\(examModel.examStr)（\(examModel.dateMMdd)）"
    }
    
    override func showEmpty(_ show: Bool) {
        emptyPlanView.isHidden = !show
    }
    
    override func createModel() {
        let urlStr = String(format: XD_API_EXAM_SCHEDULE_OTHERS, examModel.examID)
        let model = SSURLReqeustModel(httpMethod: .get, urlString: urlStr, loadFromFile: false, isPaged: canDragLoadMore)
        self.model = model
    }
    
    override func didFinishLoad(with object: Any!) {
        if let data = (object as! [String : Any])["data"] as? [String : Any] {
            if let arr = data["data"] as? [[String : Any]] {
                var items = [ExamOthersItem]()
                for dict in arr {
                    let item = ExamOthersItem(model: ExamineeModel.yy_model(with: dict)!)
                    items.append(item)
                }
                tableViewModel.addObjects(from: items)
                tableViewModel.hasMore = items.count >= SSConfig.defaultPageSize
            }
        }
    }
}
