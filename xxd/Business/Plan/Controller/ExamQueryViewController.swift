//
//  ExamQueryViewController.swift
//  xxd
//
//  Created by remy on 2018/5/24.
//  Copyright © 2018年 com.smartstudy. All rights reserved.
//
import JTAppleCalendar

/// 出国考试时间查询
class ExamQueryViewController: SSViewController {
    
    private var buttonTypes: [ExamType]? {
        didSet {
            if let types = buttonTypes {
                popButtons.removeAll()
                for value in types {
                    let btn = configurePopButton(value)
                    popButtons.append(btn)
                    self.view.insertSubview(btn, belowSubview: filterBackgroundView)
                }
            }
        }
    }
    private let kButtonTag: Int = 1000
    private var popButtons: [UIButton] = []
    private var isFilterSelected: Bool = false
    private lazy var todayString: String = {
        let formatter: DateFormatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: Date())
    }()
    private lazy var blurView: UIVisualEffectView = {
        let effectView: UIVisualEffectView = UIVisualEffectView(frame: UIScreen.main.bounds)
        effectView.alpha = 0.85
        effectView.effect = UIBlurEffect(style: UIBlurEffectStyle.extraLight)
        effectView.isHidden = true
        return effectView
    }()
    /// 上次更新时间
    private lazy var tipView: ExamTimeUpdateTipView = {
        let view = ExamTimeUpdateTipView(frame: CGRect(x: 0, y: XDSize.topHeight, width: XDSize.screenWidth, height: 40))
        view.isHidden = true
        return view
    }()
    /// 日历视图
    private lazy var calendarView: XDCalendarView = {
        let calendar: XDCalendarView = XDCalendarView(frame: CGRect(x: 0.0, y: 0, width: XDSize.screenWidth, height: 0))
        calendar.delegate = self
        calendar.isHidden = true
        return calendar
    }()
    private lazy var filterBackgroundView: UIView = {
        let view: UIView = UIView(frame: CGRect(x: self.view.width-64.0, y: self.view.height-114.0, width: 50.0, height: 50.0), color: UIColor.clear)
        view.addSubview(filterButton)
        filterButton.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        view.addSubview(filterCancelButton)
        filterCancelButton.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(3.0)
            make.top.equalToSuperview().offset(-3.0)
            make.width.height.equalTo(20.0)
        }
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        view.layer.shadowRadius = 6
        view.layer.shadowOpacity = 0.1
        view.layer.cornerRadius = 25.0
        return view
    }()
    private lazy var filterCancelButton: UIButton = {
        let button: UIButton = UIButton(frame: CGRect.zero)
        button.setImage(UIImage(named: "filter_cancel"), for: .normal)
        button.addTarget(self, action: #selector(eventButtonResponse(_:)), for: .touchUpInside)
        button.tag = kButtonTag + 1
        button.isHidden = true
        return button
    }()
    private lazy var filterButton: UIButton = {
        let button: UIButton = UIButton(frame: CGRect.zero, title: "筛选\n全部", fontSize: 12.0, titleColor: UIColor.white, backgroundColor: UIColor(0x078CF1), target: self, action: #selector(eventButtonResponse(_:)))
        button.setImage(UIImage(named: "calendar_filter_close"), for: .selected)
        button.setTitle("", for: .selected)
        button.tag = kButtonTag
        button.layer.cornerRadius = 25.0
        button.layer.masksToBounds = true
        button.titleLabel?.numberOfLines = 2
        return button
    }()
    private var myPlanLabel: UILabel!
    private lazy var myPlanView: UIView = {
        let view = UIView(frame: CGRect(x: 0, y: XDSize.screenHeight - 49, width: XDSize.screenWidth, height: 49), color: XDColor.mainBackground)
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(myPlanTap(_:))))
        myPlanLabel = UILabel(frame: .zero, text: "我的考试计划", textColor: XDColor.itemTitle, fontSize: 16)!
        view.addSubview(myPlanLabel)
        myPlanLabel.snp.makeConstraints({ (make) in
            make.centerY.equalToSuperview()
            make.left.equalTo(16)
        })
        return view
    }()

    private var hasMyPlan: Bool = false
    private var planNum: Int = 0 {
        didSet {
            if myPlanLabel != nil {
                myPlanLabel.text = planNum > 0 ? "我的考试计划（\(planNum)）" : "我的考试计划"
            }
        }
    }
    private var dataList: [String : [ExamDayModel]] = [:]
    private var selectedExamModels: [ExamType : [ExamDayModel]] = [:]
    
    override init!(query: [AnyHashable : Any]!) {
        super.init(query: query)
        self.hasMyPlan = query["hasMyPlan"] as! Bool
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "出国考试时间查询"
        view.addSubview(tipView)
        view.addSubview(calendarView)
        view.addSubview(myPlanView)
        view.addSubview(blurView)
        view.addSubview(filterBackgroundView)
        if hasMyPlan {
            buttonTypes = [.mine, .toefl, .ielts, .sat, .gmat, .gre]
        } else {
            buttonTypes = [.toefl, .ielts, .sat, .gmat, .gre]
        }
        myPlanView.isHidden = !hasMyPlan
        adjustView(true)
        reloadData()
    }
    
    func adjustView(_ hideTip: Bool) {
        UIView.animate(withDuration: 0.25) {
            self.tipView.isHidden = hideTip
            self.calendarView.top = XDSize.topHeight + (hideTip ? 0 : self.tipView.height)
            self.calendarView.height = XDSize.screenHeight - self.calendarView.top - (self.hasMyPlan ? self.myPlanView.height : 0)
        }
    }
    
    func reloadData() {
        XDPopView.loading()
        var params: [String : Any] = [:]
        params["plain"] = !hasMyPlan
        SSNetworkManager.shared().get(XD_API_EXAM_SCHEDULE, parameters: params, success: {
            [weak self] (task, responseObject) in
            guard let sSelf = self else { return }
            if let responseDictionary = responseObject as? [String : Any], let data = responseDictionary["data"] as? [String: Any] {
                if let meta = data["meta"] as? [String : Any] {
                    if let num = meta["mySelectCount"] as? Int {
                        sSelf.planNum = num
                    }
                    if let updateText = meta["updateTimeText"] as? String {
                        sSelf.whetherUpdateTipViewVisible(updateText)
                    }
                    if let startDate = meta["startMonth"] as? String {
                        sSelf.calendarView.startDate = startDate
                    }
                    if let endDate = meta["stopMonth"] as? String {
                        sSelf.calendarView.endDate = endDate
                    }
                }
                if let examList = data["data"] as? [[String : Any]] {
                    examList.forEach {
                        let dateStr = ($0["date"] as? String) ?? ""
                        var arr = [ExamDayModel]()
                        if let items = $0["items"] as? [[String : Any]] {
                            items.forEach {
                                let model = ExamDayModel.yy_model(with: $0)!
                                model.dateStr = dateStr
                                model.weekday = model.localWeekDay
                                arr.append(model)
                                sSelf.addToSelectedExamModels(model)
                            }
                        }
                        if arr.count > 0 {
                            sSelf.dataList[dateStr] = arr
                        }
                    }
                    sSelf.calendarView.examScheduleModels = sSelf.dataList
                    sSelf.calendarView.isHidden = false
                }
            }
            XDPopView.hide()
        }) { (task, error) in
            XDPopView.toast(error.localizedDescription)
        }
    }

    override func routerEvent(name: String, data: Dictionary<String, Any>) {
        super.routerEvent(name: name, data: data)
        // 考试时间更新视图关闭按钮的事件响应
        if name == "ExamTimeUpdateTipView" {
            adjustView(true)
        }
    }

    /// 生成筛选按钮
    private func configurePopButton(_ buttonType: ExamType) -> UIButton {
        let button: UIButton = UIButton(frame: CGRect(x: self.view.width-59.0, y: self.view.height-109.0, width: 40.0, height: 40.0), title: buttonType.rawValue, fontSize: 12.0, titleColor: UIColor.white, backgroundColor: buttonType.attributeColor(), target: self, action: #selector(ExamQueryViewController.eventButtonResponse(_:)))
        if buttonType == .mine {
            button.titleLabel?.numberOfLines = 2
            button.setTitleColor(UIColor(0x078CF1), for: .normal)
            button.layer.borderWidth = XDSize.unitWidth
            button.layer.borderColor = UIColor(0x078CF1).cgColor
        }
        button.tag = kButtonTag + 5
        button.layer.cornerRadius = 20.0
        button.layer.masksToBounds = true
        button.isHidden = true
        return button
    }
    
    /// 判断是否显示考试时间更新视图
    private func whetherUpdateTipViewVisible(_ updateText: String) {
        if hasMyPlan {
            if let savedDic = UserDefaults.standard.value(forKey: "updateTimeDictionary") as? [String: Any] {
                if let lastTime = savedDic["time"] as? String, let isClosed = savedDic["isClosed"] as? Bool {
                    if lastTime != updateText {
                        makeUpdateTipViewVisible(dateText: updateText)
                    } else if !isClosed {
                        makeUpdateTipViewVisible(dateText: updateText)
                    }
                }
            } else {
                makeUpdateTipViewVisible(dateText: updateText)
                UserDefaults.standard.set(["time": updateText, "isClosed": false], forKey: "updateTimeDictionary")
            }
        }
    }
    
    /// 显示考试时间更新视图
    private func makeUpdateTipViewVisible(dateText: String) {
        tipView.updateTime = dateText
        adjustView(false)
    }
}

