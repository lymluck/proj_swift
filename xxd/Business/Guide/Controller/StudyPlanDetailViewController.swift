//
//  StudyPlanDetailViewController.swift
//  xxd
//
//  Created by remy on 2018/1/15.
//  Copyright © 2018年 com.smartstudy. All rights reserved.
//

import WMPageController

private var kTagBarHeight: CGFloat = 40

class StudyPlanDetailViewController: SSViewController, EditInfoViewControllerDelegate, WMPageControllerDelegate, WMPageControllerDataSource {
    
    private var params = [String : String]()
    private var options: [String : Any]?
    private var selectedItem: XDItemView!
    private var currentIndex = 0
    private var _dataList = [StudyTimelineModel]()
    var dataList = [Any]() {
        didSet {
            var arr = [StudyTimelineModel]()
            for (index, data) in dataList.enumerated() {
                if let data = data as? [String : Any], let model = StudyTimelineModel.yy_model(with: data) {
                    if model.isCurrentGrade {
                        currentIndex = index
                    }
                    if let stages = data["stages"] as? [[String : Any]] {
                        var subs = [StudyTimelineStageModel]()
                        for data in stages {
                            if let model = StudyTimelineStageModel.yy_model(with: data) {
                                subs.append(model)
                            }
                        }
                        model.subModels = subs
                    }
                    arr.append(model)
                }
            }
            _dataList = arr
        }
    }
    lazy var makePlanView: MakeStudyPlanView = {
        let view = MakeStudyPlanView(frame: CGRect(x: 0, y: XDSize.topHeight, width: XDSize.screenWidth, height: XDSize.visibleHeight))
        return view
    }()
    private lazy var pageController: WMPageController = {
        let vc = WMPageController()
        vc.delegate = self
        vc.dataSource = self
        vc.titleColorSelected = XDColor.main
        vc.titleColorNormal = XDColor.itemText
        vc.titleSizeNormal = 15
        vc.titleSizeSelected = 15
        vc.menuViewStyle = .line
        vc.progressHeight = 2
        vc.progressWidth = (XDSize.screenWidth / CGFloat(_dataList.count)).rounded(.up)
        vc.progressColor = XDColor.main
        vc.menuItemWidth = vc.progressWidth
        vc.scrollEnable = false
        return vc
    }()
    private lazy var timeline = StudyTimelineViewController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "留学规划"
        
