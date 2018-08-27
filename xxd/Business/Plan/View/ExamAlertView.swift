//
//  ExamAlertView.swift
//  xxd
//
//  Created by remy on 2018/5/25.
//  Copyright © 2018年 com.smartstudy. All rights reserved.
//

protocol ExamAlertStyle: AnyObject {
    
    func addContent()
}
extension ExamAlertStyle where Self: UIView {
    
    func wrapStyle() {
        backgroundColor = .white
        layer.cornerRadius = 12
        layer.shadowRadius = 12
        layer.shadowOffset = .zero
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.2
    }
    
    func show(isMaskHide: Bool) {
        XDPopView.topView(view: self, isMaskHide: isMaskHide, alpha: 0.4)
    }
    
    func hide() {
        XDPopView.hideTopView()
    }
}

class ExamConfirmAlert: UIView, ExamAlertStyle {
    
    var confirmHandler: ((ExamDayModel) -> Void)?
    var model: ExamDayModel!
    
    convenience init(model: ExamDayModel) {
        self.init(frame: CGRect(x: 0, y: 0, width: 270, height: 157))
        self.model = model
        wrapStyle()
        addContent()
    }
    
    func addContent() {
        // 考试
        let examLabel = UILabel(frame: CGRect(x: 16, y: 20, width: 238, height: 24), text: "\(model.examStr)考试", textColor: XDColor.itemTitle, fontSize: 17, bold: true)!
        examLabel.textAlignment = .center
        self.addSubview(examLabel)
        // 考试时间
        let dateLabel = UILabel(frame: CGRect(x: 16, y: 52, width: 238, height: 18), text: model.dateMMdd + " " + model.weekday, textColor: UIColor(0x046FC2), fontSize: 13)!
        dateLabel.textAlignment = .center
        self.addSubview(dateLabel)
        // 参加考试的用户数
        let selectCountLabel = UILabel(frame: CGRect(x: 16, y: 82, width: 238, height: 18), text: "\(model.selectCount)位选校帝用户计划参加当天考试", textColor: XDColor.itemText, fontSize: 12)!
        selectCountLabel.textAlignment = .center
        self.addSubview(selectCountLabel)
        // 关闭
        let closeBtn = UIButton(frame: CGRect(x: 0, y: 113, width: 135, height: 44), title: "取消", fontSize: 16, titleColor: XDColor.main, target: self, action: #selector(closeTap))!
        self.addSubview(closeBtn)
        // 参加考试
        let confirmBtn = UIButton(frame: CGRect(x: 135, y: 113, width: 135, height: 44), title: "参加考试", fontSize: 16, bold: true, titleColor: XDColor.main, backgroundColor: nil, target: self, action: #selector(confirmTap))!
        self.addSubview(confirmBtn)
        // 分割线
        let line1 = UIView(frame: CGRect(x: 0, y: 113, width: 270, height: XDSize.unitWidth), color: XDColor.itemLine)
        self.addSubview(line1)
        let line2 = UIView(frame: CGRect(x: 135, y: 113, width: XDSize.unitWidth, height: 44), color: XDColor.itemLine)
        self.addSubview(line2)
        
        self.center = CGPoint(x: XDSize.screenWidth / 2, y: XDSize.screenHeight / 2)
    }
    
    @discardableResult
    static func show(model: ExamDayModel) -> ExamConfirmAlert {
        let view = ExamConfirmAlert(model: model)
        view.show(isMaskHide: false)
        return view
    }
    
    @objc func closeTap() {
        hide()
    }
    
    @objc func confirmTap() {
        hide()
        DispatchQueue.main.async {
            self.confirmHandler?(self.model)
        }
    }
}

class ExamContinueAlert: UIView, ExamAlertStyle {
    
    var confirmHandler: ((ExamDayModel) -> Void)?
    var models: [ExamDayModel] = []
    
    convenience init(models: [ExamDayModel]) {
        self.init(frame: CGRect(x: 0, y: 0, width: 270, height: 0))
        self.models = models
        wrapStyle()
        addContent()
    }
    
    func addContent() {
        guard models.count > 1, let model = models.first else { return }
        // 考试
        let examLabel = UILabel(frame: CGRect(x: 16, y: 20, width: 238, height: 24), text: "\(model.examStr)考试", textColor: XDColor.itemTitle, fontSize: 17, bold: true)!
        examLabel.textAlignment = .center
        self.addSubview(examLabel)
        // 考试时间
        let dateLabel = UILabel(frame: CGRect(x: 16, y: 52, width: 238, height: 18), text: model.dateMMdd + " " + model.weekday, textColor: UIColor(0x046FC2), fontSize: 13)!
        dateLabel.textAlignment = .center
        self.addSubview(dateLabel)
        // 分割线
        let middleLine = UIView(frame: CGRect(x: 16, y: 78, width: 238, height: XDSize.unitWidth), color: XDColor.itemLine)
        self.addSubview(middleLine)
        // 已添加的考试
        let examListLabel = UILabel(frame: CGRect(x: 16, y: 89, width: 238, height: 20), text: "已添加的\(model.examStr)考试", textColor: XDColor.itemTitle, fontSize: 14)!
        examListLabel.textAlignment = .center
        self.addSubview(examListLabel)
        // 已添加的考试列表
        let scrollView = UIScrollView(frame: CGRect(x: 0, y: examListLabel.bottom + 8, width: 270, height: 0))
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = true
        scrollView.alwaysBounceVertical = true
        self.addSubview(scrollView)
        let existModels = models[1...]
        for (index, model) in existModels.enumerated() {
            let top = CGFloat(index * 18)
            let dateLabel = UILabel(frame: CGRect(x: 16, y: top, width: 238, height: 18), text: model.dateMMdd + " " + model.weekday, textColor: UIColor(0x046FC2), fontSize: 13)!
            dateLabel.textAlignment = .center
            scrollView.addSubview(dateLabel)
        }
        scrollView.contentSize = CGSize(width: 270, height: CGFloat(existModels.count * 18))
        scrollView.height = CGFloat(min(existModels.count, 7) * 18)
        // 注意合理安排考试时间
        let examTipLabel = UILabel(frame: CGRect(x: 16, y: 0, width: 238, height: 18), text: "注意合理安排考试时间", textColor: XDColor.itemText, fontSize: 13)!
        examTipLabel.top = scrollView.bottom + 12
        examTipLabel.textAlignment = .center
        self.addSubview(examTipLabel)
        let btnTop = examTipLabel.bottom + 12
        // 关闭
        let closeBtn = UIButton(frame: CGRect(x: 0, y: btnTop, width: 135, height: 44), title: "取消", fontSize: 16, titleColor: XDColor.main, target: self, action: #selector(closeTap))!
        self.addSubview(closeBtn)
        // 参加考试
        let confirmBtn = UIButton(frame: CGRect(x: 135, y: btnTop, width: 135, height: 44), title: "继续添加", fontSize: 16, bold: true, titleColor: XDColor.main, backgroundColor: nil, target: self, action: #selector(confirmTap))!
        self.addSubview(confirmBtn)
        // 分割线
        let line1 = UIView(frame: CGRect(x: 0, y: btnTop, width: 270, height: XDSize.unitWidth), color: XDColor.itemLine)
        self.addSubview(line1)
        let line2 = UIView(frame: CGRect(x: 135, y: btnTop, width: XDSize.unitWidth, height: 44), color: XDColor.itemLine)
        self.addSubview(line2)
        
        self.height = btnTop + 44
        self.center = CGPoint(x: XDSize.screenWidth / 2, y: XDSize.screenHeight / 2)
    }
    
    @discardableResult
    static func show(models: [ExamDayModel]) -> ExamContinueAlert {
        let view = ExamContinueAlert(models: models)
        view.show(isMaskHide: false)
        return view
    }
    
    @objc func closeTap() {
        hide()
    }
    
    @objc func confirmTap() {
        hide()
        DispatchQueue.main.async {
            guard let model = self.models.first else { return }
            self.confirmHandler?(model)
        }
    }
}

class ExamCancelAlert: UIView, ExamAlertStyle {
    
    var cancelHandler: ((ExamDayModel) -> Void)?
    var othersHandler: ((ExamDayModel) -> Void)?
    var model: ExamDayModel!
    
    convenience init(model: ExamDayModel) {
        self.init(frame: CGRect(x: 0, y: 0, width: 270, height: 249))
        self.model = model
        wrapStyle()
        addContent()
    }
    
    func addContent() {
        // 考试
        let examLabel = UILabel(frame: CGRect(x: 16, y: 20, width: 238, height: 24), text: "\(model.examStr)考试", textColor: XDColor.itemTitle, fontSize: 17, bold: true)!
        examLabel.textAlignment = .center
        self.addSubview(examLabel)
        // 考试时间
        let dateLabel = UILabel(frame: CGRect(x: 16, y: 52, width: 238, height: 18), text: model.dateStr + " " + model.weekday, textColor: UIColor(0x046FC2), fontSize: 13)!
        dateLabel.textAlignment = .center
        self.addSubview(dateLabel)
        // 参加考试的用户数
        let selectCountLabel = UILabel(frame: CGRect(x: 16, y: 82, width: 238, height: 18), text: "\(model.selectCount)位选校帝用户计划参加当天考试", textColor: XDColor.itemText, fontSize: 12)!
        selectCountLabel.textAlignment = .center
        self.addSubview(selectCountLabel)
        // 关闭
        let closeBtn = addBtn(text: "关闭", action: #selector(closeTap))
        closeBtn.top = selectCountLabel.bottom + 13
        // 取消考试
        let cancelBtn = addBtn(text: "取消本次考试计划", action: #selector(cancelTap))
        cancelBtn.top = closeBtn.bottom
        // 看看哪些人正在备考
        let othersBtn = addBtn(text: "看看哪些人正在备考", action: #selector(othersTap))
        othersBtn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        othersBtn.top = cancelBtn.bottom
        
        self.center = CGPoint(x: XDSize.screenWidth / 2, y: XDSize.screenHeight / 2)
    }
    
    func addBtn(text: String, action: Selector) -> UIButton {
        let btn = UIButton(frame: CGRect(x: 0, y: 0, width: 270, height: 45), title: text, fontSize: 16, titleColor: XDColor.main, target: self, action: action)!
        self.addSubview(btn)
        // 分割线
        let line = UIView(frame: CGRect(x: 0, y: 0, width: 270, height: XDSize.unitWidth), color: XDColor.itemLine)
        btn.addSubview(line)
        
        return btn
    }
    
    @discardableResult
    static func show(model: ExamDayModel) -> ExamCancelAlert {
        let view = ExamCancelAlert(model: model)
        view.show(isMaskHide: false)
        return view
    }
    
    @objc func closeTap() {
        hide()
    }
    
    @objc func cancelTap() {
        hide()
        DispatchQueue.main.async {
            self.cancelHandler?(self.model)
        }
    }
    
    @objc func othersTap() {
        hide()
        DispatchQueue.main.async {
            self.othersHandler?(self.model)
        }
    }
}


class ExamTypeAlert: UIView, ExamAlertStyle {
    
    var itemHandler: ((ExamDayModel) -> Void)?
    var models: [ExamDayModel] = []
    
    convenience init(models: [ExamDayModel]) {
        self.init(frame: CGRect(x: 0, y: 0, width: 270, height: 249))
        self.models = models
        wrapStyle()
        addContent()
    }
    
    func addContent() {
        // 选择考试场次
        let titleLabel = UILabel(frame: CGRect(x: 24, y: 24, width: 222, height: 24), text: "选择考试场次", textColor: XDColor.itemTitle, fontSize: 17, bold: true)!
        self.addSubview(titleLabel)
        // 分割线
        let line = UIView(frame: CGRect(x: 0, y: 72 - XDSize.unitWidth, width: 270, height: XDSize.unitWidth), color: XDColor.itemLine)
        self.addSubview(line)
        // 考试类型
        let topSpace: CGFloat = 72
        for (index, model) in models.enumerated() {
            let top = CGFloat(index * 52) + topSpace
            let itemView = UIView(frame: CGRect(x: 0, y: top, width: 270, height: 52))
            itemView.tag = index
            itemView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(itemTap(_:))))
            self.addSubview(itemView)
            
            let text = "• \(model.examStr)"
            let color = model.examType?.attributeColor() ?? UIColor.black
            let examLabel = UILabel(frame: CGRect(x: 24, y: 0, width: 222, height: 52), text: text, textColor: color, fontSize: 15)!
            itemView.addSubview(examLabel)
            // 分割线
            let bottomLine = UIView(frame: CGRect(x: 24, y: 52 - XDSize.unitWidth, width: 246, height: XDSize.unitWidth), color: XDColor.itemLine)
            itemView.addSubview(bottomLine)
        }
        
        self.height = CGFloat(models.count * 52 + 72)
        self.center = CGPoint(x: XDSize.screenWidth / 2, y: XDSize.screenHeight / 2)
    }
    
    @discardableResult
    static func show(models: [ExamDayModel]) -> ExamTypeAlert {
        let view = ExamTypeAlert(models: models)
        view.show(isMaskHide: true)
        return view
    }
    
    @objc func itemTap(_ gestureRecognizer: UIGestureRecognizer) {
        hide()
        DispatchQueue.main.async {
            let index = gestureRecognizer.view!.tag
            self.itemHandler?(self.models[index])
        }
    }
}
