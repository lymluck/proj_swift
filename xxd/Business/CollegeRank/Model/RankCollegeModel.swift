//
//  RankCollegeModel.swift
//  xxd
//
//  Created by remy on 2018/1/24.
//  Copyright © 2018年 com.smartstudy. All rights reserved.
//

class RankCollegeModel: NSObject {
    
    @objc var collegeID = 0 // 排行
    @objc var targetID = 0 // 我的选校->添加选校->搜索,含义等同于 collegeID
    @objc var schoolID = 0
    @objc var rankCategoryID = 0
    @objc var rank = ""
    @objc var chineseName = ""
    @objc var englishName = ""
    
    // 兼容解析院校列表数据(我的选校->添加选校->搜索),此时 id 代表 collegeID(部分学校没有)
    // 排行大全内 schoolId 代表 collegeID(部分学校没有)
    // schoolChineseName, schoolEnglishName 是为了解析艺术院校中的院校名称
    @objc static func modelCustomPropertyMapper() -> Dictionary<String, Any> {
        return [
            "collegeID": "schoolId",
            "targetID": "id",
            "rank": ["rank", "worldRank"],
            "chineseName": ["schoolChineseName", "chineseName"],
            "englishName": ["schoolEnglishName", "englishName"]
        ]
    }
}
