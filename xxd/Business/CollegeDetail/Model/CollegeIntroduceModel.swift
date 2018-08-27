//
//  CollegeIntroduceModel.swift
//  xxd
//
//  Created by remy on 2018/2/24.
//  Copyright © 2018年 com.smartstudy. All rights reserved.
//

enum InterviewType: String {
    case need
    case noNeed
    case unknown
}

enum ExamScoreType: String {
    case gpa
    case toefl
    case ielts
    case gre
    case gmat
    case sat
    case sat2
    case act
}

protocol CollegeCommonInfo {
    
    var coverURL: String { get set }
    var logoURL: String { get set }
    var chineseName: String { get set }
    var englishName: String { get set }
    var cityPath: String { get set }
    var localRank: Int { get set }
    var worldRank: Int { get set }
}

class CollegeIntroduceModel: NSObject, CollegeCommonInfo {
    
    @objc var coverURL = ""
    @objc var logoURL = ""
    @objc var chineseName = ""
    @objc var englishName = ""
    @objc var cityPath = ""
    @objc var localRank = 0
    @objc var worldRank = 0
    
    @objc var address = ""
    @objc var acceptRate = ""
    @objc var phone = ""
    @objc var deadline = ""
    @objc var fee = ""
    @objc var applyFee = ""
    @objc var website = ""
    @objc var scoreAct = ""
    @objc var scoreGmat = ""
    @objc var scoreGre = ""
    @objc var scoreIelts = ""
    @objc var scoreSat = ""
    @objc var scoreSat2 = ""
    @objc var scoreToefl = ""
    @objc var gpa = ""
    @objc var requireInterview: String?
    lazy var interviewType: InterviewType = {
        if let requireInterview = requireInterview {
            return requireInterview == "1" ? .need : .noNeed
        } else {
            return .unknown
        }
    }()
    lazy var examScoreModels: [CollegeExamScoreModel] = {
        var models = [CollegeExamScoreModel]()
        if !gpa.isEmpty {
            models.append(getExamScoreModel(.gpa, "GPA", gpa))
        }
        if !scoreSat.isEmpty {
            models.append(getExamScoreModel(.sat, "SAT", scoreSat))
        }
        if !scoreAct.isEmpty {
            models.append(getExamScoreModel(.act, "ACT", scoreAct))
        }
        if !scoreGre.isEmpty {
            models.append(getExamScoreModel(.gre, "GRE", scoreGre))
        }
        if !scoreGmat.isEmpty {
            models.append(getExamScoreModel(.gmat, "GMAT", scoreGmat))
        }
        if !scoreToefl.isEmpty {
            models.append(getExamScoreModel(.toefl, "托福", scoreToefl))
        }
        if !scoreIelts.isEmpty {
            models.append(getExamScoreModel(.ielts, "雅思", scoreIelts))
        }
        if !scoreSat2.isEmpty {
            models.append(getExamScoreModel(.sat2, "SAT2", scoreSat2))
        }
        return models
    }()
    
    @objc static func modelCustomPropertyMapper() -> Dictionary<String, Any> {
        return [
            "coverURL": "coverPicture",
            "acceptRate": "admissionRate",
            "phone": "contactPhone",
            "fee": "feeTotal",
            "logoURL": "logo",
            "applyFee": "feeApplication"
        ]
    }
    
    func getExamScoreModel(_ type: ExamScoreType, _ name: String, _ score: String) -> CollegeExamScoreModel {
        let model = CollegeExamScoreModel()
        model.type = type
        model.name = name
        model.score = score
        return model
    }
}

class CollegeExamScoreModel: NSObject {
    
    var type: ExamScoreType!
    var name = ""
    var score = ""
}
