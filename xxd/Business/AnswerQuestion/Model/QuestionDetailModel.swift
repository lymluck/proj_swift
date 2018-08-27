//
//  QuestionDetailModel.swift
//  xxd
//
//  Created by remy on 2018/3/6.
//  Copyright © 2018年 com.smartstudy. All rights reserved.
//

enum QuestionDetailType {
    case questionText
    case answerText
    case answerAudio
    case unknown
}

enum AnswerActionType: String {
    case requestInfo = "request_info"
    case completeRequestInfo = "complete_request_info"
}

class QuestionDetailModel: NSObject {
    
    @objc var commentID = 0
    @objc var commenterId = 0
    /// 被评论的那条评论id
    @objc var atCommentId = 0
    @objc var commenterAvatar = ""
    @objc var commenterName = ""
    @objc var content = ""
    @objc var voiceURL = ""
    @objc var imUserId = ""
    @objc var createTimeText = ""
    @objc var commentType = ""
    @objc var schoolCertified = false
    @objc var actionType: String = ""
    /// 对教师回复的星级评价
    @objc var ratingScore = 0
//    @objc var score = 0
    /// 对教师回复的文字评价
    @objc var ratingComment = ""
    /// 捕获老师第一条回复的commentId
    @objc var firstCommentId: Int = -1
    @objc var _voiceDuration = 0.0
    lazy var type: QuestionDetailType = {
        if commentType == "subQuestion" {
            return .questionText
        } else if commentType == "answer" {
            if voiceURL.isEmpty {
                return .answerText
            } else {
                return .answerAudio
            }
        }
        return .unknown
    }()
    /// 信息状态
    lazy var infoActionType: AnswerActionType? = {
        return AnswerActionType(rawValue: actionType)
    }()
    lazy var voiceDuration: Double = {
        return max(min(_voiceDuration, 180), 1)
    }()
    lazy var voiceTimeStr: String = {
        var str = ""
        if voiceDuration > 60 {
            str += "\(Int(voiceDuration / 60))\'"
        }
        str += "\(Int(voiceDuration) % 60)\""
        return str
    }()
    
    @objc static func modelCustomPropertyMapper() -> Dictionary<String, Any> {
        return [
            "commentID": "id",
            "firstCommentId": "id",
            "commenterAvatar": "commenter.avatar",
            "commenterName": "commenter.name",
            "imUserId": "commenter.imUserId",
            "voiceURL": "voiceUrl",
            "_voiceDuration": "voiceDuration"
        ]
    }
}
