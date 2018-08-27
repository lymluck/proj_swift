//
//  XDPopView.swift
//  xxd
//
//  Created by remy on 2017/12/28.
//  Copyright © 2017年 com.smartstudy. All rights reserved.
//

class XDPopView {
    
    static let POP_VIEW_DURATION = 1.7
    static var lastHud: MBProgressHUD?
    static var window: UIWindow?
    
    static func toast(_ text: String) {
        var window = UIApplication.shared.windows.last
        if #available(iOS 11.0, *), let w = window {
            if String(describing: type(of: w)) != "UIRemoteKeyboardWindow" {
                window = UIApplication.shared.keyWindow
            }
        }
        toast(text, window)
    }
    
    static func toast(_ text: String, _ view: UIView?) {
        hide()
        if let view = view {
            let hud = MBProgressHUD.showAdded(to: view, animated: true)
            hud.isUserInteractionEnabled = false
            hud.mode = .text
            hud.bezelView.color = UIColor.black.withAlphaComponent(0.8)
            hud.bezelView.style = .solidColor
            hud.detailsLabel.text = text
            hud.detailsLabel.font = UIFont.boldSystemFont(ofSize: 14)
            hud.detailsLabel.textColor = UIColor.white
            hud.margin = 12
            hud.offset = CGPoint(x: 0, y: 255.5 - XDSize.screenHeight * 0.5)
            hud.hide(animated: true, afterDelay: POP_VIEW_DURATION)
            lastHud = hud
        }
    }
    
    static func loading() {
        var window = UIApplication.shared.windows.last
        if #available(iOS 11.0, *), let w = window {
            if String(describing: type(of: w)) != "UIRemoteKeyboardWindow" {
                window = UIApplication.shared.keyWindow
            }
        }
        loading(window)
    }
    
    static func loading(_ view: UIView?) {
        hide()
        if let view = view {
            let hud = MBProgressHUD.showAdded(to: view, animated: true)
            hud.mode = .indeterminate
            hud.contentColor = UIColor.white
            hud.bezelView.color = UIColor.black.withAlphaComponent(0.8)
            hud.bezelView.style = .solidColor
            lastHud = hud
        }
    }
    
    static func progress(_ text: String) {
        progress(text, UIApplication.shared.windows.last)
    }
    
    static func progress(_ text: String, _ view: UIView?) {
        hide()
        if let view = view {
            let hud = MBProgressHUD.showAdded(to: view, animated: true)
            hud.mode = .determinateHorizontalBar
            hud.contentColor = UIColor.white
            lastHud = hud
        }
    }
    
    static func updateProgress(_ hud: MBProgressHUD, _ value: Float) {
        hud.progress = value
        if value >= 1 {
            hud.hide(animated: false)
        }
    }
    
    static func hide() {
        if let lastHud = lastHud {
            lastHud.hide(animated: false)
            self.lastHud = nil
        }
    }
    
    static func topView(view: UIView, isMaskHide: Bool, alpha: CGFloat) {
        window = UIWindow(frame: UIScreen.main.bounds)
        if let window = window {
            window.windowLevel = UIWindowLevelAlert
            window.backgroundColor = UIColor.clear
            window.makeKeyAndVisible()
            let wrap = UIControl(frame: window.bounds)
            wrap.backgroundColor = UIColor.black.withAlphaComponent(alpha)
            if isMaskHide {
                wrap.addTarget(self, action: #selector(hideTopView), for: .touchUpInside)
            }
            window.addSubview(wrap)
            window.addSubview(view)
        }
    }
    
    @objc static func hideTopView() {
        if let window = window {
            window.removeAllSubviews()
            self.window = nil
        }
    }
}
