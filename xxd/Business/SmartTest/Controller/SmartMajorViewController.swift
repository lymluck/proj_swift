//
//  SmartMajorViewController.swift
//  xxd
//
//  Created by remy on 2018/2/6.
//  Copyright © 2018年 com.smartstudy. All rights reserved.
//

private let ANSWER_TAG_BASE = 100

class SmartMajorViewController: SSViewController {
    
    private var scrollView: XDScrollView!
    private var progressView: UIView!
    private var progressLabel: UILabel!
    private var prevView: UIView!
    private var currentView: UIView!
    private var nextView: UIView!
    private var test: UILabel!
    private var currentIndex = 0
    private var maxValue: CGFloat = XDSize.screenWidth - 59
    private var smartMajorKey = ""
    private var dataList = [[String : Any]]()
    private var answers: [String]!
    private var previousButton: UIButton?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "smart_major".localized
        navigationBar.leftItem.text = "back".localized
        navigationBar.rightItem.image = UIImage(named: "smart_major_info")
        
        scrollView = XDScrollView(frame: CGRect(x: 0, y: XDSize.topHeight, width: XDSize.screenWidth, height: XDSize.contentHeight - 62))
        scrollView.delaysContentTouches = false
        scrollView.canCancelContentTouches = false
        view.addSubview(scrollView)
        
        let cube = UIView(frame: CGRect(x: 24, y: 72, width: XDSize.screenWidth - 48, height: 230))
        cube.layer.anchorPointZ = cube.width * 0.5
        var transform = CATransform3DIdentity
        transform.m34 = -1.0 / 800
        cube.layer.sublayerTransform = transform
        scrollView.addSubview(cube)
        prevView = questionView(-CGFloat.pi / 2)
        currentView = questionView(0)
        nextView = questionView(CGFloat.pi / 2)
        cube.addSubview(prevView)
        cube.addSubview(currentView)
        cube.addSubview(nextView)
        
        let offsetY: CGFloat = UIDevice.isIPhoneX ? 20 : 0
        
        view.addSubview(UIView(frame: CGRect(x: 20, y: XDSize.screenHeight - 54 - offsetY, width: XDSize.screenWidth - 40, height: XDSize.unitWidth), color: UIColor(0xCCCCCC)))
        
        test = UILabel(frame: CGRect(x: 0, y: XDSize.screenHeight - 62 - offsetY, width: 0, height: 18), text: "", textColor: UIColor(0xCCCCCC), fontSize: 12)
        test.backgroundColor = XDColor.mainBackground
        test.textAlignment = .center
        view.addSubview(test)
        
        let bottomView = UIView(frame: CGRect(x: 0, y: XDSize.screenHeight - 28 - offsetY, width: XDSize.screenWidth, height: 28 + offsetY), color: XDColor.itemLine)
        view.addSubview(bottomView)
        
        let progressBg = UIView(frame: CGRect(x: 8, y: 10, width: maxValue, height: 8), color: UIColor(0xf0f0f0))
        progressBg.layer.cornerRadius = 4
        bottomView.addSubview(progressBg)
        
        progressView = UIView(frame: CGRect(x: 8, y: 10, width: 0, height: 8), color: XDColor.main)
        progressView.layer.anchorPoint = CGPoint(x: 0, y: 0.5)
        progressView.layer.cornerRadius = 4
        bottomView.addSubview(progressView)
        
        progressLabel = UILabel(frame: CGRect(x: progressBg.right + 8, y: 7, width: 35, height: 15), text: "", textColor: XDColor.mainLine, fontSize: 12)
        progressLabel.textAlignment = .center
        bottomView.addSubview(progressLabel)
        
