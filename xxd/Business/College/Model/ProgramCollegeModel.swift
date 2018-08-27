//
//  ProgramCollegeModel.swift
//  xxd
//
//  Created by remy on 2018/2/14.
//  Copyright © 2018年 com.smartstudy. All rights reserved.
//

class ProgramCollegeModel: NSObject {
    
    @objc var collegeID = 0
    @objc var localRank = ""
    @objc var chineseName = ""
    @objc var englishName = ""
    @objc var majorChineseName = ""
    @objc var majorEnglishName = ""
    @objc var logoURL = ""
    @objc var isSelected = false
    
    @objc static func modelCustomPropertyMapper() -> Dictionary<String, Any> {
        return [
            "collegeID": "id",
            "isSelected": "selected"
        ]
    }
}
