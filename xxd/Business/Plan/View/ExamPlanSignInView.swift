//
//  ExamPlanSignInView.swift
//  xxd
//
//  Created by Lisen on 2018/5/24.
//  Copyright © 2018年 com.smartstudy. All rights reserved.
//

import UIKit
import DeviceKit

/// 备考计划的签到视图
class ExamPlanSignInView: UIView {
    
    var checkinModel: ExamScheduleCheckinModel? {
        didSet {
            if let model = checkinModel {
                examTitle.text = model.examName
                if model.countdown == 0 {
                    countDownLabel.attributedText = NSAttributedString(string: "今日开考，(๑·̀ㅂ·́)و✧加油!", attributes: [NSAttributedStringKey.foregroundColor: UIColor(0xFF8100)])
                } else {
                    countDownLabel.attributedText = "倒计时" + NSAttributedString(string: " \(model.countdown) ", attributes: [NSAttributedStringKey.foregroundColor: UIColor(0xFF8A00), NSAttributedStringKey.font: UIFont.boldNumericalFontOfSize(18.0)]) + "天"
                }
                calendarLabel.text = model.examDate
                if model.isCheckin {
                    signInButton.backgroundColor = UIColor(0xC4C9CC)
                    signInButton.setTitle("今日已打卡", for: .normal)
                } else {
                    signInButton.backgroundColor = UIColor(0x078CF1)
                    signInButton.setTitle("备考打卡", for: .normal)
                }
            }
        }
    }
    var isExamPrepared: Bool = true
    private lazy var titleFontSize: CGFloat = {
        if Device().diagonal == 4.0 {
            return 17.0
        }
        return 19.0
    }()
    private var topSpace: CGFloat = 61.0
    private var lineSpace: CGFloat = 6.0
    
    private lazy var planImageView: UIImageView = UIImageView(image: UIImage(named: "plan_prepared"))
    private lazy var planTitle: UILabel = UILabel(frame: CGRect.zero, text: "我的计划", textColor: UIColor.white, fontSize: titleFontSize, bold: true)
    private lazy var examTitle: UILabel = UILabel(frame: CGRect.zero, text: "", textColor: UIColor(0x26343F), fontSize: 16.0, bold: true)
    private lazy var countDownLabel: UILabel = UILabel(frame: CGRect.zero, text: "倒计时", textColor: UIColor(0x26343F), fontSize: 14.0)
    private lazy var calendarImageView: UIImageView = UIImageView(frame: CGRect.zero, imageName: "calendar")
    private lazy var calendarLabel: UILabel = UILabel(frame: CGRect.zero, text: "", textColor: UIColor(0x949BA1), fontSize: 11.0)
    private lazy var signInButton: UIButton = {
        let button: UIButton = UIButton(frame: CGRect.zero)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 13.0)
        button.addTarget(self, action: #selector(eventButtonResponse(_:)), for: .touchUpInside)
        button.layer.cornerRadius = 16.0
        button.layer.masksToBounds = true
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initContentViews()
        configureShadowView()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        planImageView.frame = CGRect(x: 0.0, y: 0.0, width: self.bounds.width, height: 45.0)
        let imageMaskPath: UIBezierPath = UIBezierPath(roundedRect: planImageView.bounds, byRoundingCorners: [UIRectCorner.topLeft, UIRectCorner.topRight], cornerRadii: CGSize(width: 6.0, height: 6.0))
        let maskLayer: CAShapeLayer = CAShapeLayer()
        maskLayer.path = imageMaskPath.cgPath
        planImageView.layer.mask = maskLayer
        planTitle.snp.makeConstraints { (make) in
            make.center.equalTo(planImageView)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    @objc private func eventButtonResponse(_ sender: UIButton) {
        if let examId = checkinModel?.examId {
            routerEvent(name: "SignInButtonTap", data: ["button": sender, "ExamID": examId])
        }
    }

    private func initContentViews() {
        backgroundColor = UIColor.white
        addSubview(planImageView)
        addSubview(planTitle)
        addSubview(examTitle)
        examTitle.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(16.0)
            make.top.equalToSuperview().offset(topSpace)
        }
        addSubview(calendarImageView)
        calendarImageView.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(16.0)
            make.top.equalTo(examTitle.snp.bottom).offset(lineSpace)
        }
        addSubview(calendarLabel)
        calendarLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(calendarImageView)
            make.left.equalTo(calendarImageView.snp.right).offset(2.0)
        }
        addSubview(countDownLabel)
        countDownLabel.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(topSpace)
            make.right.equalToSuperview().offset(-16.0)
        }
        addSubview(signInButton)
        signInButton.snp.makeConstraints { (make) in
            make.bottom.equalToSuperview().offset(-12.0)
            make.centerX.equalToSuperview()
            make.width.equalTo(126.0)
            make.height.equalTo(32.0)
        }
    }
    
    private func configureShadowView() {
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0.0, height: 6.0)
        layer.shadowRadius = 12.0
        layer.shadowOpacity = 0.08
        layer.cornerRadius = 6.0
    }
}


