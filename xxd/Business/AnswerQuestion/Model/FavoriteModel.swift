//
//  FavoriteModel.swift
//  xxd
//
//  Created by remy on 2018/1/25.
//  Copyright © 2018年 com.smartstudy. All rights reserved.
//

enum FavoriteType: Int {
    case question       // 留学问答
    case news           // 留学咨询
    case schoolIntro    // 学校简介
    case undergraduate  // 本科申请
    case graduate       // 研究生申请
    case majorLib       // 专业库
    case program        // 专业推荐院校
    case highschool     // 高中院校
    case columnNews     // 专栏文章
    case unknown        // 未知
}

class FavoriteModel: NSObject {

    @objc var favoriteID = 0
    @objc var displayText = ""
    @objc var name = ""
    @objc var collectType = ""
    lazy var favoriteType: FavoriteType = {
        let info = getFavoriteInfo(collectType)
        return info.type
    }()
    lazy var title: String = {
        let info = getFavoriteInfo(collectType)
        return info.typeName
    }()
    lazy var urlPath: String = {
        let info = getFavoriteInfo(collectType)
        if info.urlStr.isEmpty {
            return ""
        }
        return String(format: info.urlStr, favoriteID)
    }()
    @objc var collectTime = ""
    lazy var favoriteTime: String = {
        if !collectTime.isEmpty {
            return Date(iso8601String: collectTime)?.string(format: "yyyy-MM-dd") ?? ""
        }
        return ""
    }()
    @objc var _displayImage = ""
    lazy var displayImage: String = {
        if !_displayImage.isEmpty {
            return UIImage.OSSImageURLString(urlStr: _displayImage, size: CGSize(width: 110, height: 83), policy: .fillAndClip)
        }
        return ""
    }()
    
    @objc static func modelCustomPropertyMapper() -> Dictionary<String, Any> {
        return [
            "favoriteID": "id",
            "_displayImage": "displayImage"
        ]
    }
    
    func getFavoriteInfo(_ typeStr: String) -> (type: FavoriteType, urlStr: String, typeName: String) {
        var type = FavoriteType.unknown, urlStr = "", typeName = ""
        switch typeStr {
        case "question":
            type = .question
            typeName = "title_favorite_type_question".localized
        case "news":
            type = .news
            urlStr = XD_WEB_NEWS_DETAIL
            typeName = "title_favorite_type_news".localized
        case "school-introduction":
            type = .schoolIntro
            typeName = "title_favorite_type_school_intro".localized
        case "school-undergraduate-application":
            type = .undergraduate
            urlStr = XD_WEB_UNDERGRADUATE
            typeName = "title_favorite_type_undergraduate".localized
        case "school-graduate-application":
            type = .graduate
            urlStr = XD_WEB_GRADUATE
            typeName = "title_favorite_type_graduate".localized
        case "major-lib-major":
            type = .majorLib
            urlStr = XD_WEB_MAJOR_DETAIL
            typeName = "title_favorite_type_major_lib".localized
        case "major-lib-program":
            type = .program
            typeName = "title_favorite_type_program".localized
        case "highschool":
            type = .highschool
            typeName = "title_highschool".localized
        case "columnNews":
            type = .columnNews
            typeName = "title_favorite_type_columnNews".localized
        default:
            break
        }
        return (type, urlStr, typeName)
    }
}
