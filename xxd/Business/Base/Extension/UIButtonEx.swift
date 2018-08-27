//
//  UIButtonEx.swift
//  xxd
//
//  Created by remy on 2018/1/25.
//  Copyright © 2018年 com.smartstudy. All rights reserved.
//

import Kingfisher
import pop

private var kNaughtyKey: UInt8 = 0

extension UIButton {
    
    func setAutoOSSImage(urlStr: String) {
        setAutoOSSImage(urlStr: urlStr, policy: .fill)
    }
    
    func setAutoOSSImage(urlStr: String, policy: OSSImagePolicy) {
        setOSSImage(urlStr: urlStr, size: size, policy: policy, placeholderImage: UIImage.getPlaceHolderImage(size: size))
    }
    
    func setOSSImage(urlStr: String, size: CGSize, policy: OSSImagePolicy) {
        setOSSImage(urlStr: urlStr, size: size, policy: policy, placeholderImage: UIImage.getPlaceHolderImage(size: size))
    }
    
    func setOSSImage(urlStr: String, size: CGSize, policy: OSSImagePolicy, placeholderImage: UIImage) {
        let OSSUrlStr = UIImage.OSSImageURLString(urlStr: urlStr, size: size, policy: policy)
        kf.setImage(with: URL(string: OSSUrlStr), for: .normal, placeholder: placeholderImage)
    }
    
    var naughty: Bool {
        get {
            return (objc_getAssociatedObject(self, &kNaughtyKey) as? Bool) ?? false
        }
        set {
            if naughty != newValue {
                objc_setAssociatedObject(self, &kNaughtyKey, newValue, .OBJC_ASSOCIATION_ASSIGN)
                if newValue {
                    addTarget(self, action: #selector(scaleToSmall), for: [.touchDown, .touchDragEnter])
                    addTarget(self, action: #selector(scaleAnimation), for: .touchUpInside)
                    addTarget(self, action: #selector(scaleToDefault), for: .touchDragExit)
                } else {
                    removeTarget(self, action: #selector(scaleToSmall), for: [.touchDown, .touchDragEnter])
                    removeTarget(self, action: #selector(scaleAnimation), for: .touchUpInside)
                    removeTarget(self, action: #selector(scaleToDefault), for: .touchDragExit)
                }
            }
        }
    }
    
    @objc func scaleToSmall() {
        if let scaleAnimation = POPBasicAnimation(propertyNamed: kPOPLayerScaleXY) {
            scaleAnimation.toValue = CGSize(width: 0.95, height: 0.95)
            layer.pop_add(scaleAnimation, forKey: "layerScaleSmallAnimation")
        }
    }
    
    @objc func scaleAnimation() {
        if let scaleAnimation = POPSpringAnimation(propertyNamed: kPOPLayerScaleXY) {
            scaleAnimation.velocity = CGSize(width: 3, height: 3)
            scaleAnimation.toValue = CGSize(width: 1, height: 1)
            scaleAnimation.springBounciness = 18
            layer.pop_add(scaleAnimation, forKey: "layerScaleSpringAnimation")
        }
    }
    
    @objc func scaleToDefault() {
        if let scaleAnimation = POPBasicAnimation(propertyNamed: kPOPLayerScaleXY) {
            scaleAnimation.toValue = CGSize(width: 1, height: 1)
            layer.pop_add(scaleAnimation, forKey: "layerScaleDefaultAnimation")
        }
    }
}
