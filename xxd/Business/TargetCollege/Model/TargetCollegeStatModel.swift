//
//  TargetCollegeStatModel.swift
//  xxd
//
//  Created by Lisen on 2018/6/4.
//  Copyright © 2018年 com.smartstudy. All rights reserved.
//

import UIKit

class TargetCollegeStatModel: NSObject {
    @objc var matchTypes: [TargetCollegeMatchTypeModel]?
    @objc var years: [TargetCollegeAbroadTimeModel]?
    @objc var watchers: [TargetCollegeWatcherModel]?
    @objc var topSchools: [TargetCollegeTopSchoolModel]?
    
    @objc static func modelContainerPropertyGenericClass() -> Dictionary<String, Any> {
        return ["matchTypes": TargetCollegeMatchTypeModel.self,
                "years": TargetCollegeAbroadTimeModel.self,
                "watchers": TargetCollegeWatcherModel.self,
                "topSchools": TargetCollegeTopSchoolModel.self
        ]
    }
}


class TargetCollegeMatchTypeModel: NSObject {
    @objc var name: String = ""
    @objc var matchTypeId = ""
    @objc var usersCount = 0
    @objc var usersIncludeMe = false
}

class TargetCollegeAbroadTimeModel: NSObject {
    @objc var year: String = ""
    @objc var count = 0
}

class TargetCollegeWatcherModel: NSObject {
    @objc var userId: Int = 0
    @objc var name: String = ""
    @objc var avatar: String = ""
    @objc var selectSchoolCount: Int = 0
    
    @objc static func modelCustomPropertyMapper() -> Dictionary<String, Any> {
        return [
            "userId": "id"
        ]
    }
}

class TargetCollegeTopSchoolModel: NSObject {
    @objc var selectedCount: Int = 0
    @objc var collegeId: Int = 0
    @objc var logoURL: String = ""
    @objc var chineseName: String = ""
    @objc var englishName: String = ""
    lazy var logo: String = {
        return UIImage.OSSImageURLString(urlStr: logoURL, size: CGSize(width: 60, height: 60), policy: .pad)
    }()
    
    @objc static func modelCustomPropertyMapper() -> Dictionary<String, Any> {
        return [
            "collegeId": "id",
            "logoURL": "logo"
        ]
    }
}
