//
//  ScannerView.swift
//  xxd
//
//  Created by Lisen on 2018/8/13.
//  Copyright © 2018 com.smartstudy. All rights reserved.
//

import UIKit

class ScannerView: UIView {
    
    private lazy var leftTopImageView: UIImageView = UIImageView(frame: .zero, imageName: "left_top_cor")
    private lazy var leftBottomImageView: UIImageView = UIImageView(frame: .zero, imageName: "left_bottom_cor")
    private lazy var rightTopImageView: UIImageView = UIImageView(frame: .zero, imageName: "right_top_cor")
    private lazy var rightBottomImageView: UIImageView = UIImageView(frame: .zero, imageName: "right_bottom_cor")
    private lazy var lineImageView: UIImageView = UIImageView(frame: CGRect(origin: CGPoint.zero, size: self.bounds.size), imageName: "scanner_lines")
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initContentViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func layoutSubviews() {
        leftTopImageView.snp.makeConstraints { (make) in
            make.left.top.equalToSuperview()
            make.width.height.equalTo(16.0)
        }
        leftBottomImageView.snp.makeConstraints { (make) in
            make.left.bottom.equalToSuperview()
            make.width.height.equalTo(16.0)
        }
        rightTopImageView.snp.makeConstraints { (make) in
            make.right.top.equalToSuperview()
            make.width.height.equalTo(16.0)
        }
        rightBottomImageView.snp.makeConstraints { (make) in
            make.right.bottom.equalToSuperview()
            make.width.height.equalTo(16.0)
        }
    }
    
    private func initContentViews() {
        addSubview(lineImageView)
        layer.masksToBounds = true
        addSubview(leftTopImageView)
        addSubview(leftBottomImageView)
        addSubview(rightTopImageView)
        addSubview(rightBottomImageView)
        let cornerLayer: CAShapeLayer = CAShapeLayer()
        cornerLayer.frame = bounds
        cornerLayer.borderColor = UIColor(white: 1.0, alpha: 0.7).cgColor
        cornerLayer.borderWidth = 0.5
        layer.insertSublayer(cornerLayer, at: 0)
    }
    
    func animateScannerLines() {
        lineImageView.top = -bounds.height
        UIView.animate(withDuration: 2.0, delay: 0.0, options: [.curveEaseIn, .repeat], animations: {
            self.lineImageView.top += self.bounds.height
        }, completion: { _ in
            
        })
    }
    
}
