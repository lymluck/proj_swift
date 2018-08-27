//
//  UIViewController+TS.swift
//  TSKit
//
//  Created by chenyusen on 2018/1/30.
//  Copyright © 2018年 TechSen. All rights reserved.
//

import UIKit


public extension UIViewController {
    public var isVisible: Bool {
        // http://stackoverflow.com/questions/2777438/how-to-tell-if-uiviewcontrollers-view-is-visible
        return self.isViewLoaded && view.window != nil
    }
    /// modal出一个控制器,如果该控制器不是导航栏控制器,则自动添加
    ///
    /// - Parameters:
    ///   - viewController: 被model的控制器
    ///   - animated: 是否执行动画
    ///   - completion: Modal完成后的回调
    public func presentModal(_ viewController: UIViewController,
                             animated: Bool = true,
                             completion: (() -> Void)? = nil) {
        var aViewController = viewController
        if !(aViewController is UINavigationController) {
            aViewController = NavigationController(rootViewController: aViewController)
        }
        present(aViewController, animated: animated, completion: completion)
    }
    
    
    /// 透明弹出一个控制器
    ///
    /// - Parameters:
    ///   - viewController: 被model的控制器
    ///   - animated: 是否执行动画
    ///   - completion: Modal完成后的回调
    public func presentTranslucent(_ viewController: UIViewController,
                                   animated: Bool = false,
                                   completion: (() -> Void)? = nil
        ) {
        var aViewController = viewController
        if !(aViewController is UINavigationController) {
            aViewController = NavigationController(rootViewController: aViewController)
        }
        aViewController.modalPresentationStyle = .custom;
        aViewController.modalPresentationCapturesStatusBarAppearance = true;
        present(aViewController, animated: animated, completion: completion)
    }
}

