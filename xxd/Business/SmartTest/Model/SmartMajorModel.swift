//
//  SmartMajorModel.swift
//  xxd
//
//  Created by remy on 2018/1/31.
//  Copyright © 2018年 com.smartstudy. All rights reserved.
//

class SmartMajorModel: NSObject {
    
    @objc var collegeID = 0
    @objc var chineseName = ""
    @objc var englishName = ""
    @objc var localRank = ""
    @objc var isSelected = false
    @objc var _logo = ""
    lazy var logoURL: String = {
        return UIImage.OSSImageURLString(urlStr: _logo, size: CGSize(width: 60, height: 60), policy: .pad)
    }()
    
    @objc static func modelCustomPropertyMapper() -> Dictionary<String, Any> {
        return [
            "collegeID": "id",
            "_logo": "logo",
            "isSelected": "selected"
        ]
    }
}
