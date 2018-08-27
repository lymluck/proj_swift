//
//  CollegeIntroduceView.swift
//  xxd
//
//  Created by remy on 2018/2/24.
//  Copyright © 2018年 com.smartstudy. All rights reserved.
//

class CollegeIntroduceCell: UIView {
    
    private var titleLabel: UILabel!
    private var contentLabel: UILabel!
    var title = "" {
        didSet {
            titleLabel.text = title
        }
    }
    var detailText = "" {
        didSet {
            contentLabel.text = detailText.isEmpty ? "school_intro_missing_value".localized : detailText
        }
    }
    
    convenience init() {
        self.init(frame: .zero)
        backgroundColor = UIColor.white
        
        titleLabel = UILabel(text: "", textColor: XDColor.itemText, fontSize: 14)
        addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (make) in
            make.centerX.equalTo(self)
            make.bottom.equalTo(self).offset(-13)
        }
        
        contentLabel = UILabel(text: "", textColor: UIColor(0x58646E), fontSize: 22)
        contentLabel.font = UIFont.boldNumericalFontOfSize(22)
        addSubview(contentLabel)
        contentLabel.snp.makeConstraints { (make) in
            make.centerX.equalTo(self)
            make.bottom.equalTo(titleLabel.snp.top).offset(-4)
        }
    }
}

class CollegeIntroduceLinkCell: UIView {
    
    private var iconView: UIImageView!
    private var titleLabel: UILabel!
    private var contentLabel: UILabel!
    var icon: UIImage! {
        didSet {
            iconView.image = icon
        }
    }
    var title = "" {
        didSet {
            titleLabel.text = title
        }
    }
    var detailText = "" {
        didSet {
            contentLabel.text = detailText.isEmpty ? "school_intro_missing_value".localized : detailText
        }
    }
    
    convenience init() {
        self.init(frame: .zero)
        backgroundColor = UIColor.white
        
        titleLabel = UILabel(text: "", textColor: XDColor.itemText, fontSize: 15)
        addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (make) in
            make.top.equalTo(self).offset(21)
            make.left.equalTo(self).offset(35)
        }
        
        iconView = UIImageView()
        addSubview(iconView)
        iconView.snp.makeConstraints { (make) in
            make.centerY.equalTo(titleLabel)
            make.left.equalTo(self).offset(10)
        }
        
        contentLabel = UILabel(text: "", textColor: XDColor.itemTitle, fontSize: 15)
        contentLabel.numberOfLines = 0
        addSubview(contentLabel)
        contentLabel.snp.makeConstraints { (make) in
            make.top.equalTo(titleLabel)
            make.left.equalTo(self).offset(119)
            make.right.lessThanOrEqualTo(self).offset(-16)
            make.bottom.equalTo(self).offset(-21)
        }
    }
}

class CollegeIntroduceApplyCostCell: UIView {
    
    private var costLabel: UILabel!
    private var interviewLabel: UILabel!
    var cost = "" {
        didSet {
            costLabel.text = cost.isEmpty ? "school_intro_missing_value".localized : cost
        }
    }
    var interviewType: InterviewType! {
        didSet {
            switch interviewType {
            case .need:
                interviewLabel.text = "yes".localized
            case .noNeed:
                interviewLabel.text = "no".localized
            case .unknown:
                interviewLabel.text = "school_intro_missing_value".localized
            default:
                break
            }
        }
    }
    
