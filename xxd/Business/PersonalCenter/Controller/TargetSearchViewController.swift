//
//  TargetSearchViewController.swift
//  xxd
//
//  Created by remy on 2018/2/2.
//  Copyright © 2018年 com.smartstudy. All rights reserved.
//

class TargetSearchViewController: SSViewController {
    
    private var scrollView: XDScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = XDColor.mainBackground
        
        scrollView = XDScrollView(frame: CGRect(x: 0, y: 0, width: XDSize.screenWidth, height: XDSize.visibleHeight))
        scrollView.backgroundColor = UIColor.white
        view.addSubview(scrollView)
        
        let btn1 = searchBtn("tab_item_college", "search_college")
        scrollView.addSubview(btn1)
        let btn2 = searchBtn("tab_item_rank", "search_rank")
        btn2.tag = 1
        scrollView.addSubview(btn2)
        let btn3 = searchBtn("smart_college", "search_smart_college")
        btn3.tag = 2
        scrollView.addSubview(btn3)
        
        let space = (XDSize.screenWidth - btn1.width - btn2.width - btn3.width) * 0.25
        btn1.left = space
        scrollView.addSubview(UIView(frame: CGRect(x: btn1.right + space * 0.5, y: 41, width: XDSize.unitWidth, height: 20), color: UIColor(0xCCCCCC)))
        btn2.left = btn1.right + space
        scrollView.addSubview(UIView(frame: CGRect(x: btn2.right + space * 0.5, y: 41, width: XDSize.unitWidth, height: 20), color: UIColor(0xCCCCCC)))
        btn3.left = btn2.right + space
        
        let vc = XDSearchViewController(type: .target)
        vc.customWrap = scrollView
        vc.isBackWhenCancel = true
        addChildViewController(vc)
        view.addSubview(vc.view)
    }
    
    private func searchBtn(_ text: String, _ imageName: String) -> UIButton {
        let str = text.localized
        let btn = UIButton(frame: CGRect(x: 0, y: 35, width: 0, height: 32), title: str, fontSize: 15, titleColor: UIColor(0xAAAAAA), target: self, action: #selector(searchTarget(sender:)))!
        btn.titleEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 0)
        btn.setImage(UIImage(named: imageName), for: .normal)
        btn.setImage(UIImage(named: imageName), for: .highlighted)
        btn.contentHorizontalAlignment = .center
        btn.width = str.widthForFont((btn.titleLabel?.font)!) + 36
        return btn
    }
    
    //MARK:- Action
    @objc func searchTarget(sender: UIButton) {
        let index = sender.tag
        if index == 0 {
            navigationController?.pushViewController(CollegeViewController(), animated: true)
        } else if index == 1 {
            navigationController?.pushViewController(RankViewController(), animated: true)
        } else if index == 2 {
            navigationController?.pushViewController(SmartCollegeViewController(), animated: true)
        }
    }
}
