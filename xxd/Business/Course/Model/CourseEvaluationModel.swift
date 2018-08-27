//
//  CourseEvaluationModel.swift
//  xxd
//
//  Created by remy on 2018/1/23.
//  Copyright © 2018年 com.smartstudy. All rights reserved.
//

class CourseEvaluationModel: NSObject {
    
    @objc var portraitURL = ""
    @objc var nickname = ""
    @objc var userID = 0
    @objc var date = NSDate()
    @objc var comment = ""
    @objc var evaluation = 0
    @objc var ID = 0
    
    @objc static func modelCustomPropertyMapper() -> Dictionary<String, Any> {
        return [
            "portraitURL": "user.avatar",
            "nickname": "user.name",
            "ID": "id",
            "courseID": "productId",
            "userID": "user.id",
            "evaluation": "rate",
            "date": "createTime"
        ]
    }
}
