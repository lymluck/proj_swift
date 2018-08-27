//
//  ArtMajorFilterView.swift
//  xxd
//
//  Created by Lisen on 2018/7/6.
//  Copyright © 2018年 com.smartstudy. All rights reserved.
//

import UIKit

private let kButtonTag = 1000

@objc protocol ArtMajorFilterViewDelegate {
    func artMajorFilterViewDidSelect(option: [String: String])
}

/// 艺术院校筛选视图
class ArtMajorFilterView: UIView {
    
    weak var delegate: ArtMajorFilterViewDelegate?
    var countryOptions: [[String]] = [[]] {
        didSet {
            countryFilterView.dataList = countryOptions
        }
    }
    var degreeOptions: [[String]] = [[]] {
        didSet {
            degreeFilterView.dataList = degreeOptions
        }
    }
    var selectedCountry: String = "" {
        didSet {
            countryFilterView.value = selectedCountry
            configureFilterButton(button: countryBtn, title: countryFilterView.text)
        }
    }
    var selectedDegree: String = "" {
        didSet {
            degreeFilterView.value = selectedDegree
            configureFilterButton(button: degreeBtn, title: degreeFilterView.text)
        }
    }
    private var bgView: UIControl!
    private var lastBtn: UIButton?
    private var countryBtn: UIButton = {
        let button: UIButton = UIButton(frame: CGRect(x: 0.0, y: 0.0, width: XDSize.screenWidth/2.0, height: XDSize.kFilterBarHeight))
        button.tag = kButtonTag
        return button
    }()
    private var degreeBtn: UIButton = {
        let button: UIButton = UIButton(frame: CGRect(x: XDSize.screenWidth/2.0, y: 0.0, width: XDSize.screenWidth/2.0, height: XDSize.kFilterBarHeight))
        button.tag = kButtonTag+1
        return button
    }()
    private lazy var countryFilterView: CollegeFilterOptionsView = CollegeFilterOptionsView()
    private lazy var degreeFilterView: CollegeFilterOptionsView = CollegeFilterOptionsView()
    
    convenience init() {
        self.init(frame: CGRect(x: 0, y: XDSize.topHeight, width: XDSize.screenWidth, height: XDSize.kFilterBarHeight))
        initContentViews()
    }
    
    override func routerEvent(name: String, data: Dictionary<String, Any>) {
        if name == kEventCollegeFilterOptionChange {
            guard let selectedBtn = lastBtn else { return }
            var option: [String:String] = ["": ""]
            var buttonTitle: String = ""
            if selectedBtn.tag == kButtonTag {
                buttonTitle = countryFilterView.text
                option = ["countryId": countryFilterView.value]
            } else {
                buttonTitle = degreeFilterView.text
                option = ["degreeId": degreeFilterView.value]
            }
            selectedBtn.setTitle(buttonTitle, for: .normal)
            let titleWidth = ceil(buttonTitle.widthForFont(UIFont.systemFont(ofSize: 14.0)))
            selectedBtn.imageEdgeInsets = UIEdgeInsets(top: 0.0, left: titleWidth+3.0, bottom: 0.0, right: -(titleWidth+3.0))
            hideFilterView()
            guard let _ = delegate?.artMajorFilterViewDidSelect(option: option) else { return }
        }
    }
    
    @objc private func eventBackgroundViewTapResponse(_ gesture: UITapGestureRecognizer) {
        hideFilterView()
    }
    
    @objc private func eventButtonResponse(_ sender: UIButton) {
        let index: Int = sender.tag - kButtonTag
        if let lastBtn = lastBtn, lastBtn == sender {
            sender.isSelected = false
            self.lastBtn = nil
            hideFilterView()
            return
        }
        lastBtn?.isSelected = false
        sender.isSelected = true
        lastBtn = sender
        countryFilterView.isHidden = (index == 1)
        degreeFilterView.isHidden = (index == 0)
        bgView.isHidden = false
        height = bgView.height
    }
    
    private func initContentViews() {
        backgroundColor = UIColor.clear
        bgView = UIControl(frame: bounds)
        bgView.height = XDSize.screenHeight - self.screenViewY
        bgView.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        bgView.isHidden = true
        bgView.layer.masksToBounds = true
        bgView.addTarget(self, action: #selector(eventBackgroundViewTapResponse(_:)), for: .touchUpInside)
        addSubview(bgView)
        addSubview(countryBtn)
        addSubview(degreeBtn)
        addSubview(countryFilterView)
        addSubview(degreeFilterView)
        addSubview(UIView(frame: CGRect(x: width/2.0, y: 12.0, width: 0.5, height: 16.0), color: UIColor(0xC4C9CC)))
        addSubview(UIView(frame: CGRect(x: 0.0, y: height-0.5, width: width, height: 0.5), color: XDColor.itemLine))
    }
    
    private func configureFilterButton(button: UIButton, title: String) {
        button.backgroundColor = UIColor.white
        button.setTitle(title, for: .normal)
        button.setTitleColor(UIColor(0x26343F), for: .normal)
        button.setTitleColor(UIColor(0x078CF1), for: .selected)
        button.setImage(UIImage(named: "down"), for: .normal)
        button.setImage(UIImage(named: "up")?.tint(XDColor.main), for: .selected)
        button.titleEdgeInsets = UIEdgeInsets(top: 0.0, left: -15.0, bottom: 0.0, right: 15.0)
        let titleWidth = ceil(title.widthForFont(UIFont.systemFont(ofSize: 14.0)))
        button.imageEdgeInsets = UIEdgeInsets(top: 0.0, left: titleWidth+3.0, bottom: 0.0, right: -(titleWidth+3.0))
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14.0)
        button.addTarget(self, action: #selector(eventButtonResponse(_:)), for: .touchUpInside)
    }
    
    private func hideFilterView() {
            lastBtn?.isSelected = false
            countryFilterView.isHidden = true
            degreeFilterView.isHidden =  true
            bgView.isHidden = true
            height = XDSize.kFilterBarHeight
            lastBtn = nil
    }
}
