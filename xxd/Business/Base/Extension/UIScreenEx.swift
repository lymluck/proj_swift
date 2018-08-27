//
//  UIScreenEx.swift
//  xxd
//
//  Created by remy on 2017/12/20.
//  Copyright © 2017年 com.smartstudy. All rights reserved.
//

extension UIScreen {
    
    static var size: CGSize {
        return UIScreen.main.bounds.size
    }
    
    static var width: CGFloat {
        return UIScreen.main.bounds.size.width
    }
    
    static var height: CGFloat {
        return UIScreen.main.bounds.size.height
    }
    
    public static var center: CGPoint {
        return CGPoint(x: width / 2, y: height / 2)
    }
    
    static var isP35: Bool {
        let currentScreenSize = UIScreen.main.nativeBounds.size
        return __CGSizeEqualToSize(CGSize(width: 640, height: 960), currentScreenSize)
    }
    
    static var isP4: Bool {
        let currentScreenSize = UIScreen.main.nativeBounds.size
        return __CGSizeEqualToSize(CGSize(width: 640, height: 1136), currentScreenSize)
    }
}
