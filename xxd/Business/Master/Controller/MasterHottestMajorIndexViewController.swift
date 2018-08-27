//
//  MasterHottestMajorIndexViewController.swift
//  xxd
//
//  Created by Lisen on 2018/7/11.
//  Copyright © 2018年 com.smartstudy. All rights reserved.
//

import UIKit
import WMPageController

class MasterHottestMajorIndexViewController: SSViewController {
    private lazy var tagModels: [TopMenuTagModel] = [TopMenuTagModel]()
    private lazy var majorModels: [[MasterHottestMajorModel]] = [[MasterHottestMajorModel]]()
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
        fetchHottestMajorList()
    }
    
    private func initContentViews() {
        title = "热门专业"
        navigationBar.bottomLine.isHidden = true
        view.insertSubview(pageController.view, belowSubview: navigationBar)
        addChildViewController(pageController)
    }
    
    // TODO: 以更优雅的方式处理数据
    private func fetchHottestMajorList() {
        SSNetworkManager.shared().get(XD_MASTER_MAJOR_CATEGORIES, parameters: nil, success: { [weak self](dataTask, responseObject) in
            if let responseData = responseObject as? [String: Any], let serverData = responseData["data"] as? [[String: Any]], let strongSelf = self {
                for data in serverData {
                    // 解析头部国家分类数据
                    let topCategory: TopMenuTagModel = TopMenuTagModel(name: data["name"] as! String, id: data["id"] as! String)
                    strongSelf.tagModels.append(topCategory)
                    // 解析专业分类
                    if let majorDatas = data["directions"] as? [[String: Any]] {
                        var models: [MasterHottestMajorModel] = [MasterHottestMajorModel]()
                        for majorData in majorDatas {
                            let section: MasterHottestMajorModel = MasterHottestMajorModel.yy_model(with: majorData)!
                            models.append(section)
                        }
                        strongSelf.majorModels.append(models)
                    }
                }
                strongSelf.pageController.reloadData()
                let bottomLine = UIView(frame: CGRect(x: 0, y: 40.0-XDSize.unitWidth, width: XDSize.screenWidth, height: XDSize.unitWidth), color: XDColor.textPlaceholder)
                strongSelf.pageController.menuView?.insertSubview(bottomLine, at: 0)
            }
        }) { (dataTask, error) in
            XDPopView.toast(error.localizedDescription)
        }
    }
    
}

extension MasterHottestMajorIndexViewController: WMPageControllerDataSource {
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

extension MasterHottestMajorIndexViewController: WMPageControllerDelegate {
    func pageController(_ pageController: WMPageController, viewControllerAt index: Int) -> UIViewController {
        let vc: MasterHottestMajorListViewController = MasterHottestMajorListViewController()
        vc.majorModels = majorModels[index]
        return vc
    }
}