    convenience init() {
        self.init(frame: .zero)
        backgroundColor = UIColor.white
        
        let costTitleLabel = UILabel(text: "school_intro_cell_apply_cost".localized, textColor: XDColor.itemText, fontSize: 13)!
        addSubview(costTitleLabel)
        costTitleLabel.snp.makeConstraints { (make) in
            make.centerX.equalTo(self).multipliedBy(0.5)
            make.bottom.equalTo(self).offset(-14)
        }
        
        costLabel = UILabel(text: "", textColor: UIColor(0x58646E), fontSize: 20)
        costLabel.font = UIFont.boldNumericalFontOfSize(20)
        addSubview(costLabel)
        costLabel.snp.makeConstraints { (make) in
            make.centerX.equalTo(costTitleLabel)
            make.bottom.equalTo(costTitleLabel.snp.top).offset(-4)
        }
        
        let interviewTitleLabel = UILabel(text: "school_intro_cell_need_interview".localized, textColor: XDColor.itemText, fontSize: 13)!
        addSubview(interviewTitleLabel)
        interviewTitleLabel.snp.makeConstraints { (make) in
            make.centerX.equalTo(self).multipliedBy(1.5)
            make.bottom.equalTo(self).offset(-14)
        }
        
        interviewLabel = UILabel(text: "", textColor: UIColor(0x58646E), fontSize: 20)
        interviewLabel.font = UIFont.boldNumericalFontOfSize(20)
        addSubview(interviewLabel)
        interviewLabel.snp.makeConstraints { (make) in
            make.centerX.equalTo(interviewTitleLabel)
            make.bottom.equalTo(interviewTitleLabel.snp.top).offset(-4)
        }
        
        let centerLine = UIView(frame: .zero, color: XDColor.itemLine)
        addSubview(centerLine)
        centerLine.snp.makeConstraints { (make) in
            make.width.equalTo(XDSize.unitWidth)
            make.top.equalTo(self).offset(17)
            make.bottom.equalTo(self).offset(-17)
            make.centerX.equalTo(self)
        }
    }
}

class CollegeIntroduceScoreCell: UIView {
    
    private var maxCol = 4
    private var placeHolderLabel: UILabel!
    private var unitViews = [UIView]()
    private var lineViews = [UIView]()
    var model: CollegeIntroduceModel! {
        didSet {
            let _ = unitViews.map { $0.removeFromSuperview() }
            unitViews.removeAll()
            let _ = lineViews.map { $0.removeFromSuperview() }
            lineViews.removeAll()
            
            var models = model.examScoreModels.map { return $0 }
            if models.count > maxCol {
                models = Array(models[0..<maxCol])
            }
            let ratio = 1.0 / Double(models.count)
            for (index, model) in models.enumerated() {
                let unitView = UIView()
                addSubview(unitView)
                unitViews.append(unitView)
                unitView.snp.makeConstraints { (make) in
                    make.top.equalTo(self).offset(24)
                    make.left.equalTo(unitViews.count > 1 ? unitViews[index - 1].snp.right : self)
                    make.height.equalTo(46)
                    make.width.equalTo(self).multipliedBy(ratio)
                }
                
                let titleLabel = UILabel(text: model.name, textColor: XDColor.itemText, fontSize: 13)!
                unitView.addSubview(titleLabel)
                titleLabel.snp.makeConstraints { (make) in
                    make.centerX.equalTo(unitView)
                    make.bottom.equalTo(unitView)
                }
                
                let contentLabel = UILabel(text: model.score, textColor: UIColor(0x58646E), fontSize: 20)!
                contentLabel.font = UIFont.boldNumericalFontOfSize(20)
                contentLabel.adjustsFontSizeToFitWidth = true
                unitView.addSubview(contentLabel)
                contentLabel.snp.makeConstraints { (make) in
                    make.centerX.equalTo(unitView)
                    make.top.equalTo(unitView)
                    make.width.lessThanOrEqualTo(unitView.snp.width).multipliedBy(0.9)
                }
                
                if index < models.count - 1 {
                    let lineView = UIView()
                    lineView.backgroundColor = XDColor.itemLine
                    addSubview(lineView)
                    lineViews.append(lineView)
                    lineView.snp.makeConstraints { (make) in
                        make.top.bottom.equalTo(unitView)
                        make.left.equalTo(unitView.snp.right)
                        make.width.equalTo(XDSize.unitWidth)
                    }
                }
            }
            
            placeHolderLabel.isHidden = models.count > 0
        }
    }
    
    convenience init() {
        self.init(frame: .zero)
        backgroundColor = UIColor.white
        
        let tipLabel = UILabel(text: "school_intro_score_tip".localized, textColor: UIColor(0xC4C9CC), fontSize: 11)!
        addSubview(tipLabel)
        tipLabel.snp.makeConstraints { (make) in
            make.centerX.equalTo(self)
            make.bottom.equalTo(self).offset(-15)
        }
        
        placeHolderLabel = UILabel(text: "school_intro_missing_value".localized, textColor: UIColor(0x58646E), fontSize: 22)
        placeHolderLabel.font = UIFont.boldNumericalFontOfSize(22)
        placeHolderLabel.isHidden = true
        addSubview(placeHolderLabel)
        placeHolderLabel.snp.makeConstraints { (make) in
            make.centerX.equalTo(self)
            make.centerY.equalTo(self.snp.top).offset(47)
        }
    }
}
