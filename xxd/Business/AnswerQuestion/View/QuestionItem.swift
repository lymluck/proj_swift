//
//  QuestionItem.swift
//  xxd
//
//  Created by remy on 2018/1/29.
//  Copyright © 2018年 com.smartstudy. All rights reserved.
//

class QuestionItem: SSCellItem {
    
    var textHeight: CGFloat = 0
    var model: QuestionModel!
    var type: QAListType!
    lazy var cellHeight: CGFloat = {
        var height: CGFloat = 0
        // 是否显示提问者信息
        switch type {
        case .latest:
            // 68 + x + 36
            // 顶部信息 + 问题 + 问题信息
            height = textHeight.rounded(.up) + 104
            if model.answered {
                // 底部信息
                height += 50
            } else {
                // 底部分割线
                height += 10
            }
        case .recommend:
            // 68 + x + 36
            // 顶部信息 + 问题 + 院校信息
            height = textHeight.rounded(.up) + 104
            if model.schoolName.isEmpty {
                // 底部分割线
                height += 10
            } else {
                // 底部信息
                height += 50
            }
        case .search:
            // 68 + x + 36
            // 顶部信息 + 问题 + 问题信息
            height = textHeight.rounded(.up) + 104
        case .mine:
            // 18 + x + 36 + 16
            // 顶部距离 + 问题 + 问题信息 + 底部距离
            height = textHeight.rounded(.up) + 70
        default:
            break
        }
        return height
    }()
    
    convenience init(model: QuestionModel, type: QAListType = .latest) {
        self.init()
        self.model = model
        self.type = type
        let height = model.question.heightForFont(UIFont.systemFont(ofSize: 16), XDSize.screenWidth - 32, 22)
        textHeight = CGFloat.minimum(height, 66)
    }
    
    override init!(attributes: [AnyHashable : Any]! = [:]) {
        super.init(attributes: attributes)
        model = QuestionModel.yy_model(with: attributes)
        type = .latest
        let height = model.question.heightForFont(UIFont.systemFont(ofSize: 16), XDSize.screenWidth - 32, 22)
        textHeight = CGFloat.minimum(height, 66)
    }
    
    override init!(cellClass: AnyClass!, userInfo: Any!) {
        super.init(cellClass: cellClass, userInfo: userInfo)
    }
    
    override func cellClass() -> AnyClass! {
        switch type {
        case .mine:
            return QuestionMineItemCell.self
        case .latest:
            return QuestionLatestItemCell.self
        case .recommend:
            return QuestionRecommendItemCell.self
        case .search:
            return QuestionSearchItemCell.self
        default:
            return QuestionItemCell.self
        }
    }
}

class QuestionMineItemCell: SSTableViewCell {
    
    private var question: UILabel!
    private var askDate: UILabel!
    private var answerState: UILabel!
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.backgroundColor = UIColor.white
        
        // 问题内容
        question = UILabel(frame: CGRect(x: 16, y: 18, width: XDSize.screenWidth - 32, height: 0), text: "", textColor: XDColor.itemTitle, fontSize: 16)
        question.numberOfLines = 3
        contentView.addSubview(question)
        
        // 问题信息
        let infoView = UIView()
        contentView.addSubview(infoView)
        infoView.snp.makeConstraints { (make) in
            make.top.equalTo(question.snp.bottom).offset(2)
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
            make.height.equalTo(34)
        }
        
