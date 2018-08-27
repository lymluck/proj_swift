//
//  CourseIntroduceView.swift
//  xxd
//
//  Created by remy on 2018/1/22.
//  Copyright © 2018年 com.smartstudy. All rights reserved.
//

private var kReferLabelViewKey: UInt8 = 0
private var kLabelOriginTextKey: UInt8 = 0
private let tailTruncationString = "...         ."
private let contentLineHeight: CGFloat = 20

class CourseIntroduceView: UIView {
    
    private var model: CourseIntroduceModel!
    private var titleView: UIView!
    private var introView: UIView!
    private var targetView: UIView!
    private var teacherView: UIView!
    private var serviceView: UIView!
    
    convenience init(model: CourseIntroduceModel) {
        self.init()
        backgroundColor = UIColor.white
        self.model = model
        addTitleView()
        addIntroView()
        addTargetView()
        addTeacherView()
        addServiceView()
    }
    
    private func addTitleView() {
        titleView = UIView(frame: CGRect(x: 0, y: 0, width: XDSize.screenWidth, height: 131))
        addSubview(titleView)
        addTopView(titleView, model.name, 20)
        
        let rate = Float(model.rate)!
        var lastView: UIView!
        for i in 0..<5 {
            let score = Float(i + 1)
            let starView = UIImageView(image: UIImage(named: "course_evaluation_small_star_normal"))
            if score <= rate {
                starView.image = UIImage(named: "course_evaluation_small_star_selected")
            } else {
                if score == rate.rounded(.up) {
                    starView.image = UIImage(named: "course_evaluation_small_star_half")
                }
            }
            titleView.addSubview(starView)
            starView.snp.makeConstraints({ (make) in
                if lastView != nil {
                    make.left.equalTo(lastView.snp.right).offset(1)
                } else {
                    make.left.equalTo(titleView).offset(16)
                }
                make.top.equalTo(titleView).offset(58)
            })
            lastView = starView
        }
        
        let rateLabel = UILabel(frame: .zero, text: model.rate, textColor: XDColor.itemText, fontSize: 14, bold: true)!
        titleView.addSubview(rateLabel)
        rateLabel.snp.makeConstraints({ (make) in
            make.left.equalTo(lastView.snp.right).offset(4)
            make.centerY.equalTo(lastView)
        })
        
        let visitImageView = UIImageView(image: UIImage(named: "information_visit_count"))
        titleView.addSubview(visitImageView)
        visitImageView.snp.makeConstraints({ (make) in
            make.left.equalTo(titleView).offset(16)
            make.bottom.equalTo(titleView).offset(-25.5)
            make.size.equalTo(CGSize(width: 11, height: 8))
        })
        
        let text = String(format: "abroad_stage_visit_count".localized, model.playCount)
        let visitCountLabel = UILabel(text: text, textColor: XDColor.itemText, fontSize: 12)!
        let size = visitCountLabel.sizeThatFits(CGSize(width: CGFloat.greatestFiniteMagnitude, height: 12))
        titleView.addSubview(visitCountLabel)
        visitCountLabel.snp.makeConstraints({ (make) in
            make.left.equalTo(visitImageView.snp.right).offset(4)
            make.width.equalTo(size.width)
            make.centerY.equalTo(visitImageView)
        })
        
        let desc = String(format: "visa_provider".localized, model.provider)
        let providerLabel = UILabel(text: desc, textColor: XDColor.itemText, fontSize: 12)!
        titleView.addSubview(providerLabel)
        providerLabel.snp.makeConstraints({ (make) in
            make.left.equalTo(visitCountLabel.snp.right).offset(24)
            make.right.equalTo(titleView).offset(-16)
            make.centerY.equalTo(visitImageView)
        })
        
        addBottomLine(titleView)
    }
    
