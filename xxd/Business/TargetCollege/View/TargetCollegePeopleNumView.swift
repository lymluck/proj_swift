//
//  TargetCollegePeopleNumView.swift
//  xxd
//
//  Created by Lisen on 2018/6/4.
//  Copyright © 2018年 com.smartstudy. All rights reserved.
//

import UIKit

// TODO: 代码优化

/// 
class TargetCollegePeopleNumView: UIView {
    private lazy var colors = [UIColor(0xFE5252), UIColor(0x078CF1), UIColor(0x03BD52)]
    private let viewWidth: CGFloat = (XDSize.screenWidth-48.0)/3
    private lazy var titleLabel: UILabel = UILabel(frame: CGRect(x: 16.0, y: 24.0, width: 200.0, height: 18.0), text: "", textColor: UIColor(0x26343F), fontSize: 18.0, bold: true)
    
    init(frame: CGRect, models: [TargetCollegeMatchTypeModel]) {
        super.init(frame: frame)
        backgroundColor = UIColor.white
        var totalNum: Int = 0
        for (index, value) in models.enumerated() {
            let selectionView: TargetCollegePeopleSelectionView = TargetCollegePeopleSelectionView(frame: CGRect(x: 16.0+(viewWidth+8.0)*CGFloat(index), y: 66.0, width: viewWidth, height: 64.0))
            totalNum += value.usersCount
            selectionView.squareColor = colors[index]
            selectionView.viewModel = value
            addSubview(selectionView)
        }
        titleLabel.text = "\(totalNum)人选择了该校: "
        addSubview(titleLabel)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class TargetCollegePeopleSelectionView: UIView {
    
    var viewModel: TargetCollegeMatchTypeModel? {
        didSet {
            numberLabel.attributedText = NSAttributedString(string: "\(viewModel?.usersCount ?? 0)", attributes: [NSAttributedStringKey.font: UIFont.boldNumericalFontOfSize(20.0)]) + " 人"
            optionLabel.text = viewModel?.name
            if (viewModel?.usersIncludeMe)! {
                mineLabel.textAlignment = .right
                mineLabel.isHidden = false
                maskImage.isHidden = false
            }
        }
    }
    
    var squareColor: UIColor = UIColor.white {
        didSet {
            squareView.backgroundColor = squareColor
        }
    }
    private lazy var squareView: UIView = {
        let view: UIView = UIView(frame: CGRect.zero)
        view.layer.cornerRadius = 6.0
        view.addSubview(numberLabel)
        numberLabel.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
        }
        return view
    }()
    private lazy var numberLabel: UILabel = {
        let label: UILabel = UILabel(frame: CGRect.zero, text: "", textColor: UIColor.white, fontSize: 10.0)
        return label
    }()
    private lazy var optionLabel: UILabel = {
        let label: UILabel = UILabel(frame: CGRect.zero, text: "", textColor: UIColor(0x949BA1), fontSize: 15.0)
        return label
    }()
    private lazy var mineLabel: UILabel = UILabel(frame: CGRect.zero, text: "我", textColor: UIColor.white, fontSize: 10.0)
    private lazy var maskImage: UIImageView = UIImageView(frame: CGRect.zero, imageName: "cornerShadow")
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        squareView.frame = self.bounds
        mineLabel.isHidden = true
        maskImage.isHidden = true
        addSubview(squareView)
        squareView.snp.makeConstraints { (make) in
            make.left.top.right.equalToSuperview()
            make.height.equalTo(64.0)
        }
        addSubview(optionLabel)
        optionLabel.snp.makeConstraints { (make) in
            make.top.equalTo(squareView.snp.bottom).offset(12.0)
            make.centerX.equalToSuperview()
        }
        addSubview(mineLabel)
        mineLabel.snp.makeConstraints { (make) in
            make.top.equalTo(4.0)
            make.right.equalTo(-4.0)
            make.width.height.equalTo(10.0)
        }
        addSubview(maskImage)
        maskImage.snp.makeConstraints { (make) in
            make.top.right.equalToSuperview()
        }

    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
