//
//  UserGuideView.swift
//  xxd
//
//  Created by Lisen on 2018/8/16.
//  Copyright © 2018 com.smartstudy. All rights reserved.
//

import UIKit

// 引导更新后需要修改 version !!!!!!
// 引导更新后需要修改 version !!!!!!
// 引导更新后需要修改 version !!!!!!
private var guideVersion = "1.5.0"
let firstGuideKey = "\(Preference.GUIDE.rawValue + guideVersion)"

/// 用户引导页
class UserGuideView: UIView {
    
    private let maxCount = 3
    private lazy var imageNames: [String] = {
        if UIDevice.isIPhoneX {
            return ["user_guide_stepx1","user_guide_stepx2","user_guide_stepx3"]
        }
        return ["user_guide_step1","user_guide_step2","user_guide_step3"]
    }()
    private lazy var guideScroller: UIScrollView = {
        let scrollView: UIScrollView = UIScrollView(frame: self.bounds)
        scrollView.backgroundColor = UIColor.clear
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.scrollsToTop = false
        scrollView.isPagingEnabled = true
        scrollView.delegate = self
        return scrollView
    }()
    private let pageControl: UIPageControl = {
        let pageControl: UIPageControl = UIPageControl()
        pageControl.numberOfPages = 3
        pageControl.currentPage = 0
        pageControl.pageIndicatorTintColor = XDColor.itemLine
        pageControl.currentPageIndicatorTintColor = XDColor.main
        pageControl.addTarget(self, action: #selector(pageTap(sender:)), for: .valueChanged)
        return pageControl
    }()
    private lazy var enterBtn: UIButton = {
        let button: UIButton = UIButton(frame: .zero, title: "click_enter".localized, fontSize: 20.0, bold: true, titleColor: XDColor.main, backgroundColor: nil, target: self, action: #selector(eventEnterButtonResponse(_:)))
        button.layer.cornerRadius = 23
        button.layer.borderWidth = 1
        button.layer.borderColor = XDColor.main.cgColor
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initContentViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    private func initContentViews() {
        
//        if #available(iOS 11.0, *) {
//            guideScroller.contentInsetAdjustmentBehavior = .never;
//        } else {
//            automaticallyAdjustsScrollViewInsets = false
//        }
        backgroundColor = .white
        guideScroller.contentSize = CGSize(width: CGFloat(maxCount) * bounds.width, height: bounds.height)
        addSubview(guideScroller)
        addSubview(pageControl)
        pageControl.snp.makeConstraints({ (make) in
            make.bottom.equalTo(self).offset(-20)
            make.centerX.equalTo(self)
            make.size.equalTo(CGSize(width: maxCount * 17, height: 32))
        })
        for (index, name) in imageNames.enumerated() {
            let guideView: UIImageView = UIImageView(frame: bounds, imageName: name)
            guideView.left = bounds.width * CGFloat(index)
            guideView.contentMode = .scaleAspectFill
            guideView.isUserInteractionEnabled = true
            guideScroller.addSubview(guideView)
            if index == 2 {
                guideView.addSubview(enterBtn)
                enterBtn.snp.makeConstraints({ (make) in
                    make.bottom.equalTo(guideView).offset(-50)
                    make.centerX.equalTo(guideView)
                    make.size.equalTo(CGSize(width: 195, height: 46))
                })
            }
        }
        
    }
    
    static func isShow() -> Bool {
        #if TEST_MODE
        let switchOn = UserDefaults.standard.bool(forKey: "kUnlimitedGuideKey")
        if switchOn {
            return true
        }
        #endif
        return !UserDefaults.standard.bool(forKey: firstGuideKey)
    }
    
    //MARK:- Action
    @objc func pageTap(sender: UIPageControl) {
        guideScroller.setContentOffset(CGPoint(x: CGFloat(sender.currentPage) * bounds.width, y: 0), animated: true)
    }
    
    @objc private func eventEnterButtonResponse(_ sender: UIButton) {
        UserDefaults.standard.set(true, forKey: firstGuideKey)
        self.removeFromSuperview()
    }
    
}

extension UserGuideView: UIScrollViewDelegate {
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        scrollViewDidEndScrollingAnimation(scrollView)
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        let page = Int(scrollView.contentOffset.x / scrollView.width)
        pageControl.currentPage = page
        pageControl.isHidden = page == maxCount - 1
    }
}
