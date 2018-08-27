//
//  SpecialModel.swift
//  xxd
//
//  Created by remy on 2018/2/22.
//  Copyright © 2018年 com.smartstudy. All rights reserved.
//

class SpecialModel: NSObject {
    
    @objc var specialID = ""
    @objc var imageURL = ""
    @objc var visitCount = 0
    @objc var specialURL = ""
    
    @objc static func modelCustomPropertyMapper() -> Dictionary<String, Any> {
        return [
            "specialID": "id",
            "imageURL": "imageUrl",
            "specialURL": "subjectUrl"
        ]
    }
}
