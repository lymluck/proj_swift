//
//  OtherUserModel.swift
//  xxd
//
//  Created by Lisen on 2018/6/5.
//  Copyright © 2018年 com.smartstudy. All rights reserved.
//

import UIKit

/// 用户解析关于其他用户的个人信息数据的模型
class OtherUserModel: NSObject {
    // TODO: 将其他用户的信息变量和当前用户的信息变量统一
    @objc var userId: Int = 0
    @objc var userName: String = ""
    @objc var userAvatar: String = ""
    @objc var targetCountryId: String = ""
    @objc var targetDegreeId: String = ""
    @objc var admissionYear: String = ""
    @objc var targetCountryName: String = ""
    @objc var targetDegreeName: String = ""
    
    @objc static func modelCustomPropertyMapper() -> Dictionary<String, Any> {
        return [
            "userId": "id",
            "userName": "name",
            "userAvatar": "avatar"
        ]
    }
}

/// 解析个人选校主页的评论用户数据
class TargetCollegeCommentUserModel: NSObject {
    @objc var commentId: Int = 0
    @objc var commentText: String = ""
    @objc var createTime: String = ""
    @objc var commenterId: Int = 0
    @objc var commenterName: String = ""
    @objc var commenterAvatar: String = ""
    /// 被回复的用户id
    @objc var replyUserId: Int = 0
    /// 被回复的用户昵称
    @objc var replyUserName: String = ""
    /// 被回复的用户头像
    @objc var replyUserAvatar: String = ""
    
    lazy var commentTime: String = {
        if !createTime.isEmpty {
            return Date(iso8601String: createTime)?.string(format: "yyyy-MM-dd") ?? ""
        }
        return ""
    }()
    
    @objc static func modelCustomPropertyMapper() -> Dictionary<String, Any> {
        return [
            "commentId": "id",
            "commentText": "content",
            "commenterId": "author.id",
            "commenterName": "author.name",
            "commenterAvatar": "author.avatar",
            "replyUserId": "toUser.id",
            "replyUserName": "toUser.name",
            "replyUserAvatar": "toUser.avatar"
        ]
    }
    
}
