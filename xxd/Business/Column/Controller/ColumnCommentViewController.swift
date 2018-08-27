//
//  ColumnCommentViewController.swift
//  xxd
//
//  Created by Lisen on 2018/7/19.
//  Copyright © 2018年 com.smartstudy. All rights reserved.
//

import UIKit

private let kSendViewHeight: CGFloat = 49.0
private let kSendTextViewLineHeight: CGFloat = 33

/// 专栏评论
class ColumnCommentViewController: SSTableViewController {
    
    var columnId: Int = 0
    private var isHasData: Bool = false
    private var keyboardHeight: CGFloat = 0.0
    private var selectedUserId: Int?
    private lazy var emptyLabel: UILabel = {
        let label: UILabel = UILabel(frame: CGRect.zero, text: "快来成为第一个评论的人吧", textColor: UIColor(0x979797), fontSize: 16.0)
        return label
    }()
    
    private lazy var sendBtn: UIButton = {
        let button: UIButton = UIButton(frame: .zero, title: "发表", fontSize: 14, titleColor: XDColor.itemText, target: self, action: #selector(eventSendbuttonResponse(_:)))
        button.backgroundColor = XDColor.itemLine
        button.layer.cornerRadius = 4
        return button
    }()
    private lazy var commentInputView: XDTextView = {
        let textView: XDTextView = XDTextView(frame: CGRect(x: 16, y: 10, width: XDSize.screenWidth - 96, height: kSendTextViewLineHeight))
        textView.textColor = XDColor.itemTitle
        textView.placeholder = "请输入你的评论"
        textView.placeholderLabel.numberOfLines = 1
        textView.fontSize = 14
        textView.maxNumOfLines = 4
        textView.delegate = self
        return textView
    }()
    private lazy var commentView: UIView = {
        let contentView = UIView(frame: CGRect(x: 0, y: XDSize.screenHeight-kSendViewHeight, width: XDSize.screenWidth, height: kSendViewHeight), color: UIColor.white)
        contentView.addSubview(UIView(frame: CGRect(x: 0, y: 0, width: XDSize.screenWidth, height: XDSize.unitWidth), color: XDColor.itemLine))
        contentView.addSubview(sendBtn)
        sendBtn.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().offset(-10.0)
            make.size.equalTo(CGSize(width: 70, height: 29))
        }
        contentView.addSubview(commentInputView)
        return contentView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "评论"
        canDragRefresh = true
        canDragLoadMore = true
        autoresizesForKeyboard = true
        tableView.keyboardDismissMode = .onDrag
        view.addSubview(emptyLabel)
        emptyLabel.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
        }
        view.addSubview(commentView)
        tableView.contentInset = UIEdgeInsets(top: 0.0, left: 0.0, bottom: XDSize.tabbarHeight, right: 0.0)
        tableViewActions.attach(to: ColumnCommentItem.self, tap: { [weak self](object, target, indexPath) -> Bool in
            if let item = object as? ColumnCommentItem, let strongSelf = self {
                strongSelf.selectedUserId = item.model.commentId
                strongSelf.commentInputView.placeholder = "回复 " + item.model.commenterName
                strongSelf.commentInputView.focus()
            }
            return true
        })
    }
    
    override func keyboardWillAppear(_ animated: Bool, withBounds bounds: CGRect) {
        guard isViewAppearing else { return }
        keyboardHeight = bounds.height
        commentView.transform = CGAffineTransform(translationX: 0.0, y: -keyboardHeight)
    }
    
    override func keyboardWillDisappear(_ animated: Bool, withBounds bounds: CGRect) {
        if commentInputView.text.isEmpty {
            commentInputView.placeholder = "请输入你的评论"
            selectedUserId = nil
        }
        commentView.transform = .identity
        keyboardHeight = 0.0
    }
    
    override func createModel() {
        let urlString = String(format: XD_COLUMN_COMMNET_LIST, columnId)
        model = SSURLReqeustModel(httpMethod: .get, urlString: urlString, loadFromFile: false, isPaged: true)
    }
    
    override func didFinishLoad(with object: Any!) {
        if let responseObject = object as? [String: Any], let responseData = responseObject["data"] as? [String: Any], let serverData = responseData["data"] as? [[String: Any]], serverData.count > 0 {
            var cellItems: [ColumnCommentItem] = []
            for data in serverData {
                let item: ColumnCommentItem = ColumnCommentItem(attributes: data)
                cellItems.append(item)
            }
            emptyLabel.isHidden = true
            tableViewModel.addObjects(from: cellItems)
            tableViewModel.hasMore = (cellItems.count>=SSConfig.defaultPageSize)
        }
    }
    
    override func showEmpty(_ show: Bool) {
        super.showEmpty(false)
    }
    
    @objc private func eventSendbuttonResponse(_ sender: UIButton) {
        if XDUser.shared.hasLogin() {
            sender.isEnabled = false
            let urlString = String(format: XD_COMLUMN_POST_COMMNET, columnId)
            var params: [String: Any] = ["content": commentInputView.text]
            if let userId = selectedUserId {
                params["replyTo"] = userId
            }
            dismissCommentView()
            XDPopView.toast("内容发送中", self.view)
            SSNetworkManager.shared().post(urlString, parameters: params, success: { [weak self](dataTask, responseObject) in
                if let strongSelf = self {
                    sender.isEnabled = true
                    strongSelf.createModel()
                    XDPopView.toast("发布成功", strongSelf.view)
                }
            }) { (dataTask, error) in
                sender.isEnabled = true
                XDPopView.toast(error.localizedDescription, self.view)
            }
        } else {
            let signVC: SignInViewController = SignInViewController()
            present(signVC, animated: true, completion: nil)
        }
    }
    
    private func dismissCommentView() {
        commentInputView.placeholder = "请输入你的评论"
        commentInputView.text = ""
        commentInputView.blur()
        selectedUserId = nil
    }
    
}

// MARK: XDTextViewDelegate
extension ColumnCommentViewController: XDTextViewDelegate {
    func textViewTextHeightDidChange(text: String, textHeight: CGFloat) {
        commentInputView.height = textHeight
        commentView.height = (textHeight+16.0)
        commentView.top = XDSize.screenHeight-commentView.height-keyboardHeight
    }
    
    func textViewDidChanged(textView: UITextView) {
        let contentLen = textView.text.trimmingCharacters(in: .whitespacesAndNewlines).count
        if contentLen > 0 {
            sendBtn.isEnabled = true
            sendBtn.backgroundColor = XDColor.main
            sendBtn.setTitleColor(UIColor.white, for: .normal)
        } else {
            sendBtn.isEnabled = false
            sendBtn.backgroundColor = XDColor.itemLine
            sendBtn.setTitleColor(XDColor.itemText, for: .normal)
        }
    }
}
