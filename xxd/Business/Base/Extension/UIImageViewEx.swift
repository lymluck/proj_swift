//
//  UIImageViewEx.swift
//  xxd
//
//  Created by remy on 2017/12/27.
//  Copyright © 2017年 com.smartstudy. All rights reserved.
//

import Kingfisher

extension UIImageView {
    
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
        kf.setImage(with: URL(string: OSSUrlStr), placeholder: placeholderImage)
    }
    
    func setCircleOSSImage(urlStr: String) {
        setCircleOSSImage(urlStr: urlStr, size: size)
    }
    
    func setCircleOSSImage(urlStr: String, placeholderImage: UIImage) {
        setCircleOSSImage(urlStr: urlStr, size: size, placeholderImage: placeholderImage)
    }
    
    func setCircleOSSImage(urlStr: String, size: CGSize) {
        setCircleOSSImage(urlStr: urlStr, size: size, placeholderImage: UIImage.getCirclePlaceHolderImage(radius: size.width * 0.5))
    }
    
    func setCircleOSSImage(urlStr: String, size: CGSize, placeholderImage: UIImage) {
        let OSSUrlStr = UIImage.cicleOSSImageURLString(urlStr: urlStr, size: size)
        kf.setImage(with: URL(string: OSSUrlStr), placeholder: placeholderImage)
    }
    
    
}