    private func addIntroView() {
        introView = addSectionView(titleView)
        addTopView(introView, "visa_course_intro".localized, 16)
        let label = NIAttributedLabel()
        label.tailTruncationString = tailTruncationString
        label.textColor = UIColor(0x58646E)
        label.font = UIFont.systemFont(ofSize: 14)
        label.numberOfLines = 4
        label.lineHeight = contentLineHeight
        label.text = model.introduction.replacingOccurrences(of: "\n", with: "，")
        objc_setAssociatedObject(label, &kLabelOriginTextKey, model.introduction, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        introView.addSubview(label)
        let labelWidth = XDSize.screenWidth - 32
        let size = label.sizeThatFits(CGSize(width: labelWidth, height: .greatestFiniteMagnitude))
        label.snp.makeConstraints({ (make) in
            make.edges.equalTo(introView).inset(UIEdgeInsetsMake(53, 16, 12, 16))
            make.height.equalTo(size.height)
        })
        let height = model.introduction.heightForFont(label.font, labelWidth, contentLineHeight)
        if height > contentLineHeight * 4 {
            addUnfoldButton(introView, label)
        }
        addBottomLine(introView)
    }
    
    private func addTargetView() {
        targetView = addSectionView(introView)
        addTopView(targetView, "visa_course_target".localized, 16)
        let label = UILabel(text: "", textColor: UIColor(0x58646E), fontSize: 14)!
        label.numberOfLines = 0
        label.setText(model.targetUser, lineHeight: contentLineHeight)
        targetView.addSubview(label)
        label.snp.makeConstraints({ (make) in
            make.edges.equalTo(targetView).inset(UIEdgeInsetsMake(53, 16, 12, 16))
        })
        addBottomLine(targetView)
    }
    
    private func addTeacherView() {
        teacherView = addSectionView(targetView)
        addTopView(teacherView, "visa_course_teacher".localized, 16)
        let teachers = model.subModels
        if teachers.count > 0 {
            var lastView: UIView!
            for (index, model) in teachers.enumerated() {
                let view = UIView()
                teacherView.addSubview(view)
                view.snp.makeConstraints({ (make) in
                    if lastView != nil {
                        make.top.equalTo(lastView.snp.bottom)
                    } else {
                        make.top.equalTo(teacherView.subviews.first!.snp.bottom).offset(16)
                    }
                    if index == teachers.count - 1 {
                        make.bottom.equalTo(teacherView)
                    }
                    make.left.equalTo(teacherView).offset(16)
                    make.right.equalTo(teacherView)
                })
                lastView = view
                
                let logoView = UIImageView(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
                logoView.layer.cornerRadius = 20
                logoView.layer.masksToBounds = true
                logoView.setAutoOSSImage(urlStr: model.avatarURL, policy: .pad)
                view.addSubview(logoView)
                
                let nameLabel = UILabel(frame: CGRect(x: 48, y: 3, width: XDSize.screenWidth - 80, height: 14), text: model.name, textColor: XDColor.itemTitle, fontSize: 14)!
                view.addSubview(nameLabel)
                
                let descLabel = UILabel(frame: CGRect(x: 48, y: 25, width: XDSize.screenWidth - 80, height: 12), text: model.title, textColor: XDColor.textPlaceholder, fontSize: 12)!
                view.addSubview(descLabel)
                
                let label = NIAttributedLabel()
                label.tailTruncationString = tailTruncationString
                label.textColor = UIColor(0x58646E)
                label.font = UIFont.systemFont(ofSize: 14)
                label.numberOfLines = 4
                label.lineHeight = contentLineHeight
                label.text = model.introduction.replacingOccurrences(of: "\n", with: "，")
                objc_setAssociatedObject(label, &kLabelOriginTextKey, model.introduction, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                view.addSubview(label)
                let labelWidth = XDSize.screenWidth - 64
                let size = label.sizeThatFits(CGSize(width: labelWidth, height: .greatestFiniteMagnitude))
                label.snp.makeConstraints({ (make) in
                    make.edges.equalTo(view).inset(UIEdgeInsetsMake(50, 48, 21, 16))
                    make.height.equalTo(size.height)
                })
                let height = model.introduction.heightForFont(label.font, labelWidth, contentLineHeight)
                if height > contentLineHeight * 4 {
                    addUnfoldButton(view, label)
                }
            }
        }
        addBottomLine(teacherView)
    }
    
    private func addServiceView() {
        serviceView = addSectionView(teacherView, true)
        addTopView(serviceView, "visa_service".localized, 16)
        let size = CGSize(width: XDSize.screenWidth - 32, height: 114)
        let imageView = UIImageView()
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(serviceTap(gestureRecognizer:))))
        imageView.setOSSImage(urlStr: model.abroadServiceImageURL, size: size, policy: .fill)
        serviceView.addSubview(imageView)
        imageView.snp.makeConstraints({ (make) in
            make.size.equalTo(size)
            make.left.equalTo(16)
            make.top.equalTo(56)
            make.bottom.equalTo(-24)
        })
    }
    
    private func addSectionView(_ referView: UIView, _ isLast: Bool = false) -> UIView {
        let view = UIView(frame: .zero)
        addSubview(view)
        view.snp.makeConstraints({ (make) in
            make.top.equalTo(referView.snp.bottom)
            make.width.equalTo(XDSize.screenWidth)
            if isLast {
                make.bottom.equalTo(self)
            }
        })
        return view
    }
    
    private func addTopView(_ referView: UIView, _ text: String, _ fontSize: CGFloat) {
        let titleLabel = UILabel(frame: .zero, text: text, textColor: XDColor.itemTitle, fontSize: fontSize, bold: true)!
        referView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints({ (make) in
            make.top.equalTo(referView).offset(24)
            make.left.equalTo(referView).offset(16)
            make.right.equalTo(referView).offset(-16)
        })
    }
    
    private func addBottomLine(_ referView: UIView) {
        let bottomLine = UIView(frame: .zero, color: XDColor.itemLine)
        addSubview(bottomLine)
        bottomLine.snp.makeConstraints({ (make) in
            make.height.equalTo(XDSize.unitWidth)
            make.right.equalTo(referView).offset(-16)
            make.left.equalTo(referView).offset(16)
            make.bottom.equalTo(referView)
        })
    }
    
    private func addUnfoldButton(_ referView: UIView, _ label: UILabel) {
        let btn = UIButton(frame: .zero, title: "", fontSize: 0, titleColor: UIColor.clear, target: self, action: #selector(unfoldTap(sender:)))!
        btn.backgroundColor = UIColor.white
        objc_setAssociatedObject(btn, &kReferLabelViewKey, label, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        referView.addSubview(btn)
        btn.snp.makeConstraints({ (make) in
            make.size.equalTo(CGSize(width: 48, height: contentLineHeight))
            make.right.equalTo(referView).offset(-16)
            make.bottom.equalTo(label)
        })
        let textLabel = UILabel(text: "unfold".localized, textColor: XDColor.main, fontSize: 14)!
        btn.addSubview(textLabel)
        textLabel.snp.makeConstraints({ (make) in
            make.right.top.height.equalTo(btn)
        })
    }
    
    //MARK:- Action
    @objc func serviceTap(gestureRecognizer: UIGestureRecognizer) {
        XDRoute.pushWebVC([QueryKey.URLPath:XD_WEB_VISA_SERVICE,QueryKey.TitleName:"visa_service".localized])
    }
    
    @objc func unfoldTap(sender: UIButton) {
        let label = objc_getAssociatedObject(sender, &kReferLabelViewKey) as! NIAttributedLabel
        label.tailTruncationString = ""
        label.numberOfLines = 0
        let text = objc_getAssociatedObject(label, &kLabelOriginTextKey) as! String
        label.text = text
        let size = label.sizeThatFits(CGSize(width: label.width, height: .greatestFiniteMagnitude))
        label.snp.updateConstraints({ (make) in
            make.height.equalTo(size.height)
        })
        sender.removeFromSuperview()
    }
}
