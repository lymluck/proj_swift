//
//  ExamineeModel.swift
//  xxd
//
//  Created by remy on 2018/5/29.
//  Copyright © 2018年 com.smartstudy. All rights reserved.
//

class ExamineeModel: NSObject {
    
    @objc var examineeID: Int = 0
    @objc var name: String = ""
    @objc var avatar: String = ""
    @objc var checkinCount: Int = 0
    
    @objc static func modelCustomPropertyMapper() -> Dictionary<String, Any> {
        return [
            "examineeID": "id"
        ]
    }
}
