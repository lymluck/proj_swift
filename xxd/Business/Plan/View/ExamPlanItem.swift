//
//  ExamPlanItem.swift
//  xxd
//
//  Created by remy on 2018/5/24.
//  Copyright © 2018年 com.smartstudy. All rights reserved.
//

class ExamPlanItem: SSCellItem {

    var model: ExamDayModel!
    
    convenience init(model: ExamDayModel) {
        self.init()
        self.model = model
    }
    
    override func cellClass() -> AnyClass! {
        return ExamPlanItemCell.self
    }
}

class ExamPlanItemCell: SSTableViewCell {
    
    private var examLabel: UILabel!
    private var dateLabel: UILabel!
    private var selectCountLabel: UILabel!
    private var countdownLabel: UILabel!
    private var bottomLine: UIView!
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.backgroundColor = UIColor.white
        
        // 考试
        examLabel = UILabel(frame: .zero, text: "", textColor: XDColor.itemTitle, fontSize: 16, bold: true)
        contentView.addSubview(examLabel)
        examLabel.snp.makeConstraints { (make) in
            make.top.left.equalToSuperview().offset(16)
        }
        
        // 时间
        dateLabel = UILabel(text: "", textColor: UIColor(0x046FC2), fontSize: 14)
        contentView.addSubview(dateLabel)
        dateLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(80)
            make.top.equalToSuperview().offset(17)
        }
        
        // 参加考试的用户数
        selectCountLabel = UILabel(text: "", textColor: UIColor(0xC4C9CC), fontSize: 12)
        contentView.addSubview(selectCountLabel)
        selectCountLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(80)
            make.top.equalToSuperview().offset(41)
        }
        
        // 倒计时
        countdownLabel = UILabel(text: "", textColor: .clear, fontSize: 14)
        contentView.addSubview(countdownLabel)
        countdownLabel.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-16)
            make.top.equalToSuperview().offset(16)
        }
        
        // 分割线
        bottomLine = UIView(frame: CGRect(x: 16, y: contentView.height - XDSize.unitWidth, width: contentView.width, height: XDSize.unitWidth), color: XDColor.mainBackground)
        bottomLine.autoresizingMask = [.flexibleWidth, .flexibleTopMargin]
        contentView.addSubview(bottomLine)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override class func height(for object: Any!, at indexPath: IndexPath!, tableView: UITableView!) -> CGFloat {
        return 72
    }
    
    override func shouldUpdate(with object: Any!) -> Bool {
        if super.shouldUpdate(with: object), let object = object as? ExamPlanItem {
            examLabel.text = object.model.examStr
            dateLabel.text = object.model.dateMMdd + " " + object.model.weekday
            selectCountLabel.text = "\(object.model.selectCount)位选校帝用户参加"
            if object.model.over {
                countdownLabel.textColor = XDColor.itemText
                countdownLabel.text = "已考"
            } else {
                countdownLabel.textColor = XDColor.itemTitle
                if object.model.countdown == 0 {
                    countdownLabel.attributedText = NSAttributedString(string: "今日开考", attributes: [NSAttributedStringKey.foregroundColor: UIColor(0xFF8A00)])
                } else {
                    let attr = NSAttributedString(string: "\(object.model.countdown)", attributes: [NSAttributedStringKey.foregroundColor: UIColor(0xFF8A00), NSAttributedStringKey.font: UIFont.systemFont(ofSize: 18)])
                    countdownLabel.attributedText = "倒计时 " + attr + " 天"
                }
            }
        }
        return true
    }
}
