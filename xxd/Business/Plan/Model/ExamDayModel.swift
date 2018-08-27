//
//  ExamDayModel.swift
//  xxd
//
//  Created by remy on 2018/5/24.
//  Copyright © 2018年 com.smartstudy. All rights reserved.
//

import JTAppleCalendar

class ExamDayModel: NSObject {
    
    @objc var examID: Int = 0
    @objc var examStr: String = ""
    lazy var examType: ExamType? = {
        return ExamDayModel.examTypeWithString(str: examStr)
    }()
    @objc var dateStr: String = ""
    lazy var dateMMdd: String = {
        let arr = dateStr.components(separatedBy: "-")
        if arr.count > 2 {
            return "\(Int(arr[1])!)月\(arr[2])日"
        }
        return ""
    }()
    lazy var monthDateStr: String? = {
        let arr = dateStr.components(separatedBy: "-")
        if arr.count > 2 {
            return "\(arr[0])-\(arr[1])"
        }
        return nil
    }()
    lazy var localWeekDay: String = {
        let formatter: DateFormatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let date = formatter.date(from: dateStr)
        let calendar = Calendar.current
        let week = calendar.component(Calendar.Component.weekday, from: date!)
        return (DaysOfWeek(rawValue: week)?.weekDay)!
    }()
    
    @objc var selected: Bool = false
    @objc var selectCount: Int = 0
    @objc var countdown: Int = 0
    @objc var over: Bool = false
    @objc var weekday: String = ""
    
    @objc static func modelCustomPropertyMapper() -> Dictionary<String, Any> {
        return [
            "examID": "id",
            "examStr": "exam",
            "dateStr": "date"
        ]
    }
    
    static func examTypeWithString(str: String) -> ExamType? {
        switch str {
        case "GMAT":
            return .gmat
        case "GRE":
            return .gre
        case "SAT":
            return .sat
        case "托福":
            return .toefl
        case "雅思":
            return .ielts
        default:
            return nil
        }
    }
}
