//
//  SSTableViewControllerEx.swift
//  xxd
//
//  Created by remy on 2018/1/15.
//  Copyright © 2018年 com.smartstudy. All rights reserved.
//

private var offsetKey: UInt8 = 0

extension SSTableViewController {
    
    var minStayOffsetY: CGFloat {
        get {
            return objc_getAssociatedObject(self, &offsetKey) as! CGFloat
        }
        set {
            objc_setAssociatedObject(self, &offsetKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}
