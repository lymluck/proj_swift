//
//  CollegeErrorFeedbackView.swift
//  xxd
//
//  Created by Lisen on 2018/6/21.
//  Copyright © 2018年 com.smartstudy. All rights reserved.
//

import UIKit
import DeviceKit

let kErrorFeedbackTap: String = "kErrorFeedbackTap"

@objc protocol CollegeErrorFeedbackViewDelegate {
    func collegeErrorFeedbackViewDidCommit(section: String, content: String)
}

/// 院校详情界面纠错弹出框
class CollegeErrorFeedbackView: UIView {
    
    weak var delegate: CollegeErrorFeedbackViewDelegate?
    var sectionType: CollegeDetailSectionType = .intro
    private lazy var backgroundView: UIView = {
        let bgView: UIView = UIView(frame: UIScreen.main.bounds, color: UIColor.clear)
        let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(eventBackgroundViewTapResponse(_:)))
        bgView.addGestureRecognizer(tapGesture)
        tapGesture.delegate = self
        return bgView
    }()
    private lazy var titleLabel: UILabel = UILabel(frame: CGRect.zero, text: "请在下面填写建议或问题反馈", textColor: UIColor(0x26343F), fontSize: 17.0, bold: true)
    private lazy var textView: XDTextView = {
        let textView: XDTextView = XDTextView(frame: CGRect.zero)
        textView.placeholder = "您的建议和反馈可以帮助我们更好地完善院校信息"
        textView.layer.borderColor = UIColor(0xE4E5E6).cgColor
        textView.layer.borderWidth = 1.0
        textView.layer.cornerRadius = 3.0
        return textView
    }()
    private lazy var cancelButton: UIButton = {
        let button: UIButton = UIButton(frame: .zero, title: "取消", fontSize: 16.0, titleColor: UIColor(0x949BA1), backgroundColor: UIColor(0xE4E5E6), target: self, action: #selector(eventButtonResponse(_:)))
        button.setBackgroundColor(UIColor(0xD9DADA), for: .highlighted)
        button.layer.cornerRadius = 6.0
        button.layer.masksToBounds = true
        button.tag = 0
        return button
    }()
    private lazy var commitButton: UIButton = {
        let button: UIButton = UIButton(frame: .zero, title: "提交", fontSize: 16.0, titleColor: UIColor.white, backgroundColor: UIColor(0x078CF1), target: self, action: #selector(eventButtonResponse(_:)))
        button.setBackgroundColor(UIColor(0x067DD8), for: .highlighted)
        button.layer.cornerRadius = 6.0
        button.layer.masksToBounds = true
        button.tag = 1
        return button
    }()
    
    convenience init() {
        var leftMargin: CGFloat = 40.0
        var feedbackViewHeight: CGFloat = 281.0
        if Device().diagonal == 4.0 {
            leftMargin = 12.0
            feedbackViewHeight = 261.0
        }
        self.init(frame: CGRect(x: leftMargin, y: (XDSize.screenHeight-feedbackViewHeight)/2.0, width: XDSize.screenWidth-leftMargin*2.0, height: feedbackViewHeight))
        initContentViews()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        if textView.isFirstResponder {
            textView.blur()
        }
    }
    
    // MARK: public methods
    func showWithAnimation() {
        UIApplication.shared.keyWindow?.addSubview(backgroundView)
        backgroundView.addSubview(self)
        UIView.animate(withDuration: 0.15) {
            self.backgroundView.backgroundColor = UIColor(white: 0.0, alpha: 0.4)
            self.alpha = 1.0
        }
    }
    
    func dismissWithAnimation() {
        sectionType = .intro
        UIView.animate(withDuration: 0.15, animations: {
            self.backgroundView.backgroundColor = UIColor.clear
            self.alpha = 0.0
        }) { (_) in
            self.backgroundView.removeFromSuperview()
            self.removeFromSuperview()
        }
        textView.text = ""
    }
    
    // MARK: private methods
    private func initContentViews() {
        backgroundColor = UIColor.white
        alpha = 0.0
        layer.cornerRadius = 10.0
        addSubview(titleLabel)
        addSubview(textView)
        addSubview(cancelButton)
        addSubview(commitButton)        
        titleLabel.snp.makeConstraints { (make) in
            make.top.equalTo(24.0)
            make.centerX.equalToSuperview()
            make.height.equalTo(17.0)
        }
        textView.snp.makeConstraints { (make) in
            make.top.equalTo(titleLabel.snp.bottom).offset(24.0)
            make.left.equalTo(16.0)
            make.right.equalTo(-16.0)
            make.bottom.equalTo(-88.0)
        }
        cancelButton.snp.makeConstraints { (make) in
            make.left.equalTo(16.0)
            make.right.equalTo(self.snp.centerX).offset(-5.5)
            make.bottom.equalTo(-24.0)
            make.height.equalTo(40.0)
        }
        commitButton.snp.makeConstraints { (make) in
            make.left.equalTo(self.snp.centerX).offset(5.5)
            make.right.equalTo(-16.0)
            make.bottom.height.equalTo(cancelButton)
        }
    }
    
    @objc private func eventBackgroundViewTapResponse(_ gesture: UITapGestureRecognizer) {
        if textView.isFirstResponder {
            textView.blur()
        } else {
            dismissWithAnimation()
        }
    }
    
    @objc private func eventButtonResponse(_ sender: UIButton) {
        if sender.tag == 0 {
            if textView.isFirstResponder {
                textView.blur()
            }
            dismissWithAnimation()
        } else {
            guard let _ = delegate?.collegeErrorFeedbackViewDidCommit(section: sectionType.chineseTitle, content: textView.text) else { return }
        }
    }
}

// MARK: UIGestureRecognizerDelegate
extension CollegeErrorFeedbackView: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if let touchView = touch.view, touchView.isDescendant(of: self) {
            return false
        }
        return true
    }
}
