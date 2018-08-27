//
//  XDTextView.swift
//  xxd
//
//  Created by remy on 2018/1/6.
//  Copyright © 2018年 com.smartstudy. All rights reserved.
//

import SnapKit

@objc protocol XDTextViewDelegate: class {
    @objc optional func textViewOnFocus(textView: UITextView)
    @objc optional func textViewDidChanged(textView: UITextView)
    /// 用到输入框高度自增的地方需要实现该代理方法, 并且textHeight为文本框的高度
    @objc optional func textViewTextHeightDidChange(text: String, textHeight: CGFloat)
}

class XDTextView: UIView, UITextViewDelegate {
    
    weak var delegate: XDTextViewDelegate?
    var textChangeClosure: ((String, CGFloat)->Void)?
    let textView = UITextView()
    let placeholderLabel = UILabel()
    var textCountView: UILabel?
    var text: String {
        get {
            return textView.text
        }
        set {
            textView.text = newValue
            textViewDidChange(textView)
        }
    }
    var keyboardType: UIKeyboardType {
        get {
            return textView.keyboardType
        }
        set {
            textView.keyboardType = newValue
        }
    }
    var textColor: UIColor {
        get {
            return textView.textColor!
        }
        set {
            textView.textColor = newValue
        }
    }
    var fontSize: CGFloat = 0 {
        didSet {
            textView.font = UIFont.systemFont(ofSize: fontSize)
            placeholderLabel.font = UIFont.systemFont(ofSize: fontSize)
        }
    }
    var placeholder: String = "" {
        didSet {
            placeholderLabel.setText(placeholder, lineSpace: 3)
            placeholderLabel.numberOfLines = 0
            textViewDidChange(textView)
        }
    }
    var maxTextLength = 0 {
        didSet {
            if maxTextLength > 0 {
                if let view = textCountView {
                    view.text = "\(maxTextLength)"
                } else {
                    textView.snp.updateConstraints({ (make) in
                        make.bottom.equalTo(self).offset(-20)
                    })
                    let view = UILabel(frame: .null, text: "\(maxTextLength)", textColor: XDColor.textPlaceholder, fontSize: 12)!
                    view.textAlignment = .right
                    addSubview(view)
                    view.snp.makeConstraints({ (make) in
                        make.height.equalTo(20)
                        make.bottom.equalTo(self)
                        make.right.equalTo(self).offset(-16)
                    })
                    textCountView = view
                }
            } else {
                textView.snp.updateConstraints({ (make) in
                    make.bottom.equalTo(self)
                })
                textCountView?.removeFromSuperview()
            }
        }
    }
    var contentInset: UIEdgeInsets = .zero {
        didSet {
            textView.contentInset = contentInset
        }
    }
    var maxNumOfLines: Int = 1 {
        didSet {
            maxTextHeight = (self.textView.font?.lineHeight)!*CGFloat(maxNumOfLines) + self.textView.textContainerInset.top + self.textView.textContainerInset.bottom
        }
    }
    private var previousHeight: CGFloat = 0.0
    private var maxTextHeight: CGFloat = 0.0
    override var isFirstResponder: Bool {
        return super.isFirstResponder || textView.isFirstResponder
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.white
        textView.backgroundColor = UIColor.clear
        textView.textContainerInset = UIEdgeInsetsMake(8, 8, 8, 8)
        textView.textContainer.lineFragmentPadding = 0
        textView.delegate = self
        addSubview(textView)
        textView.snp.makeConstraints({ (make) in
            make.edges.equalTo(self)
        })
        textView.font = UIFont.systemFont(ofSize: 15)
        placeholderLabel.textColor = XDColor.textPlaceholder
        placeholderLabel.font = UIFont.systemFont(ofSize: 15)
        addSubview(placeholderLabel)
        placeholderLabel.snp.makeConstraints({ (make) in
            make.left.top.equalTo(self).offset(8)
            make.right.equalTo(self).offset(-8)
        })
        NotificationCenter.default.addObserver(self, selector: #selector(textViewEditChanged(notification:)), name: NSNotification.Name.UITextViewTextDidChange, object: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func focus() {
        textView.becomeFirstResponder()
    }
    
    func blur() {
        textView.resignFirstResponder()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    //MARK:- Notification
    func updateTextCount(str: String) {
        if maxTextLength > 0 {
            if str.count > maxTextLength {
                text = str.substring(to: maxTextLength)
            }
            if let view = textCountView {
                let leftCount = maxTextLength - str.count
                view.textColor = leftCount > 0 ? XDColor.textPlaceholder : UIColor(0xF6511D)
                view.text = "\(max(0, leftCount))"
            }
        }
    }
    
    @objc func textViewEditChanged(notification: Notification) {
        if let textView = notification.object as? UITextView {
            let str = textView.text ?? ""
            let lang = textView.textInputMode?.primaryLanguage
            if lang == "zh-Hans" {
                // 简体中文输入，包括简体拼音，健体五笔，简体手写
                if let selectedRange = textView.markedTextRange {
                    // 获取高亮部分
                    guard let _ = textView.position(from: selectedRange.start, offset: 0) else {
                        // 没有高亮选择的字，则对已输入的文字进行字数统计和限制
                        updateTextCount(str: str)
                        return
                    }
                    // 有高亮选择的字符串，则暂不对文字进行统计和限制
                } else {
                    // 没有高亮选择的字，则对已输入的文字进行字数统计和限制
                    updateTextCount(str: str)
                }
            } else {
                // 中文输入法以外的直接对其统计限制即可，不考虑其他语种情况
                updateTextCount(str: str)
            }
        }
    }
    
    //MARK:- XDTextViewDelegate
    func textViewDidBeginEditing(_ textView: UITextView) {
        delegate?.textViewOnFocus?(textView: textView)
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        textView.text = textView.text.trimmingCharacters(in: .whitespaces)
        textViewDidChange(textView)
    }
    
    func textViewDidChange(_ textView: UITextView) {
        placeholderLabel.isHidden = !textView.text.isEmpty
        let textHeight = ceil(textView.sizeThatFits(CGSize(width: textView.width, height: CGFloat.greatestFiniteMagnitude)).height)
        if maxNumOfLines != 1 {
            if previousHeight != textHeight {
                textView.isScrollEnabled = textHeight > maxTextHeight && maxTextHeight > 0.0
                previousHeight = textHeight
                if let closure = delegate?.textViewTextHeightDidChange, !textView.isScrollEnabled {
                    closure(textView.text, textHeight)
                }
            }
        }
        guard let _ = textView.markedTextRange else  {
            delegate?.textViewDidChanged?(textView: textView)
            return
        }
    }
}
