//
//  TargetCollegeModel.swift
//  xxd
//
//  Created by remy on 2018/1/3.
//  Copyright © 2018年 com.smartstudy. All rights reserved.
//

enum TargetCollegeType: Int {
    case top
    case middle
    case bottom
    case remove
}

class TargetCollegeModel: NSObject {
    
    @objc var collegeId = 0
    @objc var countryId = ""
    @objc var isMyTargetCountry = false
    @objc var chineseName = ""
    @objc var englishName = ""
    @objc var worldRank = ""
    @objc var matchTypeId = ""
    @objc var selectedCount: Int = 0
    lazy var targetCollegeType: TargetCollegeType = {
        return TargetCollegeModel.targetCollegeTypeWithString(str: matchTypeId)
    }()
    
    @objc static func modelCustomPropertyMapper() -> Dictionary<String, Any> {
        return [
            "collegeId": ["id"]
        ]
    }
    
    static func targetCollegeTypeWithString(str: String) -> TargetCollegeType {
        switch str {
        case "MS_MATCH_TYPE_TOP":
            return .top
        case "MS_MATCH_TYPE_MIDDLE":
            return .middle
        case "MS_MATCH_TYPE_BOTTOM":
            return .bottom
        default:
            return .top
        }
    }
    
    static func targetCollegeStringWithType(type: TargetCollegeType) -> String {
        switch type {
        case .top:
            return "MS_MATCH_TYPE_TOP"
        case .middle:
            return "MS_MATCH_TYPE_MIDDLE"
        case .bottom:
            return "MS_MATCH_TYPE_BOTTOM"
        default:
            return ""
        }
    }
}
