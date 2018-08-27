//
//  CalendarCell.swift
//  xxd
//
//  Created by Lisen on 2018/5/23.
//  Copyright © 2018年 com.smartstudy. All rights reserved.
//

import UIKit
import JTAppleCalendar
import DeviceKit

/// 日历头部视图
class CalendarSectionHeaderView: JTAppleCollectionReusableView {
    
    var isTopLineHidden: Bool = false {
        didSet {
            topLine.isHidden = isTopLineHidden
        }
    }
    var monthDate: String? {
        didSet {
            monthLabel.text = monthDate
        }
    }
    private lazy var monthLabel: UILabel = UILabel(frame: CGRect.zero, text: "", textColor: UIColor(0x078CF1), fontSize: 17.0)
    private lazy var topLine: UIView = UIView(frame: CGRect.zero, color: XDColor.itemLine)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(topLine)
        topLine.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(8.0)
            make.left.right.equalToSuperview()
            make.height.equalTo(XDSize.unitWidth)
        }
        addSubview(monthLabel)
        monthLabel.snp.makeConstraints { (make) in
            make.top.equalTo(topLine.snp.bottom).offset(24.0)
            make.centerX.equalToSuperview()
        }
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

/// 日历单元视图
class CalendarCell: JTAppleCell {
    
    var date: String? {
        didSet {
            dateLabel.text = date
        }
    }
    var isChosen: Bool = false {
        didSet {
            if isChosen {
                tagView.isHidden = true
                selectedView.isHidden = false
                if isSelectable {
                    selectedView.backgroundColor = examType?.attributeColor()
                } else {
                    selectedView.backgroundColor = UIColor(0xC4C9CC)
                }
                dateLabel.textColor = UIColor.white
                examLabel.textColor = UIColor.white
            } else {
                selectedView.isHidden = true
                if examType != nil {
                    tagView.isHidden = false
                } else {
                    tagView.isHidden = true
                }
                if isSelectable {
                    dateLabel.textColor = UIColor(0x26343F)
                    examLabel.textColor = examType?.attributeColor()
                } else {
                    dateLabel.textColor = UIColor(0xC4C9CC)
                    examLabel.textColor = UIColor(0xC4C9CC)
                }
            }
        }
    }
    
    // 选中的考试
    var chosenModel: ExamDayModel?
    
    // 数据处理需要优化
    var cellModels: [ExamDayModel]? {
        didSet {
            chosenModel = nil
            if let models = cellModels {
                examLabel.isHidden = false
                if models.count > 1 {
                    examType = .multi
                    isChosen = false
                    for model in models {
                        if model.selected {
                            examLabel.text = model.examStr
                            examType = ExamType(rawValue: model.examStr)
                            isChosen = true
                            chosenModel = model
                        }
                    }
                } else if models.count == 1 {
                    guard let model = models.first else { return }
                    examType = ExamType(rawValue: model.examStr)
                    isChosen = model.selected
                    if isChosen { chosenModel = model }
                }
            } else {
                examLabel.isHidden = true
                examType = nil
                isChosen = false
                if isSelectable {
                    dateLabel.textColor = UIColor(0x26343F)
                } else {
                    dateLabel.textColor = UIColor(0xC4C9CC)
                }
                dateLabel.font = UIFont.systemFont(ofSize: 16.0)
                tagView.isHidden = true
            }
        }
    }
    
    var isSelectable: Bool = false
    
    var examType: ExamType? {
        didSet {
            if let type = examType {
                examLabel.text = type.rawValue
                if isSelectable {
                    dateLabel.font = UIFont.boldSystemFont(ofSize: 16.0)
                    examLabel.textColor = type.attributeColor()
                    tagView.backgroundColor = type.attributeColor()
                } else {
                    dateLabel.textColor = UIColor(0xC4C9CC)
                    dateLabel.font = UIFont.systemFont(ofSize: 16.0)
                    examLabel.textColor = UIColor(0xC4C9CC)
                    tagView.backgroundColor = UIColor(0xC4C9CC)
                }
            } else {

            }
        }
    }
    
    private lazy var circleRadius: CGFloat = {
        if Device().diagonal == 4.0 {
            return  20.0
        } else {
            return 22.0
        }
    }()
    private lazy var selectedView: UIView = {
        let view: UIView = UIView(frame: CGRect.zero)
        view.isHidden = true
        view.layer.cornerRadius = circleRadius
        return view
    }()
    private lazy var dateLabel: UILabel = UILabel(frame: CGRect.zero, text: "", textColor: UIColor(0x26343F), fontSize: 16.0)
    private lazy var examLabel: UILabel = {
        let label: UILabel = UILabel(frame: CGRect.zero, text: "", textColor: UIColor(0x5FACFF), fontSize: 11.0)
        label.isHidden = true
        return label
    }()
    private lazy var tagView: UIView = {
        let view: UIView = UIView(frame: CGRect.zero)
        view.backgroundColor = UIColor(0x5FACFF)
        view.layer.cornerRadius = 3.0
        view.isHidden = true
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initContentViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    private func initContentViews() {
        contentView.addSubview(selectedView)
        selectedView.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
            make.width.height.equalTo(2.0*circleRadius)
        }
        contentView.addSubview(examLabel)
        examLabel.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(28.0)
            make.centerX.equalToSuperview()
        }
        contentView.addSubview(tagView)
        tagView.snp.makeConstraints { (make) in
            make.width.height.equalTo(6.0)
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().offset(-3.0)
        }
        contentView.addSubview(dateLabel)
        dateLabel.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(8.0)
            make.centerX.equalToSuperview()
        }
    }
}
