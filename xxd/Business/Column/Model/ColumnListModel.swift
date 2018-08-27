//
//  ColumnListModel.swift
//  xxd
//
//  Created by Lisen on 2018/7/17.
//  Copyright © 2018年 com.smartstudy. All rights reserved.
//

import UIKit

class ColumnListModel: NSObject {
    @objc var columnId: Int = 0
    @objc var coverUrl: String = ""
    @objc var columnTitle: String = ""
    @objc var visitCount: Int = 0
    @objc var likesCount: Int = 0
    @objc var authorId: Int = 0
    @objc var authorName: String = ""
    @objc var authorAvatar: String = ""
    
    @objc static func modelCustomPropertyMapper() -> Dictionary<String, Any> {
        return ["columnId": "id",
                "columnTitle": "title",
                "authorId": "author.id",
                "authorName": "author.name",
                "authorAvatar": "author.avatar"
        ]
    }
}

class ColumnDetailModel: NSObject {
    @objc var columnId: Int = 0
    @objc var coverUrl: String = ""
    @objc var authorId: Int = 0
    @objc var authorName: String = ""
    @objc var authorAvatar: String = ""
    @objc var time: String = ""
    @objc var columnTitle: String = ""
    @objc var columnContent: String = ""
    @objc var visitCount: Int = 0
    @objc var likedCount: Int = 0
    @objc var commentsCount: Int = 0
    @objc var isLiked: Bool = false
    @objc var isCollected: Bool = false
    var publishTime: String {
        get {
            if !time.isEmpty {
                return Date(iso8601String: time)?.string(format: "yyyy-MM-dd") ?? ""
            }
            return "'"
        }
    }
    
    @objc static func modelCustomPropertyMapper() -> Dictionary<String, Any> {
        return ["columnId": "id",
                "columnTitle": "title",
                "columnContent": "content",
                "authorId": "author.id",
                "authorName": "author.name",
                "authorAvatar": "author.avatar",
                "time": "publishTime",
                "isLiked": "liked",
                "isCollected": "collected"
        ]
    }
    
}
