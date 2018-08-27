//
//  HighSchoolCategoryModel.swift
//  xxd
//
//  Created by Lisen on 2018/4/4.
//  Copyright © 2018年 com.smartstudy. All rights reserved.
//

import UIKit

// NARK: 美高排行榜
class HighSchoolCategoryModel: NSObject {
    @objc var categoryId: Int = 0
    @objc var year: Int = 0
    @objc var org: String = ""
    @objc var title: String = ""
    @objc var order: Int = 0
    lazy var pureName: String = {
        return title
    }()
    
    override init() {
        super.init()
    }
    
    @objc static func modelCustomPropertyMapper() -> Dictionary<String, Any> {
        return ["categoryId": "id"]
    }
}

class HighSchoolRankModel: NSObject {
    @objc var schoolId: Int = -1
    @objc var rank: String = ""
    @objc var chineseName: String = ""
    
    @objc static func modelCustomPropertyMapper() -> Dictionary<String, Any> {
        return ["schoolId": "highschoolId"]
    }
}
