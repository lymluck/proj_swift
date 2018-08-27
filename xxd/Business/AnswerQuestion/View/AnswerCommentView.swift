//
//  AnswerCommentView.swift
//  xxd
//
//  Created by Lisen on 2018/4/23.
//  Copyright © 2018年 com.smartstudy. All rights reserved.
//

import UIKit

/// 评价视图事件代理
@objc protocol AnswerCommentViewDelegate {
    /// 评价视图关闭按钮事件
    func answerCommentViewDidDismiss()
    /// 评价视图提交按钮事件
    func answerCommentViewCommit(rateScore: String, commentText: String)
}

/// 留学问问对回答评价视图
class AnswerCommentView: UIView {
    
    weak var delegate: AnswerCommentViewDelegate?
    /// 获取用户输入的评价文本
    var commentText: String {
        get {
            return commentInputView.text
        }
    }
    var rateScore: String = ""
    private let kViewTag: Int = 4000
    private let commentBackgroundViewHeight: CGFloat = 335.0
    private lazy var commentBackgroundView: UIView = UIView(frame: CGRect.zero, color: UIColor.white)
    private lazy var titleLabel: UILabel = {
        let label: UILabel = UILabel(frame: CGRect.zero, text: "评价", textColor: UIColor(0x26343F), fontSize: 17.0, bold: true)
        label.textAlignment = .center
        return label
    }()
    private lazy var closeBtn: UIButton = {
        let button: UIButton = UIButton(frame: CGRect.zero)
        button.setImage(UIImage(named: "close"), for: .normal)
        button.tag = kViewTag
        button.addTarget(self, action: #selector(AnswerCommentView.eventButtonResponse(_:)), for: .touchUpInside)
        return button
    }()
    private lazy var separatorView: UIView = UIView(frame: CGRect.zero, color: XDColor.itemLine)
    private lazy var starBarView: EvaluationStarBar = {
        let view: EvaluationStarBar = EvaluationStarBar(frame: CGRect.zero, imageType: "middle")
        view.delegate = self
        return view
    }()
    private lazy var commentInputView: XDTextView = {
        let textView: XDTextView = XDTextView(frame: CGRect.zero)
        textView.textColor = XDColor.itemTitle
        textView.placeholder = "多说点什么吧"
        textView.placeholderLabel.numberOfLines = 1
        textView.fontSize = 14
        textView.delegate = self
        textView.backgroundColor = UIColor(0xF5F6F7)
        textView.layer.cornerRadius = 3.0
        textView.layer.masksToBounds = true
        return textView
    }()
    private lazy var commitBtn: UIButton = {
        let button: UIButton = UIButton(frame: CGRect.zero)
        button.setTitle("提交评价", for: .normal)
        button.layer.cornerRadius = 20.0
        button.layer.masksToBounds = true
        button.backgroundColor = UIColor(0x078CF1)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16.0)
        button.tag = kViewTag + 1
        button.addTarget(self, action: #selector(AnswerCommentView.eventButtonResponse(_:)), for: .touchUpInside)
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initContentViews()
        NotificationCenter.default.addObserver(self, selector: #selector(AnswerCommentView.eventKeyboardWillShow(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        if let touchView: UIView = touches.first?.view {
            if touchView.isDescendant(of: commentBackgroundView) {
                commentInputView.endEditing(true)
                UIView.animate(withDuration: 0.25) {
                    self.commentBackgroundView.transform = CGAffineTransform(translationX: 0.0, y: -self.commentBackgroundViewHeight)
                }
                return
            }
        }
        dismissCommentViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func eventKeyboardWillShow(notification: Notification) {
         if let rect = notification.userInfo![UIKeyboardFrameEndUserInfoKey] as? CGRect {
            let offsetYTransform = CGAffineTransform(translationX: 0.0, y: -rect.size.height-commentBackgroundViewHeight+80.0)
            UIView.animate(withDuration: 0.25, animations: {
                self.commentBackgroundView.transform = self.transform.concatenating(offsetYTransform)
            }) { (_) in
                
            }
        }
    }
    
    @objc func eventButtonResponse(_ sender: UIButton) {
        let index: Int = sender.tag - kViewTag
        if index == 0 {
            dismissCommentViews()
            guard let _ = delegate?.answerCommentViewDidDismiss() else { return }
        } else {
            if rateScore.isEmpty {
                XDPopView.toast("请为老师评分")
                return
            }
            dismissCommentViews()
            guard let _ = delegate?.answerCommentViewCommit(rateScore: rateScore, commentText: commentInputView.text) else { return }
        }
    }
    
    /// 以动画的形式展示出评价视图
    func showCommentViews() {
        UIApplication.shared.keyWindow?.addSubview(self)
        UIView.animate(withDuration: 0.25) {
            self.commentBackgroundView.transform = CGAffineTransform(translationX: 0.0, y: -self.commentBackgroundViewHeight)
        }
    }
    
    private func initContentViews() {
        backgroundColor = UIColor(white: 0.0, alpha: 0.8)
        commentBackgroundView.transform = CGAffineTransform.identity
        addSubview(commentBackgroundView)
        commentBackgroundView.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview().offset(commentBackgroundViewHeight)
            make.height.equalTo(commentBackgroundViewHeight)
        }
        commentBackgroundView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (make) in
            make.left.right.top.equalToSuperview()
            make.height.equalTo(56.0)
        }
        commentBackgroundView.addSubview(closeBtn)
        closeBtn.snp.makeConstraints { (make) in
            make.centerY.equalTo(titleLabel)
            make.right.equalToSuperview().offset(-16.0)
        }
        commentBackgroundView.addSubview(separatorView)
        separatorView.snp.makeConstraints { (make) in
            make.top.equalTo(titleLabel.snp.bottom)
            make.left.right.equalToSuperview()
            make.height.equalTo(XDSize.unitWidth)
        }
        commentBackgroundView.addSubview(starBarView)
        starBarView.snp.makeConstraints { (make) in
            make.top.equalTo(titleLabel.snp.bottom).offset(24.0)
            make.centerX.equalToSuperview()
        }
        commentBackgroundView.addSubview(commentInputView)
        commentInputView.snp.makeConstraints { (make) in
            make.top.equalTo(starBarView.snp.bottom).offset(28.0)
            make.left.equalToSuperview().offset(16.0)
            make.right.equalToSuperview().offset(-16.0)
            make.height.equalTo(112.0)
        }
        commentBackgroundView.addSubview(commitBtn)
        commitBtn.snp.makeConstraints { (make) in
            make.top.equalTo(commentInputView.snp.bottom).offset(24.0)
            make.centerX.equalToSuperview()
            make.width.equalTo(170.0)
            make.height.equalTo(40.0)
        }
    }
    
    /// dismiss评价视图
    private func dismissCommentViews() {
        if let _ = superview {
            commentInputView.endEditing(true)
            UIView.animate(withDuration: 0.25, animations: {
                self.commentBackgroundView.transform = CGAffineTransform.identity
            }) { (_) in
                self.removeFromSuperview()
            }
        }
    }
}

// MARK: XDTextViewDelegate
extension AnswerCommentView: XDTextViewDelegate {
    func textViewDidChanged(textView: UITextView) {
//        if let
//        commentInputView.text = textView.text
    }
}

extension AnswerCommentView: EvaluationStarBarDelegate {
    func evaluationStarBarDidMark(starCount: Int) {
        rateScore = "\(starCount)"
    }
}
