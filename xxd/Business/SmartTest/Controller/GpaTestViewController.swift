//
//  GpaTestViewController.swift
//  xxd
//
//  Created by remy on 2018/1/30.
//  Copyright © 2018年 com.smartstudy. All rights reserved.
//

class GpaTestViewController: SSViewController, XDTextFieldViewDelegate {
    
    private var scrollView: XDScrollView!
    private var itemList = [UIView]()
    private var descView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "GPA计算"
        isCustomKeyboard = true
        
        scrollView = XDScrollView(frame: CGRect(x: 0, y: XDSize.topHeight, width: XDSize.screenWidth, height: XDSize.contentHeight))
        view.addSubview(scrollView)
        
        for _ in 0..<8 {
            addScoreItem()
        }
        
        descView = UIView(frame: CGRect(x: 0, y: CGFloat(itemList.count * 64), width: XDSize.screenWidth, height: 66))
        scrollView.addSubview(descView)
        
        let attr = NSAttributedString(string: "GPA算法说明").underline
        let desc = UILabel(text: "", textColor: XDColor.itemText, fontSize: 13)!
        desc.attributedText = attr
        desc.isUserInteractionEnabled = true
        desc.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(descTap(gestureRecognizer:))))
        descView.addSubview(desc)
        desc.snp.makeConstraints({ (make) in
            make.centerX.equalTo(descView).offset(11)
            make.centerY.equalTo(descView)
            make.height.equalTo(40)
        })
        
        let image = UIImage(named: "smart_major_info")!
        let imageView = UIImageView(image: image.tint(UIColor(0x999999)))
        descView.addSubview(imageView)
        imageView.snp.makeConstraints({ (make) in
            make.centerY.equalTo(descView)
            make.right.equalTo(desc.snp.left).offset(-6)
        })
        
        if UIDevice.isIPhoneX {
            let bottomBg = CALayer()
            bottomBg.backgroundColor = UIColor.white.cgColor
            bottomBg.frame = CGRect(x: 0, y: XDSize.screenHeight - XDSize.tabbarHeight, width: XDSize.screenWidth, height: XDSize.tabbarHeight)
            view.layer.addSublayer(bottomBg)
        }
        
        let courseBtn = UIButton(frame: CGRect(x: 0, y: XDSize.screenHeight - XDSize.tabbarHeight, width: XDSize.screenWidth * 0.5, height: 49), title: "添加课程".localized, fontSize: 15, titleColor: XDColor.itemTitle, target: self, action: #selector(addCourseTap(sender:)))!
        courseBtn.backgroundColor = UIColor.white
        view.addSubview(courseBtn)
        
        let calculateBtn = UIButton(frame: CGRect(x: courseBtn.right, y: XDSize.screenHeight - XDSize.tabbarHeight, width: XDSize.screenWidth * 0.5, height: 49), title: "开始计算".localized, fontSize: 15, titleColor: UIColor.white, target: self, action: #selector(calculateTap(sender:)))!
        calculateBtn.backgroundColor = XDColor.main
        view.addSubview(calculateBtn)
        
        let topLine = UIView(frame: .zero, color: XDColor.itemLine)
        view.addSubview(topLine)
        topLine.snp.makeConstraints({ (make) in
            make.top.left.equalTo(courseBtn)
            make.size.equalTo(CGSize(width: XDSize.screenWidth, height: XDSize.unitWidth))
        })
        let bottomLine = UIView(frame: .zero, color: XDColor.itemLine)
        view.addSubview(bottomLine)
        bottomLine.snp.makeConstraints({ (make) in
            make.bottom.left.equalTo(courseBtn)
            make.size.equalTo(CGSize(width: XDSize.screenWidth, height: XDSize.unitWidth))
        })
    }
    
    func addScoreItem() {
        let view = UIView(frame: CGRect(x: 0, y: CGFloat(itemList.count * 64), width: XDSize.screenWidth, height: 64), color: UIColor.white)
        view.addSubview(UIView(frame: CGRect(x: 0, y: view.height - XDSize.unitWidth, width: XDSize.screenWidth, height: XDSize.unitWidth), color: XDColor.itemLine))
        scrollView.addSubview(view)
        itemList.append(view)
        
        let text = "课程\(itemList.count)"
        let titleLabel = UILabel(frame: CGRect(x: 24, y: 0, width: 67, height: 64), text: text, textColor: XDColor.itemTitle, fontSize: 16, bold: true)!
        view.addSubview(titleLabel)
        
        let textWidth = (XDSize.screenWidth - 127) * 0.5
        let scoreView = XDTextFieldView(frame: CGRect(x: titleLabel.right, y: 12, width: textWidth, height: 40))
        scoreView.tag = 1000
        scoreView.textColor = XDColor.itemTitle
        scoreView.backgroundColor = XDColor.mainBackground
        scoreView.fontSize = 16
        scoreView.placeholder = "成绩"
        scoreView.keyboardType = .decimalPad
        scoreView.layer.cornerRadius = 3
        scoreView.layer.borderColor = XDColor.itemLine.cgColor
        scoreView.layer.borderWidth = 1
        scoreView.delegate = self
        view.addSubview(scoreView)
        
        let pointView = XDTextFieldView(frame: CGRect(x: scoreView.right + 12, y: 12, width: textWidth, height: 40))
        pointView.tag = 1001
        pointView.textColor = XDColor.itemTitle
        pointView.backgroundColor = XDColor.mainBackground
        pointView.fontSize = 16
        pointView.placeholder = "学分"
        pointView.keyboardType = .decimalPad
        pointView.layer.cornerRadius = 3
        pointView.layer.borderColor = XDColor.itemLine.cgColor
        pointView.layer.borderWidth = 1
        pointView.delegate = self
        view.addSubview(pointView)
    }
    
    func isValidScore(_ text: String) -> Bool {
        let predicate = NSPredicate(format: "SELF MATCHES %@", "^100(?:\\.0+)?|[1-9]?[0-9](?:\\.[0-9]+)?$")
        return predicate.evaluate(with: text)
    }
    
    func isValidPoint(_ text: String) -> Bool {
        let predicate = NSPredicate(format: "SELF MATCHES %@", "^[1-9]?[0-9](?:\\.[0-9]+)?$")
        return predicate.evaluate(with: text)
    }
    
    //MARK:- Action
    @objc func descTap(gestureRecognizer: UIGestureRecognizer) {
        let vc = GpaDescViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func addCourseTap(sender: UIButton) {
        if itemList.count < 100 {
            addScoreItem()
            scrollView.addSubview(descView)
            descView.top = CGFloat(itemList.count * 64)
            scrollView.updateContentSize(subview: descView)
            scrollView.ss_scrollToBottom()
        }
    }
    
    @objc func calculateTap(sender: UIButton) {
        view.endEditing(true)
        var arr = [String]()
        for view in itemList {
            let score = view.viewWithTag(1000) as! XDTextFieldView
            let point = view.viewWithTag(1001) as! XDTextFieldView
            if !score.text.isEmpty || !point.text.isEmpty {
                if !isValidScore(score.text) {
                    XDPopView.toast("成绩为0-100")
                    score.layer.borderColor = UIColor(0xF6511D).cgColor
                    score.backgroundColor = UIColor(0xF6511D, 0.2)
                    return
                }
                if !isValidPoint(point.text) {
                    XDPopView.toast("学分为0-99")
                    point.layer.borderColor = UIColor(0xF6511D).cgColor
                    point.backgroundColor = UIColor(0xF6511D, 0.2)
                    return
                }
                let text = "\(score.text):\(point.text)"
                arr.append(text)
            }
        }
        if arr.count > 0 {
            XDPopView.loading()
            let scores = arr.joined(separator: ",")
            SSNetworkManager.shared().get(XD_API_GPA_CALCULATE, parameters: ["scores":scores], success: { (task, responseObject) in
                if let data = (responseObject as! [String : Any])["data"] as? [String : Any] {
                    let vc = GpaResultViewController()
                    vc.resultData = data["output"] as! [[String : Any]]
                    XDRoute.pushToVC(vc)
                }
                XDPopView.hide()
            }) { (task, error) in
                XDPopView.toast(error.localizedDescription)
            }
            
        } else {
            XDPopView.toast("至少填写一门成绩")
        }
    }
    
    //MARK:- XDTextFieldViewDelegate
    func textFieldOnFocus(textField: XDTextFieldView) {
        scrollView.scrollToViewOnFocus(view: textField)
        textField.layer.borderColor = XDColor.itemLine.cgColor
        textField.backgroundColor = XDColor.mainBackground
    }
}
