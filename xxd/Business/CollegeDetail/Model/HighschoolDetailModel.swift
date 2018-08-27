//
//  HighschoolDetailModel.swift
//  xxd
//
//  Created by remy on 2018/4/3.
//  Copyright © 2018年 com.smartstudy. All rights reserved.
//

class HighschoolDetailModel: NSObject {
    
    // 学校信息
    @objc var highschoolID = 0
    @objc var chineseName = ""
    @objc var englishName = ""
    @objc var rank = 0
    @objc var isCollected = false
    // 学校简介
    @objc var introduction = ""
    // 学校图片
    @objc var photos = [String]()
    // 学校概况
    @objc var boarderTypeName = ""
    @objc var sexualTypeName = ""
    @objc var schoolTypeName = ""
    @objc var establishmentYear = ""
    @objc var locationTypeName = ""
    @objc var address = ""
    @objc var area = ""
    @objc var religonName = ""
    @objc var countryName = ""
    @objc var provinceName = ""
    @objc var cityName = ""
    lazy var cityPath: String = {
        let p = provinceName.isEmpty ? "" : ("-" + provinceName)
        let c = cityName.isEmpty ? "" : ("-" + cityName)
        return countryName + p + c
    }()
    // 学校数据
    @objc var grades = ""
    @objc var classSize = ""
    @objc var apCourseCount = ""
    @objc var studentAmount = ""
    @objc var facultyStudentRatio = ""
    @objc var internationalStudentRatio = ""
    @objc var boarderRatio = ""
    @objc var seniorFacultyRatio = ""
    @objc var scoreSat = ""
    // 费用预算
    @objc var feeTuition = ""
    @objc var alumniFund = ""
    @objc var scholarship = ""
    // 申请情况
    @objc var applicationDeadline = ""
    @objc var toeflCode = ""
    @objc var ssatCode = ""
    @objc var iseeCode = ""
    @objc var interview = ""
    @objc var acceptScores = ""
    @objc var chineseApplicationAmount = ""
    @objc var chineseAdmissionAmount = ""
    @objc var chineseStudentAmount = ""
    @objc var gradesForChineseStudent = ""
    @objc var amountForChineseStudent = ""
    @objc var chineseThirdpartyPreinterview = ""
    @objc var chineseToeflAverage = ""
    @objc var chineseToeflLowest = ""
    @objc var chineseSsatAverage = ""
    @objc var chineseSsatLowest = ""
    // 暑期学校
    @objc var ssWebsite = ""
    @objc var ssStartTime = ""
    @objc var ssEndTime = ""
    @objc var ssGrades = ""
    @objc var ssAges = ""
    @objc var ssGenders = ""
    @objc var ssFeeTuition = ""
    @objc var ssEslCourse = ""
    @objc var ssChecklist = ""
    @objc var ssTel = ""
    @objc var ssEmail = ""
    // 联系信息
    @objc var tel = ""
    @objc var email = ""
    @objc var applicationTel = ""
    @objc var applicationEmail = ""
    // 独立项目
    @objc var sports = [[String : String]]()
    @objc var apCourses = [[String : String]]()
    @objc var communities = [[String : String]]()
    @objc var features = [String]()
    @objc var pros = [String]()
    @objc var honors = [String]()
    @objc var facilities = [String]()
    @objc var eslCourse = ""
    
    @objc static func modelCustomPropertyMapper() -> Dictionary<String, Any> {
        return [
            "highschoolID": "id",
            "applicationDeadline": "application.applicationDeadline",
            "toeflCode": "application.toeflCode",
            "ssatCode": "application.ssatCode",
            "iseeCode": "application.iseeCode",
            "interview": "application.interview",
            "acceptScores": "application.acceptScores",
            "chineseApplicationAmount": "application.chineseApplicationAmount",
            "chineseAdmissionAmount": "application.chineseAdmissionAmount",
            "chineseStudentAmount": "application.chineseStudentAmount",
            "gradesForChineseStudent": "application.gradesForChineseStudent",
            "amountForChineseStudent": "application.amountForChineseStudent",
            "chineseThirdpartyPreinterview": "application.chineseThirdpartyPreinterview",
            "chineseToeflAverage": "application.chineseToeflAverage",
            "chineseToeflLowest": "application.chineseToeflLowest",
            "chineseSsatAverage": "application.chineseSsatAverage",
            "chineseSsatLowest": "application.chineseSsatLowest",
            "ssWebsite": "summerSchool.website",
            "ssStartTime": "summerSchool.startTime",
            "ssEndTime": "summerSchool.endTime",
            "ssGrades": "summerSchool.grades",
            "ssAges": "summerSchool.ages",
            "ssGenders": "summerSchool.genders",
            "ssFeeTuition": "summerSchool.feeTuition",
            "ssEslCourse": "summerSchool.eslCourse",
            "ssChecklist": "summerSchool.checklist",
            "ssTel": "summerSchool.tel",
            "ssEmail": "summerSchool.email",
            "applicationTel": "application.tel",
            "applicationEmail": "application.email",
        ]
    }
}
