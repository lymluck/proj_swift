//
//  LocalNotificationManager.swift
//  Steward
//
//  Created by chenyusen on 2017/12/26.
//  Copyright © 2017年 TechSen. All rights reserved.
//

import UIKit
import UserNotifications


public struct LocalNotificationManager {
    static let shared = LocalNotificationManager()
    private init() {}
    
    public func add(notification title: String,
                                body: String,
                                date: Date,
                                identifier: String,
                                cover: Bool = true) {
        if #available(iOS 10.0, *) {
            let center = UNUserNotificationCenter.current()
            // 请求通知权限
            center.requestAuthorization(options: [.badge, .sound, .alert], completionHandler: { (granted, error) in
                if cover {
                    center.removePendingNotificationRequests(withIdentifiers: [identifier])
                }

                if granted {
                    let content = UNMutableNotificationContent()
                    content.title = title
                    content.body = body
                    content.badge = 1;
                    content.sound = UNNotificationSound.default()
                    let unitFlags = Set< Calendar.Component>([.hour, .day, .month, .year, .minute, .second])
                    let components = Calendar.current.dateComponents(unitFlags, from: date)
                    let calendarTrigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
                    let notiReq = UNNotificationRequest(identifier: identifier,
                                                        content: content,
                                                        trigger: calendarTrigger)
                    center.add(notiReq)
                } else {
                    UIAlertController.show(title: "无通知权限", message: "请到系统设置中打开")
                }
            })

        } else {
            if cover, let notis = UIApplication.shared.scheduledLocalNotifications {
                for noti in notis {
                    if let aIdentifier = noti.userInfo?["id"] as? String, aIdentifier == identifier {
                        UIApplication.shared.cancelLocalNotification(noti)
                        break
                    }
                }
            }
            
            UIApplication.shared.registerUserNotificationSettings(UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil))
            let noti = UILocalNotification()
            noti.fireDate = date
            noti.timeZone = TimeZone.current
            noti.soundName = UILocalNotificationDefaultSoundName
            noti.alertBody = body
            noti.applicationIconBadgeNumber = 1
            noti.alertTitle = title
            noti.userInfo = ["id": identifier]
            UIApplication.shared.scheduleLocalNotification(noti)
        }
    }
    
    func remove(notification identifier: String) {
    
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [identifier])
        } else {
            if let notis = UIApplication.shared.scheduledLocalNotifications {
                for noti in notis {
                    if let aIdentifier = noti.userInfo?["id"] as? String, aIdentifier == identifier {
                        UIApplication.shared.cancelLocalNotification(noti)
                    }
                }
            }
        }
    }
    
    
}
