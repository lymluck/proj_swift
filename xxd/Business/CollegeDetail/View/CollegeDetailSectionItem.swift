//
//  CollegeDetailSectionItem.swift
//  xxd
//
//  Created by remy on 2018/2/28.
//  Copyright © 2018年 com.smartstudy. All rights reserved.
//

let kEventCollegeDetailMoreTap = "kEventCollegeDetailMoreTap"
let kErrorCorrectionTap = "kErrorCorrectionTap"
private let kSectionHeight: CGFloat = 56

enum CollegeDetailSectionType: Int {
    case intro
    case bachelor
    case master
    case art
    case qa
    case info
    
    var chineseTitle: String {
        switch self {
        case .intro:
            return "学校简介"
        case .bachelor:
            return "本科申请"
        case .master:
            return "研究生申请"
        case .art:
            return "艺术生申请"
        case .qa:
            return "留学问答"
        case .info:
            return "学校留学资讯"
        }
    }
}

class CollegeDetailSectionItem: NSObject {
    
    var type: CollegeDetailSectionType!
    var headerView: CollegeDetailSectionHeaderView!
    var footerView: CollegeDetailSectionFooterView!
    
    convenience init(type: CollegeDetailSectionType) {
        self.init()
        self.type = type
        
        headerView = CollegeDetailSectionHeaderView()
        headerView.type = type
        footerView = CollegeDetailSectionFooterView()
        footerView.type = type
    }
}

class CollegeDetailSectionHeaderView: UIView {
    
    var titleLabel: UILabel!
    var bottomLine: UIView!
    private var errorCorrectButton: UIButton = UIButton(frame: CGRect.zero, title: "纠错", fontSize: 13.0, titleColor: UIColor(0x078CF1), target: self, action: #selector(eventButtonResponse(_:)))
    var type: CollegeDetailSectionType! {
        didSet {
            errorCorrectButton.tag = type.rawValue
            titleLabel.text = type.chineseTitle
            if type == .qa || type == .info {
                errorCorrectButton.isHidden = true
            }
        }
    }
    
    convenience init() {
        self.init(frame: CGRect(x: 0, y: 0, width: XDSize.screenWidth, height: kSectionHeight))
        backgroundColor = UIColor.clear
        
        titleLabel = UILabel(frame: .zero, text: "", textColor: XDColor.itemTitle, fontSize: 20, bold: true)
        titleLabel.textAlignment = .center
        titleLabel.backgroundColor = UIColor.white
        addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (make) in
            make.left.bottom.equalTo(self)
            make.size.equalTo(CGSize(width: XDSize.screenWidth, height: kSectionHeight))
        }
        addSubview(errorCorrectButton)
        errorCorrectButton.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.right.equalTo(-20.0)
        }
        bottomLine = UIView(frame: .zero, color: UIColor(0xDDDDDD))
        addSubview(bottomLine)
        bottomLine.snp.makeConstraints { (make) in
            make.left.bottom.equalTo(self)
            make.size.equalTo(CGSize(width: XDSize.screenWidth, height: XDSize.unitWidth))
        }
    }
    
    @objc private func eventButtonResponse(_ sender: UIButton) {
        routerEvent(name: kErrorCorrectionTap, data: ["sectionType": type])
    }
}

class CollegeDetailSectionFooterView: UIView {
    
    private let maxCount = 6
    private let maxCol = 3
    private var moreBtn: UIButton!
    private var labels = [UILabel]()
    var formView: UIView!
    var topLine: UIView!
    var type: CollegeDetailSectionType! {
        didSet {
            switch type {
            case .intro:
                titles = ["基本信息", "院校数据", "招生信息", "教学特色", "院系设置", "专业信息"]
            case .bachelor:
                titles = ["录取信息", "留学费用", "考试要求", "院校信息", "申请材料", "申请流程"]
            case .master:
                titles = ["录取信息", "留学费用", "考试要求", "招生办信息", "申请材料", "申请流程"]
            case .art:
                titles = ["录取信息", "留学费用", "优势专业", "本科申请", "研究生申请", "申请经验"]
            default:
                titles = nil
            }
        }
    }
    var titles: [String]? {
        didSet {
            if let titles = titles, titles.count > 0 {
                for (index, title) in titles.enumerated() {
                    labels[index].text = title
                }
                height = 166
                formView.isHidden = false
            } else {
                height = 88
                formView.isHidden = true
            }
        }
    }
    
    convenience init() {
        self.init(frame: CGRect(x: 0, y: 0, width: XDSize.screenWidth, height: 106))
        backgroundColor = UIColor.white
        
        topLine = UIView(frame: CGRect(x: 0, y: 0, width: XDSize.screenWidth, height: XDSize.unitWidth), color: UIColor(0xDDDDDD))
        addSubview(topLine)
        
        formView = UIView(frame: .zero)
        formView.isHidden = true
        addSubview(formView)
        formView.snp.makeConstraints { (make) in
            make.top.equalTo(self).offset(16)
            make.left.right.equalTo(self)
            make.width.equalTo(XDSize.screenWidth)
        }
        var lastLabel: UILabel!
        for i in 0..<maxCount {
            let top = i / maxCol * 32
            let col = i % maxCol
            let label = UILabel(text: "", textColor: UIColor(0xAAAAAA), fontSize: 13)!
            label.textAlignment = .center
            formView.addSubview(label)
            label.snp.makeConstraints { (make) in
                make.top.equalTo(formView).offset(top)
                make.left.equalTo(col == 0 ? formView : lastLabel.snp.right)
                make.width.equalTo(formView).multipliedBy(1 / CGFloat(maxCol))
                make.height.equalTo(32)
                if i == maxCount - 1 {
                    make.bottom.equalTo(formView)
                }
            }
            lastLabel = label
            labels.append(label)
            let line = UIView(frame: .zero, color: UIColor(0xDDDDDD))
            label.addSubview(line)
            line.snp.makeConstraints { (make) in
                make.centerY.equalTo(label)
                make.right.equalTo(label)
                make.size.equalTo(CGSize(width: XDSize.unitWidth, height: 10))
            }
        }
        
        moreBtn = UIButton(frame: .zero, title: "查看更多", fontSize: 14, titleColor: UIColor.white, target: self, action: #selector(moreTap(sender:)))
        moreBtn.backgroundColor = XDColor.main
        moreBtn.layer.cornerRadius = 6
        moreBtn.setImage(UIImage(named: "college_more_icon"), for: .normal)
        moreBtn.setImage(UIImage(named: "college_more_icon")?.tint(UIColor.white.withAlphaComponent(0.6)), for: .highlighted)
        moreBtn.setTitleColor(UIColor.white.withAlphaComponent(0.6), for: .highlighted)
        moreBtn.titleEdgeInsets = UIEdgeInsetsMake(0, -2, 0, -2)
        moreBtn.imageEdgeInsets = UIEdgeInsetsMake(0, 68, 0, -68)
        addSubview(moreBtn)
        moreBtn.snp.makeConstraints { (make) in
            make.bottom.equalTo(self).offset(-24)
            make.centerX.equalTo(self)
            make.size.equalTo(CGSize(width: XDSize.screenWidth - 32, height: 40))
        }
    }
    
    //MARK:- Action
    @objc func moreTap(sender: UIButton) {
        routerEvent(name: kEventCollegeDetailMoreTap, data: ["type":type])
    }
}