//MARK:- Action
extension ExamQueryViewController {

    @objc func myPlanTap(_ gestureRecognizer: UIGestureRecognizer) {
        let vc = ExamPlanViewController()
        presentModalViewController(vc, animated: true, completion: nil)
    }

    @objc func eventButtonResponse(_ sender: UIButton) {
        let index: Int = sender.tag - kButtonTag
        if index == 0 {
            if !isFilterSelected {
                filterCancelButton.isHidden = true
            }
            sender.isSelected = !sender.isSelected
            if sender.isSelected {
                if isFilterSelected {
                    filterCancelButton.isHidden = true
                }
                let _ = self.popButtons.map { $0.isHidden = false }
                UIView.animate(withDuration: 0.15, delay: 0.0, options: UIViewAnimationOptions.curveEaseOut, animations: {
                    self.blurView.isHidden = false
                    for i in 0..<self.popButtons.count {
                        self.popButtons[i].transform = CGAffineTransform(translationX: 0.0, y: -5.0-CGFloat(i+1)*50.0)
                    }
                }, completion: nil)
            } else {
                if isFilterSelected {
                    filterCancelButton.isHidden = false
                }
                UIView.animate(withDuration: 0.15, delay: 0.0, options: UIViewAnimationOptions.curveEaseInOut, animations: {
                    self.blurView.isHidden = true
                    let _ = self.popButtons.map { $0.transform = .identity }
                }) { (_) in
                    let _ = self.popButtons.map { $0.isHidden = true }
                }
            }
        } else if index == 1 {
            sender.isHidden = true
            isFilterSelected = false
            calendarView.examScheduleModels = dataList
            filterButton.setTitle("筛选\n全部", for: .normal)
        } else {
            guard let senderTitle = sender.titleLabel?.text, let filterType = ExamType(rawValue: senderTitle) else { return }
            UIView.animate(withDuration: 0.15, delay: 0.0, options: UIViewAnimationOptions.curveEaseInOut, animations: {
                self.blurView.isHidden = true
                self.filterButton.setTitle(senderTitle, for: .normal)
                let _ = self.popButtons.map {
                    $0.transform = .identity
                }
            }) { (_) in
                self.filterButton.isSelected = false
                let _ = self.popButtons.map { $0.isHidden = true }
            }
            filterCancelButton.isHidden = false
            isFilterSelected = true
            var filterDataList: [String : [ExamDayModel]] = [:]
            if filterType == .mine {
                selectedExamModels.forEach {
                    let _ = $0.value.map { filterDataList[$0.dateStr] = [$0] }
                }
            } else {
                dataList.forEach {
                    let dateStr = $0.key
                    var filterArr = $0.value
                    for value in filterArr {
                        if value.selected {
                            filterArr.removeAll()
                            filterArr.append(value)
                        }
                    }
                    let arr = filterArr.filter {
                        return $0.examType == filterType
                    }
                    if arr.count > 0 {
                        filterDataList[dateStr] = arr
                    }
                }
            }
            calendarView.examScheduleModels = filterDataList
        }
    }
}

