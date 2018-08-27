//
//  CollegeFilterView.swift
//  xxd
//
//  Created by remy on 2018/2/22.
//  Copyright © 2018年 com.smartstudy. All rights reserved.
//

private let kFilterBarHeight: CGFloat = 40
private let kBtnTitleTag = 1100
private let kBtnArrowTag = 1200

class CollegeFilterView: UIView {
    
    private var btnList = [UIView]()
    private var contentList = [UIView]()
    private var lastIndex = 0
    private var currentArrow: UIImage!
    private var countryFilter: CollegeFilterOptionsView!
    private var rankFilter: CollegeFilterOptionsView!
    private var othersFilter: CollegeFilterOthersView!
    private var isFirstPop: Bool = true
    private lazy var bgView: UIView = {
        let view: UIView = UIView(frame: self.bounds, color: UIColor.black.withAlphaComponent(0.4))
        view.height = XDSize.screenHeight - self.screenViewY
        view.isHidden = true
        view.layer.masksToBounds = true
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(eventResetBackgroundViewState)))
        return view
    }()
    private lazy var filterBgView: UIView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: XDSize.screenWidth, height: 0.0), color: UIColor.white)
    private lazy var filterTopBaseView: UIView = {
        let baseView: UIView = UIView(frame: CGRect(x: 0.0, y: kFilterBarHeight, width: XDSize.screenWidth, height: self.countryFilter.height), color: UIColor.white)
        baseView.isHidden = true
        return baseView
    }()
    private var events = [String]()
    var model: CollegeQueryModel! {
        didSet {
            countryFilter.value = model.countryID
            (btnList[0].viewWithTag(kBtnTitleTag) as! UILabel).text = countryFilter.text
            rankFilter.value = model.localRank
            (btnList[1].viewWithTag(kBtnTitleTag) as! UILabel).text = rankFilter.text
        }
    }
    
    convenience init() {
        self.init(frame: CGRect(x: 0, y: XDSize.topHeight, width: XDSize.screenWidth, height: kFilterBarHeight))
        backgroundColor = UIColor.clear
        addSubview(bgView)
        initBtnGroupView()
        
        countryFilter = CollegeFilterOptionsView()
        countryFilter.dataList = [["全球",""],["美国","COUNTRY_226"],["英国","COUNTRY_225"],["加拿大","COUNTRY_40"],["澳大利亚","COUNTRY_16"]]
        bgView.addSubview(filterTopBaseView)
        bgView.addSubview(filterBgView)
        filterBgView.addSubview(countryFilter)
        contentList.append(countryFilter)
        
        rankFilter = CollegeFilterOptionsView()
        rankFilter.dataList = [["前10名",",10"],["前30名",",30"],["前50名",",50"],["前100名",",100"],["综合排名",""]]
        filterBgView.addSubview(rankFilter)
        contentList.append(rankFilter)
        
        othersFilter = CollegeFilterOthersView(titles: ["语言成绩类别","托福要求","雅思要求","年花费（单位：美元）"])
        var arr = [[[String]]]()
        arr.append([["托福","toefl","1"],["雅思","ielts","2"]])
        arr.append([["80分以下",",80"],["80-90","80,90"],["90-100","90,100"],["100分以上","100,"],["不限",""]])
        arr.append([["5.5分以下",",5.5"],["5.5-6.5","5.5,6.5"],["6.5-7.5","6.5,7.5"],["7.5分以上","7.5,"],["不限",""]])
        arr.append([["2万以下",",19999"],["2-3万","20000,29999"],["3-4万","30000,39999"],["4万以上","40000,"],["不限",""]])
        othersFilter.heightClosure = { [weak self] (updatedHeight) in
            self?.filterBgView.height = updatedHeight
        }
        othersFilter.dataList = arr
        filterBgView.addSubview(othersFilter)
        contentList.append(othersFilter)
        
        currentArrow = UIImage(named: "down")!.tint(XDColor.main)
        
        events = ["9_A_country_change_btn","9_A_rank_change_btn","9_A_more_change_btn"]
    }
    
    private func initBtnGroupView() {
        let btnWidth = (width / 3).rounded(.up)
        for i in 0..<3 {
            let btnView = UIView(frame: CGRect(x: btnWidth * CGFloat(i), y: 0, width: btnWidth, height: kFilterBarHeight), color: UIColor.clear)
            btnView.backgroundColor = UIColor.white
            btnView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(filterBtnTap(gestureRecognizer:))))
            self.addSubview(btnView)
            btnList.append(btnView)
            var titleText = ""
            if i == 2 {
                titleText = "更多筛选"
            }
            let titleLabel = UILabel(text: titleText, textColor: XDColor.itemTitle, fontSize: 14)!
            titleLabel.tag = kBtnTitleTag
            btnView.addSubview(titleLabel)
            titleLabel.snp.makeConstraints { (make) in
                make.centerY.equalTo(btnView)
                make.centerX.equalTo(btnView).offset(-6)
            }
            
            let arrow = UIImageView(frame: .zero, imageName: "down")!
            arrow.tag = kBtnArrowTag
            arrow.transform = CGAffineTransform.identity
            btnView.addSubview(arrow)
            arrow.snp.makeConstraints { (make) in
                make.centerY.equalTo(btnView)
                make.left.equalTo(titleLabel.snp.right).offset(6)
            }
            
            if i > 0 {
                let line = UIView(frame: CGRect(x: btnWidth * CGFloat(i), y: 12, width: 1.0, height: kFilterBarHeight - 24), color: XDColor.itemLine)
                self.addSubview(line)
            }
        }
        self.addSubview(UIView(frame: CGRect(x: 0, y: kFilterBarHeight - XDSize.unitWidth, width: XDSize.screenWidth, height: XDSize.unitWidth), color: XDColor.mainLine))
    }
    
    //MARK:- Action
    override func routerEvent(name: String, data: Dictionary<String, Any>) {
        if name == kEventCollegeFilterOptionChange {
            let titleLabel = btnList[lastIndex].viewWithTag(kBtnTitleTag) as! UILabel
            if lastIndex == 0 {
                model.countryID = countryFilter.value
                titleLabel.text = countryFilter.text
            } else if lastIndex == 1 {
                model.localRank = rankFilter.value
                titleLabel.text = rankFilter.text
            }
        } else if name == kEventCollegeFilterOthersChange {
            let values = othersFilter.values
            model.scoreToefl = values[1]
            model.scoreIelts = values[2]
            model.feeTotal = values[3]
        }
        eventResetBackgroundViewState()
        super.routerEvent(name: name, data: data)
    }
    
    func hideTap(_ isClose: Bool) {
        let lastBtn = btnList[lastIndex]
        let label = lastBtn.viewWithTag(kBtnTitleTag) as! UILabel
        let arrow = lastBtn.viewWithTag(kBtnArrowTag) as! UIImageView
        // 更多筛选有选择数据时一直显示高亮
        let isActive = lastIndex == 2 && !othersFilter.isEmpty
        if !isActive {
            label.textColor = XDColor.itemTitle
            arrow.image = UIImage(named: "down")
        }
        arrow.transform = CGAffineTransform.identity
        contentList[lastIndex].isHidden = true
        if isClose {
            bgView.isHidden = true
            height = kFilterBarHeight
        }
    }
    
    @objc private func eventResetBackgroundViewState() {
        hideTap(true)
        filterTopBaseView.isHidden = true
        isFirstPop = true
    }
    
    @objc func filterBtnTap(gestureRecognizer: UIGestureRecognizer) {
        let btn = gestureRecognizer.view!
        let index = btnList.index(of: btn)!
        XDStatistics.click(events[index])
        if lastIndex != index {
            if !isFirstPop {
                hideTap(false)
            }
            lastIndex = index
        }
        if contentList[index].isHidden {
            let label = btn.viewWithTag(kBtnTitleTag) as! UILabel
            label.textColor = XDColor.main
            let arrow = btn.viewWithTag(kBtnArrowTag) as! UIImageView
            arrow.image = currentArrow
            arrow.transform = CGAffineTransform(rotationAngle: CGFloat.pi)
            contentList[index].isHidden = false
            if isFirstPop {
                filterBgView.top = -contentList[index].height
                filterBgView.height = contentList[index].height
                UIView.animate(withDuration: 0.25) {
                    self.filterBgView.top += (self.contentList[index].height + kFilterBarHeight)
                }
            } else {
                let topSpace: CGFloat = filterBgView.height - contentList[index].height
                if filterBgView.height > contentList[index].height {
                    self.filterTopBaseView.isHidden = false
                }
                filterBgView.top += topSpace
                filterBgView.height = contentList[index].height
                UIView.animate(withDuration: 0.15) {
                    self.filterBgView.top -= topSpace
                }
            }
            isFirstPop = false
            bgView.isHidden = false
            height = bgView.height
        } else {
            eventResetBackgroundViewState()
        }
    }
}
