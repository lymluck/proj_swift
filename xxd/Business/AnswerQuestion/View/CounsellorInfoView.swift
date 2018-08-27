//
//  CounsellorInfoView.swift
//  xxd
//
//  Created by remy on 2018/3/9.
//  Copyright © 2018年 com.smartstudy. All rights reserved.
//

import Kingfisher

class CounsellorInfoView: UIView {
    
    var model: CounsellorDetailModel!
    var topView: UIView!
    var schoolView: UIView!
    var orgView: UIView!
    var qaView: UIView!
    var answerCountLabel: UILabel!
    var answerCount = 0 {
        didSet {
            answerCountLabel.text = String(format: "answer_count".localized, answerCount)
        }
    }
    
    convenience init(model: CounsellorDetailModel) {
        self.init(frame: CGRect(x: 0, y: 0, width: XDSize.screenWidth, height: 0))
        backgroundColor = XDColor.mainBackground
        self.model = model
        addTopInfoView()
        addSchoolInfoView()
        addOrgInfoView()
        addQAInfoView()
        height = qaView.bottom
    }
    
    private func addTopInfoView() {
        topView = UIView(frame: CGRect(x: 0, y: 0, width: XDSize.screenWidth, height: 217), color: UIColor.white)
        addSubview(topView)
        // 头像
        let avatarView = UIImageView(frame: CGRect(x: (XDSize.screenWidth - 90) * 0.5, y: 20, width: 90, height: 90))
        avatarView.layer.cornerRadius = 45
        avatarView.layer.masksToBounds = true
        topView.addSubview(avatarView)
        avatarView.setAutoOSSImage(urlStr: model.avatarURL)
        // 名字
        let nameView = UILabel(frame: .zero, text: model.name, textColor: XDColor.itemTitle, fontSize: 20, bold: true)!
        topView.addSubview(nameView)
        nameView.snp.makeConstraints { (make) in
            make.centerX.equalTo(topView)
            make.top.equalTo(avatarView.snp.bottom).offset(16)
        }
        // 头衔+从业年数
        let infoView = UIView()
        topView.addSubview(infoView)
        infoView.snp.makeConstraints { (make) in
            make.centerX.equalTo(topView)
            make.top.equalTo(nameView.snp.bottom).offset(16)
        }
        let titleView = UILabel(text: "  \(model.title)  ", textColor: UIColor.white, fontSize: 11)!
        titleView.layer.cornerRadius = 9
        titleView.layer.masksToBounds = true
        titleView.backgroundColor = UIColor(0x77C4FF)
        infoView.addSubview(titleView)
        titleView.snp.makeConstraints { (make) in
            make.left.top.equalTo(infoView)
            make.height.equalTo(18)
        }
        let yearView = UILabel(text: "  \(String(format: "work_years".localized, model.yearsOfWorking))  ", textColor: UIColor.white, fontSize: 11)!
        yearView.layer.cornerRadius = 9
        yearView.layer.masksToBounds = true
        yearView.backgroundColor = UIColor(0xA5D7AC)
        infoView.addSubview(yearView)
        yearView.snp.makeConstraints { (make) in
            make.left.equalTo(titleView.snp.right).offset(4)
            make.top.height.equalTo(titleView)
            make.right.equalTo(infoView)
        }
    }
    
    private func addSchoolInfoView() {
        schoolView = UIView(frame: CGRect(x: 0, y: topView.bottom + 12, width: XDSize.screenWidth, height: 82), color: UIColor.white)
        addSubview(schoolView)
        // 标题
        let titleView = UILabel(frame: .zero, text: "毕业院校", textColor: XDColor.itemTitle, fontSize: 16, bold: true)!
        schoolView.addSubview(titleView)
        titleView.snp.makeConstraints { (make) in
            make.top.equalTo(schoolView).offset(20)
            make.left.equalTo(schoolView).offset(16)
            make.right.equalTo(schoolView).offset(-68)
        }
        // 学校
        let nameView = UILabel(frame: .zero, text: model.school, textColor: XDColor.itemText, fontSize: 14, bold: true)!
        schoolView.addSubview(nameView)
        nameView.snp.makeConstraints { (make) in
            make.top.equalTo(schoolView).offset(48)
            make.left.right.equalTo(titleView)
        }
        if model.schoolCertified {
            // 已认证
            let label = UILabel(text: "已认证", textColor: UIColor(0xFF9C08), fontSize: 12)!
            schoolView.addSubview(label)
            label.snp.makeConstraints { (make) in
                make.top.equalTo(schoolView).offset(50)
                make.right.equalTo(schoolView).offset(-16)
            }
            let schoolCertified = UIImageView(frame: CGRect(x: (XDSize.screenWidth - 90) * 0.5, y: 20, width: 24, height: 24))
            schoolView.addSubview(schoolCertified)
            schoolCertified.snp.makeConstraints { (make) in
                make.top.equalTo(schoolView).offset(20)
                make.centerX.equalTo(label)
            }
        }
    }
    
    private func addOrgInfoView() {
        orgView = UIView(frame: CGRect(x: 0, y: schoolView.bottom + 12, width: XDSize.screenWidth, height: 112), color: UIColor.white)
        addSubview(orgView)
        // 标题
        let titleView = UILabel(frame: .zero, text: "所在组织", textColor: XDColor.itemTitle, fontSize: 16, bold: true)!
        orgView.addSubview(titleView)
        titleView.snp.makeConstraints { (make) in
            make.top.equalTo(orgView).offset(20)
            make.left.equalTo(orgView).offset(16)
        }
        // logo
        let logoView = UIImageView(frame: CGRect(x: 16, y: 52, width: 40, height: 40))
        logoView.layer.cornerRadius = 20
        logoView.layer.masksToBounds = true
        orgView.addSubview(logoView)
        logoView.setAutoOSSImage(urlStr: model.orgLogoURL)
        // 组织
        let nameView = UILabel(text: model.school, textColor: XDColor.itemTitle, fontSize: 14)!
        orgView.addSubview(nameView)
        nameView.snp.makeConstraints { (make) in
            make.top.equalTo(orgView).offset(57)
            make.left.equalTo(orgView).offset(68)
            make.right.equalTo(orgView).offset(-16)
        }
        // 描述
        let descView = UILabel(text: model.school, textColor: XDColor.itemText, fontSize: 12)!
        orgView.addSubview(descView)
        descView.snp.makeConstraints { (make) in
            make.top.equalTo(orgView).offset(77)
            make.left.right.equalTo(nameView)
        }
    }
    
    private func addQAInfoView() {
        qaView = UIView(frame: CGRect(x: 0, y: orgView.bottom + 12, width: XDSize.screenWidth, height: 56), color: UIColor.white)
        addSubview(qaView)
        qaView.addSubview(UIView(frame: CGRect(x: 0, y: qaView.height - XDSize.unitWidth, width: XDSize.screenWidth, height: XDSize.unitWidth), color: XDColor.itemLine))
        // 标题
        let titleView = UILabel(frame: .zero, text: "答疑", textColor: XDColor.itemTitle, fontSize: 16, bold: true)!
        qaView.addSubview(titleView)
        titleView.snp.makeConstraints { (make) in
            make.centerY.equalTo(qaView)
            make.left.equalTo(qaView).offset(16)
        }
        // 答疑数量
        answerCountLabel = UILabel(text: "", textColor: XDColor.itemText, fontSize: 14)
        qaView.addSubview(answerCountLabel)
        answerCountLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(qaView)
            make.right.equalTo(qaView).offset(-16)
        }
    }
}
