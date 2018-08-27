//
//  CollegeDetailIntroView.swift
//  xxd
//
//  Created by remy on 2018/3/1.
//  Copyright © 2018年 com.smartstudy. All rights reserved.
//

class CollegeDetailIntroView: UIView {
    
    private var contentLabel: UILabel!
    private var headerView: CollegeDetailSectionHeaderView!
    private var footerView: CollegeDetailSectionFooterView!
    var model: CollegeDetailIntroModel! {
        didSet {
            contentLabel.setText(model.collegeIntro, lineHeight: 26)
            contentLabel.sizeToFit()
            footerView.top = contentLabel.bottom + 24
            height = footerView.bottom
        }
    }
    
    convenience init() {
        self.init(frame: CGRect(x: 0, y: 0, width: XDSize.screenWidth, height: 0))
        backgroundColor = UIColor.white
        
        headerView = CollegeDetailSectionHeaderView()
        headerView.type = .intro
        addSubview(headerView)
        
        contentLabel = UILabel(frame: CGRect(x: 16, y: headerView.bottom + 16, width: width - 32, height: 0), text: "", textColor: XDColor.itemTitle, fontSize: 16)
        contentLabel.numberOfLines = 10
        addSubview(contentLabel)
        
        footerView = CollegeDetailSectionFooterView()
        footerView.type = .intro
        addSubview(footerView)
    }
}
