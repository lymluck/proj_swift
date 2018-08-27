//
//  CourseOutlineModel.swift
//  xxd
//
//  Created by remy on 2018/1/22.
//  Copyright © 2018年 com.smartstudy. All rights reserved.
//

class CourseOutlineSectionModel: NSObject {
    
    @objc var name = ""
    @objc var ID = 0
    @objc var chapters = [[String : Any]]()
    lazy var subModels: [CourseOutlineModel] = {
        if chapters.count > 0 {
            var models = [CourseOutlineModel]()
            for chapterDic in chapters {
                if let points = chapterDic["sections"] as? [[String : Any]] {
                    for (index, point) in points.enumerated() {
                        if let model = CourseOutlineModel.yy_model(with: point) {
                            if index == 0, let name = chapterDic["name"] as? String {
                                model.chapterName = name
                            }
                            models.append(model)
                        }
                    }
                }
            }
            return models
        }
        return [CourseOutlineModel]()
    }()
    
    @objc static func modelCustomPropertyMapper() -> Dictionary<String, Any> {
        return [
            "ID": "id"
        ]
    }
}

class CourseOutlineModel: NSObject {
    
    @objc var name = ""
    @objc var chapterName = ""
    @objc var ID = 0
    @objc var progress = 0.0
    @objc var lastPlayTime = 0.0
    @objc var maxPlayTime = 0.0
    @objc var duration = 0.0
    @objc var isTrial = false
    
    @objc static func modelCustomPropertyMapper() -> Dictionary<String, Any> {
        return [
            "ID": "id"
        ]
    }
}
