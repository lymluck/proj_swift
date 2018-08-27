//
//  CollegeActivityCategoryViewController.swift
//  xxd
//
//  Created by Lisen on 2018/6/28.
//  Copyright © 2018年 com.smartstudy. All rights reserved.
//

import UIKit
import WMPageController


class CollegeActivityCategoryViewController: SSViewController {
    private lazy var tagModels: [TopMenuTagModel] = {
        var arr = [TopMenuTagModel]()
        let names = ["工科", "商科", "理科", "文科", "其他"]
        for (index, name) in names.enumerated() {
            let model = TopMenuTagModel(name: name.localized, id: "")
            arr.append(model)
        }
        return arr
    }()
    private lazy var pageController: WMPageController = {
        let vc = WMPageController()
        vc.delegate = self
        vc.dataSource = self
        vc.titleColorSelected = XDColor.main
        vc.titleColorNormal = XDColor.itemText
        vc.titleSizeNormal = 15
        vc.titleSizeSelected = 15
        vc.menuViewStyle = .line
        vc.progressHeight = 2
        vc.progressColor = XDColor.main
        vc.itemMargin = 0.0
        vc.automaticallyCalculatesItemWidths = true
        vc.bounces = true
        return vc
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initContentViews()
    }
    
    private func initContentViews() {
        title = "活动库"
        navigationBar.bottomLine.isHidden = true
        view.insertSubview(pageController.view, belowSubview: navigationBar)
        let bottomLine = UIView(frame: CGRect(x: 0, y: 40.0-XDSize.unitWidth, width: XDSize.screenWidth, height: XDSize.unitWidth), color: XDColor.textPlaceholder)
        pageController.menuView?.insertSubview(bottomLine, at: 0)
        addChildViewController(pageController)
    }
}

extension CollegeActivityCategoryViewController: WMPageControllerDataSource {
    func pageController(_ pageController: WMPageController, preferredFrameForContentView contentView: WMScrollView) -> CGRect {
        let top = topOffset + 40.0
        return CGRect(x: 0, y: top, width: XDSize.screenWidth, height: view.height - top)
    }
    
    func pageController(_ pageController: WMPageController, preferredFrameFor menuView: WMMenuView) -> CGRect {
        return CGRect(x: 0, y: topOffset, width: XDSize.screenWidth, height: 40.0)
    }
    
    func numbersOfChildControllers(in pageController: WMPageController) -> Int {
        return tagModels.count
    }
    
    func pageController(_ pageController: WMPageController, titleAt index: Int) -> String {
        return tagModels[index].name
    }
}

extension CollegeActivityCategoryViewController: WMPageControllerDelegate {
    func pageController(_ pageController: WMPageController, viewControllerAt index: Int) -> UIViewController {
        let vc: CollegeActivityViewController = CollegeActivityViewController()
        vc.majorName = tagModels[index].name
        return vc
    }
}
