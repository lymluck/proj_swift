//
//  CollegeActivityModel.swift
//  xxd
//
//  Created by Lisen on 2018/6/28.
//  Copyright © 2018年 com.smartstudy. All rights reserved.
//

import UIKit

class CollegeActivityModel: NSObject {
    @objc var activityId: Int = 0
    @objc var title: String = ""
    @objc var activityTime: String = ""
    @objc var activityPlace: String = ""
    @objc static func modelCustomPropertyMapper() -> Dictionary<String, Any> {
        return ["title": "name", "activityPlace": "place", "activityId": "id"]
    }
}
