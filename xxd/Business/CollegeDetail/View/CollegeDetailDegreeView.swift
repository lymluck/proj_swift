//
//  CollegeDetailDegreeView.swift
//  xxd
//
//  Created by remy on 2018/3/1.
//  Copyright © 2018年 com.smartstudy. All rights reserved.
//

private let kUnitWidth: CGFloat = XDSize.screenWidth * 0.5
private let kUnitHeight: CGFloat = 74

class CollegeDetailDegreeView: UIView {
    
    private var contentView: UIView!
    private var headerView: CollegeDetailSectionHeaderView!
    private var footerView: CollegeDetailSectionFooterView!
    private var degreeColor: UIColor!
    private var leftUnitCount = 0
    private var rightUnitCount = 0
    var model: CollegeDetailDegreeModel! {
        didSet {
            switch model.degreeType {
            case .undergraduate:
                headerView.type = .bachelor
                footerView.type = .bachelor
                degreeColor = UIColor(0x078CF1)
            case .graduate:
                headerView.type = .master
                footerView.type = .master
                degreeColor = UIColor(0xFF9c08)
            case .art:
                headerView.type = .art
                footerView.type = .art
                degreeColor = UIColor(0x8F78EF)
            }
            refreshContentView()
        }
    }
    
    convenience init() {
        self.init(frame: CGRect(x: 0, y: 0, width: XDSize.screenWidth, height: 0))
        backgroundColor = UIColor.white
        
        headerView = CollegeDetailSectionHeaderView()
        headerView.bottomLine.isHidden = true
        addSubview(headerView)
        
        contentView = UIView(frame: CGRect(x: 0, y: headerView.bottom, width: width, height: 0))
        addSubview(contentView)
        
        footerView = CollegeDetailSectionFooterView()
        addSubview(footerView)
    }
    
    private func refreshContentView() {
        contentView.removeAllSubviews()
        leftUnitCount = 0
        rightUnitCount = 0
        
        if (!model.acceptRateArt.isEmpty) {
            leftUnitView("SIA录取率", model.acceptRateArt, degreeColor)
        }
        if (!model.acceptRate.isEmpty) {
            leftUnitView("录取率", model.acceptRate, model.acceptRateArt.isEmpty ? degreeColor : nil)
        }
        if (!model.difficultyName.isEmpty) {
            leftUnitView("申请难度", model.difficultyName)
        }
        if (!model.applyCount.isEmpty) {
            leftUnitView("申请人数", model.applyCount)
        }
        if (!model.applyDeadline.isEmpty) {
            leftUnitView("申请截止时间", model.applyDeadline)
        }
        if (!model.timeOffer.isEmpty) {
            leftUnitView("offer发放时间", model.timeOffer)
        }
        if (!model.timeOfferDeadline.isEmpty) {
            leftUnitView("offer最晚发放时间", model.timeOfferDeadline)
        }
        
        if (!model.feeTotal.isEmpty) {
            rightUnitView("总花费", model.feeTotal, degreeColor)
        }
        if (!model.feeApplication.isEmpty) {
            rightUnitView("申请费", model.feeApplication)
        }
        if (!model.feeTuition.isEmpty) {
            rightUnitView("学费", model.feeTuition)
        }
        if (!model.feeBook.isEmpty) {
            rightUnitView("书本费", model.feeBook)
        }
        if (!model.feeAccommodation.isEmpty) {
            rightUnitView("住宿费", model.feeAccommodation)
        }
        if (!model.feeLife.isEmpty) {
            rightUnitView("生活费", model.feeLife)
        }
        
        let space = leftUnitCount - rightUnitCount
        let rows = max(leftUnitCount, rightUnitCount)
        if space > 0 {
            for _ in 0..<abs(space) {
                rightUnitView()
            }
        } else if space < 0 {
            for _ in 0..<abs(space) {
                leftUnitView()
            }
        }
        contentView.height = CGFloat(rows) * kUnitHeight
        footerView.top = contentView.bottom
        height = footerView.bottom
    }
    
    private func leftUnitView(_ title: String = "", _ content: String = "", _ color: UIColor? = nil) {
        let top = CGFloat(leftUnitCount) * kUnitHeight
        let view = UIView(frame: CGRect(x: 0, y: top, width: kUnitWidth, height: kUnitHeight))
        contentView.addSubview(view)
        if title.isEmpty {
            addEmptyView(view)
        } else {
            let views = getDataView(view)
            views.t.text = title
            views.c.text = content.isEmpty ? "-" : content
            if let color = color {
                views.t.textColor = color
                views.c.textColor = color
            }
        }
        let centerLine = UIView(frame: CGRect(x: kUnitWidth, y: top, width: XDSize.unitWidth, height: kUnitHeight), color: XDColor.itemLine)
        contentView.addSubview(centerLine)
        let topLine = UIView(frame: CGRect(x: 0, y: top, width: XDSize.screenWidth, height: XDSize.unitWidth), color: XDColor.itemLine)
        contentView.addSubview(topLine)
        leftUnitCount += 1
    }
    
    private func rightUnitView(_ title: String = "", _ content: String = "", _ color: UIColor? = nil) {
        let top = CGFloat(rightUnitCount) * kUnitHeight
        let view = UIView(frame: CGRect(x: kUnitWidth, y: top, width: kUnitWidth, height: kUnitHeight))
        contentView.addSubview(view)
        if title.isEmpty {
            addEmptyView(view)
        } else {
            let views = getDataView(view)
            views.t.text = title
            views.c.text = content.isEmpty ? "-" : content
            if let color = color {
                views.t.textColor = color
                views.c.textColor = color
            }
        }
        rightUnitCount += 1
    }
    
    private func getDataView(_ superView: UIView) -> (t: UILabel, c: UILabel) {
        let titleLabel = UILabel(text: "", textColor: UIColor(0xAAAAAA), fontSize: 13)!
        superView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (make) in
            make.centerX.equalTo(superView)
            make.bottom.equalTo(superView).offset(-15)
        }
        
        let contentLabel = UILabel(text: "", textColor: UIColor(0x58646E), fontSize: 20)!
        contentLabel.font = UIFont.boldNumericalFontOfSize(20)
        contentLabel.adjustsFontSizeToFitWidth = true
        superView.addSubview(contentLabel)
        contentLabel.snp.makeConstraints { (make) in
            make.centerX.equalTo(superView)
            make.bottom.equalTo(titleLabel.snp.top).offset(-5)
            make.width.lessThanOrEqualTo(superView).multipliedBy(0.9)
        }
        return (titleLabel, contentLabel)
    }
    
    private func addEmptyView(_ superView: UIView) {
        let layer = CAShapeLayer(layer: superView.layer)
        layer.lineWidth = XDSize.unitWidth
        layer.strokeColor = XDColor.itemLine.cgColor
        let path = UIBezierPath()
        path.move(to: CGPoint.zero)
        path.addLine(to: CGPoint(x: superView.width, y: superView.height))
        layer.path = path.cgPath
        superView.layer.addSublayer(layer)
    }
}
