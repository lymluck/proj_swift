//
//  NavigationController.swift
//  counselor_t
//
//  Created by chenyusen on 2017/12/6.
//  Copyright © 2017年 TechSen. All rights reserved.
//

import UIKit

class NavigationController: UINavigationController {

    var gesturePopEnable = true
    
    override func viewDidLoad() {
        super.viewDidLoad()

        interactivePopGestureRecognizer?.delegate = self
    }
}

extension NavigationController: UIGestureRecognizerDelegate {
    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        var animated = false
        if let transitionCoordinator = transitionCoordinator {
            animated = transitionCoordinator.isAnimated
        }
        if viewControllers.count == 1 || animated { // 如果当前栈中只有一个控制器,或则当前导航栏正在做转场动画,则禁止手势
            return false
        } else {
            let selector = NSSelectorFromString("isGesturePopEnable")
            if let topVC = viewControllers.last {
                if topVC is UINavigationController {
                    return false
                } else if topVC is UITabBarController {
                    return false
                } else if topVC.responds(to: selector) {
                    if let _ = topVC.perform(selector) {
                        return true
                    } else {
                        return false
                    }
                }
            }
        }
        return gesturePopEnable
    }
}
