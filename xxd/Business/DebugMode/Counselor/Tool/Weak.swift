//
//  Weak.swift
//  TSKitDemo
//
//  Created by chenyusen on 2017/9/29.
//  Copyright © 2017年 TechSen. All rights reserved.
//

import Foundation

class WeakBox<T: AnyObject> {
    weak var value : T?
    init (_ value: T) {
        self.value = value
    }
}
