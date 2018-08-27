//
//  CompleteFieldModel.swift
//  xxd
//
//  Created by remy on 2018/1/10.
//  Copyright © 2018年 com.smartstudy. All rights reserved.
//

class CompleteFieldModel: NSObject {
    
    @objc var paramKey = ""
    @objc var selectedValue = ""
    @objc var fieldName = ""
    @objc var options = [[String : Any]]()
    lazy var subModels: [CompleteFieldOptionModel] = {
        if options.count > 0 {
            return NSArray.yy_modelArray(with: CompleteFieldOptionModel.self, json: options) as! [CompleteFieldOptionModel]
        }
        return [CompleteFieldOptionModel]()
    }()
    
    @objc static func modelCustomPropertyMapper() -> Dictionary<String, Any> {
        return [
            "paramKey": "field"
        ]
    }
}

class CompleteFieldOptionModel: NSObject {
    
    @objc var value = ""
    @objc var name = ""
    @objc var nextFieldName = ""
    @objc var finish = false
    @objc var index = 0
    
    @objc static func modelCustomPropertyMapper() -> Dictionary<String, Any> {
        return [
            "value": "id",
            "nextFieldName": "next"
        ]
    }
}
