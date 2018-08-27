//
//  TeacherCompanyViewController.swift
//  xxd
//
//  Created by chenyusen on 2018/3/9.
//  Copyright © 2018年 com.smartstudy. All rights reserved.
//

import UIKit

fileprivate class ContentView: UIView {
    
    var scrollView: UIScrollView!
    var contentLabel: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
        layer.cornerRadius = 4
//        clipsToBounds = true
        layer.shadowRadius = 10
        layer.shadowColor = UIColor.black.withAlphaComponent(0.2).cgColor
        layer.shadowOffset = CGSize(width: 0, height: 10)
        layer.shadowOpacity = 5
        
        
        let titleLabel = UILabel()
        titleLabel.text = "公司介绍"
        titleLabel.font = UIFont.boldSystemFont(ofSize: 18)
        addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.top.equalTo(32)
        }
        
        let block = UIView()
        block.backgroundColor = UIColor(0xE4E5E6)
        addSubview(block)
        block.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.top.equalTo(titleLabel.snp.bottom).offset(14)
            make.size.equalTo(CGSize(width: 24, height: 3))
        }
        
        scrollView = UIScrollView()
        addSubview(scrollView)
        scrollView.snp.makeConstraints { (make) in
            make.left.equalTo(24)
            make.right.equalTo(-24)
            make.top.equalTo(81)
            make.bottom.equalTo(-20)
        }
        
        if UIDevice.isIPhoneX {
            scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 34, right: 0)
            scrollView.scrollIndicatorInsets = scrollView.contentInset
        }
        
        let container = UIView()
        scrollView.addSubview(container)
        container.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
            make.width.equalToSuperview()
        }
        
        contentLabel = UILabel()
        contentLabel.font = UIFont.systemFont(ofSize: 15)
        contentLabel.textColor = UIColor(0x58646E)
        contentLabel.numberOfLines = 0
        container.addSubview(contentLabel)
        
        contentLabel.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }
    
    func bind(content: String?) {
        contentLabel.setText(content ?? "", lineHeight: 24)
    }
    
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class TeacherCompanyViewController: BaseViewController {

    var userId: String!
    
    override init(query: [String : Any]?) {
        super.init(query: query)
        userId = query?[IMUserID] as? String
        
        assert(userId != nil)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationBar?.transparent = true
        navigationBar?.itemTintColor = .white
        
        let bgImageView = UIImageView(image: UIImage(named: "im_teacher_company_bg"))
        view.addSubview(bgImageView)
        bgImageView.snp.makeConstraints { (make) in
            make.left.right.top.equalToSuperview()
            make.height.equalTo(281)
        }
        
        let logoView = UIImageView()
        logoView.layer.cornerRadius = 45
        logoView.clipsToBounds = true
        logoView.backgroundColor = .white
        view.addSubview(logoView)
        
        logoView.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.top.equalTo(84)
            make.size.equalTo(CGSize(width: 90, height: 90))
        }
        
        let companyNameLabel = UILabel()
        companyNameLabel.textColor = .white
        companyNameLabel.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        view.addSubview(companyNameLabel)
        companyNameLabel.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.top.equalTo(logoView.snp.bottom).offset(16)
        }
        
        let subTitleLabel = UILabel()
        subTitleLabel.textColor = UIColor.white.withAlphaComponent(0.7)
        subTitleLabel.font = UIFont.systemFont(ofSize: 13)
        view.addSubview(subTitleLabel)
        subTitleLabel.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.top.equalTo(companyNameLabel.snp.bottom).offset(8)
        }
        
        
        let contentView = ContentView()
        
        view.addSubview(contentView)
        contentView.snp.makeConstraints { (make) in
            make.left.equalTo(16)
            make.right.equalTo(-16)
            make.top.equalTo(bgImageView.snp.bottom).offset(-18)
            make.bottom.equalToSuperview().offset(20)
            
        }
        
        TeacherInfoHelper.shared.teacherInfo(userId, needCompany: true) { (info) in
            if let info = info {
                logoView.kf.setImage(with: URL(string: info.companyLogo ?? ""))
                companyNameLabel.text = info.company
                subTitleLabel.text = info.companySubTitle
                contentView.bind(content: info.companyDesc)
                
            }
        }
        
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
}
