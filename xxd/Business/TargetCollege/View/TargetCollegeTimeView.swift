//
//  TargetCollegeTimeView.swift
//  xxd
//
//  Created by Lisen on 2018/6/4.
//  Copyright © 2018年 com.smartstudy. All rights reserved.
//

import UIKit

/// 意向出国时间图表视图
class TargetCollegeTimeView: UIView {
    var models: [TargetCollegeAbroadTimeModel]? {
        didSet {
            if models != nil {
                var totalNums: Int = 0
                for model in models! {
                    totalNums += model.count
                }
                // TODO: 代码优化
                configureTimeTagView(firstTagView, model: models![0])
                configureTimeTagView(secondTagView, model: models![1])
                configureTimeTagView(thirdTagView, model: models![2])
                configureTimeTagView(forthTagView, model: models![3])
                let firstLayerEndAngle = -CGFloat(models![0].count)/CGFloat(totalNums)*CGFloat(Double.pi*2.0)
                let secondLayerEndAngle = firstLayerEndAngle - CGFloat(models![1].count)/CGFloat(totalNums)*CGFloat(Double.pi*2.0)
                let thirdLayerEndAngle = secondLayerEndAngle - CGFloat(models![2].count)/CGFloat(totalNums)*CGFloat(Double.pi*2.0)
                configureShapeLayer(0.0, firstLayerEndAngle, UIColor(0xFA6B94))
                configureShapeLayer(firstLayerEndAngle, secondLayerEndAngle, UIColor(0x486FC3))
                configureShapeLayer(secondLayerEndAngle, thirdLayerEndAngle, UIColor(0xFFD87F))
                configureShapeLayer(thirdLayerEndAngle, CGFloat(Double.pi)*2.0, UIColor(0x51D6C1))
            }
        }
    }
    
    private lazy var chartView: UIView = UIView(frame: CGRect.zero, color: UIColor.clear)
    private lazy var firstTagView: TimeTagView = {
        let view: TimeTagView = TimeTagView(frame: CGRect.zero)
        view.dotColor = UIColor(0xFA6B94)
        return view
    }()
    private lazy var secondTagView: TimeTagView = {
        let view: TimeTagView = TimeTagView(frame: CGRect.zero)
        view.dotColor = UIColor(0x486FC3)
        return view
    }()
    private lazy var thirdTagView: TimeTagView = {
        let view: TimeTagView = TimeTagView(frame: CGRect.zero)
        view.dotColor = UIColor(0xFFD87F)
        return view
    }()
    private lazy var forthTagView: TimeTagView = {
        let view: TimeTagView = TimeTagView(frame: CGRect.zero)
        view.dotColor = UIColor(0x51D6C1)
        return view
    }()
    private lazy var titleLabel: UILabel = UILabel(frame: CGRect(x: 16.0, y: 24.0, width: 200.0, height: 18.0), text: "意向出国时间: ", textColor: UIColor(0x26343F), fontSize: 18.0, bold: true)
//    private lazy var firstLayer: CAShapeLayer = {
//        let shapeLayer: CAShapeLayer = CAShapeLayer()
//        shapeLayer.frame = chartView.bounds
//        shapeLayer.lineWidth = 40.0
//        shapeLayer.fillColor = UIColor.clear.cgColor
//        shapeLayer.strokeColor = UIColor(0xFA6B94).cgColor
//        return shapeLayer
//    }()
//    private lazy var secondLayer: CAShapeLayer = {
//        let shapeLayer: CAShapeLayer = CAShapeLayer()
//        shapeLayer.frame = chartView.bounds
//        shapeLayer.lineWidth = 40.0
//        shapeLayer.fillColor = UIColor.clear.cgColor
//        shapeLayer.strokeColor = UIColor(0x486FC3).cgColor
//        return shapeLayer
//    }()
//    private lazy var thirdLayer: CAShapeLayer = {
//        let shapeLayer: CAShapeLayer = CAShapeLayer()
//        shapeLayer.frame = chartView.bounds
//        shapeLayer.lineWidth = 40.0
//        shapeLayer.fillColor = UIColor.clear.cgColor
//        shapeLayer.strokeColor = UIColor(0xFFD87F).cgColor
//        return shapeLayer
//    }()
//    private lazy var forthLayer: CAShapeLayer = {
//        let shapeLayer: CAShapeLayer = CAShapeLayer()
//        shapeLayer.frame = chartView.bounds
//        shapeLayer.lineWidth = 40.0
//        shapeLayer.fillColor = UIColor.clear.cgColor
//        shapeLayer.strokeColor = UIColor(0x51D6C1).cgColor
//        return shapeLayer
//    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initContentViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func initContentViews() {
        backgroundColor = UIColor.white
        addSubview(secondTagView)
        secondTagView.snp.makeConstraints { (make) in
            make.left.equalTo(26.0)
            make.top.equalToSuperview().offset(66.0)
            make.width.equalTo(90.0)
            make.height.equalTo(44.0)
        }
        addSubview(firstTagView)
        firstTagView.snp.makeConstraints { (make) in
            make.right.equalTo(-26.0)
            make.top.equalTo(secondTagView)
            make.width.equalTo(90.0)
            make.height.equalTo(44.0)
        }
        addSubview(thirdTagView)
        thirdTagView.snp.makeConstraints { (make) in
            make.left.equalTo(26.0)
            make.bottom.equalTo(-24.0)
            make.width.equalTo(90.0)
            make.height.equalTo(44.0)
        }
        addSubview(forthTagView)
        forthTagView.snp.makeConstraints { (make) in
            make.right.equalTo(-26.0)
            make.bottom.equalTo(-24.0)
            make.width.equalTo(90.0)
            make.height.equalTo(44.0)
        }
        addSubview(chartView)
        chartView.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
            make.width.height.equalTo(200.0)
        }
        addSubview(titleLabel)
