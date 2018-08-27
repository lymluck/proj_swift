//
//  TargetCollegeNoticeView.swift
//  xxd
//
//  Created by remy on 2018/2/2.
//  Copyright © 2018年 com.smartstudy. All rights reserved.
//

class TargetCollegeNoticeView: UIView {
    
    var noticeDesc: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor(0xFFFBC1)
        
        let notice = UIImageView(frame: CGRect(x: 16, y: 12, width: 20, height: 20), imageName: "target_notice")!
        addSubview(notice)
        
        let desc = String(format: "user_target_notice".localized, XDUser.shared.model.targetCountryName)
        noticeDesc = UILabel(frame: CGRect(x: 41, y: 0, width: XDSize.screenWidth - 57, height: 44), text: desc, textColor: XDColor.itemTitle, fontSize: 13)
        addSubview(noticeDesc)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
