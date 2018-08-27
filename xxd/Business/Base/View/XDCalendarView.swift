//
//  XDCalendarView.swift
//  xxd
//
//  Created by Lisen on 2018/5/23.
//  Copyright © 2018年 com.smartstudy. All rights reserved.
//

import UIKit
import JTAppleCalendar

extension DaysOfWeek {
    var weekDay: String {
        switch self {
        case .sunday:
            return "周日"
        case .monday:
            return "周一"
        case .tuesday:
            return "周二"
        case .wednesday:
            return "周三"
        case .thursday:
            return "周四"
        case .friday:
            return "周五"
        case .saturday:
            return "周六"
        }
    }
}

@objc protocol XDCalendarViewDelegate {
    /// 用户点击日历单元格事件
    func xdCalendarViewDidSelect(_ calendarView: XDCalendarView, _ cell: CalendarCell, _ weekDay: String)
}

/// 日历视图
class XDCalendarView: UIView {
    
    weak var delegate: XDCalendarViewDelegate?
    var startDate: String = "2018-06" {
        didSet {
            
        }
    }
    var endDate: String = "2018-06"  {
        didSet {
            calendarView.reloadData()
        }
    }
    var examScheduleModels: [String : [ExamDayModel]] = [:] {
        didSet {
            calendarView.reloadData()
        }
    }
    
    private var formatter: DateFormatter = {
        let formatter: DateFormatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM"
        formatter.timeZone = TimeZone(identifier: "Asia/Shanghai")
        return formatter
    }()
    private var dayFormatter: DateFormatter = {
        let formatter: DateFormatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = TimeZone(identifier: "Asia/Shanghai")
        return formatter
    }()
    private let weekWidth: CGFloat = (XDSize.screenWidth-24.0)/7.0
    private lazy var weeks: [String] = ["日", "一", "二", "三", "四", "五", "六"]
    private lazy var weekView: UIView = {
        let view: UIView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: XDSize.screenWidth, height: 24.0), color: UIColor(0xF5F6F7))
        for i in 0..<7 {
            let label: UILabel = UILabel(frame: CGRect.zero, text: weeks[i], textColor: UIColor(0x26343F), fontSize: 11.0)
            label.textAlignment = .center
            if i == 0 || i == 6 {
                label.textColor = UIColor(0x949BA1)
            }
            view.addSubview(label)
            label.snp.makeConstraints { (make) in
                make.left.equalToSuperview().offset(12.0+CGFloat(i)*weekWidth)
                make.top.bottom.equalToSuperview()
                make.width.equalTo(weekWidth)
            }
        }
        return view
    }()
    lazy var calendarView: JTAppleCalendarView = {
        let view: JTAppleCalendarView = JTAppleCalendarView(frame: CGRect.zero)
        view.backgroundColor = UIColor.white
        view.register(CalendarCell.self, forCellWithReuseIdentifier: "CalendarCell")
        view.register(CalendarSectionHeaderView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "CalendarSectionHeader")
        view.calendarDelegate = self
        view.calendarDataSource = self
        view.cellSize = 52.0
        view.minimumLineSpacing = 0.01
        view.minimumInteritemSpacing = 0.01
        view.allowsDateCellStretching = false
        view.showsVerticalScrollIndicator = false
        return view
    }()
    private lazy var backgroundScrollView: UIScrollView = {
        let scrollView: UIScrollView = UIScrollView(frame: CGRect.zero)
        return scrollView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initContentViews()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        calendarView.frame = CGRect(x: 12.0, y: 24.0, width: XDSize.screenWidth-24.0, height: self.bounds.height-24.0)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    private func initContentViews() {
        backgroundColor = UIColor.white
        addSubview(weekView)
        addSubview(calendarView)
    }
}

// MARK: JTAppleCalendarViewDataSource
extension XDCalendarView: JTAppleCalendarViewDataSource {
    func configureCalendar(_ calendar: JTAppleCalendarView) -> ConfigurationParameters {
        let params: ConfigurationParameters = ConfigurationParameters(startDate: formatter.date(from: startDate)!, endDate: formatter.date(from: endDate)!, numberOfRows: 7, calendar: Calendar.current, generateInDates: InDateCellGeneration.forAllMonths, generateOutDates: OutDateCellGeneration.off, firstDayOfWeek: nil, hasStrictBoundaries: nil)
        return params
    }
}

// MARK: JTAppleCalendarViewDelegate
extension XDCalendarView: JTAppleCalendarViewDelegate {
    func calendar(_ calendar: JTAppleCalendarView, willDisplay cell: JTAppleCell, forItemAt date: Date, cellState: CellState, indexPath: IndexPath) {
    }
    
    func calendar(_ calendar: JTAppleCalendarView, cellForItemAt date: Date, cellState: CellState, indexPath: IndexPath) -> JTAppleCell {
        let cell: CalendarCell = calendar.dequeueReusableJTAppleCell(withReuseIdentifier: "CalendarCell", for: indexPath) as! CalendarCell
        cell.date = cellState.text
        let dateString = dayFormatter.string(from: date)
        if dateString < dayFormatter.string(from: Date()) {
            cell.isSelectable = false
        } else {
            cell.isSelectable = true
        }
        if cellState.dateBelongsTo == .thisMonth {
            cell.isHidden = false
        } else {
            cell.isHidden = true
        }
        cell.cellModels = nil
        for (key, value) in examScheduleModels {
            if key == dayFormatter.string(from: date) {
                cell.cellModels = value
                break
            }
        }
        return cell
    }
    
    func calendar(_ calendar: JTAppleCalendarView, headerViewForDateRange range: (start: Date, end: Date), at indexPath: IndexPath) -> JTAppleCollectionReusableView {
        let header = calendar.dequeueReusableJTAppleSupplementaryView(withReuseIdentifier: "CalendarSectionHeader", for: indexPath) as! CalendarSectionHeaderView
        if indexPath.section == 0 {
            header.isTopLineHidden = true
        } else {
            header.isTopLineHidden = false
        }
        let date = range.start
        let month = Calendar.current.component(.month, from: date)
        let year = Calendar.current.component(.year, from: date)
        header.monthDate = "\(year)年\(month)月"
        return header
    }
    
    /// 设置头部视图高度
    func calendarSizeForMonths(_ calendar: JTAppleCalendarView?) -> MonthSize? {
        return MonthSize(defaultSize: 60.0+XDSize.unitWidth+8.0)
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didSelectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
        guard let cell = cell as? CalendarCell else { return }
        if !cell.isSelectable { return }
        guard let _ = delegate?.xdCalendarViewDidSelect(self, cell, cellState.day.weekDay) else { return }
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didDeselectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
        
    }
}
