//
//  UIKitEx.swift
//  xxd
//
//  Created by remy on 2017/12/26.
//  Copyright © 2017年 com.smartstudy. All rights reserved.
//

import UIKit

public extension UIApplication {
    
    public class func topVC(_ base: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        if let nav = base as? UINavigationController {
            return topVC(nav.visibleViewController)
        }
        if let tab = base as? UITabBarController {
            if let selected = tab.selectedViewController {
                return topVC(selected)
            }
        }
        if let presented = base?.presentedViewController {
            return topVC(presented)
        }
        return base
    }
}

private weak var _firstResponder: AnyObject?

extension UIResponder {
    
    // https://github.com/jrose-apple/swift-evolution/blob/overridable-members-in-extensions/proposals/nnnn-overridable-members-in-extensions.md
    @objc open func routerEvent(name: String, data: Dictionary<String, Any>) {
        self.next?.routerEvent(name: name, data: data)
    }
    
    // https://github.com/wty21cn/WTYFirstResponder
    public static var firstResponder: AnyObject? {
        _firstResponder = nil
        UIApplication.shared.sendAction(#selector(findFirstResponder(_:)), to: nil, from: nil, for: nil)
        return _firstResponder
    }
    
    @objc func findFirstResponder(_ sender: AnyObject) {
        _firstResponder = self
    }
}

extension UIFont {
    
    static func numericalFontOfSize(_ fontSize: CGFloat) -> UIFont {
        return UIFont(name: "Gotham-Book", size: fontSize) ?? UIFont.systemFont(ofSize: fontSize)
    }
    
    static func boldNumericalFontOfSize(_ fontSize: CGFloat) -> UIFont {
        return UIFont(name: "Gotham-Medium", size: fontSize) ?? UIFont.boldSystemFont(ofSize: fontSize)
    }
}
