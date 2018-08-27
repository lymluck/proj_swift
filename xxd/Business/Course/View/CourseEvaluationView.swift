//
//  CourseEvaluationView.swift
//  xxd
//
//  Created by remy on 2018/1/25.
//  Copyright © 2018年 com.smartstudy. All rights reserved.
//

protocol CourseDetailEvaluationHeaderDelegate: class {
    
    func courseDetailEvaluationHeaderDidStarBarPressed()
}

class CourseEvaluationHeader: UIView {
    
    weak var delegate: CourseDetailEvaluationHeaderDelegate?
    private var starBar: EvaluationStarBar!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        let container = UIView(frame: .zero, color: UIColor.white)
        addSubview(container)
        container.snp.makeConstraints { (make) in
            make.edges.equalTo(self).inset(UIEdgeInsetsMake(0, 0, 12, 0))
        }
        
        starBar = EvaluationStarBar(frame: .zero)
        starBar.canMark = false
        starBar.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(starBarPressed(gestureRecognizer:))))
        container.addSubview(starBar)
        starBar.snp.makeConstraints { (make) in
            make.top.equalTo(container).offset(32)
            make.centerX.equalTo(container)
        }
        
        let titleLabel = UILabel(text: "course_evaluation_tip".localized, textColor: XDColor.itemText, fontSize: 14)!
        container.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (make) in
            make.top.equalTo(starBar.snp.bottom).offset(24)
            make.centerX.equalTo(container)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK:- Action
    @objc func starBarPressed(gestureRecognizer: UIGestureRecognizer) {
        delegate?.courseDetailEvaluationHeaderDidStarBarPressed()
    }
}

class CourseEvaluationSectionHeader: UIView {
    
    private var evaluationCountLabel: UILabel!
    var evaluationCount = 0 {
        didSet {
            evaluationCountLabel.text = "\("course_evaluation_evaluation_list_section".localized) (\(evaluationCount))"
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.white
        
        evaluationCountLabel = UILabel(text: "course_evaluation_evaluation_list_section".localized, textColor: XDColor.itemText, fontSize: 14)
        addSubview(evaluationCountLabel)
        evaluationCountLabel.snp.makeConstraints { (make) in
            make.top.left.equalTo(self).offset(16)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
