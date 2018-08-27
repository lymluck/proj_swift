//
//  StudyTimelineStageModel.swift
//  xxd
//
//  Created by remy on 2018/1/15.
//  Copyright © 2018年 com.smartstudy. All rights reserved.
//

class StudyTimelineStageModel: NSObject {

    @objc var items: [String]?
    @objc var name = ""
    @objc var time = ""
    @objc var isCurrentStage = false
}

class StudyTimelineModel: NSObject {
    
    @objc var grade = ""
    @objc var isCurrentGrade = false
    @objc var keywords: [String]?
    var subModels: [StudyTimelineStageModel]?
}
