//
//  UIViewControllerEx.swift
//  xxd
//
//  Created by remy on 2018/3/22.
//  Copyright © 2018年 com.smartstudy. All rights reserved.
//

import UIKit

extension UIViewController {
    
    func presentVC(_ vc: UIViewController, sourceView: UIView? = nil, sourceRect: CGRect = .null, animated flag: Bool = true, completion: (() -> Void)? = nil) {
        if let pop = vc.popoverPresentationController {
            if let sourceView = sourceView {
                pop.sourceView = sourceView
                pop.sourceRect = sourceRect == .null ? sourceView.bounds : sourceRect
            } else {
                pop.sourceView = UIApplication.shared.keyWindow
                pop.sourceRect = CGRect(x: XDSize.screenWidth / 2, y: XDSize.screenHeight, width: 0, height: 0)
            }
        }
        present(vc, animated: flag, completion: completion)
    }
    
    func alertDialog(title: String?, message: String = "", confirmTitle: String = "确定", leftActionHandler: (()->Void)?, rightActionHandler: (()->Void)?) {
        let alertVC: UIAlertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        let doneAction: UIAlertAction = UIAlertAction(title: confirmTitle, style: UIAlertActionStyle.default) { (_) in
            if let closure = rightActionHandler {
                closure()
            }
        }
        let cancelAction: UIAlertAction = UIAlertAction(title: "取消", style: UIAlertActionStyle.cancel) { (_) in
            if let closure = leftActionHandler {
                closure()
            }
        }
        alertVC.addAction(doneAction)
        alertVC.addAction(cancelAction)
        present(alertVC, animated: true, completion: nil)
    }
    
    func authorizationSettingAlert(_ title: String?, _ message: String?, okHandler: (()->Void)?, cancelHandler: (()->Void)?) {
        let alertController:UIAlertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        let okAction:UIAlertAction = UIAlertAction(title: "设置", style: UIAlertActionStyle.destructive,handler: { (action:UIAlertAction) in
            if let settingURL = URL(string: UIApplicationOpenSettingsURLString)
            {
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(settingURL, options: [:], completionHandler: nil)
                } else {
                    UIApplication.shared.openURL(settingURL)
                }
            }
            if let closure = okHandler {
                closure()
            }
        })
        let cancelAction:UIAlertAction = UIAlertAction(title: "取消", style: UIAlertActionStyle.cancel, handler: { (action: UIAlertAction) in
            if let closure = cancelHandler {
                closure()
            }
        })
        alertController.addAction(okAction)
        alertController.addAction(cancelAction)
//        UIApplication.shared.topViewController()?.present(alertController, animated: true, completion: nil)
        present(alertController, animated: true, completion: nil)
    }
}
