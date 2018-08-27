//
//  UIImageEx.swift
//  xxd
//
//  Created by remy on 2017/12/27.
//  Copyright © 2017年 com.smartstudy. All rights reserved.
//

import Kingfisher

enum OSSImagePolicy: String {
    // 等比缩放,限制在设定在指定w与h的矩形内的最大图片
    case fit = "m_lfit"
    // 等比缩放,延伸出指定w与h的矩形框外的最小图片
    case fill = "m_mfit"
    // 同fit,但实际宽高为给定的w,h,内容居中显示
    case pad = "m_pad"
    // 同fill,但实际宽高为给定的w,h,内容居中裁剪
    case fillAndClip = "m_fill"
    // 固定宽高,强制缩略
    case fixed = "m_fixed"
}

extension UIImage {
    
    // https://stackoverflow.com/questions/26542035/create-uiimage-with-solid-color-in-swift
    convenience init(color: UIColor, size: CGSize) {
        UIGraphicsBeginImageContext(size)
        color.setFill()
        UIRectFill(CGRect(origin: .zero, size: size))
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        guard let aCgImage = image?.cgImage else {
            self.init()
            return
        }
        self.init(cgImage: aCgImage)
    }
    
    func tint(_ color: UIColor, blendMode: CGBlendMode = .destinationIn) -> UIImage {
        let drawRect = CGRect(origin: .zero, size: size)
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        //        let context = UIGraphicsGetCurrentContext()
        //        context!.clip(to: drawRect, mask: cgImage!)
        color.setFill()
        UIRectFill(drawRect)
        draw(in: drawRect, blendMode: blendMode, alpha: 1.0)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }
    
    static func OSSImageURLString(urlStr: String, size: CGSize, policy: OSSImagePolicy) -> String {
        if urlStr.contains("x-oss-process=image/resize") {
            return urlStr
        }
        let width = Int(size.width * UIScreen.main.scale)
        let height = Int(size.height * UIScreen.main.scale)
        return "\(urlStr)?x-oss-process=image/resize,\(policy.rawValue),w_\(width),h_\(height),limit_0"
    }
    
    static func cicleOSSImageURLString(urlStr: String, size: CGSize) -> String {
        let radius = Int(CGFloat.minimum(size.width, size.height))
        return "\(OSSImageURLString(urlStr: urlStr, size: size, policy: .fill))/circle,r_\(radius)/format,png"
    }
    
    static func getPlaceHolderImage(size: CGSize) -> UIImage {
        return getPlaceHolderImage(size: size, radius: 0)
    }
    
    static func getCirclePlaceHolderImage(radius: CGFloat) -> UIImage {
        return getPlaceHolderImage(size: CGSize(width: radius * 2, height: radius * 2), radius: radius)
    }
    
    static func getPlaceHolderImage(size: CGSize, radius: CGFloat) -> UIImage {
        let s = CGSize(width: size.width.rounded(.up), height: size.height.rounded(.up))
        let key = ("\(NSStringFromCGSize(s))\(String(format: "%.1f", radius))" as NSString).md5()
        if let cacheImage = KingfisherManager.shared.cache.retrieveImageInMemoryCache(forKey: key) {
            return cacheImage
        }
        if let cacheImage = KingfisherManager.shared.cache.retrieveImageInDiskCache(forKey: key) {
            return cacheImage
        }
        let rect = CGRect(origin: .zero, size: s)
        let image = UIImage(named: s.width > 90 ? (s.width > 180 ? "default_placeholder_big" : "default_placeholder_middle") : "default_placeholder")!
        UIGraphicsBeginImageContextWithOptions(s, false, UIScreen.main.scale)
        let context = UIGraphicsGetCurrentContext()!
        if radius > 0 {
            UIBezierPath(roundedRect: rect, cornerRadius: radius).addClip()
        }
        context.setFillColor(UIColor(0xEEEEEE).cgColor)
        context.fill(rect)
        let imageW = CGFloat.minimum(s.width, s.height)
        let imageH = imageW
        let imageX = ((s.width - imageW) * 0.5).rounded(.up)
        let imageY = ((s.height - imageH) * 0.5).rounded(.up)
        image.draw(in: CGRect(x: imageX, y: imageY, width: imageW, height: imageH))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        KingfisherManager.shared.cache.store(newImage, forKey: key)
        return newImage
    }
}
