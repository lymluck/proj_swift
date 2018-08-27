//
//  ExamScheduleCheckinModel.swift
//  xxd
//
//  Created by Lisen on 2018/5/29.
//  Copyright © 2018年 com.smartstudy. All rights reserved.
//

import UIKit

/// 备考打卡数据模型
class ExamScheduleCheckinModel: NSObject {
    @objc var examId: Int = 0
    @objc var examName: String = ""
    @objc var examDate: String = ""
    @objc var selectCount = 0
    @objc var countdown: Int = 0
    @objc var isCheckin: Bool = false
    
    @objc static func modelCustomPropertyMapper() -> Dictionary<String, Any> {
        return [
            "examId": "id",
            "examName": "exam",
            "examDate": "date",
            "isCheckin": "checkedInToday"
        ]
    }
}
