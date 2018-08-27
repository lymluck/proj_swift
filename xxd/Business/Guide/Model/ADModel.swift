//
//  ADModel.swift
//  xxd
//
//  Created by remy on 2018/1/15.
//  Copyright © 2018年 com.smartstudy. All rights reserved.
//

class ADModel: NSObject {
    
    @objc var adID = 0
    @objc var name = ""
    @objc var adURL = ""
    @objc var imageURL = ""
    
    @objc static func modelCustomPropertyMapper() -> Dictionary<String, Any> {
        return [
            "adID": "id",
            "imageURL": "imgUrl",
            "adURL": "adUrl"
        ]
    }
}