// MARK: XDCalendarViewDelegate
extension ExamQueryViewController: XDCalendarViewDelegate {
    func xdCalendarViewDidSelect(_ calendarView: XDCalendarView, _ cell: CalendarCell, _ weekDay: String) {
        if hasMyPlan {
            guard let models = cell.cellModels, models.count > 0 else { return }
            if cell.isChosen, let chosenModel = cell.chosenModel {
                chosenModel.weekday = weekDay
                // 取消考试
                let alertView = ExamCancelAlert.show(model: chosenModel)
                alertView.cancelHandler = {
                    self.cancelExamPlan(model: $0, cell: cell)
                }
                alertView.othersHandler = {
                    let vc: ExamOthersViewController = ExamOthersViewController(query: ["model": $0])
                    XDRoute.pushToVC(vc)
                }
            } else {
                let _ = models.map { $0.weekday = weekDay }
                if models.count > 1 {
                    // 参加考试,多种考试选择
                    let alertView = ExamTypeAlert.show(models: models)
                    alertView.itemHandler = {
                        // 参加考试
                        self.showAddAlertView(model: $0, cell: cell)
                    }
                } else {
                    // 参加考试
                    showAddAlertView(model: models.first!, cell: cell)
                }
            }
        }
    }

    func showAddAlertView(model: ExamDayModel, cell: CalendarCell) {
        // 参加考试
        var selectedModels = getTypeSelectedExamModels(model)
        if selectedModels.count > 0 {
            selectedModels.insert(model, at: 0)
            let alertView = ExamContinueAlert.show(models: selectedModels)
            alertView.confirmHandler = {
                self.addExamPlan(model: $0, cell: cell)
            }
        } else {
            let alertView = ExamConfirmAlert.show(model: model)
            alertView.confirmHandler = {
                self.addExamPlan(model: $0, cell: cell)
            }
        }
    }
}

