//
//  ExamPlanViewController.swift
//  xxd
//
//  Created by remy on 2018/5/23.
//  Copyright © 2018年 com.smartstudy. All rights reserved.
//

class ExamPlanViewController: SSTableViewController {
    
    private lazy var emptyPlanView: UIView = {
        let view = UIView(frame: CGRect(x: 0, y: XDSize.topHeight, width: XDSize.screenWidth, height: XDSize.contentHeight), color: .white)
        self.view.addSubview(view)
        
        let label = UILabel(frame: .zero, text: "你还没有备考计划，快去添加吧", textColor: XDColor.itemTitle, fontSize: 16)!
        label.numberOfLines = 0
        label.textAlignment = .center
        view.addSubview(label)
        label.snp.makeConstraints({ (make) in
            make.center.equalToSuperview()
            make.width.equalTo(160)
        })
        
        return view
    }()
    private lazy var addPlanView: UIView = {
        let view = UIView(frame: CGRect(x: 0, y: XDSize.screenHeight - 49, width: XDSize.screenWidth, height: 49), color: XDColor.mainBackground)
        self.view.addSubview(view)
        
        let label = UILabel(frame: .zero, text: "继续添加考试计划", textColor: XDColor.itemTitle, fontSize: 16)!
        view.addSubview(label)
        label.snp.makeConstraints({ (make) in
            make.centerY.equalToSuperview()
            make.centerX.equalToSuperview().offset(-10)
        })
        
        let imageView = UIImageView(image: UIImage(named: "add_16")!.tint(XDColor.itemTitle))
        view.addSubview(imageView)
        imageView.snp.makeConstraints({ (make) in
            make.centerY.equalToSuperview()
            make.left.equalTo(label.snp.right).offset(4)
        })
        
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "我的考试计划"
        tableView.backgroundColor = UIColor.white
        navigationBar.leftItem.text = nil
        navigationBar.rightItem.text = "done".localized
        
        tableView.height = XDSize.contentHeight
        
        addPlanView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(addPlanTap(_:))))
    }
    
    override func rightActionTap() {
        cancelActionTap()
    }
    
    override func showEmpty(_ show: Bool) {
        emptyPlanView.isHidden = !show
    }
    
    override func createModel() {
        let model = SSURLReqeustModel(httpMethod: .get, urlString: XD_API_EXAM_SCHEDULE_MINE, loadFromFile: false, isPaged: false)
        self.model = model
    }
    
    override func didFinishLoad(with object: Any!) {
        if let data = object as? [String : Any] {
            if let arr = data["data"] as? [[String : Any]] {
                var items = [ExamPlanItem]()
                for dict in arr {
                    let item = ExamPlanItem(model: ExamDayModel.yy_model(with: dict)!)
                    items.append(item)
                }
                tableViewModel.addObjects(from: items)
            }
        }
    }
}

//MARK:- Action
extension ExamPlanViewController {
    
    @objc func addPlanTap(_ gestureRecognizer: UIGestureRecognizer) {
        cancelActionTap()
    }
}
