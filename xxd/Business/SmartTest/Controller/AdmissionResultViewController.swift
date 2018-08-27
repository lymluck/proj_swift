//
//  AdmissionResultViewController.swift
//  xxd
//
//  Created by remy on 2018/2/1.
//  Copyright © 2018年 com.smartstudy. All rights reserved.
//

import QuartzCore

class AdmissionResultViewController: SSViewController {
    
    var isUS = false
    var model: AdmissionResultModel!
    private let separator = "|"
    private let stateColors = [0xF6611D,0xFF8A00,0x3DBA9F,0x03BD52,0x639CEF]
    private var scrollView: XDScrollView!
    private var topView: UIView!
    private var bottomView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = XDColor.mainBackground
        title = "title_admission_test_result".localized
        
        scrollView = XDScrollView(frame: CGRect(x: 0, y: XDSize.topHeight, width: XDSize.screenWidth, height: XDSize.visibleHeight))
        scrollView.bottomSpace = 28
        view.addSubview(scrollView)
        
        initTopView()
        initBottomView()
    }
    
    private func initTopView() {
        topView = UIView(frame: CGRect(x: 0, y: 0, width: XDSize.screenWidth, height: 505), color: UIColor.white)
        scrollView.addSubview(topView)
        
        let logoWrap = UIView(frame: CGRect(x: (XDSize.screenWidth - 100) * 0.5, y: 24, width: 100, height: 100))
        logoWrap.backgroundColor = UIColor.white
        logoWrap.layer.cornerRadius = 50
        logoWrap.layer.shadowRadius = 3
        logoWrap.layer.shadowColor = UIColor.black.cgColor
        logoWrap.layer.shadowOpacity = 0.1
        logoWrap.layer.shadowOffset = CGSize(width: 0, height: 2)
        let logo = UIImageView(frame: CGRect(x: 12, y: 12, width: 76, height: 76))
        logo.layer.cornerRadius = 38
        logo.layer.masksToBounds = true
        logoWrap.addSubview(logo)
        topView.addSubview(logoWrap)
        
        let logoUrl = UIImage.OSSImageURLString(urlStr: model.schoolLogo, size: logo.size, policy: .pad)
        logo.kf.setImage(with: URL(string: logoUrl), placeholder: UIImage(named: "default_college_logo"))
        
        let chineseName = UILabel(frame: CGRect(x: 16, y: logoWrap.bottom + 12, width: XDSize.screenWidth - 32, height: 25), text: model.schoolChineseName, textColor: XDColor.itemTitle, fontSize: 18, bold: true)!
        chineseName.textAlignment = .center
        topView.addSubview(chineseName)
        
        let englishName = UILabel(frame: CGRect(x: 16, y: chineseName.bottom, width: XDSize.screenWidth - 32, height: 16), text: model.schoolEnglishName, textColor: XDColor.itemText, fontSize: 13)!
        englishName.textAlignment = .center
        topView.addSubview(englishName)
        
        let line = UIView(frame: CGRect(x: 16, y: englishName.bottom + 20, width: XDSize.screenWidth - 32, height: XDSize.unitWidth), color: UIColor(0xDDDDDD))
        topView.addSubview(line)
        
        let descText = String(format: "target_to_you".localized, model.schoolChineseName)
        let desc = UILabel(frame: CGRect(x: 16, y: line.bottom + 20, width: XDSize.screenWidth - 32, height: 20), text: descText, textColor: XDColor.itemText, fontSize: 14)!
        desc.textAlignment = .center
        topView.addSubview(desc)
        
        var rateIndex = 4
        if model.rate < 10 {
            rateIndex = 0
        } else if model.rate < 20 {
            rateIndex = 1
        } else if model.rate < 40 {
            rateIndex = 2
        } else if model.rate < 60 {
            rateIndex = 3
        }
        let stateStr = "admission_state".localized.components(separatedBy: ",")[rateIndex]
        let stateColor = UIColor(stateColors[rateIndex])
        
        let state = UILabel(frame: CGRect(x: 0, y: desc.bottom + 20, width: XDSize.screenWidth, height: 30), text: stateStr, textColor: stateColor, fontSize: 22, bold: true)!
        state.textAlignment = .center
        topView.addSubview(state)
        
        var left: CGFloat = (XDSize.screenWidth - 46 * 5) * 0.5
        var i = 0
        while i <= rateIndex {
            let star = UIImageView(frame: CGRect(x: left + CGFloat(i * 46), y: state.bottom + 10, width: 46, height: 38), imageName: "star_gold")!
            topView.addSubview(star)
            i += 1
        }
        while i < 5 {
            let star = UIImageView(frame: CGRect(x: left + CGFloat(i * 46), y: state.bottom + 10, width: 46, height: 38), imageName: "star_gray")!
            topView.addSubview(star)
            i += 1
        }
        
        left = (XDSize.screenWidth - 94 * 2 - 55) * 0.5
        let leftView = rateStateView(model.rate, 0)
        leftView.left = left
        let rightView = rateStateView(model.averageRate, 1)
        rightView.left = leftView.right + 55
    }
    
    private func rateStateView(_ rate: Int, _ index: Int) -> UIView {
        let descName = ["your_admission_rate","average_admission_rate"][index]
        let color = [UIColor(0xFFB400),XDColor.main][index]
        
        let view = UIView(frame: CGRect(x: 0, y: 373, width: 94, height: 94))
        topView.addSubview(view)
        
        let rateView = UILabel(frame: CGRect(x: 0, y: 20, width: view.width, height: 28), text: "\(rate)%", textColor: color, fontSize: 20)!
        rateView.textAlignment = .center
        view.addSubview(rateView)
        
        let descView = UILabel(frame: CGRect(x: 0, y: 50, width: view.width, height: 16), text: descName.localized, textColor: UIColor(0xAAAAAA), fontSize: 11)!
        descView.textAlignment = .center
        view.addSubview(descView)
        
        rollUnderHalf(index, view, Double(rate))
        return view
    }
    
    private func rollUnderHalf(_ index: Int, _ view: UIView, _ value: Double) {
        let bottomCircleName = ["right_circle_1","right_circle_2"][index]
        let bottomCircle = circleLayer(CGPoint(x: 0, y: 0.5), CGRect(x: 47, y: 0, width: 47, height: 94), bottomCircleName)
        let middleCircle = circleLayer(CGPoint(x: 0, y: 0.5), CGRect(x: 47, y: 0, width: 47, height: 94), "half_circle")
        middleCircle.backgroundColor = UIColor.white.cgColor
        let topCircle = circleLayer(CGPoint(x: 0, y: 0.5), CGRect(x: 47, y: 0, width: 47, height: 94), "half_circle")
        
        view.layer.insertSublayer(topCircle, at: 0)
        view.layer.insertSublayer(middleCircle, at: 0)
        view.layer.insertSublayer(bottomCircle, at: 0)
        
        let step = (value > 50 ? 50 : value) / 50
        let angle = Double.pi * step
        middleCircle.transform = CATransform3DMakeRotation(CGFloat(angle), 0, 0, 1)
        topCircle.transform = CATransform3DMakeRotation(.pi, 0, 0, 1)
        
        CATransaction.begin()
        CATransaction.setCompletionBlock {
            [weak self] in
            if value > 50 {
                bottomCircle.removeFromSuperlayer()
                middleCircle.removeFromSuperlayer()
                topCircle.removeFromSuperlayer()
                self?.rollOverHalf(index, view, value)
            }
        }
        
        let an = CABasicAnimation(keyPath: "transform.rotation.z")
        an.fromValue = 0
        an.toValue = angle
        an.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn)
        an.duration = 1.5
        middleCircle.add(an, forKey: "rotate")
        CATransaction.commit()
    }
    
    private func rollOverHalf(_ index: Int, _ view: UIView, _ value: Double) {
        let bottomCircleName = ["left_circle_1","left_circle_2"][index]
        let topCircleName = ["right_circle_1","right_circle_2"][index]
        let bottomCircle = circleLayer(CGPoint(x: 0, y: 0.5), CGRect(x: 0, y: 0, width: 47, height: 94), bottomCircleName)
        let middleCircle = circleLayer(CGPoint(x: 0, y: 0.5), CGRect(x: 47, y: 0, width: 47, height: 94), "half_circle")
        middleCircle.backgroundColor = UIColor.white.cgColor
        let topCircle = circleLayer(CGPoint(x: 0, y: 0.5), CGRect(x: 47, y: 0, width: 47, height: 94), topCircleName)
        
        view.layer.insertSublayer(topCircle, at: 0)
        view.layer.insertSublayer(middleCircle, at: 0)
        view.layer.insertSublayer(bottomCircle, at: 0)
        
        let step = value / 50
        let angle = Double.pi * step
        middleCircle.transform = CATransform3DMakeRotation(CGFloat(angle), 0, 0, 1)
        
        let an = CABasicAnimation(keyPath: "transform.rotation.z")
        an.fromValue = Double.pi
        an.toValue = angle
        an.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        an.duration = 1.5 * (step - 1)
        middleCircle.add(an, forKey: "rotate")
    }
    
    private func circleLayer(_ anchorPoint: CGPoint, _ rect: CGRect, _ imageName: String) -> CALayer {
        let layer = CALayer()
        layer.anchorPoint = anchorPoint
        layer.frame = rect
        layer.contents = UIImage(named: imageName)!.cgImage
        return layer
    }
    
    private func initBottomView() {
        bottomView = UIView(frame: CGRect(x: 0, y: topView.bottom + 16, width: XDSize.screenWidth, height: 0), color: UIColor.white)
        scrollView.addSubview(bottomView)
        
        let resultTitle = UILabel(frame: CGRect(x: 0, y: 0, width: XDSize.screenWidth, height: 52), text: "result_comment".localized, textColor: XDColor.itemTitle, fontSize: 17)!
        resultTitle.textAlignment = .center
        bottomView.addSubview(resultTitle)
        
        let item1 = XDItemView(frame: CGRect(x: 0, y: resultTitle.bottom, width: XDSize.screenWidth, height: 0), type: .top)
        let item2 = XDItemView(frame: CGRect(x: 0, y: 0, width: XDSize.screenWidth, height: 0), type: .middle)
        let item3 = XDItemView(frame: CGRect(x: 0, y: 0, width: XDSize.screenWidth, height: 0), type: .plain)
        let itemList = [item1,item2,item3]
        
        var models = [AdmissionDescModel]()
        if let v = Double(model.toefl), v > 0 {
            models.append(AdmissionDescModel(model: model, type: .toefl))
        } else if let v = Double(model.ielts), v > 0 {
            models.append(AdmissionDescModel(model: model, type: .ielts))
            models[0].scoreFormat = "%.1lf"
        }
        
        if isUS {
            if model.projectID == "MDT_MASTER" {
                if let v = Double(model.gre), v > 0 {
                    models.append(AdmissionDescModel(model: model, type: .gre))
                } else if let v = Double(model.gmat), v > 0 {
                    models.append(AdmissionDescModel(model: model, type: .gmat))
                }
            } else {
                if let v = Double(model.sat), v > 0 {
                    models.append(AdmissionDescModel(model: model, type: .sat))
                } else if let v = Double(model.act), v > 0 {
                    models.append(AdmissionDescModel(model: model, type: .act))
                }
            }
        }
        
        var heightAll: CGFloat = 0
        for (index, model) in models.enumerated() {
            let typeStr = model.type.rawValue
            var heightItem: CGFloat = 0
            let scoreStr = String(format: model.scoreFormat, Double(model.score) ?? 0)
            let qualifiedStr = String(format: model.scoreFormat, Double(model.qualified) ?? 0)
            
            // 标题
            let titleScoreStr = model.score.isEmpty ? "score_empty".localized : scoreStr
            let titleText = String(format: "your_score_title".localized, index + 1, typeStr)
            let titleAttr = NSAttributedString(string: titleText) + NSAttributedString(string: titleScoreStr).color(UIColor(0xFF8A00))
            let titleLabel = UILabel(frame: CGRect(x: 16, y: 20, width: XDSize.screenWidth - 16, height: 22), text: "", textColor: XDColor.itemTitle, fontSize: 16)!
            titleLabel.attributedText = titleAttr
            itemList[index].addSubview(titleLabel)
            heightItem += 42
            
            // 详细内容
            var urlStr = ""
            let descLabel = UILabel(frame: CGRect(x: 32, y: titleLabel.bottom + 12, width: XDSize.screenWidth - 48, height: 0), text: "", textColor: UIColor(0x58646E), fontSize: 15)!
            descLabel.numberOfLines = 0
            var descText = ""
            var descAttr = NSMutableAttributedString()
            if model.score.isEmpty {
                // 未填写
                descText = String(format: "your_score_state1".localized, typeStr, qualifiedStr, self.model.schoolChineseName, typeStr)
                descAttr += addAttr(descText, XDColor.main)
            } else {
                let scoreNum = Double(scoreStr)!
                let qualifiedNum = Double(qualifiedStr)!
                let scoreSpace = scoreNum - qualifiedNum
                if scoreSpace < 0 {
                    // 分数未达到
                    let space = String(format: model.scoreFormat, -scoreSpace)
                    descText = String(format: "your_score_state2_0".localized, typeStr, space)
                    descAttr += addAttr(descText, XDColor.main)
                    descText = String(format: "your_score_state2_1".localized, model.winRate, typeStr, typeStr, qualifiedStr)
                    descAttr += addAttr(descText, XDColor.main)
                    urlStr = String(format: XD_WEB_COURSE_RECOMMEND, model.type.rawValue)
                } else {
                    if qualifiedNum > 0 {
                        // 有录取分
                        if scoreSpace > 0 {
                            // 分数超出
                            let space = String(format: model.scoreFormat, scoreSpace)
                            descText = String(format: "your_score_state3_0".localized, typeStr, space)
                            descAttr += addAttr(descText, XDColor.main)
                        } else {
                            // 分数刚好
                            descText = String(format: "your_score_state3_1".localized, typeStr)
                            descAttr += descText
                        }
                        descText = String(format: "your_score_state3_2".localized, model.winRate)
                        descAttr += addAttr(descText, XDColor.main)
                        descText = String(format: "your_score_state3_3".localized, typeStr)
                        descAttr += descText
                    } else {
                        // 没有录取分
                        descText = String(format: "your_score_state3_2".localized, model.winRate)
                        descAttr += addAttr(descText, XDColor.main)
                        descAttr += "your_score_state3_4".localized
                        urlStr = String(format: XD_WEB_COURSE_RECOMMEND, model.type.rawValue)
                    }
                }
            }
            descLabel.setLineSpaceAttr(descAttr)
            let height = descAttr.string.heightForFont(descLabel.font, descLabel.width, 21)
            descLabel.height = height
            itemList[index].addSubview(descLabel)
            heightItem += 12 + descLabel.height + 20
            
            if !urlStr.isEmpty {
                let courseLabel = UILabel(frame: CGRect(x: 32, y: descLabel.bottom, width: XDSize.screenWidth - 48, height: 54), text: urlStr, textColor: XDColor.main, fontSize: 14)!
                courseLabel.isUserInteractionEnabled = true
                courseLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(courseTap(gestureRecognizer:))))
                itemList[index].addSubview(courseLabel)
                heightItem += 34
            }
            
            itemList[index].top = resultTitle.bottom + heightAll
            itemList[index].height = heightItem
            heightAll += heightItem
            bottomView.addSubview(itemList[index])
        }
        bottomView.height = resultTitle.height + heightAll
        
        let tip = UILabel(frame: CGRect(x: 16, y: bottomView.bottom + 16, width: XDSize.screenWidth - 32, height: 0), text: "test_disclaimer".localized, textColor: XDColor.itemText, fontSize: 13)!
        tip.height = tip.text!.heightForFont(tip.font, tip.width)
        tip.numberOfLines = 3
        scrollView.addSubview(tip)
        
        let btnWidth = (XDSize.screenWidth * 164 / 375).rounded()
        let btnHeight = (XDSize.screenHeight * 42 / 667).rounded()
        let space = (XDSize.screenWidth * 47 / 375 / 3).rounded()
        let btn1 = UIButton(frame: CGRect(x: space, y: tip.bottom + 24, width: btnWidth, height: btnHeight), title: "share".localized, fontSize: 15, titleColor: UIColor.white, target: self, action: #selector(shareResult))!
        btn1.backgroundColor = UIColor(0x03BD52)
        btn1.layer.cornerRadius = 6
        scrollView.addSubview(btn1)
        let btn2 = UIButton(frame: CGRect(x: XDSize.screenWidth - btnWidth - space, y: tip.bottom + 24, width: btnWidth, height: btnHeight), title: "online_consult".localized, fontSize: 15, titleColor: UIColor.white, target: self, action: #selector(gotoChat))!
        btn2.backgroundColor = XDColor.main
        btn2.layer.cornerRadius = 6
        scrollView.addSubview(btn2)
    }
    
    private func addAttr(_ str: String, _ color: UIColor) -> NSAttributedString {
        let arr = str.components(separatedBy: separator)
        let attr = NSAttributedString(string: arr[1]).color(color)
        return arr[0] + attr + arr[2]
    }
    
    //MARK:- Action
    @objc func courseTap(gestureRecognizer: UIGestureRecognizer) {
        let view = gestureRecognizer.view as! UILabel
        XDRoute.pushWebVC([QueryKey.URLPath:"\(view.text!)?hmsr=xxd"])
    }
    
    @objc func shareResult() {
        let urlStr = "\(XDEnvConfig.webHost)/\(String(format: XD_WEB_ADMISSION_RATE_RESULT, model.resultID))"
        XDShareView.shared.showSharePanel(shareURL: urlStr, shareInfo: [
            "title": "share_desc".localized,
            "description": "title_admission_test_result".localized,
            "coverUrl": model.schoolLogo
        ])
    }
    
    @objc func gotoChat() {
        XDRoute.pushMQChatVC()
        
    }
}