        // 问题时间
        askDate = UILabel(text: "", textColor: XDColor.itemText, fontSize: 12)
        infoView.addSubview(askDate)
        askDate.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview()
        }
        
        // 问题状态
        answerState = UILabel(text: "", textColor: XDColor.main, fontSize: 13)
        infoView.addSubview(answerState)
        answerState.snp.makeConstraints { (make) in
            make.right.equalToSuperview()
            make.centerY.equalToSuperview()
        }
        
        // 分割线
        let bottomLine = UIView(frame: CGRect(x: 0, y: contentView.height - 10, width: XDSize.screenWidth, height: 10), color: XDColor.mainBackground)
        bottomLine.autoresizingMask = .flexibleTopMargin
        contentView.addSubview(bottomLine)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override class func height(for object: Any!, at indexPath: IndexPath!, tableView: UITableView!) -> CGFloat {
        return (object as! QuestionItem).cellHeight
    }
    
    override func shouldUpdate(with object: Any!) -> Bool {
        if super.shouldUpdate(with: object), let object = object as? QuestionItem {
            question.height = object.textHeight
            question.setText(object.model.question, lineHeight: 22)
            askDate.text = object.model.askDate
            if object.model.answered {
                if object.model.hasUnreadAnswers > 0 {
                    answerState.text = "• 已回复"
                    answerState.textColor = UIColor(0xF6611D)
                } else {
                    answerState.text = "已回复"
                    answerState.textColor = XDColor.itemText
                }
            } else {
                answerState.text = "待回复"
                answerState.textColor = XDColor.main
            }
        }
        return true
    }
}

class QuestionItemCell: SSTableViewCell {
    
    private var topView: UIView!
    private var askerAvatar: UIImageView!
    private var askerName: UILabel!
    private var question: UILabel!
    private var askTime: UILabel!
    private var askVisit: UILabel!
    private var answerNum: UILabel!
    private lazy var countryTagView: UILabel = {
        let label: UILabel = UILabel(frame: .zero, text: "", textColor: UIColor.white, fontSize: 12.0)
        label.backgroundColor = UIColor(0xE7C676)
        label.layer.cornerRadius = 2.0
        label.layer.masksToBounds = true
        return label
    }()
    private lazy var degreeTagView: UILabel = {
        let label: UILabel = UILabel(frame: .zero, text: "ƒ", textColor: UIColor.white, fontSize: 12.0)
        label.backgroundColor = UIColor(0xFCA398)
        label.layer.cornerRadius = 2.0
        label.layer.masksToBounds = true
        return label
    }()
    private lazy var lineView: UIView = UIView(frame: .zero, color: UIColor(0xC4C9CC))
    var infoView: UIView!
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.backgroundColor = UIColor.white
        
        // 提问者信息
        topView = UIView(frame: CGRect(x: 0, y: 0, width: XDSize.screenWidth, height: 64), color: UIColor.clear)
        contentView.addSubview(topView)
        askerAvatar = UIImageView(frame: CGRect(x: 16, y: 16, width: 40, height: 40))
        askerAvatar.layer.cornerRadius = 20
        askerAvatar.layer.masksToBounds = true
        topView.addSubview(askerAvatar)
        askerName = UILabel(frame: .zero, text: "", textColor: XDColor.itemTitle, fontSize: 14, bold: true)
        topView.addSubview(askerName)
        askerName.snp.makeConstraints { (make) in
            make.centerY.equalTo(askerAvatar)
            make.left.equalTo(topView).offset(64)
//            make.right.lessThanOrEqualToSuperview().offset(-144.0)
            make.right.equalTo(-155.0)
        }
        
        // 标签信息
        topView.addSubview(degreeTagView)
        degreeTagView.snp.makeConstraints { (make) in
            make.centerY.equalTo(askerAvatar)
            make.right.equalTo(-16.0)
            make.height.equalTo(18.0)
        }
        topView.addSubview(countryTagView)
        countryTagView.snp.makeConstraints { (make) in
            make.centerY.equalTo(degreeTagView)
            make.right.equalTo(degreeTagView.snp.left).offset(-4.0)
            make.height.equalTo(18.0)
        }

        // 问题内容
        question = UILabel(frame: CGRect(x: 16, y: 68, width: XDSize.screenWidth - 32, height: 0), text: "", textColor: XDColor.itemTitle, fontSize: 16)
        question.numberOfLines = 3
        contentView.addSubview(question)
        
        // 问题信息
        infoView = UIView()
        contentView.addSubview(infoView)
        infoView.snp.makeConstraints { (make) in
            make.top.equalTo(question.snp.bottom).offset(2)
            make.left.right.equalTo(contentView)
            make.height.equalTo(34)
        }
        
