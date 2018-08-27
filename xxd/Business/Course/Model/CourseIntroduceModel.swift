//
//  CourseIntroduceModel.swift
//  xxd
//
//  Created by remy on 2018/1/22.
//  Copyright © 2018年 com.smartstudy. All rights reserved.
//

class CourseIntroduceModel: NSObject {
    
    @objc var name = ""
    @objc var introduction = ""
    @objc var provider = ""
    @objc var targetUser = ""
    @objc var rate = ""
    @objc var abroadServiceImageURL = ""
    @objc var playCount = 0
    @objc var sectionCount = 0
    @objc var teachers = [[String : Any]]()
    lazy var subModels: [CourseIntroduceTeacherModel] = {
        if teachers.count > 0 {
            return NSArray.yy_modelArray(with: CourseIntroduceTeacherModel.self, json: teachers) as! [CourseIntroduceTeacherModel]
        }
        return [CourseIntroduceTeacherModel]()
    }()
    
    @objc static func modelCustomPropertyMapper() -> Dictionary<String, Any> {
        return [
            "abroadServiceImageURL": "abroadServiceImageUrl"
        ]
    }
}

class CourseIntroduceTeacherModel: NSObject {
    
    @objc var name = ""
    @objc var title = ""
    @objc var avatarURL = ""
    @objc var introduction = ""
    
    @objc static func modelCustomPropertyMapper() -> Dictionary<String, Any> {
        return [
            "avatarURL": "avatarUrl"
        ]
    }
}
