//
//  UserInfoView.swift
//  xxd
//
//  Created by remy on 2018/2/5.
//  Copyright © 2018年 com.smartstudy. All rights reserved.
//

import Kingfisher

let kEventUserInfoAvatarTap = "kEventUserInfoAvatarTap"
let kEventUserInfoItemTap = "kEventUserInfoItemTap"
private let kItemHeight: CGFloat = 64

enum UserInfoType {
    case highSchoolUS // 美高
    case graduateUS // 美本
    case undergraduateUS // 美研
    case otherUS // 美其他
    case highSchoolOther // 其他高
    case graduateOther // 其他本
    case undergraduateOther // 其他研
    case otherOther // 其他其他
}

/// 个人中心信息编辑及问答详情界面中的个人信息完善共用
class UserInfoView: UIView {
    
    lazy var avatar: UIImageView = {
        let imageView = UIImageView(frame: CGRect(origin: .zero, size: CGSize(width: XDSize.screenWidth, height: XDSize.topHeight+160.0)))
        imageView.contentMode = .scaleAspectFill
        imageView.isHidden = true
        return imageView
    }()
    private var topSectionHeight: CGFloat = XDSize.topHeight
    private var isFirstSectionVisible: Bool = false
    private var userType: UserInfoType!
    private var middleSection: UIView!
    private var userItems = [XDItemView]()
    
    convenience init(frame: CGRect, isFromQA: Bool = false) {
        self.init(frame: frame)
        backgroundColor = UIColor.clear
        if !isFromQA {
            addTopSection()
        }
        addMiddleSection()
        refreshView()
    }    
    