/// 签到成功弹出视图
class SignInSuccessView: UIView {
    
    private lazy var shareView: ExamPlanScreenShotShareView = ExamPlanScreenShotShareView(frame: UIScreen.main.bounds)
    private lazy var titleLabel: UILabel = {
        let label: UILabel = UILabel(frame: CGRect.zero)
        label.numberOfLines = 4
        return label
    }()
    private lazy var dateView: DateView = DateView(frame: CGRect.zero)
    private lazy var heartenImageView: UIImageView = UIImageView(frame: CGRect.zero, imageName: "hearten_small")
    private lazy var shareButtton: UIButton = {
        let button: UIButton = UIButton(frame: CGRect.zero)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16.0)
        button.addTarget(self, action: #selector(eventShareButtonResponse(_:)), for: .touchUpInside)
        button.layer.cornerRadius = 6.0
        button.layer.masksToBounds = true
        button.setTitle("分享到朋友圈", for: .normal)
        button.setTitleColor(UIColor.white, for: .normal)
        button.backgroundColor = UIColor(0xFE7C44)
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initContentViews()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let imageHeight: CGFloat = (self.width*274.0/311.0)
        heartenImageView.contentMode = .scaleAspectFill
        heartenImageView.frame = CGRect(x: 0.0, y: self.height-imageHeight, width: self.width, height: imageHeight)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    /// 分享到朋友圈
    @objc private func eventShareButtonResponse(_ sender: UIButton) {
        if let sharedImage = shareView.generateScreenShotImage() {
            let messageObject: UMSocialMessageObject = UMSocialMessageObject()
            let shareObject: UMShareImageObject = UMShareImageObject()
            shareObject.shareImage = sharedImage
            messageObject.shareObject = shareObject
            UMSocialManager.default().share(to: UMSocialPlatformType.wechatTimeLine, messageObject: messageObject, currentViewController: nil) { (result, error) in
                if let error = error as NSError? {
                    var alertString: String = "share_failure".localized
                    if error.code == 2009 {
                        alertString = "分享取消"
                    }
                    XDPopView.toast(alertString)
                } else {
                    XDPopView.toast("share_success".localized)
                }
            }
        }
    }
    
    public func configureView(examName: String, daysCount: Int, currentYear: String, currentMonth: String, currentDay: String) {
        let paragraph1: NSMutableParagraphStyle = NSMutableParagraphStyle()
        paragraph1.lineSpacing = 6.0
        let paragraph2: NSMutableParagraphStyle = NSMutableParagraphStyle()
        paragraph2.lineSpacing = 4.0
        if Device().diagonal == 4.0 {
            paragraph1.lineSpacing = 4.0
        }
        let attrTitle = NSAttributedString(string: "备考"+examName, attributes: [NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 17.0), NSAttributedStringKey.paragraphStyle: paragraph1]) + NSAttributedString(string: "\n一\n", attributes: [NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 18.0), NSAttributedStringKey.paragraphStyle: paragraph1]) +
            NSAttributedString(string: "我已坚持\n", attributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 13.0), NSAttributedStringKey.paragraphStyle: paragraph2]) +
            NSAttributedString(string: "\(daysCount)", attributes: [NSAttributedStringKey.font: UIFont.boldNumericalFontOfSize(38.0), NSAttributedStringKey.paragraphStyle: paragraph2]) +
            NSAttributedString(string: " 天", attributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 12.0), NSAttributedStringKey.foregroundColor: UIColor(0x8DC2C5), NSAttributedStringKey.baselineOffset: 1.0])
        titleLabel.attributedText = attrTitle
        dateView.day = currentMonth + "." + currentDay
        dateView.year = currentYear
        shareView.configureSharedView(examName: examName, daysCount: daysCount, currentYear: currentYear, currentMonth: currentMonth, currentDay: currentDay)
    }
    
    private func initContentViews() {
        backgroundColor = UIColor.white
        layer.cornerRadius = 10.0
        layer.masksToBounds = true
        var topSpace: CGFloat = 24.0
        if Device().diagonal == 4.0 {
            topSpace = 20.0
        }
        addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(20.0)
            make.top.equalToSuperview().offset(topSpace)
        }
        addSubview(dateView)
        dateView.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(topSpace)
            make.right.equalToSuperview().offset(-20.0)
            make.width.equalTo(43.0)
            make.height.equalTo(49.0)
        }
        addSubview(heartenImageView)
        addSubview(shareButtton)
        shareButtton.snp.makeConstraints { (make) in
            make.bottom.equalToSuperview().offset(-20.0)
            make.left.equalToSuperview().offset(20.0)
            make.right.equalToSuperview().offset(-20.0)
            make.height.equalTo(40.0)
        }
    }
}

