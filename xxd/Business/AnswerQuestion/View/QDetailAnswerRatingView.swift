//
//  QDetailAnswerRatingView.swift
//  xxd
//
//  Created by Lisen on 2018/7/25.
//  Copyright © 2018 com.smartstudy. All rights reserved.
//

import UIKit

/// 查看学生对老师的评价视图
class QDetailAnswerRatingView: UIView {
    
    var rateScore: Int = 0 {
        didSet {
            rateScoreView.starCount = rateScore
        }
    }
    var rateContent: String? {
        didSet {
            rateContentLabel.text = rateContent
        }
    }
    private lazy var rateSeparatorView: UIView = UIView(frame: CGRect.zero, color: XDColor.itemLine)
    private lazy var rateHintLabel: UILabel = {
        let label: UILabel = UILabel(frame: CGRect.zero, text: "评价", textColor: UIColor(0x949BA1), fontSize: 15.0)
        label.textAlignment = .center
        return label
    }()
    private lazy var rateScoreView: EvaluationStarBar = {
        let view: EvaluationStarBar = EvaluationStarBar(frame: CGRect.zero, imageType: "small")
        view.isUserInteractionEnabled = false
        return view
    }()
    private lazy var rateContentLabel: UILabel = UILabel(frame: CGRect.zero, text: "", textColor: UIColor(0x58646E), fontSize: 14.0)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        initContentViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    private func initContentViews() {
        backgroundColor = UIColor.white
        addSubview(rateSeparatorView)
        rateSeparatorView.snp.makeConstraints { (make) in
            make.top.right.equalToSuperview()
            make.left.equalToSuperview().offset(64.0)
            make.height.equalTo(XDSize.unitWidth)
        }
        addSubview(rateHintLabel)
        rateHintLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(16.0)
            make.top.equalToSuperview().offset(19.0)
        }
        addSubview(rateScoreView)
        rateScoreView.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(19.0)
            make.left.equalToSuperview().offset(64.0)
        }
        rateContentLabel.numberOfLines = 0
        rateContentLabel.sizeToFit()
        addSubview(rateContentLabel)
        rateContentLabel.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(42.0)
            make.left.equalToSuperview().offset(64.0)
            make.right.equalToSuperview().offset(-16.0)
            make.bottom.equalToSuperview().offset(-20.0)
        }
    }
    
}

/// 未评价视图
class QDetailAnswerUnratingView: UIView {
    
    private lazy var rateSeparatorView: UIView = UIView(frame: CGRect.zero, color: XDColor.itemLine)
    private lazy var rateStarView: EvaluationStarBar = {
        let view: EvaluationStarBar = EvaluationStarBar(frame: CGRect.zero, imageType: "middle")
        view.isUserInteractionEnabled = false
        return view
    }()
    private lazy var rateHintLabel: UILabel = {
        let label: UILabel = UILabel(frame: CGRect.zero, text: "评价该老师", textColor: UIColor(0x949BA1), fontSize: 13.0)
        label.textAlignment = .center
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        initContentViews()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    private func initContentViews() {
        backgroundColor = UIColor.white
        /// 添加评价视图
        addSubview(rateSeparatorView)
        rateSeparatorView.snp.makeConstraints { (make) in
            make.top.right.equalToSuperview()
            make.left.equalToSuperview().offset(64.0)
            make.height.equalTo(XDSize.unitWidth)
        }
        addSubview(rateStarView)
        rateStarView.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(20.0)
            make.centerX.equalToSuperview()
        }
        addSubview(rateHintLabel)
        rateHintLabel.snp.makeConstraints { (make) in
            make.top.equalTo(rateStarView.snp.bottom).offset(12.0)
            make.centerX.equalToSuperview()
            make.height.equalTo(14.0)
        }
    }
}