        // 提问时间
        askTime = UILabel(text: "", textColor: XDColor.itemText, fontSize: 12)
        topView.addSubview(askTime)
        askTime.snp.makeConstraints { (make) in
            make.left.equalTo(topView).offset(16)
            make.centerY.equalTo(infoView)
        }
        topView.addSubview(lineView)
        lineView.snp.makeConstraints { (make) in
            make.left.equalTo(askTime.snp.right).offset(5.0)
            make.centerY.equalTo(askTime)
            make.width.equalTo(1.0)
            make.height.equalTo(10.0)
        }
        
        // flag
        let visitImageView = UIImageView(image: UIImage(named: "information_visit_count"))
        infoView.addSubview(visitImageView)
        visitImageView.snp.makeConstraints { (make) in
            make.centerY.equalTo(infoView)
//            make.left.equalTo(infoView).offset(16)
            make.left.equalTo(lineView.snp.right).offset(5.0)
        }
        
        // 问题浏览数
        askVisit = UILabel(text: "", textColor: XDColor.itemText, fontSize: 12)
        infoView.addSubview(askVisit)
        askVisit.snp.makeConstraints { (make) in
            make.centerY.equalTo(infoView)
            make.left.equalTo(visitImageView.snp.right).offset(2)
//            make.left.equalTo(16.0)
        }
        
        // 问题回答数
        answerNum = UILabel(text: "", textColor: XDColor.main, fontSize: 12)
        infoView.addSubview(answerNum)
        answerNum.snp.makeConstraints { (make) in
            make.right.equalTo(infoView).offset(-16)
            make.centerY.equalTo(infoView)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override class func height(for object: Any!, at indexPath: IndexPath!, tableView: UITableView!) -> CGFloat {
        return (object as! QuestionItem).cellHeight
    }
    
    override func shouldUpdate(with object: Any!) -> Bool {
        if super.shouldUpdate(with: object), let object = object as? QuestionItem {
            askerAvatar.setAutoOSSImage(urlStr: object.model.askerAvatar)
            askerName.text = object.model.askerName
            if object.model.targetCountry.isEmpty {
                countryTagView.isHidden = true
            } else {
                countryTagView.isHidden = false
                countryTagView.text = " " + object.model.targetCountry + " "
            }
            if object.model.targetDegree.isEmpty {
                degreeTagView.isHidden = true
            } else {
                degreeTagView.isHidden = false
                degreeTagView.text = " " + object.model.targetDegree + " "
            }
            askTime.text = object.model.createTimeText
            question.height = object.textHeight
            question.setText(object.model.question, lineHeight: 22)
            askVisit.text = "\(object.model.visitCount)人看过"
            answerNum.text = "\(object.model.answerCount) 回答"
        }
        return true
    }
}

class QuestionSearchItemCell: QuestionItemCell {
    
