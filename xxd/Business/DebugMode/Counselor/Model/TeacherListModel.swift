//
//  TeacherListModel.swift
//  xxd
//
//  Created by chenyusen on 2018/3/5.
//  Copyright © 2018年 com.smartstudy. All rights reserved.
//

import UIKit

class TeacherListModel: NSObject {
    @objc var name: String = ""
    @objc var avatar: String = ""
    @objc var imUserId: String = ""
    @objc var title: String = ""
    @objc var school: String = ""
    @objc var workYear: Int = 0
    @objc var location: String = ""
    @objc var company: String = ""
    @objc var logo: String = ""
    
    @objc static func modelCustomPropertyMapper() -> Dictionary<String, Any> {
        return [
            "workYear": "yearsOfWorking",
            "company": "organization.name",
            "logo": "organization.smallLogo"
        ]
    }
}
