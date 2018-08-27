//
//  HighSchoolListModel.swift
//  xxd
//
//  Created by Lisen on 2018/4/7.
//  Copyright © 2018年 com.smartstudy. All rights reserved.
//

import UIKit

// MARK: 美高院校库列表数据模型
class HighSchoolListModel: NSObject {
    @objc var schoolId: Int = -1
    @objc var rank = ""
    @objc var chineseName = ""
    @objc var englishName = ""
    @objc var countryName = ""
    @objc var provinceName = ""
    @objc var cityName = ""
    @objc var boarderTypeName = ""
    @objc var sexualTypeName = ""
    @objc var seniorFacultyRatio = ""
    
    @objc static func modelCustomPropertyMapper() -> Dictionary<String, Any> {
        return ["schoolId": "id"]
    }
}

//美高院校库筛选数据模型
class HighSchoolRankCategoryModel: NSObject {
    @objc var rankTitle = ""
    @objc var rankKey = ""
    @objc var options = [HighSchoolRankOptionsModel]()
    
    @objc static func modelCustomPropertyMapper() -> Dictionary<String, Any> {
        return ["rankTitle": "title", "rankKey": "key"]
    }
    
    @objc static func modelContainerPropertyGenericClass() -> Dictionary<String, Any> {
        return ["options": HighSchoolRankOptionsModel.self]
    }
}

class HighSchoolRankOptionsModel: NSObject {
    @objc var optionId = ""
    @objc var optionName = ""
    @objc var isSelected = false
    @objc var subOptions: HighSchoolRankSubOptionsModel?
    
    @objc static func modelCustomPropertyMapper() -> Dictionary<String, Any> {
        return ["optionId": "id", "optionName": "name"]
    }
}

class HighSchoolRankSubOptionsModel: NSObject {
    @objc var rankRange: HighSchoolRankCategoryModel?
}
