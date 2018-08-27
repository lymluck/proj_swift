//
//  IndexInformationViewController.swift
//  xxd
//
//  Created by remy on 2018/1/18.
//  Copyright © 2018年 com.smartstudy. All rights reserved.
//

private var kTagBarHeight: CGFloat = 40

import WMPageController

class IndexInformationViewController: SSViewController, WMPageControllerDelegate, WMPageControllerDataSource {
    
    private lazy var tagModels: [InformationTagModel] = {
        var arr = [InformationTagModel]()
        let names = ["information_tag_total", "information_tag_us", "information_tag_uk", "information_tag_ca", "information_tag_au"]
        let ids = [0, 23758, 23759, 23761, 23760]
        for (index, name) in names.enumerated() {
            let model = InformationTagModel()
            model.name = name.localized
            model.tagID = ids[index]
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
        XDStatistics.click("17_B_news_list")
        navigationBar.centerTitle = "tab_item_info".localized
        navigationBar.rightItem.image = UIImage(named: "top_right_search")
        navigationBar.rightItem.action = #selector(searchTap)
        navigationBar.bottomLine.isHidden = true
        
        view.insertSubview(pageController.view, belowSubview: navigationBar)
        addChildViewController(pageController)
        
        let bottomLine = UIView(frame: CGRect(x: 0, y: kTagBarHeight - XDSize.unitWidth, width: XDSize.screenWidth, height: XDSize.unitWidth), color: UIColor(0xCCCCCC))
        pageController.menuView?.insertSubview(bottomLine, at: 0)
    }
    
    //MARK:- Action
    @objc func searchTap() {
        XDStatistics.click("17_A_search_btn")
        let vc = XDSearchViewController(type: .information)
        vc.extraParams = ["enabled":true,"deleted":false]
        tabBarController?.presentModalTranslucentViewController(vc, animated: false, completion: nil)
    }
    
    //MARK:- WMPageControllerDataSource
    func pageController(_ pageController: WMPageController, preferredFrameFor menuView: WMMenuView) -> CGRect {
        return CGRect(x: 0, y: topOffset, width: XDSize.screenWidth, height: kTagBarHeight)
    }
    
    func pageController(_ pageController: WMPageController, preferredFrameForContentView contentView: WMScrollView) -> CGRect {
        let top = topOffset + kTagBarHeight
        return CGRect(x: 0, y: top, width: XDSize.screenWidth, height: view.height - top)
    }
    
    func numbersOfChildControllers(in pageController: WMPageController) -> Int {
        return tagModels.count
    }
    
    func pageController(_ pageController: WMPageController, viewControllerAt index: Int) -> UIViewController {
        switch index {
        case 0:
            XDStatistics.click("17_A_all_btn")
        case 1:
            XDStatistics.click("17_A_America_btn")
        case 2:
            XDStatistics.click("17_A_England_btn")
        case 3:
            XDStatistics.click("17_A_Canada_btn")
        case 4:
            XDStatistics.click("17_A_Australia_btn")
        default:
            break
        }
        let vc = InformationViewController(tagID: tagModels[index].tagID)
        return vc
    }
    
    func pageController(_ pageController: WMPageController, titleAt index: Int) -> String {
        return tagModels[index].name
    }
}
