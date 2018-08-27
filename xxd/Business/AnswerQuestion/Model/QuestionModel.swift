//
//  QuestionModel.swift
//  xxd
//
//  Created by remy on 2018/1/25.
//  Copyright © 2018年 com.smartstudy. All rights reserved.
//

class QuestionModel: NSObject {
    
    @objc var userID = ""
    @objc var questionID = 0
    @objc var question = ""
    @objc var visitCount = 0
    @objc var askerAvatar = ""
    @objc var askerName = ""
    @objc var answerCount = 0
    @objc var hasUnreadAnswers = 0
    @objc var answered = false
    @objc var answer = ""
    @objc var answererName = ""
    @objc var answererAvatar = ""
    @objc var answererTitle = ""
    @objc var createTimeText = ""
    @objc var createTime = ""
    @objc var schoolName = ""
    @objc var schoolLogo = ""
    @objc var targetCountry = ""
    @objc var targetDegree = ""
    lazy var askDetailTime: String = {
        if !createTime.isEmpty {
            return Date(iso8601String: createTime)?.string(format: "yyyy-MM-dd HH:mm:ss") ?? ""
        }
        return ""
    }()
    lazy var askDate: String = {
        if !createTime.isEmpty {
            return Date(iso8601String: createTime)?.string(format: "yyyy-MM-dd") ?? ""
        }
        return ""
    }()
    
    @objc static func modelCustomPropertyMapper() -> Dictionary<String, Any> {
        return [
            "userID": "userId",
            "questionID": "id",
            "question": "content",
            "askerAvatar": "asker.avatar",
            "askerName": "asker.name",
            "answererName": "firstAnswerer.name",
            "answererAvatar": "firstAnswerer.avatar",
            "answererTitle": "firstAnswerer.title",
            "targetCountry": "targetCountryName",
            "targetDegree": "targetDegreeName"
            
        ]
    }
}

/// 问答页tab
class QuestionTagModel: NSObject {
    
    var type: QAListType = .latest
    var name: String = ""
}
