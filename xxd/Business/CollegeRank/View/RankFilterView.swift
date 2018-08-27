//
//  RankFilterView.swift
//  xxd
//
//  Created by remy on 2018/4/23.
//  Copyright © 2018年 com.smartstudy. All rights reserved.
//

class RankFilterView: UIView {
    
    weak var wrap: UIView?
    var countryID: String = ""
    private var titleLabel: UILabel!
    private var arrow: UIImageView!
    lazy var filterBtn: UIView = {
        let view = UIView(frame: CGRect(x: XDSize.screenWidth - 108, y: XDSize.statusBarHeight, width: 108, height: XDSize.topBarHeight))
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(filterBtnTap(gestureRecognizer:))))
        return view
    }()
    private lazy var countryFilter: CollegeFilterOptionsView = {
        let view = CollegeFilterOptionsView()
        view.isHidden = false
        view.origin = .zero
        view.dataList = [["全球",""],["美国","COUNTRY_226"],["英国","COUNTRY_225"],["加拿大","COUNTRY_40"],["澳大利亚","COUNTRY_16"]]
        addSubview(view)
        return view
    }()
    private let dataList: [String : String] = ["COUNTRY_226": "美国",
                                               "COUNTRY_225": "英国",
                                               "COUNTRY_40": "加拿大",
                                               "COUNTRY_16": "澳大利亚"]
    
    convenience init() {
        self.init(frame: CGRect(x: 0, y: XDSize.topHeight, width: XDSize.screenWidth, height: XDSize.screenHeight - XDSize.topHeight))
        backgroundColor = UIColor.black.withAlphaComponent(0.4)
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(bgViewTap)))
        
        // 其他和全球不一样,不能直接用
        if XDUser.shared.userCountryType() != .other {
            countryID = XDUser.shared.model.targetCountryId
        }
        let titleText = dataList[countryID] ?? "全球"
        
        arrow = UIImageView(frame: .zero)
        arrow.image = UIImage(named: "down")!.tint(XDColor.main)
        arrow.transform = CGAffineTransform.identity
        filterBtn.addSubview(arrow)
        arrow.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().offset(-12)
        }
        
        titleLabel = UILabel(text: titleText, textColor: XDColor.main, fontSize: 14)
        filterBtn.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.right.equalTo(arrow.snp.left).offset(-4)
        }
    }

    //MARK:- Action
    override func routerEvent(name: String, data: Dictionary<String, Any>) {
        if name == kEventCollegeFilterOptionChange {
            countryID = countryFilter.value
            titleLabel.text = countryFilter.text
            super.routerEvent(name: name, data: data)
            hideTap()
        }
    }
    
    func hideTap() {
        arrow.transform = CGAffineTransform.identity
        self.removeFromSuperview()
    }
    
    @objc func bgViewTap() {
        hideTap()
    }

    // 显示/关闭意向国家切换
    @objc func filterBtnTap(gestureRecognizer: UIGestureRecognizer) {
        if let _ = self.superview {
            hideTap()
        } else {
            if let wrap = wrap {
                arrow.transform = CGAffineTransform(rotationAngle: CGFloat.pi)
                countryFilter.value = countryID
                wrap.addSubview(self)
            }
        }
    }
}
