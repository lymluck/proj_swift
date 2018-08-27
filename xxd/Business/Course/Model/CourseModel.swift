//
//  CourseModel.swift
//  xxd
//
//  Created by remy on 2018/1/18.
//  Copyright © 2018年 com.smartstudy. All rights reserved.
//

// 课程列表 model
class CourseModel: NSObject {
    
    @objc var courseID = 0
    @objc var name = ""
    @objc var visitCount = 0
    @objc var sectionCount = 0
    @objc var coverURL = ""
    @objc var rate = ""
    
    @objc static func modelCustomPropertyMapper() -> Dictionary<String, Any> {
        return [
            "courseID": "productId",
            "name": ["title", "name"],
            "visitCount": ["visitCount", "playCount"],
            "coverURL": "coverUrl"
        ]
    }
}
