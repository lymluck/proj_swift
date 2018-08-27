//
//  DateEx.swift
//  xxd
//
//  Created by remy on 2017/12/27.
//  Copyright © 2017年 com.smartstudy. All rights reserved.
//

extension Date {
    
    public init?(iso8601String: String) {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone.current
        if let date = formatter.date(from: iso8601String) {
            self = date
        } else {
            return nil
        }
    }
    
    public var iso8601String: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(abbreviation: "GMT")
        return formatter.string(from: self).appending("Z")
    }
    
    public func string(format: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.string(from: self)
    }
    
    func displayString() -> String {
        let time = -timeIntervalSinceNow
        if time < 60 {
            return "刚刚"
        } else if time / 60 < 60 {
            return "\(Int(time / 60))分钟前"
        } else if time / 3600 < 24 {
            return "\(Int(time / 3600))小时前"
        } else if time / 86400 < 7 {
            return "\(Int(time / 86400))天前"
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = "MM-dd HH:mm"
            return formatter.string(from: self)
        }
    }
    

    public var weekday: Int {
        return Calendar.current.component(.weekday, from: self)
    }
    
    public var isInToday: Bool {
        return Calendar.current.isDateInToday(self)
    }
    
    public var isInYesterday: Bool {
        return Calendar.current.isDateInYesterday(self)
    }
    
    public func adding(_ component: Calendar.Component, value: Int) -> Date {
        return Calendar.current.date(byAdding: component, value: value, to: self)!
    }
    
    public func string(withFormat format: String = "dd/MM/yyyy HH:mm") -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: self)
    }
    
    public func daysSince(_ date: Date) -> Double {
        return timeIntervalSince(date)/(3600*24)
    }

//    func commentString() -> String {
//        let time = -timeIntervalSinceNow
//        if time < 60 {
//            return "刚刚"
//        } else if time / 60 < 60 {
//            return "\(Int(time / 60))分钟前"
//        } else if time / 3600 < 24 {
//            let formatter = DateFormatter()
//            formatter.dateFormat = "HH:mm"
//            return "今天 " + formatter.string(from: self)
//        } else if time / 3600 < 48 {
//            let formatter = DateFormatter()
//            formatter.dateFormat = "HH:mm"
//            return "昨天 " + formatter.string(from: self)
//        } else if time / 86400 < 7 {
//            let formatter = DateFormatter()
//            formatter.dateFormat = "HH:mm"
//            return "\(Int(time / 86400))天前" + formatter.string(from: self)
//        } else {
//            let formatter = DateFormatter()
//            formatter.dateFormat = "MM-dd HH:mm"
//            return formatter.string(from: self)
//        }
//    }

}
