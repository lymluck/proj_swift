//
//  EvaluationStarLine.swift
//  xxd
//
//  Created by remy on 2018/1/25.
//  Copyright © 2018年 com.smartstudy. All rights reserved.
//

class EvaluationStarLine: UIView {
    
    private var _starCount = 0
    private let starMaxCount = 5
    private var starViews = [UIImageView]()
    var starCount: Int {
        get {
            return _starCount
        }
        set {
            _starCount = max(0, min(5, newValue))
            for i in 0..<starMaxCount {
                starViews[i].isHighlighted = i < _starCount
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        var lastView: UIView!
        for i in 0..<starMaxCount {
            let starView = UIImageView(image: UIImage(named: "course_evaluation_small_star_normal"), highlightedImage: UIImage(named: "course_evaluation_small_star_selected"))
            addSubview(starView)
            starViews.append(starView)
            starView.snp.makeConstraints({ (make) in
                if lastView != nil {
                    make.left.equalTo(lastView.snp.right).offset(3)
                } else {
                    make.left.equalTo(self)
                }
                make.top.bottom.equalTo(self)
                if i == starMaxCount - 1 {
                    make.right.equalTo(self)
                }
            })
            lastView = starView
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