    private func addTopSection() {
        let bgView = UIView(frame: CGRect(x: 0, y: 0, width: XDSize.screenWidth, height: XDSize.topHeight + 160), color: UIColor.clear)
        bgView.layer.masksToBounds = true
        addSubview(bgView)
        bgView.addSubview(avatar)
        let bgMask = UIImageView(frame: CGRect(x: 0, y: XDSize.topHeight + 127, width: XDSize.screenWidth, height: 99), imageName: "user_bg_mask")!
        addSubview(bgMask)
        let avatarPicker = UIImageView(frame: CGRect(x: (XDSize.screenWidth - 43) * 0.5, y: XDSize.topHeight + 130, width: 43, height: 44), imageName: "set_avatar")!
        avatarPicker.isUserInteractionEnabled = true
        avatarPicker.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(avatarTap(gestureRecognizer:))))
        addSubview(avatarPicker)
        topSectionHeight = XDSize.topHeight+174.0
        isFirstSectionVisible = true
    }
    
    private func addMiddleSection() {
        middleSection = UIView(frame: CGRect(x: 0, y: topSectionHeight, width: XDSize.screenWidth, height: 0), color: UIColor.clear)
        addSubview(middleSection)
        // 请求参数key,XDUser值key,XDUser显示key
        var keys = [
            "name,nickname,nickname",
            "admissionTime,admissionTimeId,admissionTimeName",
            "targetCountry,targetCountryId,targetCountryName",
            "targetDegree,targetDegreeId,targetDegreeName",
            "budget,budgetId,budgetName",
            "targetSchoolRank,targetSchoolRankId,targetSchoolRankName",
            "targetMajorDirection,targetMajorDirectionId,targetMajorDirectionName",
            "currentSchool,currentSchool,currentSchool",
            "score,scoreId,scoreName",
            "scoreLanguage,scoreLanguageId,scoreLanguageName",
            "scoreStandard,scoreStandardId,scoreStandardName",
            "activitySocial,activitySocialId,activitySocialName",
            "activityInternship,activityInternshipId,activityInternshipName",
            "activityResearch,activityResearchId,activityResearchName",
            "activityCommunity,activityCommunityId,activityCommunityName",
            "activityExchange,activityExchangeId,activityExchangeName"
        ];
        if !isFirstSectionVisible {
            keys.removeFirst()
        }
        for (index, key) in keys.enumerated() {
            let item = XDItemView(frame: CGRect(x: 0, y: 0, width: XDSize.screenWidth, height: kItemHeight), type: .middle)
            item.isRightArrow = true
            item.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(itemTap(gestureRecognizer:))))
            middleSection.addSubview(item)
            userItems.append(item)
            
            let title = UILabel(frame: CGRect(x: 16, y: 21, width: 85, height: 22), text: "", textColor: XDColor.itemText, fontSize: 16)!
            item.addSubview(title)
            
            let content = UILabel(frame: CGRect(x: 101, y: 21, width: item.width - 133, height: 22), text: "", textColor: XDColor.itemTitle, fontSize: 16)!
            item.addSubview(content)
            
            let arr = key.components(separatedBy: ",")
            item.info = [
                "content": content,
                "title": title,
                "index": index,
                "paramKey": arr[0],
                "valueKey": arr[1],
                "nameKey": arr[2],
            ]
        }
    }
    
    private func reloadUserType() {
        let model = XDUser.shared.model
        if model.targetCountryId == "COUNTRY_226" {
            switch model.targetDegreeId {
            case "DEGREE_MDT_MASTER":
                userType = .graduateUS
            case "DEGREE_MDT_BACHELOR":
                userType = .undergraduateUS
            case "DEGREE_MDT_SENIOR_HIGH_SCHOOL":
                userType = .highSchoolUS
            default:
                userType = .otherUS
            }
        } else {
            switch model.targetDegreeId {
            case "DEGREE_MDT_MASTER":
                userType = .graduateOther
            case "DEGREE_MDT_BACHELOR":
                userType = .undergraduateOther
            case "DEGREE_MDT_SENIOR_HIGH_SCHOOL":
                userType = .highSchoolOther
            default:
                userType = .otherOther
            }
        }
    }
    
    func refreshView() {
        reloadUserType()
        let model = XDUser.shared.model
        if !model.avatarURL.isEmpty {
            avatar.isHidden = false
            avatar.kf.setImage(with: URL(string: model.avatarURL))
        }
        var typeKeys = [String]()
        var titleKeyIndex = 0
        //FIXME: 资金预算暂时添加到了第四个
        switch userType {
        case .graduateUS:
            titleKeyIndex = 3
            typeKeys = ["1", "111111", "111101111"]
        case .graduateOther:
            titleKeyIndex = 3
            typeKeys = ["1", "111101", "111101111"]
        case .undergraduateUS:
            titleKeyIndex = 2
            typeKeys = ["1", "111110", "111110001"]
        case .undergraduateOther:
            titleKeyIndex = 2
            typeKeys = ["1", "111100", "111110001"]
        case .highSchoolUS:
            titleKeyIndex = 1
            typeKeys = ["1", "111100", "111000000"]
        case .highSchoolOther:
            titleKeyIndex = 1
            typeKeys = ["1", "111100", "111000000"]
        case .otherUS:
            typeKeys = ["1", "111111", "111001111"]
        default:
            typeKeys = ["1", "111101", "111001111"]
            break
        }
        // 标题key
        var keys = [
            "user_info_name",
            "user_info_abroad_time",
            "user_info_target",
            "user_info_degree",
            "user_info_budget",
            "user_info_target_college_rank",
            "user_info_major_direction",
            ["user_info_other_school","user_info_middle_school","user_info_high_school","user_info_college"][titleKeyIndex],
            ["user_info_other_school_score","user_info_middle_school_score","user_info_high_school_score","user_info_college_score"][titleKeyIndex],
            "user_info_language_score",
            ["","","user_info_SAT_ACT","user_info_GRE_GMAT"][titleKeyIndex],
            "user_info_social_activity",
            "user_info_internship_activity",
            "user_info_research_activity",
            "user_info_community_activity",
            "user_info_exchange_activity"
        ]
        if !isFirstSectionVisible {
            typeKeys.removeFirst()
            keys.removeFirst()
        }
        var height: CGFloat = 0
        var index = 0
        for types in typeKeys {
            var lastItem: XDItemView?
            for i in 0..<types.count {
                let item = userItems[index]
                let type = Int(types.substring(loc: i, len: 1))!
                if type == 1 {
                    item.isHidden = false
                    item.top = height
                    let title = item.info["title"] as! UILabel
                    title.text = keys[index].localized
                    let content = item.info["content"] as! UILabel
                    content.text = model.value(forKey: item.info["nameKey"] as! String) as? String
                    height += kItemHeight
                    item.lineType = .middle
                    lastItem = item
                } else {
                    item.isHidden = true
                }
                index += 1
            }
            lastItem?.lineType = .plain
            height += 12.0
        }
        middleSection.height = height
        self.height = middleSection.bottom
    }
    
    func refreshItem(_ item: XDItemView) {
        let content = item.info["content"] as! UILabel
        let key = item.info["nameKey"] as! String
        content.text = XDUser.shared.model.value(forKey: key) as? String
    }
    
    //MARK:- Action
    @objc private func avatarTap(gestureRecognizer: UIGestureRecognizer) {
        routerEvent(name: kEventUserInfoAvatarTap, data: ["item": gestureRecognizer.view!])
    }
    
    @objc private func itemTap(gestureRecognizer: UIGestureRecognizer) {
        routerEvent(name: kEventUserInfoItemTap, data: ["item": gestureRecognizer.view!])
    }
}
