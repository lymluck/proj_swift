//
//  AdmissionResultModel.swift
//  xxd
//
//  Created by remy on 2018/1/31.
//  Copyright © 2018年 com.smartstudy. All rights reserved.
//

class AdmissionResultModel: NSObject {
    
    @objc var resultID = 0
    @objc var schoolLogo = ""
    @objc var schoolChineseName = ""
    @objc var schoolEnglishName = ""
    @objc var rate = 0
    @objc var averageRate = 0
    @objc var projectID = ""
    
    @objc var toefl = ""
    @objc var qualifiedToefl = ""
    @objc var toeflWinRate = ""
    @objc var ielts = ""
    @objc var qualifiedIelts = ""
    @objc var ieltsWinRate = ""
    @objc var sat = ""
    @objc var qualifiedSat = ""
    @objc var satWinRate = ""
    @objc var act = ""
    @objc var qualifiedAct = ""
    @objc var actWinRate = ""
    @objc var gre = ""
    @objc var qualifiedGre = ""
    @objc var greWinRate = ""
    @objc var gmat = ""
    @objc var qualifiedGmat = ""
    @objc var gmatWinRate = ""
    
    @objc static func modelCustomPropertyMapper() -> Dictionary<String, Any> {
        return [
            "resultID": "id",
            "projectID": "projectId"
        ]
    }
}

enum TestType: String {
    case toefl
    case ielts
    case gre
    case gmat
    case sat
    case act
}

class AdmissionDescModel: NSObject {
    
    var type: TestType!
    var score = ""
    var qualified = ""
    var winRate = ""
    var scoreFormat = ""
    
    convenience init(model: AdmissionResultModel, type: TestType) {
        self.init()
        self.type = type
        scoreFormat = "%.lf"
        switch type {
        case .toefl:
            score(model.toefl, model.qualifiedToefl, model.toeflWinRate)
        case .ielts:
            score(model.ielts, model.qualifiedIelts, model.ieltsWinRate)
        case .gre:
            score(model.gre, model.qualifiedGre, model.greWinRate)
        case .gmat:
            score(model.gmat, model.qualifiedGmat, model.gmatWinRate)
        case .sat:
            score(model.sat, model.qualifiedSat, model.satWinRate)
        case .act:
            score(model.act, model.qualifiedAct, model.actWinRate)
        }
    }
    
    private func score(_ score: String, _ qualified: String, _ winRate: String) {
        self.score = score
        self.qualified = qualified
        self.winRate = winRate
    }
}
