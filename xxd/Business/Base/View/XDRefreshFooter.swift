//
//  XDRefreshFooter.swift
//  xxd
//
//  Created by remy on 2017/12/29.
//  Copyright © 2017年 com.smartstudy. All rights reserved.
//

class RefreshFooterIndicatorView: UIView {
    
    var activityIndicatorView: UIImageView!
    var isAnimating = false
    
    convenience init() {
        self.init(frame: .zero)
        activityIndicatorView = UIImageView()
        activityIndicatorView.image = UIImage(named: "drag_fresh_more_loading")
        self.addSubview(activityIndicatorView)
        activityIndicatorView.snp.makeConstraints { (make) in
            make.center.equalTo(self)
        }
    }
    
    func startAnimating() {
        guard !isAnimating else {
            return
        }
        let animation = CABasicAnimation(keyPath: "transform.rotation.z")
        animation.duration = 0.5
        animation.repeatCount = HUGE
        animation.fromValue = 0
        animation.toValue = Double.pi * 2
        animation.isCumulative = true
        animation.isRemovedOnCompletion = false
        isAnimating = true
        activityIndicatorView.layer.add(animation, forKey: "")
    }
    
    func stopAnimating() {
        guard isAnimating else {
            return
        }
        activityIndicatorView.layer.removeAllAnimations()
        isAnimating = false
    }
}

class XDRefreshFooter: MJRefreshAutoFooter {
    
    var textLabel: UILabel!
    var indicatorView: RefreshFooterIndicatorView!
    
    override func prepare() {
        super.prepare()
        mj_h = 34
        
        textLabel = UILabel(text: "drag_to_load_more".localized, textColor: XDColor.itemText, fontSize: 12)
        self.addSubview(textLabel)
        textLabel.snp.makeConstraints { (make) in
            make.center.equalTo(self)
        }
        
        indicatorView = RefreshFooterIndicatorView()
        self.addSubview(indicatorView)
        indicatorView.snp.makeConstraints { (make) in
            make.size.equalTo(CGSize(width: 13, height: 13))
            make.right.equalTo(textLabel.snp.left).offset(-5)
            make.centerY.equalTo(textLabel)
        }
    }
    
    override var state: MJRefreshState {
        get {
            return super.state
        }
        set {
            if newValue != state {
                super.state = newValue
                switch state {
                case .idle:
                    indicatorView.stopAnimating()
                    indicatorView.isHidden = false
                    textLabel.text = "drag_to_load_more".localized
                case .pulling:
                    indicatorView.stopAnimating()
                    indicatorView.isHidden = false
                    textLabel.text = "drag_to_load_more".localized
                case .refreshing:
                    indicatorView.startAnimating()
                    indicatorView.isHidden = false
                    textLabel.text = "drag_refresh_is_loading_more".localized
                case .noMoreData:
                    indicatorView.stopAnimating()
                    indicatorView.isHidden = true
                    textLabel.text = "drag_refresh_is_no_more_data".localized
                default:
                    break
                }
            }
        }
    }
}
