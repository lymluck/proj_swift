//
//  QDetailHeader.swift
//  xxd
//
//  Created by remy on 2018/1/29.
//  Copyright © 2018年 com.smartstudy. All rights reserved.
//

class QDetailHeader: UIView, QDetailItemStyle {
    
    private var askerAvatar: UIImageView!
    private var askerName: UILabel!
    private var question: UILabel!
    private var askTime: UILabel!
    private var answerStatus: UILabel!
    private lazy var countryTagView: UILabel = {
        let label: UILabel = UILabel(frame: .zero, text: "", textColor: UIColor.white, fontSize: 12.0)
        label.backgroundColor = UIColor(0xE7C676)
        label.layer.cornerRadius = 2.0
        label.layer.masksToBounds = true
        return label
    }()
    private lazy var degreeTagView: UILabel = {
        let label: UILabel = UILabel(frame: .zero, text: "", textColor: UIColor.white, fontSize: 12.0)
        label.backgroundColor = UIColor(0xFCA398)
        label.layer.cornerRadius = 2.0
        label.layer.masksToBounds = true
        return label
    }()
    var model: QuestionModel! {
        didSet {
            var height: CGFloat = topInfoHeight
            let textHeight = model.question.heightForFont(UIFont.boldSystemFont(ofSize: 16), XDSize.screenWidth - 80, contentTextLineHeight)
            height += textHeight + 50 + 40
            self.height = height
            
            askerAvatar.setAutoOSSImage(urlStr: model.askerAvatar)
            askerName.text = model.askerName
            if model.targetCountry.isEmpty {
                countryTagView.isHidden = true
            } else {
                countryTagView.isHidden = false
                countryTagView.text = " " + model.targetCountry + " "
            }
            if model.targetDegree.isEmpty {
                degreeTagView.isHidden = true
            } else {
                degreeTagView.isHidden = false
                degreeTagView.text = " " + model.targetDegree + " "
            }
            question.setText(model.question, lineHeight: contentTextLineHeight)
            question.height = textHeight
            askTime.text = model.askDetailTime
            answerStatus.text = model.answered ? "回复" : "选校帝留学服务老师正在解答中,请稍后..."
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.white
        
        // 提问者信息
        askerAvatar = UIImageView(frame: CGRect(x: 16, y: 16, width: 40, height: 40))
        askerAvatar.layer.cornerRadius = 20
        askerAvatar.layer.masksToBounds = true
        self.addSubview(askerAvatar)
        askerName = UILabel(frame: .zero, text: "", textColor: XDColor.itemTitle, fontSize: 14, bold: true)
        self.addSubview(askerName)
        askerName.snp.makeConstraints { (make) in
            make.centerY.equalTo(askerAvatar)
            make.left.equalTo(self).offset(contentPaddingLeft)
//            make.right.lessThanOrEqualTo(-144.0)
            make.right.equalTo(-155.0)
        }
        
        // 标签信息
        addSubview(degreeTagView)
        degreeTagView.snp.makeConstraints { (make) in
            make.centerY.equalTo(askerAvatar)
            make.right.equalTo(-16.0)
            make.height.equalTo(18.0)
        }
        addSubview(countryTagView)
        countryTagView.snp.makeConstraints { (make) in
            make.centerY.equalTo(degreeTagView)
            make.right.equalTo(degreeTagView.snp.left).offset(-4.0)
            make.height.equalTo(18.0)
        }
        
        // 问题内容
        question = UILabel(frame: CGRect(x: contentPaddingLeft, y: topInfoHeight, width: XDSize.screenWidth - 80, height: 0), text: "", textColor: XDColor.itemTitle, fontSize: 16, bold: true)
        question.numberOfLines = 0
        self.addSubview(question)
        let flag = UILabel(frame: .zero, text: " 问 ", textColor: UIColor.white, fontSize: 12)!
        flag.backgroundColor = UIColor(0xFFB400)
        flag.layer.cornerRadius = 2
        flag.layer.masksToBounds = true
        self.addSubview(flag)
        flag.snp.makeConstraints { (make) in
            make.top.equalTo(question).offset(2)
            make.right.equalTo(question.snp.left).offset(-8)
            make.height.equalTo(20)
        }
        
        // 问题信息
        askTime = UILabel(frame: .zero, text: "", textColor: XDColor.itemText, fontSize: 12)
        self.addSubview(askTime)
        askTime.snp.makeConstraints { (make) in
            make.top.equalTo(question.snp.bottom).offset(22)
            make.left.equalTo(self).offset(contentPaddingLeft)
        }
        
        // 回答情况
        let lineView = UIView(frame: .zero, color: XDColor.mainBackground)
        self.addSubview(lineView)
        lineView.snp.makeConstraints { (make) in
            make.top.equalTo(question.snp.bottom).offset(50)
            make.left.equalTo(self)
            make.size.equalTo(CGSize(width: XDSize.screenWidth, height: 40))
        }
        answerStatus = UILabel(frame: .zero, text: "", textColor: XDColor.itemText, fontSize: 14)
        lineView.addSubview(answerStatus)
        answerStatus.snp.makeConstraints { (make) in
            make.top.equalTo(lineView).offset(14)
            make.left.equalTo(lineView).offset(16)
            make.right.equalTo(lineView).offset(-16)
            make.height.equalTo(20)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