/// 打卡成功视图右上角的日期视图
class DateView: UIView {
    var day: String? {
        didSet {
            dayLabel.text = day
        }
    }
    var year: String? {
        didSet {
            yearLabel.text = year
        }
    }
    private lazy var dayLabel: UILabel = UILabel(frame: CGRect.zero, text: "", textColor: UIColor(0x26343F), fontSize: 13.0)
    private lazy var yearLabel: UILabel = UILabel(frame: CGRect.zero, text: "", textColor: UIColor(0x26343F), fontSize: 13.0)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initContentViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        let path: UIBezierPath = UIBezierPath()
        path.move(to: CGPoint(x: 11.0, y: (height/2.0)+3.0))
        path.addLine(to: CGPoint(x: width-11.0, y: (height/2.0)-3.0))
        path.lineWidth = 1.0
        UIColor(0x26343F).set()
        path.stroke()
    }
    
    private func initContentViews() {
        backgroundColor = UIColor.clear
        layer.borderWidth = 1.0
        layer.borderColor = UIColor(0x26343F).cgColor
        
        addSubview(dayLabel)
        dayLabel.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(6.0)
            make.centerX.equalToSuperview()
        }
        addSubview(yearLabel)
        yearLabel.snp.makeConstraints { (make) in
            make.bottom.equalToSuperview().offset(-5.0)
            make.centerX.equalToSuperview()
        }
    }
    
}

/// 用于分享的屏幕快照
class ExamPlanScreenShotShareView: UIView {
    
