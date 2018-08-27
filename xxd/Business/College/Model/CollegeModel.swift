//
//  CollegeModel.swift
//  xxd
//
//  Created by remy on 2018/2/13.
//  Copyright © 2018年 com.smartstudy. All rights reserved.
//

class CollegeModel: NSObject {
    
    @objc var collegeID = 0
    @objc var chineseName = ""
    @objc var englishName = ""
    @objc var countryName = ""
    @objc var provinceName = ""
    @objc var cityName = ""
    @objc var acceptRate = ""
    @objc var logoURL = ""
    @objc var viewTime = ""
    @objc var viewTimeText = ""
    @objc var orderRank: Int = 0
    @objc var coverImage = ""
    
    @objc static func modelCustomPropertyMapper() -> Dictionary<String, Any> {
        return [
            "collegeID": "id",
            "logoURL": "logo",
            "acceptRate": "TIE_ADMINSSION_RATE",
            "coverImage": "coverPicture"
        ]
    }
}
