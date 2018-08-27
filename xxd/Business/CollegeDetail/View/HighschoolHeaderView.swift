//
//  HighschoolHeaderView.swift
//  xxd
//
//  Created by remy on 2018/4/3.
//  Copyright © 2018年 com.smartstudy. All rights reserved.
//

class HighschoolDetailHeaderView: UIView {
    
    private var rankView: CollegeRankView!
    private var chineseName: UILabel!
    private var englishName: UILabel!
    private var address: UILabel!
    var wrap: UIView!
    var model: HighschoolDetailModel! {
        didSet {
            chineseName.text = model.chineseName
            englishName.text = model.englishName
            address.text = model.cityPath
            rankView.rank = model.rank
        }
    }
    
    convenience init() {
        let space: CGFloat = UIDevice.isIPhoneX ? 24 : 0
        self.init(frame: CGRect(x: 0, y: 0, width: XDSize.screenWidth, height: 198 + space))
        
        // 背景
        let backgroundView = UIImageView(frame: bounds, imageName: "highschool_detail_bg")!
        backgroundView.contentMode = .scaleAspectFill
        addSubview(backgroundView)
        
        // 内容
        wrap = UIView(frame: CGRect(x: 0, y: space, width: XDSize.screenWidth, height: 198))
        addSubview(wrap)
        
        // 中文名
        chineseName = UILabel(frame: .zero, text: "", textColor: UIColor.white, fontSize: 23, bold: true)
        wrap.addSubview(chineseName)
        chineseName.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(16)
            make.top.equalToSuperview().offset(68)
            make.width.lessThanOrEqualTo(XDSize.screenWidth - 108)
        }
        
        // 英文名
        englishName = UILabel(text: "", textColor: UIColor.white, fontSize: 14)
        wrap.addSubview(englishName)
        englishName.snp.makeConstraints { (make) in
            make.left.equalTo(chineseName)
            make.top.equalTo(chineseName.snp.bottom).offset(4)
            make.width.lessThanOrEqualTo(XDSize.screenWidth - 108)
        }
        
        // 排名
        rankView = CollegeRankView()
        rankView.title = "FS关注度"
        wrap.addSubview(rankView)
        rankView.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-24)
            make.top.equalToSuperview().offset(62)
        }
        
        // flag
        let flag = UIImageView()
        flag.image = UIImage(named: "school_intro_website")
        wrap.addSubview(flag)
        flag.snp.makeConstraints { (make) in
            make.left.equalTo(chineseName)
            make.top.equalTo(englishName.snp.bottom).offset(25)
        }
        
        // 地址
        address = UILabel(text: "", textColor: UIColor.white.withAlphaComponent(0.6), fontSize: 13)
        wrap.addSubview(address)
        address.snp.makeConstraints { (make) in
            make.centerY.equalTo(flag)
            make.left.equalTo(flag.snp.right).offset(4)
            make.right.lessThanOrEqualToSuperview().offset(-24)
        }
    }
}
