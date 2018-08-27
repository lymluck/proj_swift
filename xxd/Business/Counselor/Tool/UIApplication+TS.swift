//
//  UIApplication+TS.swift
//  xxd
//
//  Created by chenyusen on 2018/3/8.
//  Copyright © 2018年 com.smartstudy. All rights reserved.
//

import Foundation
public extension UIApplication {
    public func topViewController(_ controller: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        if let navigationController = controller as? UINavigationController {
            return topViewController(navigationController.visibleViewController)
        }
        if let tabController = controller as? UITabBarController {
            if let selected = tabController.selectedViewController {
                return topViewController(selected)
            }
        }
        if let presented = controller?.presentedViewController {
            return topViewController(presented)
        }
        return controller
    }
}
