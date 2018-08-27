//
//  PrivacySettingView.swift
//  xxd
//
//  Created by Lisen on 2018/6/4.
//  Copyright © 2018年 com.smartstudy. All rights reserved.
//

import UIKit

@objc protocol PrivacySettingViewDelegate {
    func privacySettingDidSet(_ visible: Bool)
}

/// 选校隐私设置弹框视图
class PrivacySettingView: UIView {
    weak var delegate: PrivacySettingViewDelegate?
    var isSelectionVisible: Bool = false {
        didSet {
            if isSelectionVisible {
                unlockButton.isSelected = true
                lockButton.isSelected = false
                UIView.animate(withDuration: 0.15) {
                    self.unlockButton.backgroundColor = UIColor(0x078CF1)
                    self.lockButton.backgroundColor = UIColor.clear
                }
            } else {
                unlockButton.isSelected = false
                lockButton.isSelected = true
                UIView.animate(withDuration: 0.15) {
                    self.unlockButton.backgroundColor = UIColor.clear
                    self.lockButton.backgroundColor = UIColor(0x078CF1)
                }
            }
        }
    }
    
    private lazy var alertBackgroundView: UIView = {
        let view: UIView = UIView(frame: UIScreen.main.bounds, color: UIColor.clear)
        let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(eventTapGestureResponse(_:)))
        tapGesture.delegate = self
        view.addGestureRecognizer(tapGesture)
        return view
    }()
    private lazy var titleLabel: UILabel = UILabel(frame: CGRect.zero, text: "隐私设置", textColor: UIColor(0x26343F), fontSize: 19.0, bold: true)
    private lazy var lineView: UIView = UIView(frame: CGRect.zero, color: UIColor(0x078CF1))
    private lazy var tipLabel: UILabel = {
        let label: UILabel = UILabel(frame: CGRect.zero, text: "", textColor: UIColor(0x58646E), fontSize: 15.0)
        var paragraph = NSMutableParagraphStyle()
        paragraph.lineSpacing = 8.0
        label.attributedText = NSAttributedString(string: "设为隐私后我的选校对其他人不可见, ", attributes: [NSAttributedStringKey.paragraphStyle: paragraph]) + NSAttributedString(string: "同时也不可查看其他人的选校。", attributes: [NSAttributedStringKey.foregroundColor: UIColor(0xFF9C08)])
        label.numberOfLines = 0
        return label
    }()
    private lazy var closeButton: UIButton = {
        let button: UIButton = UIButton(frame: CGRect.zero)
        button.setImage(UIImage(named: "close"), for: .normal)
        button.setImage(UIImage(named: "close"), for: .highlighted)
        button.addTarget(self, action: #selector(eventButtonResponse(_:)), for: .touchUpInside)
        button.tag = 2
        return button
    }()
    private lazy var unlockButton: UIButton = {
        let button: UIButton = UIButton(frame: CGRect.zero)
        button.setImage(UIImage(named: "privacy_unlock_normal"), for: .normal)
        button.setImage(UIImage(named: "privacy_unlock_selected"), for: .selected)
        button.setTitle("所有人可见", for: UIControlState.normal)
        button.setTitle("所有人可见", for: UIControlState.selected)
        button.setTitleColor(UIColor.white, for: .selected)
        button.setTitleColor(UIColor(0x949BA1), for: .normal)
        button.titleEdgeInsets = UIEdgeInsets(top: 0.0, left: 8.0, bottom: 0.0, right: 0.0)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 15.0)
        button.layer.borderColor = UIColor(0xC4C9CC).cgColor
        button.layer.borderWidth = XDSize.unitWidth
        button.layer.cornerRadius = 20.0
        button.layer.masksToBounds = true
        button.tag = 0
        button.addTarget(self, action: #selector(eventButtonResponse(_:)), for: .touchUpInside)
        return button
    }()
    private lazy var lockButton: UIButton = {
        let button: UIButton = UIButton(frame: CGRect.zero)
        button.setImage(UIImage(named: "privacy_lock_normal"), for: .normal)
        button.setImage(UIImage(named: "privacy_lock_selected"), for: .selected)
        button.setTitle("设为隐私", for: UIControlState.normal)
        button.setTitle("设为隐私", for: UIControlState.selected)
        button.setTitleColor(UIColor.white, for: .selected)
        button.setTitleColor(UIColor(0x949BA1), for: .normal)
        button.titleEdgeInsets = UIEdgeInsets(top: 0.0, left: 8.0, bottom: 0.0, right: 0.0)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 15.0)
        button.layer.borderColor = UIColor(0xC4C9CC).cgColor
        button.layer.borderWidth = XDSize.unitWidth
        button.layer.cornerRadius = 20.0
        button.layer.masksToBounds = true
        button.tag = 1
        button.addTarget(self, action: #selector(eventButtonResponse(_:)), for: .touchUpInside)
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initContentViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    /// 背景视图的点击事件
    @objc private func eventTapGestureResponse(_ gesture: UITapGestureRecognizer) {
       dismissAlertViewWithAnimation()
    }
    
    @objc private func eventButtonResponse(_ sender: UIButton) {
        if sender.tag == 2 {
            dismissAlertViewWithAnimation()
        } else {
            let isVisible: Bool = sender.tag == 0 ? true : false
            guard let _ = delegate?.privacySettingDidSet(isVisible) else { return }
        }
    }
    
    /// 以动画的形式展示弹框视图
    func showAlertViewWithAnimation() {
        alertBackgroundView.addSubview(self)
        UIApplication.shared.keyWindow?.addSubview(alertBackgroundView)
        self.alpha = 0.0
        UIView.animate(withDuration: 0.15, animations: {
            self.alertBackgroundView.backgroundColor = UIColor(white: 0.0, alpha: 0.6)
            self.alpha = 1.0
        })
    }
    
    private func initContentViews() {
        backgroundColor = UIColor.white
        layer.cornerRadius = 10.0
        addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (make) in
            make.left.equalTo(16.0)
            make.top.equalTo(40.0)
        }
        addSubview(lineView)
        lineView.snp.makeConstraints { (make) in
            make.left.equalTo(titleLabel)
            make.top.equalTo(titleLabel.snp.bottom).offset(10.0)
            make.width.equalTo(22.0)
            make.height.equalTo(4.0)
        }
        addSubview(closeButton)
        closeButton.snp.makeConstraints { (make) in
            make.top.equalTo(13.0)
            make.right.equalTo(-13.0)
            make.width.height.equalTo(20.0)
        }
        addSubview(tipLabel)
        tipLabel.snp.makeConstraints { (make) in
            make.top.equalTo(lineView.snp.bottom).offset(32.0)
            make.left.equalTo(titleLabel)
            make.right.equalTo(-16.0)
        }
        addSubview(lockButton)
        lockButton.snp.makeConstraints { (make) in
            make.left.equalTo(titleLabel)
            make.right.equalTo(-16.0)
            make.bottom.equalTo(-40.0)
            make.height.equalTo(40.0)
        }
        addSubview(unlockButton)
        unlockButton.snp.makeConstraints { (make) in
            make.left.equalTo(titleLabel)
            make.right.equalTo(-16.0)
            make.bottom.equalTo(lockButton.snp.top).offset(-24.0)
            make.height.equalTo(40.0)
        }
    }
    
    private func dismissAlertViewWithAnimation() {
        UIView.animate(withDuration: 0.15, animations: {
            self.superview?.backgroundColor = UIColor.clear
            self.alpha = 0.0
        }) { (_) in
            self.alpha = 1.0
            self.superview?.removeFromSuperview()
            self.removeFromSuperview()
        }
    }
}

// MARK: UIGestureRecognizerDelegate
extension PrivacySettingView: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if let touchView = touch.view, touchView.isDescendant(of: self) {
            return false
        }
        return true
    }
}
