//
//  ColumnCommentModel.swift
//  xxd
//
//  Created by Lisen on 2018/7/19.
//  Copyright © 2018年 com.smartstudy. All rights reserved.
//

import UIKit

class ColumnCommentModel: NSObject {
    @objc var userId: Int = 0
    @objc var commentId: Int = 0
    @objc var commentContent: String = ""
    @objc var commentTime: String = ""
    @objc var commenterId: Int = 0
    @objc var commenterAvatar: String = ""
    @objc var commenterName: String = ""
    @objc var previousComment: [String: Any] = [: ]
    lazy var lastComment: ColumnCommentModel = {
        return ColumnCommentModel.yy_model(with: previousComment)!
    }()
    
    @objc static func modelCustomPropertyMapper() -> Dictionary<String, Any> {
        return [ "commentId": "id",
            "commentContent": "content",
            "commentTime": "createTimeText",
            "commenterId": "user.id",
            "commenterAvatar": "user.avatar",
            "commenterName": "user.name"
        ]
    }
    
}
