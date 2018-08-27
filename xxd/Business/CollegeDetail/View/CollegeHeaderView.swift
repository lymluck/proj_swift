//
//  CollegeHeaderView.swift
//  xxd
//
//  Created by remy on 2018/2/24.
//  Copyright © 2018年 com.smartstudy. All rights reserved.
//

public class CollegeRankView: UIImageView {
    
    private var titleLabel: UILabel!
    private var rankLabel: UILabel!
    var title = "" {
        didSet {
            titleLabel.text = title
        }
    }
    var rank = 0 {
        didSet {
            rankLabel.text = rank > 0 ? "\(rank)" : "暂无"
        }
    }
    
    convenience init() {
        self.init(frame: .zero)
        image = UIImage(named: "school_rank_bg_flag")
        
        let lineView = UIView(frame: .zero, color: UIColor.white.withAlphaComponent(0.4))
        addSubview(lineView)
        lineView.snp.makeConstraints { (make) in
            make.top.equalTo(self).offset(20)
            make.left.right.equalTo(self)
            make.height.equalTo(XDSize.unitWidth)
        }
        
        titleLabel = UILabel(text: "", textColor: UIColor.white, fontSize: 10)
        addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (make) in
            make.centerX.equalTo(self)
            make.top.equalTo(self).offset(5)
        }
        
        rankLabel = UILabel(text: "", textColor: UIColor.white, fontSize: 17)
        rankLabel.font = UIFont.boldNumericalFontOfSize(17)
        addSubview(rankLabel)
        rankLabel.snp.makeConstraints { (make) in
            make.centerX.equalTo(self)
            make.top.equalTo(lineView.snp.bottom).offset(4)
        }
    }
    
}

class CollegeHeaderView: UIView {
    
    private var backgroundView: UIImageView!
    private var logo: UIImageView!
    private var localRankView: CollegeRankView!
    private var worldRankView: CollegeRankView!
    private var chineseName: UILabel!
    private var englishName: UILabel!
    private var address: UILabel!
    private var cover: CAGradientLayer!
    var isHiddenName = false {
        didSet {
            chineseName.isHidden = isHiddenName
        }
    }
    var model: CollegeCommonInfo! {
        didSet {
            backgroundView.setAutoOSSImage(urlStr: model.coverURL)
            logo.setAutoOSSImage(urlStr: model.logoURL, policy: .pad)
            chineseName.text = model.chineseName
            englishName.text = model.englishName
            address.text = model.cityPath
            localRankView.rank = model.localRank
            worldRankView.rank = model.worldRank
        }
    }
    
    convenience init() {
        self.init(frame: CGRect(x: 0, y: 0, width: XDSize.screenWidth, height: 284))
        
        // 背景
        backgroundView = UIImageView(frame: bounds)
        addSubview(backgroundView)
        
        // 蒙层
        cover = CAGradientLayer()
        cover.frame = bounds
        cover.colors = [UIColor.black.withAlphaComponent(0.3).cgColor, UIColor.black.withAlphaComponent(0.7).cgColor]
        cover.startPoint = CGPoint(x: 0, y: 0)
        cover.endPoint = CGPoint(x: 0, y: 1)
        layer.addSublayer(cover)
        
        // logo
        let logoWrap = UIView(frame: CGRect(x: (XDSize.screenWidth - 109) * 0.5, y: 64, width: 109, height: 109))
        logoWrap.backgroundColor = UIColor.white
        logoWrap.layer.cornerRadius = 54.5
        addSubview(logoWrap)
        logo = UIImageView(frame: CGRect(x: 12, y: 12, width: 85, height: 85))
        logo.layer.cornerRadius = 42.5
        logo.layer.masksToBounds = true
        logoWrap.addSubview(logo)
        
        // 中文名
        chineseName = UILabel(frame: .zero, text: "", textColor: UIColor.white, fontSize: 23, bold: true)
        addSubview(chineseName)
        chineseName.snp.makeConstraints { (make) in
            make.centerX.equalTo(self)
            make.centerY.equalTo(self.snp.top).offset(206)
        }
        
        // 英文名
        englishName = UILabel(text: "", textColor: UIColor.white, fontSize: 14)
        addSubview(englishName)
        englishName.snp.makeConstraints { (make) in
            make.centerX.equalTo(self)
            make.top.equalTo(self).offset(222)
            make.width.lessThanOrEqualTo(XDSize.screenWidth - 32)
        }
        
        // 地址
        address = UILabel(text: "", textColor: UIColor.white.withAlphaComponent(0.6), fontSize: 13)
        addSubview(address)
        address.snp.makeConstraints { (make) in
            make.centerX.equalTo(self)
            make.top.equalTo(self).offset(248)
        }
        
        // 国内排名
        localRankView = CollegeRankView()
        localRankView.title = "school_detail_header_country_rank_title".localized
        addSubview(localRankView)
        localRankView.snp.makeConstraints { (make) in
            make.right.equalTo(logoWrap.snp.left).offset(-45)
            make.top.equalTo(self).offset(95)
        }
        
        // 世界排名
        worldRankView = CollegeRankView()
        worldRankView.title = "school_detail_header_intl_rank_title".localized
        addSubview(worldRankView)
        worldRankView.snp.makeConstraints { (make) in
            make.left.equalTo(logoWrap.snp.right).offset(45)
            make.top.equalTo(self).offset(95)
        }
    }
}
