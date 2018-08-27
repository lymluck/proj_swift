//
//  MajorModel.swift
//  xxd
//
//  Created by remy on 2018/2/14.
//  Copyright © 2018年 com.smartstudy. All rights reserved.
//

class MajorModel: NSObject {
    
    @objc var categoryID = ""
    @objc var name = ""
    @objc var majorId = 0
    @objc var minorCategories = [[String : Any]]()
    lazy var subModels: [MajorModel] = {
        if minorCategories.count > 0 {
            var models = [MajorModel]()
            for dict in minorCategories {
                if let majors = dict["majors"] {
                    let arr = NSArray.yy_modelArray(with: MajorModel.self, json: majors) as! [MajorModel]
                    models += arr
                }
            }
            return models
        }
        return [MajorModel]()
    }()
    lazy var URLPath: String = {
        if minorCategories.isEmpty {
            return String(format: XD_WEB_MAJOR_DETAIL, majorId)
        }
        return ""
    }()
    
    @objc static func modelCustomPropertyMapper() -> Dictionary<String, Any> {
        return [
            "categoryID": "id",
            "majorId": "id"
        ]
    }
}

class HottestMajorModel: NSObject {
    @objc var categoryId = ""
    @objc var categoryName = ""
    @objc var majorId = 0
    @objc var majors = [[String: Any]]()
    lazy var subMajors: [HottestMajorModel] = {
        var models: [HottestMajorModel] = []
        if majors.count > 0 {
            for majorDic in majors {
                let model = HottestMajorModel.yy_model(with: majorDic)!
                models.append(model)
            }
        }
        return models
    }()
    lazy var majorURLPath: String = {
       return String(format: XD_WEB_MAJOR_DETAIL, majorId)
    }()
    
    @objc static func modelCustomPropertyMapper() -> Dictionary<String, Any> {
        return ["categoryId": "id",
                "majorId": "id",
                "categoryName": "name"
        ]
    }
}

