//
//  XDUserModel.swift
//  xxd
//
//  Created by remy on 2018/2/26.
//  Copyright © 2018年 com.smartstudy. All rights reserved.
//

private let mapper = [
    "ticket": ["ticket", "account.ticket"],
    "token": ["token", "user.token", "account.user.token"],
    "ID": ["id", "user.id", "account.user.id"],
    "imToken": ["user.imToken"],
    "imUserId": ["user.imUserId", "imUserId"],
    "userID": ["userId", "user.userId", "account.user.userId"],
    "ssUser": ["ssUser", "account.ssUser"],
    "nickname": ["name", "user.name", "account.user.name"],
    "avatarURL": ["avatar", "user.avatar", "account.user.avatar"],
    "phoneNumber": ["phone", "user.phone", "account.user.phone"],
    "unreadMessageCount": ["notificationUnreadCount", "user.info.notificationUnreadCount"],
    "hasUnreadQuestions": ["hasUnreadQuestions", "user.info.hasUnreadQuestions"],
    "targetCountryId": ["targetSection.targetCountry.id", "user.info.targetSection.targetCountry.id"],
    "targetCountryName": ["targetSection.targetCountry.name", "user.info.targetSection.targetCountry.name"],
    "targetDegreeId": ["targetSection.targetDegree.id", "user.info.targetSection.targetDegree.id"],
    "targetDegreeName": ["targetSection.targetDegree.name", "user.info.targetSection.targetDegree.name"],
    "targetSchoolRankId": ["targetSection.targetSchoolRank.id", "user.info.targetSection.targetSchoolRank.id"],
    "targetSchoolRankName": ["targetSection.targetSchoolRank.name", "user.info.targetSection.targetSchoolRank.name"],
    "budgetId": ["targetSection.budget.id", "user.info.targetSection.budget.id"], // 增加资金预算显示条目
    "budgetName": ["targetSection.budget.name", "user.info.targetSection.budget.name"],
    "targetMajorDirectionId": ["targetSection.targetMajorDirection.id", "user.info.targetSection.targetMajorDirection.id"],
    "targetMajorDirectionName": ["targetSection.targetMajorDirection.name", "user.info.targetSection.targetMajorDirection.name"],
    "admissionTimeId": ["targetSection.admissionTime.id", "user.info.targetSection.admissionTime.id"],
    "admissionTimeName": ["targetSection.admissionTime.name", "user.info.targetSection.admissionTime.name"],
    "currentSchool": ["backgroundSection.currentSchool.id", "user.info.backgroundSection.currentSchool.id"],
    "scoreId": ["backgroundSection.score.id", "user.info.backgroundSection.score.id"],
    "scoreName": ["backgroundSection.score.name", "user.info.backgroundSection.score.name"],
    "scoreLanguageId": ["backgroundSection.scoreLanguage.id", "user.info.backgroundSection.scoreLanguage.id"],
    "scoreLanguageName": ["backgroundSection.scoreLanguage.name", "user.info.backgroundSection.scoreLanguage.name"],
    "scoreStandardId": ["backgroundSection.scoreStandard.id", "user.info.backgroundSection.scoreStandard.id"],
    "scoreStandardName": ["backgroundSection.scoreStandard.name", "user.info.backgroundSection.scoreStandard.name"],
    "activityInternshipId": ["backgroundSection.activityInternship.id", "user.info.backgroundSection.activityInternship.id"],
    "activityInternshipName": ["backgroundSection.activityInternship.name", "user.info.backgroundSection.activityInternship.name"],
    "activityResearchId": ["backgroundSection.activityResearch.id", "user.info.backgroundSection.activityResearch.id"],
    "activityResearchName": ["backgroundSection.activityResearch.name", "user.info.backgroundSection.activityResearch.name"],
    "activityCommunityId": ["backgroundSection.activityCommunity.id", "user.info.backgroundSection.activityCommunity.id"],
    "activityCommunityName": ["backgroundSection.activityCommunity.name", "user.info.backgroundSection.activityCommunity.name"],
    "activityExchangeId": ["backgroundSection.activityExchange.id", "user.info.backgroundSection.activityExchange.id"],
    "activityExchangeName": ["backgroundSection.activityExchange.name", "user.info.backgroundSection.activityExchange.name"],
    "activitySocialId": ["backgroundSection.activitySocial.id", "user.info.backgroundSection.activitySocial.id"],
    "activitySocialName": ["backgroundSection.activitySocial.name", "user.info.backgroundSection.activitySocial.name"]
]

