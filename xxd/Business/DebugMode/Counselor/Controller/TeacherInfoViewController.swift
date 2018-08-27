//
//  TeacherInfoViewController.swift
//  xxd
//
//  Created by chenyusen on 2018/3/9.
//  Copyright © 2018年 com.smartstudy. All rights reserved.
//

import UIKit

/// 教师主页的头部视图
private class TeacherInfoViewHeader: UIView {
    private var avatarView: UIImageView!
    private var nameLabel: UILabel!
    private var titleLabel: NoAdjustColorLabel!
    private var workYearLabel: NoAdjustColorLabel!
    private var actionButton: UIButton!
    
    func add(target: AnyObject, action: Selector) {
        actionButton.addTarget(target, action: action, for: .touchUpInside)
    }
    
    func bind(name: String?, avatarUrl: String?, title: String?, workYear: String?) {
        avatarView.kf.setImage(with: URL(string: avatarUrl ?? ""))
        nameLabel.text = name
        if let title = title {
            titleLabel.text = "   " + title + "   "
        }
        if let workYeaer = workYear {
            workYearLabel.text = "   从业" + workYeaer + "年   "
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
      
        actionButton = UIButton()
        addSubview(actionButton)
        actionButton.setBackgroundColor(UIColor.white, for: .normal)
        actionButton.setBackgroundColor(UIColor(0xF2F2F2), for: .highlighted)
        actionButton.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        avatarView = UIImageView()
        avatarView.layer.cornerRadius = 25
        avatarView.clipsToBounds = true
        addSubview(avatarView)
        avatarView.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.left.equalTo(16)
            make.size.equalTo(CGSize(width: 50, height: 50))
        }
        
        nameLabel = UILabel()
        nameLabel.font = UIFont.systemFont(ofSize: 17)
        nameLabel.textColor = UIColor(0x26343F)
        addSubview(nameLabel)
        nameLabel.snp.makeConstraints { (make) in
            make.top.equalTo(23)
            make.left.equalTo(82)
            make.width.lessThanOrEqualTo(XDSize.screenWidth - 130)
        }
        
        titleLabel = NoAdjustColorLabel()
        titleLabel.textColor = .white
        titleLabel.layer.cornerRadius = 9
        titleLabel.clipsToBounds = true
        titleLabel.font = UIFont.systemFont(ofSize: 11)
        titleLabel.customBackgroundColor = UIColor(0x77C4FF)
        addSubview(titleLabel)
        titleLabel.snp.makeConstraints({ (make) in
            make.left.equalTo(82)
            make.top.equalTo(50)
            make.height.equalTo(18)
            make.width.lessThanOrEqualTo(150)
        })
        
        workYearLabel = NoAdjustColorLabel()
        workYearLabel.textColor = .white
        workYearLabel.layer.cornerRadius = 9
        workYearLabel.clipsToBounds = true
        workYearLabel.font = UIFont.systemFont(ofSize: 11)
        workYearLabel.customBackgroundColor = UIColor(0xA5D7AC)
        addSubview(workYearLabel)
        workYearLabel.snp.makeConstraints({ (make) in
            make.left.equalTo(titleLabel.snp.right).offset(4)
            make.top.equalTo(50)
            make.height.equalTo(18)
            make.width.lessThanOrEqualTo(150)
        })
        
        let arrowView = UIImageView(image: UIImage(named: "item_right_arrow"))
        addSubview(arrowView)
        arrowView.snp.makeConstraints { (make) in
            make.right.equalTo(-16)
            make.centerY.equalToSuperview()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private class TeacherInfoCompanyView: UIView {
    private var logoView: UIImageView!
    private var companyNameLabel: UILabel!
    private var descLabel: UILabel!
    private var actionButton: UIButton!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
        
        actionButton = UIButton()
        addSubview(actionButton)
        actionButton.setBackgroundColor(UIColor.white, for: .normal)
        actionButton.setBackgroundColor(UIColor(0xF2F2F2), for: .highlighted)
        actionButton.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        logoView = UIImageView()
        logoView.layer.borderColor = UIColor(0xC4C9CC).cgColor
        logoView.layer.borderWidth = XDSize.unitWidth
        logoView.layer.cornerRadius = 25
        logoView.clipsToBounds = true
        addSubview(logoView)
        
        logoView.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.left.equalTo(16)
            make.size.equalTo(CGSize(width: 50, height: 50))
        }
        
        companyNameLabel = UILabel()
        companyNameLabel.textColor = UIColor(0x26343F)
        companyNameLabel.font = UIFont.systemFont(ofSize: 17)
        addSubview(companyNameLabel)
        companyNameLabel.snp.makeConstraints { (make) in
            make.left.equalTo(82)
            make.top.equalTo(26)
        }
        
        descLabel = UILabel()
        descLabel.textColor = UIColor(0x949BA1)
        descLabel.font = UIFont.systemFont(ofSize: 13)
        addSubview(descLabel)
        descLabel.snp.makeConstraints { (make) in
            make.left.equalTo(82)
            make.top.equalTo(53)
        }
        
        let arrowView = UIImageView(image: UIImage(named: "item_right_arrow"))
        addSubview(arrowView)
        arrowView.snp.makeConstraints { (make) in
            make.right.equalTo(-16)
            make.centerY.equalToSuperview()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func add(target: AnyObject, action: Selector) {
        actionButton.addTarget(target, action: action, for: .touchUpInside)
    }
    
    func bind(logoUrl: String?, companyName: String?, desc: String?) {
        logoView.kf.setImage(with:URL(string: logoUrl ?? ""))
        companyNameLabel.text = companyName
        descLabel.text = desc
    }
}

private class TeacherInfoNormalView: UIView {
    private var titleLabel: UILabel!
    private var actionButton: UIButton!
    
    init(frame: CGRect, title: String) {
        super.init(frame: frame)
        backgroundColor = .white
        
        actionButton = UIButton()
        addSubview(actionButton)
        actionButton.setBackgroundColor(UIColor.white, for: .normal)
        actionButton.setBackgroundColor(UIColor(0xF2F2F2), for: .highlighted)
        actionButton.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.textColor = UIColor(0x26343F)
        titleLabel.font = UIFont.systemFont(ofSize: 16)
        addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.left.equalTo(16)
        }
        
        
        let arrowView = UIImageView(image: UIImage(named: "item_right_arrow"))
        addSubview(arrowView)
        arrowView.snp.makeConstraints { (make) in
            make.right.equalTo(-16)
            make.centerY.equalToSuperview()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func add(target: AnyObject, action: Selector) {
        actionButton.addTarget(target, action: action, for: .touchUpInside)
        actionButton.setBackgroundColor(UIColor(0xF2F2F2), for: .highlighted)
    }
    
    func bind(title: String) {
        titleLabel.text = title
    }
}

private class TeacherInfoSwitchView: UIView {
    private var titleLabel: UILabel!
    var aSwitch: UISwitch!
    
    init(frame: CGRect, title: String) {
        super.init(frame: frame)
        backgroundColor = .white
        titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.textColor = UIColor(0x26343F)
        titleLabel.font = UIFont.systemFont(ofSize: 16)
        addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.left.equalTo(16)
        }
        
        aSwitch = UISwitch()
        aSwitch.onTintColor = UIColor(0x0081f8)
        addSubview(aSwitch)
        aSwitch.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.right.equalTo(-16)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

class TeacherInfoViewController: BaseViewController {
    
    var userId: String!
    
    override init(query: [String : Any]?) {
        super.init(query: query)
        userId = query?[IMUserID] as? String
        assert(userId != nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "聊天详情"
        
        let container = UIView()
        scrollView.addSubview(container)
        container.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
            make.width.equalToSuperview()
        }
        
        let header = TeacherInfoViewHeader()
        container.addSubview(header)
        header.add(target: self, action: #selector(headerDidPressed))
        header.snp.makeConstraints { (make) in
            make.top.equalTo(12)
            make.left.right.equalToSuperview()
            make.height.equalTo(90)
        }
        
        let company = TeacherInfoCompanyView()
        container.addSubview(company)
        company.add(target: self, action: #selector(companyDidPressed))
        company.snp.makeConstraints { (make) in
            make.top.equalTo(header.snp.bottom).offset(12)
            make.left.right.equalToSuperview()
            make.height.equalTo(90)
        }
        
        let blackListSwitchView = TeacherInfoSwitchView(frame: CGRect.zero, title: "将对方加入黑名单")
        container.addSubview(blackListSwitchView)
        blackListSwitchView.snp.makeConstraints { (make) in
            make.top.equalTo(company.snp.bottom).offset(12)
            make.left.right.equalToSuperview()
            make.height.equalTo(64)
        }
        
        CounselorIM.shared.getBlacklistStatus(targetId: userId) { [weak self] (isIn) in
            guard let sSelf = self else { return }
            blackListSwitchView.aSwitch.isOn = isIn
            blackListSwitchView.aSwitch.addTarget(sSelf, action: #selector(sSelf.switchStatusChanged(_:)), for: .valueChanged)
        }
        
        let divider = UIView()
        divider.backgroundColor = UIColor(0xE4E5E6)
        container.addSubview(divider)
        divider.snp.makeConstraints { (make) in
            make.height.equalTo(XDSize.unitWidth)
            make.left.right.equalToSuperview()
            make.top.equalTo(blackListSwitchView.snp.bottom)
        }

        let reportView = TeacherInfoNormalView(frame: CGRect.zero, title: "举报对方")
        container.addSubview(reportView)
        reportView.add(target: self, action: #selector(reportDidPressed))
        reportView.snp.makeConstraints { (make) in
            make.top.equalTo(divider.snp.bottom)
            make.left.right.equalToSuperview()
            make.height.equalTo(64)
            make.bottom.equalToSuperview()
        }

        container.addSubview(blackListSwitchView)
        
        TeacherInfoHelper.shared.teacherInfo(userId) { (info) in
            if let info = info {
                header.bind(name: info.name, avatarUrl: info.avatar, title: info.title, workYear: info.workYear)
                company.bind(logoUrl: info.companyLogo, companyName: info.company, desc: info.companySubTitle)
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
         super.viewDidAppear(animated)
        
    }
}

extension TeacherInfoViewController {
    @objc func switchStatusChanged(_ sender: UISwitch) {
        if sender.isOn {
            CounselorIM.shared.add(toBlackList: userId, completion: { (success) in
                if !success {
                    sender.isOn = !sender.isOn
                }
            })
        } else {
            CounselorIM.shared.remove(fromBlackList: userId, completion: { (success) in
                if !success {
                    sender.isOn = !sender.isOn
                }
            })
        }
        
    }
}


extension TeacherInfoViewController {
    @objc func headerDidPressed() {
        self.navigationController?.pushViewController(TeacherInfoDetailViewController(query: [IMUserID: userId]), animated: true)
//        let vc = CounsellorDetailViewController()
//        vc.counsellorID = userId
//        XDRoute.pushToVC(vc)
    }
    
    @objc func companyDidPressed() {
        self.navigationController?.pushViewController(TeacherCompanyViewController(query: [IMUserID: userId]), animated: true)
    }
    
    @objc func reportDidPressed() {
        self.navigationController?.pushViewController(TeacherReportViewController(query: [IMUserID: userId]), animated: true)
    }
    
}
