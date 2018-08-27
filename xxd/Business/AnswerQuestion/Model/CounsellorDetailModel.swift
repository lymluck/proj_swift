//
//  CounsellorDetailModel.swift
//  xxd
//
//  Created by remy on 2018/3/9.
//  Copyright © 2018年 com.smartstudy. All rights reserved.
//

class CounsellorDetailModel: NSObject {
    
    @objc var avatarURL = ""
    @objc var name = ""
    @objc var title = ""
    @objc var school = ""
    @objc var schoolCertified = false
    @objc var yearsOfWorking = 0
    @objc var orgName = ""
    @objc var orgTitle = ""
    @objc var orgLogoURL = ""
    
    @objc static func modelCustomPropertyMapper() -> Dictionary<String, Any> {
        return [
            "avatarURL": "avatar",
            "orgName": "organization.name",
            "orgTitle": "organization.subtitle",
            "orgLogoURL": "organization.logo"
        ]
    }
}
