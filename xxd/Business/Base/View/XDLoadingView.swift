//
//  XDLoadingView.swift
//  xxd
//
//  Created by remy on 2018/2/25.
//  Copyright © 2018年 com.smartstudy. All rights reserved.
//

class XDLoadingView: UIView {
    
    private var imageView1: UIImageView!
    private var imageView2: UIImageView!
    private var imageView3: UIImageView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        imageView1 = UIImageView(image: UIImage(named: "loading_1"))
        imageView1.layer.opacity = 0
        self.addSubview(imageView1)
        imageView2 = UIImageView(image: UIImage(named: "loading_2"))
        imageView2.layer.opacity = 0
        self.addSubview(imageView2)
        imageView3 = UIImageView(image: UIImage(named: "loading_3"))
        imageView3.layer.opacity = 0
        self.addSubview(imageView3)
        
        self.frame = imageView1.bounds
        
        let unitDuration = 0.35
        
        let an1 = CAKeyframeAnimation(keyPath: "opacity")
        an1.duration = unitDuration * 4.5
        an1.keyTimes = [NSNumber(value: 0), NSNumber(value: 2.0 / 9), NSNumber(value: 4.0 / 9), NSNumber(value: 1)]
        an1.values = [0, 1, 0, 0]
        an1.repeatCount = Float.greatestFiniteMagnitude
        an1.isRemovedOnCompletion = false
        imageView1.layer.add(an1, forKey: "")
        
        let an2 = CAKeyframeAnimation(keyPath: "opacity")
        an2.duration = unitDuration * 4.5
        an2.keyTimes = [NSNumber(value: 0), NSNumber(value: 2.0 / 9), NSNumber(value: 4.0 / 9), NSNumber(value: 1)]
        an2.values = [0, 1, 0, 0]
        an2.repeatCount = Float.greatestFiniteMagnitude
        an2.isRemovedOnCompletion = false
        an2.beginTime = CACurrentMediaTime() + unitDuration * 1.5
        imageView2.layer.add(an2, forKey: "")
        
        let an3 = CAKeyframeAnimation(keyPath: "opacity")
        an3.duration = unitDuration * 4.5
        an3.keyTimes = [NSNumber(value: 0), NSNumber(value: 2.0 / 9), NSNumber(value: 4.0 / 9), NSNumber(value: 1)]
        an3.values = [0, 1, 0, 0]
        an3.repeatCount = Float.greatestFiniteMagnitude
        an3.isRemovedOnCompletion = false
        an3.beginTime = CACurrentMediaTime() + unitDuration * 3
        imageView3.layer.add(an3, forKey: "")
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
