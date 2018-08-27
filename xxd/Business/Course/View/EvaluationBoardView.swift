//
//  EvaluationBoardView.swift
//  xxd
//
//  Created by remy on 2018/1/25.
//  Copyright © 2018年 com.smartstudy. All rights reserved.
//

protocol EvaluationBoardViewDelegate: class {
    
    func evaluationBoardViewDidSubmitPressed(rate: Int, content: String)
}

class EvaluationBoardView: UIView, EvaluationStarBarDelegate {
    
    weak var delegate: EvaluationBoardViewDelegate?
    private(set) var submitButton: UIButton!
    var hasMark: Bool {
        return starBar.starCount > 0
    }
    private var starBar: EvaluationStarBar!
    private var descLabel: UILabel!
    private var textView: XDTextView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.white
        layer.cornerRadius = 5
        layer.shadowRadius = 10
        layer.shadowOffset = CGSize(width: 0, height: 4)
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.2
        
        starBar = EvaluationStarBar(frame: .zero)
        starBar.delegate = self
        addSubview(starBar)
        starBar.snp.makeConstraints { (make) in
            make.top.equalTo(self).offset(25)
            make.centerX.equalTo(self)
        }
        
        descLabel = UILabel(text: "", textColor: XDColor.main, fontSize: 14)
        addSubview(descLabel)
        descLabel.snp.makeConstraints { (make) in
            make.top.equalTo(starBar.snp.bottom).offset(9)
            make.centerX.equalTo(self)
        }
        
        textView = XDTextView(frame: .zero)
        textView.fontSize = 14
        textView.placeholder = "course_evaluation_mark_question".localized
        addSubview(textView)
        textView.snp.makeConstraints { (make) in
            make.size.equalTo(CGSize(width: 263, height: 120))
            make.centerX.equalTo(self)
            make.bottom.equalTo(self).offset(-82)
        }
        
        submitButton = UIButton(frame: .zero, title: "course_evaluation_submit_evaluation".localized, fontSize: 14, titleColor: UIColor.white, target: self, action: #selector(submitButtonPressed(sender:)))
        submitButton.backgroundColor = UIColor(0xC4C9CC)
        submitButton.layer.cornerRadius = 17
        submitButton.layer.masksToBounds = true
        submitButton.isEnabled = false
        addSubview(submitButton)
        submitButton.snp.makeConstraints { (make) in
            make.size.equalTo(CGSize(width: 170, height: 34))
            make.centerX.equalTo(self)
            make.bottom.equalTo(self).offset(-24)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func descriptionWithStarCount(_ count: Int) -> String {
        switch count {
        case 1:
            return "course_evaluation_mark_desc_one".localized
        case 2:
            return "course_evaluation_mark_desc_two".localized
        case 3:
            return "course_evaluation_mark_desc_three".localized
        case 4:
            return "course_evaluation_mark_desc_four".localized
        case 5:
            return "course_evaluation_mark_desc_five".localized
        default:
            return ""
        }
    }
    
    override func didMoveToWindow() {
        super.didMoveToWindow()
        starBar.startAnimating()
    }
    
    //MARK:- EvaluationStarBarDelegate
    func evaluationStarBarDidMark(starCount: Int) {
        descLabel.text = descriptionWithStarCount(starCount)
        submitButton.isEnabled = starCount > 0
        submitButton.backgroundColor = XDColor.main
    }
    
    //MARK:- Action
    @objc func submitButtonPressed(sender: UIButton) {
        let content = textView.text.isEmpty ? descriptionWithStarCount(starBar.starCount) : textView.text
        delegate?.evaluationBoardViewDidSubmitPressed(rate: starBar.starCount, content: content)
    }
}