        SSNetworkManager.shared().get(XD_API_SMART_MAJOR_COUNT, parameters: nil, success: {
            [weak self] (task, responseObject) in
            if let data = (responseObject as! [String : Any])["data"] as? Int, let strongSelf = self {
                let testText = String(format: "test_user_count".localized, data)
                let width = testText.widthForFont(strongSelf.test.font) + 30
                strongSelf.test.text = testText
                strongSelf.test.left = (XDSize.screenWidth - width) * 0.5
                strongSelf.test.width = width
            }
        }, failure: nil)
        SSNetworkManager.shared().get(XD_API_SMART_MAJOR_QUESTIONS, parameters: nil, success: {
            [weak self] (task, responseObject) in
            if let data = (responseObject as? [String : Any])!["data"] as? [String : Any], let strongSelf = self {
                strongSelf.smartMajorKey = data["key"] as! String
                strongSelf.dataList = data["questions"] as! [[String : Any]]
                if strongSelf.dataList.count > 0 {
                    strongSelf.answers = [String](repeating: "", count: strongSelf.dataList.count)
                    strongSelf.refreshView(0)
                }
            }
        }) { (task, error) in
            XDPopView.toast(error.localizedDescription)
        }
    }
    
    private func questionView(_ angle: CGFloat) -> UIView {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: XDSize.screenWidth - 48, height: 230), color: UIColor.white)
        view.layer.shadowOpacity = 0.06
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowRadius = 8
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.isHidden = true
        
        let label = UILabel(frame: CGRect(x: 16, y: 16, width: view.width - 32, height: 0), text: "", textColor: XDColor.itemTitle, fontSize: 18)!
        label.numberOfLines = 0
        view.addSubview(label)
        
        view.addSubview(UIView(frame: CGRect(x: 0, y: 169 - XDSize.unitWidth, width: view.width, height: XDSize.unitWidth), color: UIColor(0xDDDDDD)))
        
        let btn1 = UIButton(frame: CGRect(x: 0, y: 169, width: view.width * 0.5, height: 61), title: "yes".localized, fontSize: 20, titleColor: XDColor.itemText, target: self, action: #selector(answerTap(sender:)))!
        btn1.backgroundColor = UIColor.white
        btn1.tag = ANSWER_TAG_BASE + 1
        btn1.addTarget(self, action: #selector(answerIn(sender:)), for: .touchDown)
        btn1.addTarget(self, action: #selector(answerOut(sender:)), for: .touchDragExit)
        view.addSubview(btn1)
        
        let btn2 = UIButton(frame: CGRect(x: btn1.width, y: 169, width: btn1.width, height: 61), title: "no".localized, fontSize: 20, titleColor: XDColor.itemText, target: self, action: #selector(answerTap(sender:)))!
        btn2.backgroundColor = UIColor.white
        btn2.tag = ANSWER_TAG_BASE
        btn2.addTarget(self, action: #selector(answerIn(sender:)), for: .touchDown)
        btn2.addTarget(self, action: #selector(answerOut(sender:)), for: .touchDragExit)
        view.addSubview(btn2)
        
        view.addSubview(UIView(frame: CGRect(x: btn1.width, y: 169, width: XDSize.unitWidth, height: 61), color: UIColor(0xDDDDDD)))
        
        view.layer.anchorPointZ = -view.width * 0.5
        view.layer.transform = CATransform3DMakeRotation(angle, 0, 1, 0)
        
        return view
    }
    
    //MARK: 崩溃出现的地方 175
    private func refreshView(_ step: Int) {
        let lastIndex = currentIndex
        currentIndex += step
        let num = currentIndex + 1
        let dict = dataList[currentIndex]
        let text = "\(num). \(dict["text"] as! String)"
        var label = currentView.subviews.first as! UILabel
        let stepWidth = maxValue / CGFloat(dataList.count)
        if step > 0 {
            label = nextView.subviews.first as! UILabel
        } else if step < 0 {
            label = prevView.subviews.first as! UILabel
        }
        label.setText(text, lineHeight: 24)
        label.height = text.heightForFont(label.font, label.width, 24)
        progressView.width = stepWidth * CGFloat(num)
        if step == 0 {
            currentView.isHidden = false
            nextView.isHidden = false
            prevView.isHidden = false
        } else {
            let currentLabel = currentView.subviews.first as! UILabel
            var angle = -Double.pi / 2
            var selectedTag = 0
            if step < 0 {
                angle = Double.pi / 2
                selectedTag = ANSWER_TAG_BASE + Int(answers[lastIndex - 1])!
                answerIn(sender: prevView.viewWithTag(selectedTag) as! UIButton)
            } else {
                selectedTag = ANSWER_TAG_BASE + Int(answers[lastIndex])!
            }
            CATransaction.begin()
            CATransaction.setCompletionBlock({
                [unowned self] in
                currentLabel.setText(text, lineHeight: 24)
                currentLabel.height = label.height
                if step < 0 {
                    self.answerOut(sender: self.prevView.viewWithTag(selectedTag) as! UIButton)
                }
                self.answerOut(sender: self.currentView.viewWithTag(ANSWER_TAG_BASE) as! UIButton)
                self.answerOut(sender: self.currentView.viewWithTag(ANSWER_TAG_BASE + 1) as! UIButton)
                // 如果 isRemovedOnCompletion=true
                // completionBlock会在当前runloop结束后(layer已恢复到初始状态)执行,影响体验
                // 所以 isRemovedOnCompletion=false 手动取消动画恢复初始状态
                self.currentView.layer.removeAllAnimations()
                self.nextView.layer.removeAllAnimations()
                self.prevView.layer.removeAllAnimations()
                self.progressView.layer.removeAllAnimations()
            })
            let an = CABasicAnimation(keyPath: "transform.rotation.y")
            an.fillMode = kCAFillModeForwards
            an.isRemovedOnCompletion = false
            an.fromValue = 0
            an.toValue = angle
            an.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
            an.duration = 0.5
            currentView.layer.add(an, forKey: "rotate")
            let an1 = an.copy() as! CABasicAnimation
            an1.fromValue = Double.pi / 2
            an1.toValue = angle + Double.pi / 2
            nextView.layer.add(an1, forKey: "rotate")
            let an2 = an.copy() as! CABasicAnimation
            an2.fromValue = -Double.pi / 2
            an2.toValue = angle - Double.pi / 2
            prevView.layer.add(an2, forKey: "rotate")
            let an3 = an.copy() as! CABasicAnimation
            an3.keyPath = "bounds"
            progressView.width = stepWidth * CGFloat(lastIndex + 1)
            an3.fromValue = progressView.bounds
            progressView.width = stepWidth * CGFloat(num)
            an3.toValue = progressView.bounds
            progressView.layer.add(an3, forKey: "bounds")
            CATransaction.commit()
        }
        progressLabel.text = "\(num)/\(dataList.count)"
    }
    
    func gotoResult(_ dict: [String : Any]) {
        let vc = SmartMajorResultViewController()
        vc.shareID = dict["id"] as! Int
        vc.conclusion = dict["conclusion"] as! [[String : Any]]
        vc.scores = dict["scores"] as! [String : Any]
        vc.dataList = dict["recommendSchools"] as? [SmartMajorModel]
        navigationController?.pushViewController(vc, animated: true)
        refreshView(0)
    }
    
    //MARK:- Action
    @objc func answerIn(sender: UIButton) {
        sender.setTitleColor(UIColor.white, for: .normal)
        sender.backgroundColor = XDColor.main
    }
    
    @objc func answerOut(sender: UIButton) {
        sender.setTitleColor(XDColor.itemText, for: .normal)
        sender.backgroundColor = UIColor.white
    }
    
    @objc func answerTap(sender: UIButton) {
        guard (currentView.layer.animationKeys()?.count ?? 0) == 0 else { return }
        answers[currentIndex] = "\(sender.tag - ANSWER_TAG_BASE)"
        if currentIndex < dataList.count - 1 {
            refreshView(1)
        } else {
            if XDUser.shared.hasLogin() {
                if let previousBtn = previousButton, sender != previousBtn {
                    answerOut(sender: previousBtn)
                }
                XDPopView.loading()
                let params = ["key":smartMajorKey,"answers":answers.joined()]
                SSNetworkManager.shared().post(XD_API_SMART_MAJOR_ANSWER, parameters: params, success: {
                    [weak self] (task, responseObject) in
                    if let data = (responseObject as? [String : Any])!["data"] as? [String : Any], let strongSelf = self {
                        strongSelf.previousButton = sender
                        var dict = data
                        let arr = NSArray.yy_modelArray(with: SmartMajorModel.self, json: data["recommendSchools"]!) as! [SmartMajorModel]
                        dict["recommendSchools"] = arr
                        strongSelf.gotoResult(dict)
                    }
                    XDPopView.hide()
                }) { (task, error) in
                    XDPopView.toast(error.localizedDescription)
                }
            } else {
                answerOut(sender: sender)
                let vc = SignInViewController()
                presentModalViewController(vc, animated: true, completion: nil)
            }
        }
    }
    
    override func backActionTap() {
        guard (currentView.layer.animationKeys()?.count ?? 0) == 0 else { return }
        if currentIndex > 0 {
            if navigationBar.leftItem.subText?.isEmpty ?? true {
                navigationBar.subLeftText = "close".localized
            }
            refreshView(-1)
        } else {
            super.backActionTap()
        }
    }
    
    override func subLeftActionTap() {
        guard (currentView.layer.animationKeys()?.count ?? 0) == 0 else { return }
        super.backActionTap()
    }
    
    override func rightActionTap() {
        let vc = SmartMajorHollandViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
}
