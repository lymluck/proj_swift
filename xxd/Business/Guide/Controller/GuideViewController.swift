//
//  GuideViewController.swift
//  xxd
//
//  Created by remy on 2018/1/15.
//  Copyright © 2018年 com.smartstudy. All rights reserved.
//

// 引导更新后需要修改 version !!!!!!
// 引导更新后需要修改 version !!!!!!
// 引导更新后需要修改 version !!!!!!
private var guideVersion = "1.5.0"

class GuideViewController: SSViewController, UIScrollViewDelegate {
    
    let scrollView = UIScrollView()
    let pageControl = UIPageControl()
    let maxCount = 3
    
    override func needNavigationBar() -> Bool {
        return false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.frame = view.bounds
        scrollView.backgroundColor = UIColor.clear
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.scrollsToTop = false
        scrollView.isPagingEnabled = true
        scrollView.delegate = self
        if #available(iOS 11.0, *) {
            scrollView.contentInsetAdjustmentBehavior = .never;
        } else {
            automaticallyAdjustsScrollViewInsets = false
        }
        scrollView.contentSize = CGSize(width: CGFloat(maxCount) * view.width, height: view.height)
        view.addSubview(scrollView)
        
        pageControl.numberOfPages = maxCount
        pageControl.currentPage = 0
        pageControl.pageIndicatorTintColor = XDColor.itemLine
        pageControl.currentPageIndicatorTintColor = XDColor.main
        pageControl.addTarget(self, action: #selector(pageTap(sender:)), for: .valueChanged)
        view.addSubview(pageControl)
        pageControl.snp.makeConstraints({ (make) in
            make.bottom.equalTo(view).offset(-20)
            make.centerX.equalTo(view)
            make.size.equalTo(CGSize(width: maxCount * 17, height: 32))
        })
        
        var imageNames = ["user_guide_step1","user_guide_step2","user_guide_step3"]
        if UIDevice.isIPhoneX {
            imageNames = ["user_guide_stepx1","user_guide_stepx2","user_guide_stepx3"]
        }
        for (index, name) in imageNames.enumerated() {
            let guideView = UIImageView(frame: view.bounds, imageName: name)!
            guideView.left = view.width * CGFloat(index)
            guideView.contentMode = .scaleAspectFill
            guideView.isUserInteractionEnabled = true
            scrollView.addSubview(guideView)
            
            if index == 2 {
                let enterBtn = UIButton(frame: .zero, title: "click_enter".localized, fontSize: 20, bold: true, titleColor: XDColor.main, backgroundColor: nil, target: self, action: #selector(enterTap(sender:)))!
                enterBtn.layer.cornerRadius = 23
                enterBtn.layer.borderWidth = 1
                enterBtn.layer.borderColor = XDColor.main.cgColor
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
        let key = "\(Preference.GUIDE.rawValue + guideVersion)"
        return !UserDefaults.standard.bool(forKey: key)
    }
    
    //MARK:- Action
    @objc func pageTap(sender: UIPageControl) {
        scrollView.setContentOffset(CGPoint(x: CGFloat(sender.currentPage) * scrollView.width, y: 0), animated: true)
    }
    
    @objc func enterTap(sender: UIButton) {
        let key = "\(Preference.GUIDE.rawValue + guideVersion)"
        UserDefaults.standard.set(true, forKey: key)
        if XDUser.shared.hasLogin() {
            dismiss(animated: true, completion: nil)
        } else {
            let vc = SignInViewController()
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    //MARK:- UIScrollViewDelegate
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        scrollViewDidEndScrollingAnimation(scrollView)
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        let page = Int(scrollView.contentOffset.x / scrollView.width)
        pageControl.currentPage = page
        pageControl.isHidden = page == maxCount - 1
    }
}
