//
//  SSCellItemEx.swift
//  xxd
//
//  Created by remy on 2017/12/29.
//  Copyright © 2017年 com.smartstudy. All rights reserved.
//

enum CellBottomLineType: Int {
    case normal, right, center, none
}

private var lineTypeKey: UInt8 = 0

extension SSCellItem {
    
    var bottomLineType: CellBottomLineType {
        set {
            objc_setAssociatedObject(self, &lineTypeKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        get {
            if let v = objc_getAssociatedObject(self, &lineTypeKey) as? CellBottomLineType {
                return v
            }
            return .normal
        }
    }
}
