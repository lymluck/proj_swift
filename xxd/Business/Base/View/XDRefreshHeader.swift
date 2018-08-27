//
//  XDRefreshHeader.swift
//  xxd
//
//  Created by remy on 2017/12/29.
//  Copyright © 2017年 com.smartstudy. All rights reserved.
//

private let gifPath = Bundle.main.path(forResource: "drag_refresh", ofType: "gif")!
private let gifData = try? Data(contentsOf: URL(fileURLWithPath: gifPath))
private let gifImage = UIImage(smallGIFData: gifData, scale: UIScreen.main.scale)!
private let gifImages = gifImage.images!
private let gifDuration = gifImage.duration

class XDRefreshHeader: MJRefreshStateHeader {
    
    lazy var gifView = UIImageView()
    lazy var stateImages = [MJRefreshState : Any]()
    lazy var stateDurations = [MJRefreshState : Any]()
    
    func setImages(images: [UIImage]?, duration: TimeInterval, for state: MJRefreshState) {
        if let images = images {
            stateImages[state] = images
            stateDurations[state] = duration
            if let image = images.first, image.size.height > mj_h {
                mj_h = image.size.height
            }
        }
    }
    
    func setImages(images: [UIImage]?, for state: MJRefreshState) {
        if let images = images {
            setImages(images: images, duration: Double(images.count) * 0.1, for: state)
        }
    }
    
    override func prepare() {
        super.prepare()
        // 初始化间距
        labelLeftInset = 20
        
        setImages(images: [gifImages.first!], for: .idle)
        setImages(images: [gifImages.first!], for: .pulling)
        setImages(images: gifImages, duration: gifDuration, for: .refreshing)
        
        lastUpdatedTimeLabel.isHidden = true
        stateLabel.isHidden = true
        gifView.image = gifImages.first!
        self.addSubview(gifView)
    }
    
    override var pullingPercent: CGFloat {
        didSet {
            if let images = stateImages[.idle] as? [UIImage] {
                if state != .idle || images.count == 0 { return }
                // 停止动画
                if !isBackToOrigin() {
                    gifView.stopAnimating()
                }
                // 设置当前需要显示的图片
                var index = images.count * Int(pullingPercent)
                if index >= images.count {
                    index = images.count - 1
                }
                gifView.image = images[index]
                var scale = min(1, max(pullingPercent, 0.000001))
                if fabs(pullingPercent) < 0.00001 {
                    scale = 1
                }
                gifView.transform = CGAffineTransform(scaleX: scale, y: scale)
            }
        }
    }
    
    override var state: MJRefreshState {
        get {
            return super.state
        }
        set {
            if newValue != state {
                super.state = newValue
                //MARK: 崩溃发生的地方
                // 根据状态做事情
                if newValue == .pulling || newValue == .refreshing {
                    if let images = stateImages[newValue] as? [UIImage], images.count > 0 {
                        gifView.stopAnimating()
                        if images.count == 1 {
                            // 单张图片
                            gifView.image = images.last
                        } else {
                            // 多张图片
                            gifView.animationImages = images
                            gifView.animationDuration = stateDurations[newValue] as! TimeInterval
                            gifView.startAnimating()
                        }
                    }
                } else if newValue == .idle {
                    if !isBackToOrigin() {
                        gifView.stopAnimating()
                    }
                }
            }
        }
    }
    
    override func placeSubviews() {
        super.placeSubviews()
        if gifView.constraints.count > 0 { return }
        gifView.frame = bounds
        if stateLabel.isHidden && lastUpdatedTimeLabel.isHidden {
            gifView.contentMode = .center
        } else {
            gifView.contentMode = .right
            let stateWidth = stateLabel.mj_textWith()
            var timeWidth: CGFloat = 0
            if !lastUpdatedTimeLabel.isHidden {
                timeWidth = lastUpdatedTimeLabel.mj_textWith()
            }
            let textWidth = max(stateWidth, timeWidth)
            gifView.mj_w = mj_w * 0.5 - textWidth * 0.5 - labelLeftInset
        }
    }
    
    func isBackToOrigin() -> Bool {
        if scrollView != nil {
            if let animationKeys = scrollView.layer.animationKeys() {
                if scrollView.contentOffset.y == 0 && (animationKeys.contains("bounds.size") && animationKeys.contains("bounds.origin")) || scrollView.contentOffset.y != 0 {
                    return true
                }
            }
        }
        return false
    }
}
