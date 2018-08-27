//
//  CollegeHotCategoryViewController.swift
//  xxd
//
//  Created by Lisen on 2018/6/12.
//  Copyright © 2018年 com.smartstudy. All rights reserved.
//

import UIKit
import WMPageController


struct TopMenuTagModel {
    let name: String
    let id: String
}

private var kTagBarHeight: CGFloat = 40
class CollegeHotCategoryViewController: SSViewController {
    
    var categoryType: CollegeCategoryType = .viewed
    private lazy var tagModels: [TopMenuTagModel] = {
        var arr = [TopMenuTagModel]()
        let names = ["information_tag_total", "information_tag_us", "information_tag_uk", "information_tag_ca", "information_tag_au"]
        let countryIds = ["", "COUNTRY_226", "COUNTRY_225", "COUNTRY_40", "COUNTRY_16"]
        for (index, name) in names.enumerated() {
            let model = TopMenuTagModel(name: name.localized, id: countryIds[index])
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
        vc.itemMargin = 16
        vc.automaticallyCalculatesItemWidths = true
        vc.bounces = true
        return vc
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = categoryType.titleName()
        navigationBar.bottomLine.isHidden = true
        view.insertSubview(pageController.view, belowSubview: navigationBar)
        addChildViewController(pageController)
        let bottomLine = UIView(frame: CGRect(x: 0, y: kTagBarHeight - XDSize.unitWidth, width: XDSize.screenWidth, height: XDSize.unitWidth), color: UIColor(0xCCCCCC))
        pageController.menuView?.insertSubview(bottomLine, at: 0)
    }
}

extension CollegeHotCategoryViewController: WMPageControllerDataSource {
    func pageController(_ pageController: WMPageController, preferredFrameForContentView contentView: WMScrollView) -> CGRect {
        let top = topOffset + kTagBarHeight
        return CGRect(x: 0, y: top, width: XDSize.screenWidth, height: view.height - top)
    }
    
    func pageController(_ pageController: WMPageController, preferredFrameFor menuView: WMMenuView) -> CGRect {
         return CGRect(x: 0, y: topOffset, width: XDSize.screenWidth, height: kTagBarHeight)
    }
    
    func numbersOfChildControllers(in pageController: WMPageController) -> Int {
        return tagModels.count
    }
    
    func pageController(_ pageController: WMPageController, titleAt index: Int) -> String {
        return tagModels[index].name
    }
}

extension CollegeHotCategoryViewController: WMPageControllerDelegate {
    func pageController(_ pageController: WMPageController, viewControllerAt index: Int) -> UIViewController {
        let vc = CollegeHotRankViewController()
        vc.categoryType = categoryType
        vc.countryId = tagModels[index].id
        return vc
    }
}
