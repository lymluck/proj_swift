//
//  EvaluationStarBar.swift
//  xxd
//
//  Created by remy on 2018/1/25.
//  Copyright © 2018年 com.smartstudy. All rights reserved.
//

import pop

protocol EvaluationStarBarDelegate: class {
    func evaluationStarBarDidMark(starCount: Int)
}

/// 评价星级视图
class EvaluationStarBar: UIView {
    
    private var _starCount = 0
    var starCount: Int {
        get {
            return _starCount
        }
        set {
            guard _starCount != newValue else { return }
            _starCount = max(0, min(5, newValue))
            delegate?.evaluationStarBarDidMark(starCount: newValue)
            for i in 0..<starMaxCount {
                starButtons[i].isSelected = i < starCount
            }
        }
    }
    var canMark = true {
        didSet {
            container.isUserInteractionEnabled = canMark
        }
    }
    weak var delegate: EvaluationStarBarDelegate?
    private var starButtons = [UIButton]()
    private var container: UIView!
    private var stopAnimatingFlag = false
    private let starMaxCount = 5
    
    /// imageType: 星星图片尺寸, 只有big/middle/small这三种类型
    init(frame: CGRect, imageType: String = "big") {
        super.init(frame: frame)
        var space: CGFloat = 16.0
        if imageType == "small" {
            space = 2.0
        }
        container = UIView()
        addSubview(container)
        container.snp.makeConstraints { (make) in
            make.edges.equalTo(self)
        }
        
        var lastStarBtn: UIButton!
        for i in 0..<starMaxCount {
            let starBtn = UIButton()
            starBtn.adjustsImageWhenHighlighted = false
            starBtn.naughty = true
            starBtn.tag = i
            starBtn.setBackgroundImage(UIImage(named: "course_evaluation_\(imageType)_star_normal"), for: .normal)
            starBtn.setBackgroundImage(UIImage(named: "course_evaluation_\(imageType)_star_selected"), for: .highlighted)
            starBtn.setBackgroundImage(UIImage(named: "course_evaluation_\(imageType)_star_selected"), for: .selected)
            starBtn.setBackgroundImage(UIImage(named: "course_evaluation_\(imageType)_star_selected"), for: [.highlighted, .selected])
            starBtn.addTarget(self, action: #selector(starBGButtonPressed(sender:)), for: .touchUpInside)
            container.addSubview(starBtn)
            starButtons.append(starBtn)
            starBtn.snp.makeConstraints({ (make) in
                if lastStarBtn != nil {
                    make.left.equalTo(lastStarBtn.snp.right).offset(space)
                } else {
                    make.left.equalTo(container)
                }
                make.top.bottom.equalTo(container)
                if i == starMaxCount - 1 {
                    make.right.equalTo(container)
                }
            })
            lastStarBtn = starBtn
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func startAnimating() {
        guard !stopAnimatingFlag else {
            stopAnimatingFlag = false
            return
        }
        for i in 0..<starMaxCount {
            if let scaleAnimation = POPSpringAnimation(propertyNamed: kPOPLayerScaleXY) {
                scaleAnimation.beginTime = CACurrentMediaTime() + 1 + 0.35 * Double(i)
                scaleAnimation.velocity = CGSize(width: 5, height: 5)
                scaleAnimation.toValue = CGSize(width: 1, height: 1)
                scaleAnimation.springBounciness = 25
                scaleAnimation.removedOnCompletion = true
                if i == starMaxCount - 1 {
                    scaleAnimation.completionBlock = {
                        [weak self] (anim, finished) in
                        self?.startAnimating()
                    }
                }
                starButtons[i].layer.pop_add(scaleAnimation, forKey: "scaleAnimation")
            }
        }
    }
    
    func stopAnimating() {
        stopAnimatingFlag = true
        for i in 0..<starMaxCount {
            starButtons[i].layer.pop_removeAnimation(forKey: "scaleAnimation")
        }
    }
    
    //MARK:- Action
    @objc func starBGButtonPressed(sender: UIButton) {
        starCount = sender.tag + 1
        stopAnimating()
    }
}
