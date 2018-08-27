//
//  XDTextFieldView.swift
//  xxd
//
//  Created by remy on 2018/1/5.
//  Copyright © 2018年 com.smartstudy. All rights reserved.
//

import SnapKit

@objc protocol XDTextFieldViewDelegate: class {
    
    @objc optional func textFieldOnReturn(textField: UITextField)
    @objc optional func textFieldRightItemTap(sender: UIButton)
    @objc optional func textFieldOnFocus(textField: XDTextFieldView)
    @objc optional func textFieldOnChange(textField: UITextField)
    @objc optional func textFieldDidChanged(textField: UITextField)
}

class XDTextFieldView: UIView, XDLineStyle, UITextFieldDelegate {
    
    weak var delegate: XDTextFieldViewDelegate?
    var leftContentInsets: CGFloat = 15
    var rightContentInsets: CGFloat = 15
    let textField = UITextField()
    var text: String {
        get {
            return textField.text ?? ""
        }
        set {
            textField.text = newValue
        }
    }
    var roundCorner: Bool = false {
        willSet {
            layer.cornerRadius = newValue ? 4 : 0
        }
    }
    var fontSize: CGFloat = 0 {
        willSet {
            textField.font = UIFont.systemFont(ofSize: newValue)
        }
    }
    var keyboardType: UIKeyboardType {
        get {
            return textField.keyboardType
        }
        set {
            textField.keyboardType = newValue
        }
    }
    var textColor: UIColor {
        get {
            return textField.textColor!
        }
        set {
            textField.textColor = newValue
        }
    }
    var placeholder: String {
        get {
            return textField.placeholder ?? ""
        }
        set {
            textField.placeholder = newValue
        }
    }
    override var isFirstResponder: Bool {
        return textField.isFirstResponder
    }
    var placeholderSize: CGFloat?
    var leftImage: UIImage?
    var rightImage: UIImage?
    var rightImageSelected: UIImage?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.white
        textField.backgroundColor = UIColor.clear
        textField.delegate = self
        textField.addTarget(self, action: #selector(textFieldEditChanged(textField:)), for: .editingChanged)
        textColor = UIColor.black
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func focus() {
        textField.becomeFirstResponder()
    }
    
    func blur() {
        textField.resignFirstResponder()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        addSubview(textField)
        textField.snp.makeConstraints({ (make) in
            make.top.height.equalTo(self)
            make.left.equalTo(self).offset(leftContentInsets)
            make.right.equalTo(self).offset(-rightContentInsets)
        })
        
        if let placeholderSize = placeholderSize {
            let attr = NSAttributedString(string: placeholder, attributes: [
                NSAttributedStringKey.foregroundColor: XDColor.textPlaceholder,
                NSAttributedStringKey.font: UIFont.systemFont(ofSize: placeholderSize)
                ])
            textField.attributedPlaceholder = attr
        }
        if let leftImage = leftImage {
            let leftImageView = UIImageView(image: leftImage)
            addSubview(leftImageView)
            leftImageView.snp.makeConstraints({ (make) in
                make.left.equalTo(self).offset(8)
                make.centerY.equalTo(self)
            })
            textField.snp.updateConstraints({ (make) in
                make.left.equalTo(leftImageView).offset(6)
            })
        }
        if let rightImage = rightImage {
            let rightButton = UIButton()
            addSubview(rightButton)
            rightButton.setImage(rightImage, for: .normal)
            if let rightImageSelected = rightImageSelected {
                rightButton.setImage(rightImageSelected, for: .selected)
            }
            rightButton.addTarget(self, action: #selector(rightItemTap(sender:)), for: .touchUpInside)
            rightButton.snp.makeConstraints({ (make) in
                make.top.right.equalTo(self)
                make.width.height.equalTo(self.snp.height)
            })
            textField.snp.updateConstraints({ (make) in
                make.right.equalTo(rightButton.left)
            })
        }
    }
    
    //MARK:- Action
    @objc func textFieldEditChanged(textField: UITextField) {
        guard let _ = textField.markedTextRange else  {
            delegate?.textFieldDidChanged?(textField: textField)
            return
        }
    }
    
    @objc func rightItemTap(sender: UIButton) {
        if let delegate = delegate {
            sender.isSelected = !sender.isSelected
            delegate.textFieldRightItemTap?(sender: sender)
        }
    }
    
    //MARK:- UITextFieldDelegate
    func textFieldDidBeginEditing(_ textField: UITextField) {
        delegate?.textFieldOnFocus?(textField: self)
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        delegate?.textFieldOnChange?(textField: textField)
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.text = textField.text?.trimmingCharacters(in: .whitespaces)
        delegate?.textFieldOnReturn?(textField: textField)
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.text = textField.text?.trimmingCharacters(in: .whitespaces)
    }
}
