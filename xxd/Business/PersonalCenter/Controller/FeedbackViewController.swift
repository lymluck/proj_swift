//
//  FeedbackViewController.swift
//  xxd
//
//  Created by remy on 2018/1/10.
//  Copyright © 2018年 com.smartstudy. All rights reserved.
//

class FeedbackViewController: SSViewController, XDTextViewDelegate, XDTextFieldViewDelegate {
    
    var scrollView: XDScrollView!
    var textView: XDTextView!
    var textFieldView: XDTextFieldView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "user_feedback".localized
        
        scrollView = XDScrollView(frame: CGRect(x: 0, y: XDSize.topHeight, width: XDSize.screenWidth, height: XDSize.visibleHeight))
        view.addSubview(scrollView)
        
        let desc = UILabel(frame: .zero, text: "feedback_desc".localized, textColor: XDColor.mainLine, fontSize: 13)!
        desc.numberOfLines = 0
        scrollView.addSubview(desc)
        desc.snp.makeConstraints({ (make) in
            make.left.equalTo(scrollView).offset(10)
            make.top.equalTo(scrollView).offset(15)
            make.width.equalTo(XDSize.screenWidth - 20)
        })
        
        textView = XDTextView(frame: .zero)
        textView.textColor = XDColor.itemText
        textView.placeholder = "feedback_text_default".localized
        textView.maxTextLength = 250
        textView.delegate = self
        scrollView.addSubview(textView)
        textView.snp.makeConstraints({ (make) in
            make.left.equalTo(scrollView)
            make.top.equalTo(desc.snp.bottom).offset(15)
            make.size.equalTo(CGSize(width: XDSize.screenWidth, height: 189))
        })
        
        let label = UILabel(frame: .zero, text: "feedback_contact_way".localized, textColor: XDColor.itemTitle, fontSize: 15)!
        let labelWidth = ceil(label.text!.widthForFont(label.font))
        
        textFieldView = XDTextFieldView(frame: .zero)
        textFieldView.textColor = XDColor.itemText
        textFieldView.fontSize = 15
        textFieldView.leftContentInsets = labelWidth + 40
        textFieldView.placeholder = "feedback_contact_default".localized
        textFieldView.delegate = self
        scrollView.addSubview(textFieldView)
        textFieldView.snp.makeConstraints({ (make) in
            make.left.equalTo(scrollView)
            make.top.equalTo(textView.snp.bottom).offset(15)
            make.size.equalTo(CGSize(width: XDSize.screenWidth, height: 50))
        })
        textFieldView.addSubview(label)
        label.snp.makeConstraints({ (make) in
            make.left.equalTo(20)
            make.top.equalTo(textFieldView)
            make.size.equalTo(CGSize(width: labelWidth, height: 50))
        })
        
        let btn = UIButton(frame: .zero, title: "submit".localized, fontSize: 15, bold: true, titleColor: UIColor.white, backgroundColor: nil, target: self, action: #selector(submitTap(sender:)))!
        btn.backgroundColor = XDColor.main
        btn.layer.cornerRadius = 6
        scrollView.addSubview(btn)
        btn.snp.makeConstraints({ (make) in
            make.left.equalTo(20)
            make.top.equalTo(textFieldView.snp.bottom).offset(40)
            make.size.equalTo(CGSize(width: XDSize.screenWidth - 40, height: 42))
        })
    }
    
    @objc func submitTap(sender: UIButton) {
        let content = textView.text.trimmingCharacters(in: .whitespaces)
        let contact = textFieldView.text.trimmingCharacters(in: .whitespaces)
        if content.count == 0 {
            XDPopView.toast("feedback_content_empty".localized)
        } else if contact.count == 0 {
            XDPopView.toast("feedback_contact_empty".localized)
        } else if contact.count > 50 {
            XDPopView.toast("feedback_contact_limit".localized)
        } else {
            XDPopView.loading()
            let params = ["content":content,"contact":contact]
            SSNetworkManager.shared().post(XD_API_FEEDBACK_EDIT, parameters: params, success: { [weak self] (task, responseObject) in
                self?.backActionTap()
                XDPopView.toast("submit_success".localized, UIApplication.shared.keyWindow)
            }, failure: { (task, error) in
                XDPopView.toast(error.localizedDescription)
            })
        }
    }
    
    //MARK:- XDTextViewDelegate
    func textViewOnFocus(textView: UITextView) {
        scrollView.scrollToViewOnFocus(view: textView)
    }
    
    //MARK:- XDTextFieldViewDelegate
    func textFieldOnFocus(textField: XDTextFieldView) {
        scrollView.scrollToViewOnFocus(view: textField)
    }
}
