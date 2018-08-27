//
//  CALayerEx.swift
//  xxd
//
//  Created by remy on 2017/12/13.
//  Copyright © 2017年 com.smartstudy. All rights reserved.
//

import QuartzCore

public extension CALayer {
    
    public var width: CGFloat {
        get { return frame.size.width }
        set { frame.size.width = newValue }
    }
    
    public var height: CGFloat {
        get { return frame.size.height }
        set { frame.size.height = newValue }
    }
    
    public var top: CGFloat {
        get { return frame.origin.y }
        set { frame.origin.y = newValue }
    }
    
    public var left: CGFloat {
        get { return frame.origin.x }
        set { frame.origin.x = newValue }
    }
    
    public var bottom: CGFloat {
        get { return top + height }
        set { top = newValue - height }
    }
    
    public var right: CGFloat {
        get { return left + width }
        set { left = newValue - width }
    }
    
    public var positionX: CGFloat {
        get { return position.x }
        set { position = CGPoint(x: newValue, y: position.y) }
    }
    
    public var positionY: CGFloat {
        get { return position.y }
        set { position = CGPoint(x: position.x, y: newValue) }
    }
    
    public var size: CGSize {
        get { return frame.size }
        set { frame.size = newValue }
    }
    
    public var origin: CGPoint {
        get { return frame.origin }
        set { frame.origin = newValue }
    }
    
    public var screenTop: CGFloat {
        var y = top
        var layer = self
        while true {
            if let superlayer = layer.superlayer {
                y += superlayer.top
                layer = superlayer
            } else {
                break
            }
        }
        return y
    }
    
    public var screenLeft: CGFloat {
        var x = left
        var layer = self
        while true {
            if let superlayer = layer.superlayer {
                x += superlayer.left
                layer = superlayer
            } else {
                break
            }
        }
        return x
    }
    
    public var screenBottom: CGFloat { return screenTop + height }
    
    public var screenRight: CGFloat { return screenLeft + width }
}
