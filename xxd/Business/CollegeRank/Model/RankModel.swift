//
//  RankModel.swift
//  xxd
//
//  Created by remy on 2018/1/24.
//  Copyright © 2018年 com.smartstudy. All rights reserved.
//

class RankModel: NSObject {
    
    @objc var categoryID = 0
    @objc var artCategoryId = ""
    @objc var isMajorRank = false
    @objc var year = ""
    @objc var type = ""
    @objc var title = ""
    @objc var groupName = ""
    lazy var name: String = {
        if !title.isEmpty {
            return year + type + title
        } else if !groupName.isEmpty {
            return groupName
        }
        return ""
    }()
    lazy var pureName: String = {
        if isMajorRank {
            return title.replacingOccurrences(of: "排名", with: "").replacingOccurrences(of: "美国", with: "").replacingOccurrences(of: "大学", with: "")
        }
        return title
    }()
    @objc var groupIcon = ""
    lazy var logoURL: String = {
        if !groupIcon.isEmpty {
            return UIImage.OSSImageURLString(urlStr: groupIcon, size: CGSize(width: 34, height: 34), policy: .pad)
        }
        return ""
    }()
    @objc var rankings = [[String : Any]]()
    lazy var subModels: [RankModel] = {
        if rankings.count > 0 {
            return NSArray.yy_modelArray(with: RankModel.self, json: rankings) as! [RankModel]
        }
        return [RankModel]()
    }()
    
    @objc static func modelCustomPropertyMapper() -> Dictionary<String, Any> {
        return [
            "categoryID": "id",
            "artCategoryId": "id"
        ]
    }
}