    private lazy var titleLabel: UILabel = {
        let label: UILabel = UILabel(frame: CGRect.zero)
        label.numberOfLines = 4
        return label
    }()
    private lazy var dateView: DateView = DateView(frame: CGRect.zero)
    private lazy var heartenImageView: UIImageView = UIImageView(frame: CGRect.zero, imageName: "hearten_share")
    private lazy var qrCodeBackgroundView: UIView = {
        let view: UIView = UIView(frame: CGRect.zero)
        view.backgroundColor = UIColor.white
        view.layer.cornerRadius = 10.0
        view.addSubview(qrCodeImageView)
        var leftSpace: CGFloat = 20.0
        var rightSpace: CGFloat = 16.0
        if Device().diagonal == 4.0 {
            leftSpace = 16.0
            rightSpace = 8.0
        }
        qrCodeImageView.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(leftSpace)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(60.0)
        }
        view.addSubview(introductionLabel)
        introductionLabel.snp.makeConstraints { (make) in
            make.left.equalTo(qrCodeImageView.snp.right).offset(rightSpace)
            make.centerY.equalToSuperview()
        }
        return view
    }()
    private lazy var qrCodeImageView: UIImageView = UIImageView(frame: CGRect.zero, imageName: "qrCode")
    private lazy var introductionLabel: UILabel = {
        let label: UILabel = UILabel(frame: CGRect.zero, text: "", textColor: UIColor(0x949BA1), fontSize: 13.0)
        let paragraph2: NSMutableParagraphStyle = NSMutableParagraphStyle()
        paragraph2.lineSpacing = 4.0
        label.attributedText = NSAttributedString(string: "选校帝App\n", attributes: [NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 20.0), NSAttributedStringKey.foregroundColor: UIColor(0x26343F), NSAttributedStringKey.paragraphStyle: paragraph2]) + "出国留学具有参考意义的院校库"
        label.numberOfLines = 2
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initContentViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    public func configureSharedView(examName: String, daysCount: Int, currentYear: String, currentMonth: String, currentDay: String) {
        let paragraph1: NSMutableParagraphStyle = NSMutableParagraphStyle()
        paragraph1.lineSpacing = 6.0
        let paragraph2: NSMutableParagraphStyle = NSMutableParagraphStyle()
        paragraph2.lineSpacing = 4.0
        
        let attrTitle = NSAttributedString(string: "备考"+examName, attributes: [NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 17.0), NSAttributedStringKey.paragraphStyle: paragraph1]) + NSAttributedString(string: "\n一\n", attributes: [NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 18.0), NSAttributedStringKey.paragraphStyle: paragraph1]) + NSAttributedString(string: "我已坚持\n", attributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 13.0), NSAttributedStringKey.paragraphStyle: paragraph2]) + NSAttributedString(string: "\(daysCount)", attributes: [NSAttributedStringKey.font: UIFont.boldNumericalFontOfSize(38.0), NSAttributedStringKey.paragraphStyle: paragraph2]) + NSAttributedString(string: " 天", attributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 12.0), NSAttributedStringKey.foregroundColor: UIColor(0x8DC2C5)])
        titleLabel.attributedText = attrTitle
        dateView.day = currentMonth + "." + currentDay
        dateView.year = currentYear
    }
    
    public func generateScreenShotImage() -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(self.bounds.size, false, UIScreen.main.scale)
        drawHierarchy(in: self.bounds, afterScreenUpdates: true)
        let snapshotImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return snapshotImage
    }
    
    private func initContentViews() {
        backgroundColor = UIColor.white
        addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(20.0)
            make.top.equalToSuperview().offset(24.0)
        }
        addSubview(dateView)
        dateView.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(24.0)
            make.right.equalToSuperview().offset(-20.0)
            make.width.equalTo(43.0)
            make.height.equalTo(49.0)
        }
        addSubview(heartenImageView)
        heartenImageView.snp.makeConstraints { (make) in
            make.left.equalToSuperview()
            make.width.equalTo(round(375.0*XDSize.scaleRatio))
            make.height.equalTo(round(498*XDSize.scaleRatio))
            make.bottom.equalToSuperview()
        }
        addSubview(qrCodeBackgroundView)
        qrCodeBackgroundView.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(16.0)
            make.right.equalToSuperview().offset(-16.0)
            make.bottom.equalToSuperview().offset(-20.0)
            make.height.equalTo(100.0)
        }
    }
    
}
