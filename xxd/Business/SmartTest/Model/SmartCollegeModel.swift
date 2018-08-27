//
//  SmartCollegeModel.swift
//  xxd
//
//  Created by remy on 2018/1/31.
//  Copyright © 2018年 com.smartstudy. All rights reserved.
//

class SmartCollegeModel: NSObject {
    
    @objc var collegeID = 0
    @objc var chineseName = ""
    @objc var englishName = ""
    @objc var localRank = ""
    @objc var isSelected = false
    @objc var matchTypeId = ""
    @objc var _logo = ""
    lazy var logoURL: String = {
        return UIImage.OSSImageURLString(urlStr: _logo, size: CGSize(width: 60, height: 60), policy: .pad)
    }()
    @objc var prob = ""
    lazy var acceptRate: String = {
        if let rate = Float(prob) {
            return String(format: "%.f%%", rate * 100)
        }
        return ""
    }()
    
    @objc static func modelCustomPropertyMapper() -> Dictionary<String, Any> {
        return [
            "collegeID": "school.id",
            "_logo": "school.logo",
            "chineseName": "school.chineseName",
            "englishName": "school.englishName",
            "localRank": "school.localRank",
            "isSelected": "selected"
        ]
    }
}
