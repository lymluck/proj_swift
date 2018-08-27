//
//  XDUser+Target.swift
//  xxd
//
//  Created by remy on 2018/4/9.
//  Copyright © 2018年 com.smartstudy. All rights reserved.
//

enum UserTargetType: Equatable {
    // https://stackoverflow.com/questions/24339807/how-to-test-equality-of-swift-enums-with-associated-values
    static func ==(lhs: UserTargetType, rhs: UserTargetType) -> Bool {
        switch (lhs, rhs) {
        case let (.us(a), .us(b)),
             let (.uk(a), .uk(b)),
             let (.ca(a), .ca(b)),
             let (.au(a), .au(b)),
             let (.other(a), .other(b)):
            return a == b
        default:
            return false
        }
    }
    case us(UserDegreeType)
    case uk(UserDegreeType)
    case ca(UserDegreeType)
    case au(UserDegreeType)
    case other(UserDegreeType)
}

enum UserCountryType {
    case us, uk, ca, au, other
    
    /// 不同意向地相对应的QQ群
    var qq_group_scheme_url: String {
        var groupInfo: (String, String) = ("", "")
        switch self {
        case .us:
            groupInfo = ("517936658", "94467e65a3e9149a753e47091c4013b68fb2bd69627cd6de9cd79190ac06e425")
        case .uk:
            groupInfo = ("693023533", "9513da0c539bd9d1425f47c94c209018b762aad47a76a11ba2455a621c386c50")
        case .ca:
            groupInfo = ("679888153", "b16704022bbf77a2388c241296b5e103069d99ca3dc9842b28be11f415b91473")
        case .au:
            groupInfo = ("794662943", "ce8290ae9031b4f6be7d38ae337a1d25a674126922c06e053d3ac5ed1de75704")
        default:
            groupInfo = ("626350084", "9b5ee9bdbc28ae9a8aef5f9a33c0b69e800d985e1b1a5a098ce61e5f4441edf5")
        }
        return String(format: "mqqapi://card/show_pslcard?src_type=internal&version=1&uin=%@&key=%@&card_type=group&source=external", groupInfo.0, groupInfo.1)
    }
}

enum UserDegreeType {
    case highschool, bachelor, master, other
}

enum UserMajorDirectionType {
    case engineering, business, science, society, art, others
}

/// 考试类型
enum ExamType: String {
    case gre = "GRE"
    case gmat = "GMAT"
    case sat = "SAT"
    case ielts = "雅思"
    case toefl = "托福"
    case mine = "我的\n计划"
    case multi = "多种考试"
    
    
    func attributeColor() -> UIColor {
        switch self {
        case .gre:
            return UIColor(0x4B67BF)
        case .gmat:
            return UIColor(0x4FC069)
        case .sat:
            return UIColor(0x5FACFF)
        case .ielts:
            return UIColor(0xFF5A52)
        case .toefl:
            return UIColor(0xFFB02F)
        case .multi:
            return UIColor(0xFF7FA4)
        case .mine:
            return UIColor(0xFFFFFF)
        }
    }
}

extension XDUser {
    
    func userCountryType() -> UserCountryType {
        switch model.targetCountryId {
        case "COUNTRY_226":
            return .us
        case "COUNTRY_225":
            return .uk
        case "COUNTRY_40":
            return .ca
        case "COUNTRY_16":
            return .au
        default:
            return .other
        }
    }
    
    func userTargetType() -> UserTargetType {
        let degree = userDegreeType()
        switch model.targetCountryId {
        case "COUNTRY_226":
            return UserTargetType.us(degree)
        case "COUNTRY_225":
            return UserTargetType.uk(degree)
        case "COUNTRY_40":
            return UserTargetType.ca(degree)
        case "COUNTRY_16":
            return UserTargetType.au(degree)
        default:
            return UserTargetType.other(degree)
        }
    }
    
    func userDegreeType() -> UserDegreeType {
        switch model.targetDegreeId {
        case "DEGREE_MDT_BACHELOR":
            return.bachelor
        case "DEGREE_MDT_MASTER":
            return.master
        case "DEGREE_MDT_SENIOR_HIGH_SCHOOL":
            return.highschool
        default:
            return .other
        }
    }
    
    func userMajorDirection() -> UserMajorDirectionType {
        switch model.targetMajorDirectionId {
        case "ENGINEERING":
            return .engineering
        case "BUSINESS":
            return .business
        case "SCIENCE":
            return .science
        case "SOCIETY":
            return .society
        case "ARTS":
            return .art
        default:
            return .others
        }
    }
}
