//
//  ArtMajorCollegeRankModel.swift
//  xxd
//
//  Created by Lisen on 2018/7/5.
//  Copyright © 2018年 com.smartstudy. All rights reserved.
//

import UIKit


class ArtMajorCollegeRankModel: NSObject {
    @objc var majorId: Int = 0
    @objc var majorName: String = ""
    @objc var schoolChineseName: String = ""
    @objc var schoolEnglishName: String = ""
    @objc var website: String = ""
    @objc var rank: Int = 0
    
    @objc static func modelCustomPropertyMapper() -> Dictionary<String, Any> {
        return ["majorId": "id",
            "majorName": "englishName"
        ]
    }
}
