//
//  TranspondViewHeaderSection.swift
//  counselor_t
//
//  Created by chenyusen on 2018/2/9.
//  Copyright © 2018年 TechSen. All rights reserved.
//

import UIKit

class TranspondViewHeaderSection: SectionView {

    var titleLabel: UILabel!
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        contentView.backgroundColor = UIColor(0xF6F7F8)
        
        titleLabel = UILabel(frame: CGRect.zero, text: nil, textColor: UIColor(0x949BA1), fontSize: 12)
        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.left.equalTo(16)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func updateSection(sectionItem: SectionItem?) {
        if let title = sectionItem?.model as? String {
            titleLabel.text = title
        }
    }

}