    private var bottomLine: UIView!
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        // 分割线
        bottomLine = UIView(frame: CGRect(x: 16, y: contentView.height - XDSize.unitWidth, width: XDSize.screenWidth - 32, height: XDSize.unitWidth), color: XDColor.itemLine)
        bottomLine.autoresizingMask = .flexibleTopMargin
        contentView.addSubview(bottomLine)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class QuestionLatestItemCell: QuestionItemCell {

    private var bottomView: UIView!
    private var answererName: UILabel!
    private var answererTitle: UILabel!
    private lazy var lineView: UIView = UIView(frame: .zero, color: UIColor(0xC4C9CC))

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        // 回答者信息
        bottomView = UIView(frame: .zero)
        contentView.addSubview(bottomView)
        bottomView.snp.makeConstraints { (make) in
            make.top.equalTo(infoView.snp.bottom)
            make.left.right.equalTo(contentView)
            make.height.equalTo(50)
        }
        
        // 顶部分割线
        let tline = UIView(frame: CGRect(x: 16, y: 0, width: XDSize.screenWidth - 32, height: XDSize.unitWidth), color: XDColor.itemLine)
        bottomView.addSubview(tline)
        
        // flag
        let flag = UIImageView(image: UIImage(named: "answer_flag"))
        bottomView.addSubview(flag)
        flag.snp.makeConstraints { (make) in
            make.left.equalTo(bottomView).offset(16)
            make.top.equalTo(bottomView).offset(11)
        }
        
        // 回答者名称
        answererName = UILabel(text: "", textColor: XDColor.main, fontSize: 12)
        bottomView.addSubview(answererName)
        answererName.snp.makeConstraints { (make) in
            make.centerY.equalTo(flag)
            make.left.equalTo(flag.snp.right).offset(6)
            make.width.lessThanOrEqualToSuperview().multipliedBy(0.5)
        }
        bottomView.addSubview(lineView)
        lineView.snp.makeConstraints { (make) in
            make.centerY.equalTo(answererName)
            make.left.equalTo(answererName.snp.right).offset(4.0)
            make.width.equalTo(1.0)
            make.height.equalTo(9.0)
        }
        
        // 回答者头衔
        answererTitle = UILabel(text: "", textColor: XDColor.itemText, fontSize: 12)
        bottomView.addSubview(answererTitle)
        answererTitle.snp.makeConstraints { (make) in
            make.centerY.equalTo(flag)
            make.left.equalTo(lineView.snp.right).offset(4)
            make.right.lessThanOrEqualToSuperview().offset(-16)
        }
        
        // 底部分割线
        let bottomLine = UIView(frame: CGRect(x: 0, y: contentView.height - 10, width: XDSize.screenWidth, height: 10), color: XDColor.mainBackground)
        bottomLine.autoresizingMask = .flexibleTopMargin
        contentView.addSubview(bottomLine)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func shouldUpdate(with object: Any!) -> Bool {
        if super.shouldUpdate(with: object), let object = object as? QuestionItem {
            if object.model.answererName.isEmpty {
                bottomView.isHidden = true
            } else {
                bottomView.isHidden = false
                answererName.text = object.model.answererName
                answererTitle.text = "\(object.model.answererTitle)"
            }
        }
        return true
    }
}

class QuestionRecommendItemCell: QuestionItemCell {
    
    private var bottomView: UIView!
    private var schoolLogo: UIImageView!
    private var schoolName: UILabel!
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        // 院校信息
        bottomView = UIView(frame: .zero)
        contentView.addSubview(bottomView)
        bottomView.snp.makeConstraints { (make) in
            make.top.equalTo(infoView.snp.bottom)
            make.left.right.equalTo(contentView)
            make.height.equalTo(50)
        }
        
        // 顶部分割线
        let tline = UIView(frame: CGRect(x: 16, y: 0, width: XDSize.screenWidth - 32, height: XDSize.unitWidth), color: XDColor.itemLine)
        bottomView.addSubview(tline)
        
        // 院校logo
        schoolLogo = UIImageView(frame: CGRect(x: 16, y: 12, width: 16, height: 16))
        schoolLogo.layer.cornerRadius = 8
        schoolLogo.layer.masksToBounds = true
        bottomView.addSubview(schoolLogo)
        
        // 院校名称
        schoolName = UILabel(text: "", textColor: XDColor.main, fontSize: 12)
        bottomView.addSubview(schoolName)
        schoolName.snp.makeConstraints { (make) in
            make.centerY.equalTo(schoolLogo)
            make.left.equalToSuperview().offset(36)
            make.right.lessThanOrEqualToSuperview().offset(-16)
        }
        
        // 底部分割线
        let bottomLine = UIView(frame: CGRect(x: 0, y: contentView.height - 10, width: XDSize.screenWidth, height: 10), color: XDColor.mainBackground)
        bottomLine.autoresizingMask = .flexibleTopMargin
        contentView.addSubview(bottomLine)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func shouldUpdate(with object: Any!) -> Bool {
        if super.shouldUpdate(with: object), let object = object as? QuestionItem {
            if object.model.schoolName.isEmpty {
                bottomView.isHidden = true
            } else {
                bottomView.isHidden = false
                schoolLogo.setAutoOSSImage(urlStr: object.model.schoolLogo)
                schoolName.text = object.model.schoolName
            }
        }
        return true
    }
}