class XDUserModel: NSObject {
    
    @objc var ticket = ""
    @objc var token = ""
    @objc var ID = ""
    @objc var userID = ""
    @objc var ssUser = ""
    @objc var nickname = ""
    @objc var avatarURL = ""
    @objc var phoneNumber = ""
    @objc var email = ""
    @objc var unreadMessageCount = ""
    @objc var hasUnreadQuestions = ""
    @objc var targetCountryId = ""
    @objc var targetCountryName = ""
    @objc var targetDegreeId = ""
    @objc var targetDegreeName = ""
    @objc var targetSchoolRankId = ""
    @objc var targetSchoolRankName = ""
    @objc var budgetId = ""
    @objc var budgetName = ""
    @objc var targetMajorDirectionId = ""
    @objc var targetMajorDirectionName = ""
    @objc var admissionTimeId = ""
    @objc var admissionTimeName = ""
    @objc var currentSchool = ""
    @objc var scoreId = ""
    @objc var scoreName = ""
    @objc var scoreLanguageId = ""
    @objc var scoreLanguageName = ""
    @objc var scoreStandardId = ""
    @objc var scoreStandardName = ""
    @objc var activityInternshipId = ""
    @objc var activityInternshipName = ""
    @objc var activityResearchId = ""
    @objc var activityResearchName = ""
    @objc var activityCommunityId = ""
    @objc var activityCommunityName = ""
    @objc var activityExchangeId = ""
    @objc var activityExchangeName = ""
    @objc var activitySocialId = ""
    @objc var activitySocialName = ""
    @objc var imUserId = ""
    @objc var imToken = ""
    /// 设置选校主页的隐私权限
    var isPrivacy: Bool = false
    @objc static func modelCustomPropertyMapper() -> Dictionary<String, Any> {
        return mapper
    }
}

class XDUserUpdateModel: NSObject {
    
    @objc var ticket: String?
    @objc var token: String?
    @objc var ID: String?
    @objc var userID: String?
    @objc var ssUser: String?
    @objc var nickname: String?
    @objc var avatarURL: String?
    @objc var phoneNumber: String?
    @objc var email: String?
    @objc var unreadMessageCount: String?
    @objc var hasUnreadQuestions: String?
    @objc var targetCountryId: String?
    @objc var targetCountryName: String?
    @objc var targetDegreeId: String?
    @objc var targetDegreeName: String?
    @objc var budgetId: String?
    @objc var budgetName: String?
    @objc var targetSchoolRankId: String?
    @objc var targetSchoolRankName: String?
    @objc var targetMajorDirectionId: String?
    @objc var targetMajorDirectionName: String?
    @objc var admissionTimeId: String?
    @objc var admissionTimeName: String?
    @objc var currentSchool: String?
    @objc var scoreId: String?
    @objc var scoreName: String?
    @objc var scoreLanguageId: String?
    @objc var scoreLanguageName: String?
    @objc var scoreStandardId: String?
    @objc var scoreStandardName: String?
    @objc var activityInternshipId: String?
    @objc var activityInternshipName: String?
    @objc var activityResearchId: String?
    @objc var activityResearchName: String?
    @objc var activityCommunityId: String?
    @objc var activityCommunityName: String?
    @objc var activityExchangeId: String?
    @objc var activityExchangeName: String?
    @objc var activitySocialId: String?
    @objc var activitySocialName: String?
    @objc var imUserId: String?
    @objc var imToken: String?
    
    @objc static func modelCustomPropertyMapper() -> Dictionary<String, Any> {
        return mapper
    }
}
