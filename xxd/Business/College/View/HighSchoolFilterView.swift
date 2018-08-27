//
//  HighSchoolFilterView.swift
//  xxd
//
//  Created by Lisen on 2018/4/7.
//  Copyright © 2018年 com.smartstudy. All rights reserved.
//

import UIKit

private let kFilterBarHeight: CGFloat = 40.0

@objc protocol HighSchoolFilterViewDelegate {
    func highSchoolFilterView(select params: Dictionary<String, Any>)
}

/// 美高院校头部的筛选视图
class HighSchoolFilterView: UIView {
    // MARK: properties
    weak var delegate: HighSchoolFilterViewDelegate?
    private let btnWidth: CGFloat = UIScreen.main.bounds.width / 3.0
    private let kViewTag: Int = 10000
    private var lastIndex = 0
    private var lastBtn: UIButton?
    private var contentList = [UIView]()
    private var isFirstPop: Bool = true
    private lazy var rankHeight: CGFloat = {
        if (UIScreen.isP4 || UIScreen.isP35) {
            return 324.0
        }
        return 504.0
    }()
    private lazy var adaptOptionHeight: CGFloat = {
        if (UIScreen.isP4 || UIScreen.isP35) {
            return 266.0 + 43.0
        }
        return 266.0
    }()
    private var lastOptionSel: (String, String) = ("", "") {
        didSet {
            if lastOptionSel.0.isEmpty && lastOptionSel.1.isEmpty {
                optionsBtn.setTitleColor(UIColor(0x26343F), for: .normal)
            } else {
                optionsBtn.setTitleColor(UIColor(0x078CF1), for: .normal)
            }
        }
    }
    private lazy var bgView: UIView =  {
        let view = UIView(frame: CGRect.init(x: 0.0, y: 0.0, width: XDSize.screenWidth, height: XDSize.screenHeight - screenViewY), color: UIColor(white: 0.0, alpha: 0.6))
        let tapGes: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(HighSchoolFilterView.eventTapResponse(_:)))
        tapGes.delegate = self
        view.addGestureRecognizer(tapGes)
        view.isHidden = true
        view.layer.masksToBounds = true
        return view
    }()
    private lazy var baseView: UIView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: XDSize.screenWidth, height: 0.0), color: UIColor.white)
    private lazy var topBaseView: UIView = {
        let view: UIView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: XDSize.screenWidth, height: 226.0), color: UIColor.white)
        view.isHidden = true
        return view
    }()
    private var rankBtn: UIButton!
    private var tuitionBtn: UIButton!
    private var optionsBtn: UIButton!
    private lazy var leftSeparatorView: UIView = UIView(frame: CGRect(x: self.btnWidth, y: 12.0, width: 1.0, height: 16.0), color: XDColor.itemLine)
    private lazy var rightSeparatorView: UIView = UIView(frame: CGRect(x: self.btnWidth * 2.0, y: 12.0, width: 1.0, height: 16.0), color: XDColor.itemLine)
    private lazy var separatorView: UIView = UIView(frame: CGRect(x: 0.0, y: kFilterBarHeight, width: XDSize.screenWidth, height: XDSize.unitWidth), color: UIColor(0xC4C9CC))
    lazy var rankFilterView: HighSchoolRankFilterView = {
        let filterView: HighSchoolRankFilterView = HighSchoolRankFilterView(frame: CGRect(x: 0.0, y: 0.0, width: XDSize.screenWidth, height: rankHeight))
        filterView.isHidden = true
        return filterView
    }()
    lazy var tuitionFilterView: HighSchoolTuitionFilterView = {
        let filterView: HighSchoolTuitionFilterView = HighSchoolTuitionFilterView(frame: CGRect(x: 0.0, y: 0.0, width: XDSize.screenWidth, height: 336.0))
        filterView.isHidden = true
        return filterView
    }()
    lazy var optionsFilterView: HighSchoolOptionsFilterView = {
        let filterView: HighSchoolOptionsFilterView = HighSchoolOptionsFilterView(frame: CGRect(x: 0.0, y: 0.0, width: XDSize.screenWidth, height: adaptOptionHeight))
        filterView.isHidden = true
        return filterView
    }()
    
     // MARK: life cycle
    convenience init() {
        self.init(frame: CGRect(x: 0.0, y: XDSize.topHeight, width: XDSize.screenWidth, height: kFilterBarHeight))
        initContentViews()
        updateFilterView()
    }
    
    // MARK: event response
    @objc private func eventTapResponse(_ tap: UITapGestureRecognizer) {
        hideBackgroundView()
    }
    
    @objc private func eventButtonResponse(_ sender: UIButton) {
        let index: Int = sender.tag - kViewTag
        if index != lastIndex {
            if !isFirstPop {
                closeFilterView(false)
            }
            lastIndex = index
        }
        lastBtn = sender
        if contentList[index].isHidden {
            sender.isSelected = true
            contentList[index].isHidden = false
            if isFirstPop {
                baseView.top = -contentList[index].height
                baseView.height = contentList[index].height
                UIView.animate(withDuration: 0.25) {
                    self.baseView.top += (self.contentList[index].height + kFilterBarHeight)
                }
            } else {
                let topSpace: CGFloat = baseView.height - contentList[index].height
                if topSpace > 0 {
                    topBaseView.isHidden = false
                }
                baseView.height = contentList[index].height
                baseView.top += topSpace
                UIView.animate(withDuration: 0.15) {
                    self.baseView.top -= topSpace
                }
            }
            isFirstPop = false
            bgView.isHidden = false
            height = bgView.height
        } else {
            hideBackgroundView()
        }
    }
    
    // MARK: private methods
    private func initContentViews() {
        backgroundColor = .clear
        rankBtn = configButton(originX: 0.0, title: "排名", imageLeftInset: 31.0, tag: kViewTag)
        tuitionBtn = configButton(originX: btnWidth, title: "费用", imageLeftInset: 31.0, tag: kViewTag + 1)
        optionsBtn = configButton(originX: btnWidth * 2.0, title: "更多筛选", imageLeftInset: 59.0, tag: kViewTag + 2)
        addSubview(bgView)
        bgView.addSubview(topBaseView)
        bgView.addSubview(baseView)
        addSubview(rankBtn)
        addSubview(tuitionBtn)
        addSubview(leftSeparatorView)
        addSubview(optionsBtn)
        addSubview(rightSeparatorView)
        addSubview(separatorView)
        baseView.addSubview(rankFilterView)
        baseView.addSubview(tuitionFilterView)
        baseView.addSubview(optionsFilterView)
        contentList.append(rankFilterView)
        contentList.append(tuitionFilterView)
        contentList.append(optionsFilterView)
    }
    
    private func configButton(originX: CGFloat, title: String, imageLeftInset: CGFloat, tag: Int) -> UIButton {
        let button: UIButton = UIButton(frame: CGRect(x: originX, y: 0.0, width: btnWidth, height: kFilterBarHeight))
        button.backgroundColor = .white
        button.setTitle(title, for: .normal)
        button.setTitleColor(UIColor(0x26343F), for: .normal)
        button.setTitleColor(UIColor(0x078CF1), for: .selected)
        button.setImage(UIImage(named: "down"), for: .normal)
        button.setImage(UIImage(named: "up")?.tint(XDColor.main), for: .selected)
        button.titleEdgeInsets = UIEdgeInsets(top: 0.0, left: -15.0, bottom: 0.0, right: 15.0)
        button.imageEdgeInsets = UIEdgeInsets(top: 0.0, left: imageLeftInset, bottom: 0.0, right: -imageLeftInset)
        button.titleLabel?.textAlignment = .center
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14.0)
        button.tag = tag
        button.addTarget(self, action: #selector(HighSchoolFilterView.eventButtonResponse(_:)), for: .touchUpInside)
        return button
    }
    
    private func closeFilterView(_ isClosed: Bool) {
        lastBtn?.isSelected = false
        contentList[lastIndex].isHidden = true
        if isClosed {
            bgView.isHidden = true
            height = kFilterBarHeight
        }
    }
    
    private func hideBackgroundView() {
        isFirstPop = true
        topBaseView.isHidden = true
        closeFilterView(true)
    }
    
    private func updateFilterView() {
        rankFilterView.rankParamClosure = { [weak self](categoryId, rankId, title) in
            if let `self` = self {
                self.rankBtn.setTitle(title, for: .normal)
                self.rankBtn.titleLabel?.sizeToFit()
                let titleWidth = self.rankBtn.titleLabel?.frame.width
                self.rankBtn.imageEdgeInsets = UIEdgeInsets(top: 0.0, left: (titleWidth! + 3.0), bottom: 0.0, right: -(titleWidth! + 3.0))
                self.hideBackgroundView()
                let params = ["rankCategoryId": categoryId, "rankRange": rankId]
                guard let _ = self.delegate?.highSchoolFilterView(select: params) else { return }
            }
        }
        tuitionFilterView.tiotionParamsClosure = { [weak self] (range, title) in
            if let `self` = self {
                self.tuitionBtn.setTitle(title, for: .normal)
                self.tuitionBtn.titleLabel?.sizeToFit()
                let titleWidth = self.tuitionBtn.titleLabel?.frame.width
                self.tuitionBtn.imageEdgeInsets = UIEdgeInsets(top: 0.0, left: (titleWidth! + 3.0), bottom: 0.0, right: -(titleWidth! + 3.0))
                self.hideBackgroundView()
                let data = ["feeRange": range]
                guard let _ =  self.delegate?.highSchoolFilterView(select: data) else {
                    return
                }
            }
        }
        optionsFilterView.sexParamsClosure = { [weak self] sexId in
            if let `self` = self {
                self.lastOptionSel.0 = sexId
                self.hideBackgroundView()
                let data = ["sexualTypeId": sexId]
                guard let _ =  self.delegate?.highSchoolFilterView(select: data) else {
                    return
                }
            }
        }
        optionsFilterView.boardParamsClosure = { [weak self] boardId in
            if let `self` = self {
                self.lastOptionSel.1 = boardId
                self.hideBackgroundView()
                let data = ["boarderTypeId": boardId]
                guard let _ =  self.delegate?.highSchoolFilterView(select: data) else {
                    return
                }
            }
        }
    }
}

extension HighSchoolFilterView: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if let touchView = touch.view {
            if touchView.isDescendant(of: rankFilterView) {
                return false
            } else if touchView.isDescendant(of: tuitionFilterView) {
                return false
            } else if touchView.isDescendant(of: optionsFilterView) {
                return false
            }
        }
        return true
    }
}