//        chartView.layer.addSublayer(firstLayer)
//        chartView.layer.addSublayer(secondLayer)
//        chartView.layer.addSublayer(thirdLayer)
//        chartView.layer.addSublayer(forthLayer)
    }
    
    private func configureShapeLayer(_ startAngle: CGFloat, _ endAngle: CGFloat, _ strokeColor: UIColor) {
        let shapeLayer: CAShapeLayer = CAShapeLayer()
        shapeLayer.frame = chartView.bounds
        shapeLayer.lineWidth = 40.0
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.strokeColor = strokeColor.cgColor
        shapeLayer.path = UIBezierPath(arcCenter: CGPoint(x: 100.0, y: 100.0), radius: 60.0, startAngle: startAngle, endAngle: endAngle, clockwise: false).cgPath
        chartView.layer.addSublayer(shapeLayer)
    }
    
    private func configureBezierPath(for shapeLayer: CAShapeLayer, _ startAngle: CGFloat, _ endAngle: CGFloat) {
        
        
        shapeLayer.path = UIBezierPath(arcCenter: CGPoint(x: 100.0, y: 100.0), radius: 60.0, startAngle: startAngle, endAngle: endAngle, clockwise: false).cgPath
    }
    
    private func configureTimeTagView(_ tagView: TimeTagView, model: TargetCollegeAbroadTimeModel) {
        tagView.timeLabel.text = model.year
        tagView.numberLabel.text = "\(model.count) 人"
    }
}

/// 出国时间标签视图
class TimeTagView: UIView {
    var dotColor: UIColor = UIColor.white {
        didSet {
            dotView.backgroundColor = dotColor
        }
    }
    private lazy var dotView: UIView = {
        let view: UIView = UIView(frame: CGRect(x: 0.0, y: 7.0, width: 8.0, height: 8.0))
        view.layer.cornerRadius = 4.0
        return view
    }()
    lazy var timeLabel: UILabel = {
        let label: UILabel = UILabel(frame: CGRect(x: 12.0, y: 0.0, width: 70.0, height: 21.0), text: "", textColor: UIColor(0x949BA1), fontSize: 15.0)
        return label
    }()
    lazy var numberLabel: UILabel = {
        let label: UILabel = UILabel(frame: CGRect.zero, text: "", textColor: UIColor(0x949BA1), fontSize: 15.0)
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(dotView)
        addSubview(timeLabel)
        addSubview(numberLabel)
        numberLabel.snp.makeConstraints { (make) in
            make.top.equalTo(timeLabel.snp.bottom).offset(2.0)
            make.left.equalTo(timeLabel)
            make.height.equalTo(21.0)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}


