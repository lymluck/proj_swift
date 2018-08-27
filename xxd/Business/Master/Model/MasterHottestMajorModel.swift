//
//  MasterHottestMajorModel.swift
//  xxd
//
//  Created by Lisen on 2018/7/11.
//  Copyright © 2018年 com.smartstudy. All rights reserved.
//

import UIKit

class MasterHottestMajorModel: NSObject {
    
    @objc var categoryId: Int = 0
    @objc var categoryName: String = ""
    @objc var categories: [[String: Any]] = [[String: Any]]()
    lazy var subMajors: [MasterMajorModel] = {
        var models: [MasterMajorModel] = [MasterMajorModel]()
        if categories.count > 0 {
            for major in categories {
                let model: MasterMajorModel = MasterMajorModel.yy_model(with: major)!
                models.append(model)
            }
        }
        return models
    }()
    
    @objc static func modelCustomPropertyMapper() -> Dictionary<String, Any> {
        return ["categoryId":"id",
                "categoryName":"name"
        ]
    }
}

class MasterMajorModel: NSObject {
    @objc var majorId: Int = 0
    
    @objc var categoryRank: Int = 0
    @objc var schoolName: String = ""
    @objc var chineseName: String = ""
    @objc var englishName: String = ""
    @objc var visitCount: Int = 0
    
    @objc static func modelCustomPropertyMapper() -> Dictionary<String, Any> {
        return ["majorId":"id"
        ]
    }
}