        if _dataList.count > 0 {
            addTimelineView()
        } else {
            view.addSubview(makePlanView)
        }
    }
    
    func addTimelineView() {
        addChildViewController(timeline)
        timeline.dataList = _dataList
        let top = topOffset + kTagBarHeight
        timeline.view.frame = CGRect(x: 0, y: top, width: XDSize.screenWidth, height: view.height - top)
        view.addSubview(timeline.view)
        // 因为纵向展示,所以屏蔽 WMPageController 内容部分
        addChildViewController(pageController)
        view.insertSubview(pageController.view, belowSubview: navigationBar)
        pageController.selectIndex = Int32(currentIndex)
        perform(#selector(delayForTimeline), with: nil, afterDelay: 0)
    }
    
    func reloadData(_ vc: EditInfoViewController) {
        if let options = options {
            let paramKey = selectedItem.info["paramKey"] as! String
            if paramKey == "currentGradeId" {
                let dict = options["currentGradeId"] as! [String : Any]
                if let key = params["targetDegreeId"] {
                    vc.dataList = dict[key] as! [EditInfoModel]
                }
            } else {
                vc.dataList = options[paramKey] as! [EditInfoModel]
            }
        } else {
            XDPopView.loading()
            SSNetworkManager.shared().get(XD_API_ABROAD_TIMELINES_OPTIONS, parameters: nil, success: { [weak self] (task, responseObject) in
                let data = (responseObject as? [String : Any])!["data"] as! [String : Any]
                if let strongSelf = self {
                    strongSelf.options = [String : Any]()
                    var degrees = [EditInfoModel]()
                    var grades = [String : [EditInfoModel]]()
                    
                    let targetDegrees = data["targetDegrees"] as! [[String : Any]]
                    for degree in targetDegrees {
                        let model = EditInfoModel.yy_model(with: degree)!
                        degrees.append(model)
                        grades[model.value] = [EditInfoModel]()
                    }
                    strongSelf.options!["targetDegreeId"] = degrees
                    
                    let currentGrades = data["currentGrades"] as! [[String : Any]]
                    for grade in currentGrades {
                        let model = EditInfoModel.yy_model(with: grade)!
                        let targetDegreeId = grade["targetDegreeId"] as! String
                        grades[targetDegreeId]!.append(model)
                    }
                    strongSelf.options!["currentGradeId"] = grades
                    
                    strongSelf.reloadData(vc)
                }
                XDPopView.hide()
            }) { (task, error) in
                XDPopView.toast(error.localizedDescription)
            }
        }
    }
    
    //MARK:- Action
    override func backActionTap() {
        navigationController?.popToRootViewController(animated: true)
    }
    
    @objc func delayForTimeline() {
        timeline.moveToStagePoint()
    }
    
    override func routerEvent(name: String, data: Dictionary<String, Any>) {
        if name == kEventStudyPlanItemTap {
            selectedItem = data["item"] as! XDItemView
            let title = (selectedItem.info["title"] as! UILabel).text!
            let value = selectedItem.info["value"] as! String
            let vc = EditInfoViewController(title: title, type: .list)
            vc.defaultValue = value
            vc.delegate = self
            reloadData(vc)
            navigationController?.pushViewController(vc, animated: true)
        } else if name == kEventStudyPlanMakeTap {
            XDPopView.loading()
            SSNetworkManager.shared().post(XD_API_ABROAD_TIMELINES, parameters: params, success: { [weak self] (task, responseObject) in
                if let strongSelf = self {
                    strongSelf.makePlanView.removeFromSuperview()
                    strongSelf.dataList = (responseObject as? [String : Any])!["data"] as! [Any]
                    strongSelf.addTimelineView()
                }
                XDPopView.hide()
            }) { (task, error) in
                XDPopView.toast(error.localizedDescription)
            }
        } else if name == kEventMoveTimeline {
            currentIndex = data["index"] as! Int
            pageController.selectIndex = Int32(currentIndex)
        }
    }
    
    //MARK:- WMPageControllerDataSource
    func pageController(_ pageController: WMPageController, preferredFrameFor menuView: WMMenuView) -> CGRect {
        return CGRect(x: 0, y: topOffset, width: XDSize.screenWidth, height: kTagBarHeight)
    }
    
    func pageController(_ pageController: WMPageController, preferredFrameForContentView contentView: WMScrollView) -> CGRect {
        // 不能是CGRect.zero,手势返回触发didEnterViewController,selectIndex会不正确
        let top = topOffset + kTagBarHeight
        return CGRect(x: 0, y: top, width: XDSize.screenWidth, height: view.height - top)
    }
    
    func numbersOfChildControllers(in pageController: WMPageController) -> Int {
        return _dataList.count
    }
    
    func pageController(_ pageController: WMPageController, viewControllerAt index: Int) -> UIViewController {
        return UIViewController()
    }
    
    func pageController(_ pageController: WMPageController, titleAt index: Int) -> String {
        return _dataList[index].grade
    }
    
    func pageController(_ pageController: WMPageController, didEnter viewController: UIViewController, withInfo info: [AnyHashable : Any]) {
        let index = info["index"] as! Int
        if index != currentIndex {
            currentIndex = index
            timeline.moveToStage(index: index)
        }
    }
    
    //MARK:- EditInfoViewDelegate
    func editInfoViewControllerDidSaveInfo(with model: EditInfoResultModel) {
        let paramKey = selectedItem.info["paramKey"] as! String
        params[paramKey] = model.value
        selectedItem.info["value"] = model.value
        selectedItem.info["name"] = model.name
        (selectedItem.info["content"] as! UILabel).text = model.name
        if paramKey == "targetDegreeId" {
            params["currentGradeId"] = ""
            makePlanView.clearItem(index: 1)
        }
        makePlanView.refreshItemStatus()
    }
}
