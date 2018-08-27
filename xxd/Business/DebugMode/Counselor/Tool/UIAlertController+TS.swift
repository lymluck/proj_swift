
//
//  UIAlertController+TS.swift
//  Steward
//
//  Created by chenyusen on 2017/12/23.
//  Copyright © 2017年 TechSen. All rights reserved.
//

import UIKit

extension UIAlertController {
    typealias Action = () -> ()
    
    static func show(title: String? = nil,
                     message: String? = nil,
                     actionTitle: String? = nil,
                     cancelTitle: String? = nil,
                     action:(() -> ())? = nil,
                     cancelAction:(() -> ())? = nil) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        if let cancelTitle = cancelTitle {
            let defaultCancelAction = UIAlertAction(title: cancelTitle, style: .cancel) { (_) in
                cancelAction?()
                alertController.dismiss(animated: true, completion: nil)
            }
            alertController.addAction(defaultCancelAction)
        }
        
        if let actionTitle = actionTitle, let action = action {
            let alertAction = UIAlertAction(title: actionTitle, style: .default) { (_) in
                action()
            }
            alertController.addAction(alertAction)
        }
        UIApplication.topVC()?.presentModalTranslucentViewController(alertController, animated: true, completion: nil)
    }
}