extension ExamQueryViewController {

    // 已添加的同类考试
    func getTypeSelectedExamModels(_ model: ExamDayModel) -> [ExamDayModel] {
        if let typeKey = model.examType {
            return selectedExamModels[typeKey] ?? []
        }
        return []
    }

    // 取消已添加的同类考试
    func removeFromSelectedExamModels(_ model: ExamDayModel) {
        if let typeKey = model.examType {
            let models = selectedExamModels[typeKey] ?? []
            selectedExamModels[typeKey] = models.filter {
                return $0.examID != model.examID
            }
        }
    }

    // 添加到已添加的同类考试
    func addToSelectedExamModels(_ model: ExamDayModel) {
        if model.selected, let typeKey = model.examType {
            var models = selectedExamModels[typeKey] ?? []
            models.append(model)
            let sortedModels = models.sorted(by: { return $0.dateStr < $1.dateStr })
            selectedExamModels[typeKey] = sortedModels.filter { $0.dateStr > todayString }
        }
    }

    func cancelExamPlan(model: ExamDayModel, cell: CalendarCell) {
        XDPopView.loading()
        let urlStr = String(format: XD_API_EXAM_SCHEDULE_OPERATE, model.examID)
        SSNetworkManager.shared().delete(urlStr, parameters: nil, success: {
            [weak self] (task, responseObject) in
            guard let sSelf = self else { return }
            cell.examType = cell.cellModels!.count > 1 ? ExamType.multi : model.examType
            cell.isChosen = false
            cell.chosenModel = nil
            model.selected = false
            sSelf.removeFromSelectedExamModels(model)
            sSelf.planNum -= 1
            XDPopView.hide()
        }) { (task, error) in
            XDPopView.toast(error.localizedDescription)
        }
    }

    func addExamPlan(model: ExamDayModel, cell: CalendarCell) {
        XDPopView.loading()
        let urlStr = String(format: XD_API_EXAM_SCHEDULE_OPERATE, model.examID)
        SSNetworkManager.shared().post(urlStr, parameters: nil, success: {
            [weak self] (task, responseObject) in
            guard let sSelf = self else { return }
            cell.examType = model.examType
            cell.isChosen = true
            cell.chosenModel = model
            model.selected = true
            sSelf.addToSelectedExamModels(model)
            sSelf.planNum += 1
            XDPopView.hide()
        }) { (task, error) in
            XDPopView.toast(error.localizedDescription)
        }
    }
}
