//
//  TeacherAnswerItem.swift
//  xxd
//
//  Created by chenyusen on 2018/3/13.
//  Copyright © 2018年 com.smartstudy. All rights reserved.
//

import UIKit

protocol AnswerHeaderItemDelegate: class {
    func moreQuestionButtonPressed()
}

class AnswerHeaderItem: TableCellItem {
    
    weak var delegate: AnswerHeaderItemDelegate?
    var count: Int = 0
    override var cellClass: UITableViewCell.Type? {
        return AnswerHeaderCell.self
    }
}

class AnswerHeaderCell: TableCell {
    var questionCountLabel: UILabel!
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        
        contentView.backgroundColor = .white
        let titleLabel = UILabel()
        titleLabel.textColor = UIColor(0x26343F)
        titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        titleLabel.text = "答疑"
        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.left.equalTo(16)
        }
        
        
        let arrowView = UIImageView(image: UIImage(named: "counselor_arrow_more"))
        contentView.addSubview(arrowView)
        arrowView.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.right.equalTo(-16)
        }
        
        questionCountLabel = UILabel()
        questionCountLabel.textColor = UIColor(0x949BA1)
        questionCountLabel.font = UIFont.systemFont(ofSize: 14)
        contentView.addSubview(questionCountLabel)
        questionCountLabel.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.right.equalTo(arrowView.snp.left).offset(-3)
        }
        questionCountLabel.isUserInteractionEnabled = true
        questionCountLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(questionCountLabelPressed)))
        
        
        let bottomLine = UIView()
        bottomLine.backgroundColor = UIColor(0xe4e5e6)
        contentView.addSubview(bottomLine)
        bottomLine.snp.makeConstraints { (make) in
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(XDSize.unitWidth)
        }
        
        
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func updateCell(_ cellItem: TableCellItemProtocol?) {
        super.updateCell(cellItem)
        if let cellItem = cellItem as? AnswerHeaderItem {
            questionCountLabel.text = "共回答 \(cellItem.count) 个问题"
        }
        
        
    }
    
    @objc func questionCountLabelPressed() {
        if let cellItem = cellItem as? AnswerHeaderItem {
            cellItem.delegate?.moreQuestionButtonPressed()
        }
    }
    
}

class TeacherAnswerItem: TableCellItem {
    
    var isLast: Bool = false
    
    var cellH: CGFloat = 0
    
    override var model: Any? {
        didSet {
            if let model = model as? QuestionModel {
                let height = model.question.heightForFont(UIFont.systemFont(ofSize: 16), XDSize.screenWidth - 32, 22)
                cellH = height + 68 + 43
                
            }
        }
    }

    override var cellClass: UITableViewCell.Type? {
        return TeacherAnswerCell.self
    }
    
    override var cellHeight: CGFloat {
        return cellH
    }
}


class TeacherAnswerCell: TableCell {
    var avatarView: UIImageView!
    var nameLabel: UILabel!
    var dataLabel: UILabel!
    var questionLabel: UILabel!
    var bottomLine: UIView!
    var askVisitLabel: UILabel!
    var answerNumLabel: UILabel!
    
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        avatarView = UIImageView()
        avatarView.layer.cornerRadius = 20
        avatarView.clipsToBounds = true
        contentView.addSubview(avatarView)
        avatarView.snp.makeConstraints { (make) in
            make.left.top.equalTo(16)
            make.size.equalTo(CGSize(width: 40, height: 40))
        }
        
        nameLabel = UILabel()
        nameLabel.textColor = UIColor(0x26343F)
        nameLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        contentView.addSubview(nameLabel)
        nameLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(avatarView)
            make.left.equalTo(64)
            make.width.lessThanOrEqualTo(150)
        }
        
        dataLabel = UILabel()
        dataLabel.textColor = UIColor(0xC4C9CC)
        dataLabel.font = UIFont.systemFont(ofSize: 12)
        dataLabel.textAlignment = .right
        contentView.addSubview(dataLabel)
        dataLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(avatarView)
            make.right.equalTo(-16)
        }
        
        questionLabel = UILabel()
        questionLabel.textColor = UIColor(0x26343F)
        questionLabel.font = UIFont.systemFont(ofSize: 16)
        questionLabel.numberOfLines = 0
        contentView.addSubview(questionLabel)
        questionLabel.snp.makeConstraints { (make) in
            make.left.equalTo(16)
            make.right.lessThanOrEqualTo(-16)
            make.top.equalTo(68)
            make.bottom.lessThanOrEqualTo(-43)
        }
        
        
        bottomLine = UIView()
        bottomLine.backgroundColor = UIColor(0xe4e5e6)
        contentView.addSubview(bottomLine)
        bottomLine.snp.makeConstraints { (make) in
            make.left.equalTo(16)
            make.bottom.right.equalToSuperview()
            make.height.equalTo(XDSize.unitWidth)
        }
        
        let visitImageView = UIImageView(image: UIImage(named: "information_visit_count"))
        contentView.addSubview(visitImageView)
        visitImageView.snp.makeConstraints { (make) in
            make.left.equalTo(16)
            make.bottom.equalTo(-16)
        }
        
        askVisitLabel = UILabel(text: "", textColor: XDColor.itemText, fontSize: 12)
        contentView.addSubview(askVisitLabel)
        askVisitLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(visitImageView)
            make.left.equalTo(visitImageView.snp.right).offset(2)
        }
        answerNumLabel = UILabel(text: "", textColor: XDColor.main, fontSize: 12)
        contentView.addSubview(answerNumLabel)
        answerNumLabel.snp.makeConstraints { (make) in
            make.right.equalTo(-16)
            make.centerY.equalTo(visitImageView)
        }
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func updateCell(_ cellItem: TableCellItemProtocol?) {
        super.updateCell(cellItem)
        if let cellItem = cellItem as? TeacherAnswerItem, let model = cellItem.model as? QuestionModel {
            avatarView.kf.setImage(with: URL(string: model.askerAvatar))
            nameLabel.text = model.askerName
            dataLabel.text = model.createTimeText
//            question.height = object.textHeight
            questionLabel.setText(model.question, lineHeight: 22)
            bottomLine.isHidden = cellItem.isLast
            askVisitLabel.text = "\(model.visitCount)人看过"
            answerNumLabel.text = "\(model.answerCount) 回答"
        }
    }
}
