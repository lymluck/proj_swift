//
//  ChatNavigationCenterView.swift
//  counselor_t
//
//  Created by chenyusen on 2018/1/4.
//  Copyright © 2018年 TechSen. All rights reserved.
//

import UIKit

class ChatNavigationCenterView: UIView {
    
    private var nicknameLabel: UILabel!
    private var bottomContainer: UIView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        nicknameLabel = UILabel(frame: CGRect.zero, text: nil, textColor: UIColor(0x263540), fontSize: 17, bold: true)
        addSubview(nicknameLabel)
        nicknameLabel.textAlignment = .center
        nicknameLabel.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.left.greaterThanOrEqualTo(0)
            make.right.greaterThanOrEqualTo(0)
            make.centerX.equalToSuperview()
            make.width.lessThanOrEqualTo(200)
        }
        
        bottomContainer = UIView()
        addSubview(bottomContainer)
        bottomContainer.snp.makeConstraints { (make) in
            make.centerX.bottom.equalToSuperview()
            make.top.equalTo(nicknameLabel.snp.bottom)
        }
    }
    
    func bind(_ userInfo: TeacherInfo) {
        
        bottomContainer.removeAllSubviews()
        nicknameLabel.text = userInfo.name
        
        var tags: [String] = []
        if let company = userInfo.company, !company.isEmpty {
            tags.append(company)
        }
        
        
        var lastLabel: UILabel!
        for (index, tag) in tags.enumerated() {
            
            let label = UILabel(frame: CGRect.zero, text: nil, textColor: UIColor(0x949BA1), fontSize: 11)!
            label.text = tag
            bottomContainer.addSubview(label)
            label.snp.makeConstraints({ (make) in
                if index == 0 {
                    make.left.equalToSuperview()
                } else {
                    make.left.equalTo(lastLabel.snp.right).offset(12)
                }
                make.top.bottom.equalToSuperview()
                
                if index == tags.count - 1 {
                    make.right.equalToSuperview()
                }
            })
            if index != tags.count - 1 {
                let line = UIView()
                line.backgroundColor = UIColor(0xE4E5E6)
                bottomContainer.addSubview(line)
                line.snp.makeConstraints({ (make) in
                    make.left.equalTo(label.snp.right).offset(6)
                    make.width.equalTo(1)
                    make.height.equalTo(12)
                    make.centerY.equalToSuperview()
                })
            }
            lastLabel = label
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

