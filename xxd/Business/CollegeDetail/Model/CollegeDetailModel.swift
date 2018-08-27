//
//  CollegeDetailModel.swift
//  xxd
//
//  Created by remy on 2018/2/24.
//  Copyright © 2018年 com.smartstudy. All rights reserved.
//

class CollegeDetailModel: NSObject {
    
    @objc var school: CollegeDetailIntroModel?
    @objc var bachelor: CollegeDetailDegreeModel?
    @objc var master: CollegeDetailDegreeModel?
    @objc var art: CollegeDetailDegreeModel?
    @objc var informations: [InformationModel]?
    @objc var questions: [QuestionModel]?
    
    @objc static func modelCustomPropertyMapper() -> Dictionary<String, Any> {
        return [
            "bachelor": "undergraduateApplication",
            "master": "graduateApplication",
            "art": "siaInfo",
            "informations": "news.data",
            "questions": "questions.data"
        ]
    }
    
    @objc static func modelContainerPropertyGenericClass() -> Dictionary<String, Any> {
        return [
            "informations": InformationModel.self,
            "questions": QuestionModel.self
        ]
    }
}

class CollegeDetailIntroModel: NSObject, CollegeCommonInfo {
    
    @objc var coverURL = ""
    @objc var logoURL = ""
    @objc var chineseName = ""
    @objc var englishName = ""
    @objc var localRank = 0
    @objc var worldRank = 0
    lazy var cityPath: String = {
        let p = provinceName.isEmpty ? "" : ("-" + provinceName)
        let c = cityName.isEmpty ? "" : ("-" + cityName)
        return countryName + p + c
    }()
    
    @objc var countryName = ""
    @objc var provinceName = ""
    @objc var cityName = ""
    @objc var collegeID = 0
    @objc var collegeIntro = ""
    @objc var selected = false
    
    @objc static func modelCustomPropertyMapper() -> Dictionary<String, Any> {
        return [
            "collegeID": "id",
            "collegeIntro": "textIntroduction",
            "coverURL": "coverPicture",
            "phone": "contactPhone",
            "logoURL": "logo"
        ]
    }
}

enum CollegeDetailDegreeType: Int {
    case undergraduate
    case graduate
    case art
}

class CollegeDetailDegreeModel: NSObject {

    @objc var difficultyName = "" // 难度
    @objc var applyCount = "" // 申请人数
    @objc var applyDeadline = "" // 申请截止日
    @objc var timeOffer = "" //offer发放日
    @objc var timeOfferDeadline = "" // offer截止日
    @objc var feeTotal = "" // 总费用
    @objc var feeAccommodation = "" // 住宿费
    @objc var feeTuition = "" // 学费
    @objc var feeBook = "" // 书本费
    @objc var feeLife = "" // 生活费
    @objc var feeApplication = "" // 申请费
    @objc var feeTraffic = "" // 交通费
    @objc var admissionRate = -1.0
    lazy var acceptRate: String = { // 录取率
        if admissionRate < 1 && admissionRate > 0 {
            return String(format: "%.f%%", (admissionRate * 100).rounded())
        }
        return ""
    }()
    @objc var admissionRateSia = -1.0
    lazy var acceptRateArt: String = { // 艺术生录取率
        if admissionRateSia < 1 && admissionRateSia > 0 {
            return String(format: "%.f%%", (admissionRateSia * 100).rounded())
        }
        return ""
    }()
    var degreeType: CollegeDetailDegreeType = .undergraduate

    @objc static func modelCustomPropertyMapper() -> Dictionary<String, Any> {
        return [
            "applyCount": "applicationStudentAmount",
            "applyDeadline": "timeApplicationDeadline"
        ]
    }
}
