//
//  QuestionDetailViewController.swift
//  xxd
//
//  Created by remy on 2018/1/15.
//  Copyright © 2018年 com.smartstudy. All rights reserved.
//

import AVFoundation
import SwiftyJSON

private let kSendViewHeight: CGFloat = 49
private let kSendTextViewLineHeight: CGFloat = 33
private let kSendTextViewMaxHeight: CGFloat = 99
private let kBottomBarHeight: CGFloat = UIDevice.isIPhoneX ? 94 : 60

class QuestionDetailViewController: SSTableViewController, XDTextViewDelegate {
    
    var questionID = 0
    private var commentID = 0
    /// 老师索要个人信息那条评论的id
    private var requestInfoCommentId = 0
    private var sendBtn: UIButton!
    private var cellView: UIView?
    private var textView: XDTextView!
    /// 是否正在查询老师信息
    private var isQueryTeacherInfo: Bool = false
    private lazy var rateView: AnswerCommentView = {
        let view: AnswerCommentView =  AnswerCommentView(frame: UIScreen.main.bounds)
        view.delegate = self
        return view
    }()
    private var isAsker: Bool! {
        didSet {
            if oldValue == nil && isAsker != nil {
                if isAsker {
                    isCustomKeyboard = true
                    keyboardTopView = sendView
                    view.addSubview(sendView)
                    // TODO: 由于在cell里面对touch事件进行了传递, 故此处暂时隐掉点击事件
//                    tableViewActions.attach(to: QDetailAnswerTextItem.self, tap: {
//                        [weak self] (object, target, indexPath) -> Bool in
//                        if let object = object as? QDetailAnswerTextItem {
//                            let cellView = self?.tableView.cellForRow(at: indexPath!)
//                            self?.routerEvent(name: kEventAskAppendTap, data: ["view": cellView!, "item": object])
//                        }
//                        return true
//                    })
//                    tableViewActions.attach(to: QDetailAnswerAudioItem.self, tap: {
//                        [weak self] (object, target, indexPath) -> Bool in
//                        if let object = object as? QDetailAnswerAudioItem {
//                            let cellView = self?.tableView.cellForRow(at: indexPath!)
//                            self?.routerEvent(name: kEventAskAppendTap, data: ["view": cellView!, "item": object])
//                        }
//                        return true
//                    })
                } else {
                    tableView.height = XDSize.screenHeight - topOffset - kBottomBarHeight
                    tableView.contentInset = UIEdgeInsetsMake(0, 0, 12, 0)
                    view.addSubview(askView)
                }
            }
        }
    }
    private lazy var askView: UIView = {
        let view = UIView(frame: CGRect(x: 0, y: XDSize.screenHeight - kBottomBarHeight, width: XDSize.screenWidth, height: kBottomBarHeight), color: UIColor.white)
        
        let btnView = UIView(frame: .zero, color: UIColor(0xFFB400))
        btnView.layer.cornerRadius = 22
        btnView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(askTap)))
        view.addSubview(btnView)
        btnView.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(8)
            make.size.equalTo(CGSize(width: 299, height: 44))
        }
        
        let topLine = UIView(frame: CGRect(x: 0, y: 0, width: XDSize.screenWidth, height: XDSize.unitWidth), color: XDColor.itemLine)
        view.addSubview(topLine)
        
        let titleView = UILabel(text: "我也要提问", textColor: UIColor.white, fontSize: 16)!
        btnView.addSubview(titleView)
        titleView.snp.makeConstraints { (make) in
            make.centerY.equalTo(btnView)
            make.centerX.equalTo(btnView).offset(11)
        }
        
        let imageView = UIImageView(frame: .zero, imageName: "question_add_white")!
        btnView.addSubview(imageView)
        imageView.snp.makeConstraints { (make) in
            make.centerY.equalTo(btnView)
            make.right.equalTo(titleView.snp.left).offset(-8)
        }
        return view
    }()
    private lazy var sendView: UIView = {
        let sendView = UIView(frame: CGRect(x: 0, y: XDSize.screenHeight, width: XDSize.screenWidth, height: kSendViewHeight), color: UIColor.white)
        
        sendView.addSubview(UIView(frame: CGRect(x: 0, y: 0, width: XDSize.screenWidth, height: XDSize.unitWidth), color: XDColor.itemLine))
        
        sendBtn = UIButton(frame: .zero, title: "发表", fontSize: 14, titleColor: XDColor.itemText, target: self, action: #selector(sendTap(sender:)))
        sendBtn.backgroundColor = XDColor.itemLine
        sendBtn.layer.cornerRadius = 3
        sendView.addSubview(sendBtn)
        sendBtn.snp.makeConstraints { (make) in
            make.right.bottom.equalTo(sendView).offset(-10)
            make.size.equalTo(CGSize(width: 70, height: 29))
        }
        
        textView = XDTextView(frame: CGRect(x: 16, y: 10, width: XDSize.screenWidth - 96, height: kSendTextViewLineHeight))
        textView.textColor = XDColor.itemTitle
        textView.placeholder = "请输入你的问题"
        textView.placeholderLabel.numberOfLines = 1
        textView.fontSize = 14
        textView.maxNumOfLines = 4
        textView.delegate = self
        sendView.addSubview(textView)
        return sendView
    }()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        AudioManager.shared.stopAllAudioPlay()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        AudioManager.shared.stopAllAudioPlay()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        XDStatistics.click("21_B_question_detail")
        clearTableViewWhenLoadingNew = true
        canDragRefresh = true
        title = "title_question_details".localized
        
        tableView.keyboardDismissMode = .onDrag
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidShow(notification:)), name: NSNotification.Name.UIKeyboardDidShow, object: nil)
    }
    
    private func createItem(_ dict: [AnyHashable : Any]) -> QDetailItem? {
        if let model = QuestionDetailModel.yy_model(with: dict) {
            var item: QDetailItem!
            switch model.type {
            case .questionText:
                item = QDetailAskTextItem()
            case .answerText:
                item = QDetailAnswerTextItem()
            case .answerAudio:
                item = QDetailAnswerAudioItem()
            default:
                return nil
            }
            item.model = model
            return item
        }
        return nil
    }
    
    override func createModel() {
        let urlStr = String(format: XD_API_QUESTION_DETAIL, questionID)
        model = SSURLReqeustModel(httpMethod: .get, urlString: urlStr, loadFromFile: false, isPaged: false)
    }
    
    override func didFinishLoad(with object: Any!) {
        if let data = (object as! [String : Any])["data"] as? [String : Any] {
            let header = QDetailHeader(frame: CGRect(x: 0, y: 0, width: XDSize.screenWidth, height: 0))
            header.model = QuestionModel.yy_model(with: data)
            tableView.tableHeaderView = header
            isAsker = header.model.userID == XDUser.shared.model.ID
            
            if let answersData = data["answers"] as? [[String : Any]] {
                var answers = [QDetailItem]()
                let asker = header.model.askerName
                for dict in answersData {
                    if let singleAnswer = createItem(dict) {
                        singleAnswer.setup(targetUser: asker, isFirst: true, isAsker: isAsker)
                        answers.append(singleAnswer)
                        let answerer = singleAnswer.model.commenterName
                        var lastAnswerItem = singleAnswer
                        if let subs = dict["comments"] as? [[String : Any]] {
                            for dict in subs {
                                if let subComment = createItem(dict) {
                                    subComment.model.firstCommentId = singleAnswer.model.commentID
                                    subComment.model.ratingScore = singleAnswer.model.ratingScore
                                    subComment.model.ratingComment = singleAnswer.model.ratingComment
                                    if subComment.model.type == .answerText || subComment.model.type == .answerAudio {
                                        lastAnswerItem = subComment
                                        subComment.setup(targetUser: asker, isAsker: isAsker)
                                    } else {
                                        subComment.setup(targetUser: answerer, isAsker: isAsker)
                                    }
                                    answers.append(subComment)
                                }
                            }
                        }
                        lastAnswerItem.showQuestionAfter = true
                        answers.last!.isLast = true
                    }
                }
                tableViewModel.addObjects(from: answers)
            }
        }
    }
    
    override func showEmpty(_ show: Bool) {
        super.showEmpty(false)
    }
    
    //MARK:- Notification
    @objc func keyboardDidShow(notification: Notification) {
        guard isViewAppearing else { return }
        let rect = notification.userInfo![UIKeyboardFrameEndUserInfoKey] as! CGRect
        /// 在评价编辑界面, 由于没有为cellView复制, 而会导致在键盘消失crash
        if let cellView = cellView {
            let height = tableView.height - rect.size.height - sendView.height
            let offsetY = cellView.screenViewY - tableView.top + cellView.height - height
            tableView.setContentOffset(CGPoint(x: 0, y: offsetY), animated: false)
        }
    }
    
    //MARK:- XDTextViewDelegate
    func textViewTextHeightDidChange(text: String, textHeight: CGFloat) {
        let keyboardHeight = XDSize.screenHeight - sendView.bottom
        textView.height = textHeight
        sendView.height = kSendViewHeight - kSendTextViewLineHeight + textHeight
        sendView.top = XDSize.screenHeight - sendView.height - keyboardHeight
    }
    
    func textViewDidChanged(textView: UITextView) {
        let contentLen = textView.text.trimmingCharacters(in: .whitespaces).count
        if contentLen > 0 {
            sendBtn.backgroundColor = XDColor.main
            sendBtn.setTitleColor(UIColor.white, for: .normal)
        } else {
            sendBtn.backgroundColor = XDColor.itemLine
            sendBtn.setTitleColor(XDColor.itemText, for: .normal)
        }
    }
    
    //MARK:- Action
    override func routerEvent(name: String, data: Dictionary<String, Any>) {
        if name == kEventAskAppendTap {
            if let item = data["item"] as? QDetailItem, let textView = textView {
                textView.blur()
                textView.placeholder = "追问 @" + item.model.commenterName + "："
                textView.focus()
                cellView = data["view"] as? UIView
                commentID = item.model.commentID
            }
        } else if name == kEventTeacherInfoTap {
            if !isQueryTeacherInfo {
                isQueryTeacherInfo = true
                let id = data["id"] as! String
                // 会出现没有认证信息的老师,所以先请求
                SSNetworkManager.shared().get(XD_FETCH_TEACHER_INFO, parameters: ["imUserId": id], success: {
                    [weak self] (_, response) in
                    if let res = response {
                        let vc = TeacherInfoDetailViewController(query: [IMUserID: id])
                        vc.jsonData = JSON(res)
                        XDRoute.pushToVC(vc)
                    }
                    self?.isQueryTeacherInfo = false
                }, failure: {
                    [weak self] (_, error) in
                    self?.isQueryTeacherInfo = false
                })
            }
        } else if name == "unratingViewTap" {
            if let item = data["item"] as? QDetailItem, item.model.firstCommentId != -1 {
                commentID = item.model.firstCommentId
            }
            if textView.isFirstResponder {
                textView.blur()
            }
            rateView.showCommentViews()
        } else if name == kEventTeacherCheckInfoTap {
            if let item = data["item"] as? QDetailItem {
                requestInfoCommentId = item.model.commentID
                let infoVC: UserInfoEditViewController = UserInfoEditViewController()
                infoVC.delegate = self
                XDRoute.pushToVC(infoVC)
            }
        } else if name == kEventStudentCheckInfoTap {
            if let item = data["item"] as? QDetailItem {
                requestInfoCommentId = item.model.atCommentId
                if item.isAsker {
                    let infoVC: UserInfoEditViewController = UserInfoEditViewController()
                    infoVC.delegate = self
                    navigationController?.pushViewController(infoVC, animated: true)
                } else {
                    let otherUserVC: OtherUserInfoViewController = OtherUserInfoViewController()
                    otherUserVC.otherUserId = item.model.commenterId
                    otherUserVC.otherUserName = item.model.commenterName
                    navigationController?.pushViewController(otherUserVC, animated: true)
                }
            }
        }
    }
    
    @objc func sendTap(sender: UIButton) {
        let content = textView.text.trimmingCharacters(in: .whitespaces)
        if content.count > 0 {
            textView.text = ""
            view.endEditing(true)
            XDPopView.loading()
            let urlStr = String(format: XD_API_SUB_QUESTION_APPEND, questionID, commentID)
            SSNetworkManager.shared().post(urlStr, parameters: ["content":content], success: {
                [weak self] (task, responseObject) in
                self?.reload()
                XDPopView.hide()
            }) { (task, error) in
                XDPopView.toast(error.localizedDescription)
            }
        }
    }
    
    @objc func askTap() {
        if XDUser.shared.hasLogin() {
            let vc = AskViewController()
            presentModalViewController(vc, animated: true, completion: nil)
        } else {
            let vc = SignInViewController()
            presentModalViewController(vc, animated: true, completion: nil)
        }
    }
}

// MARK: AnswerCommentViewDelegate
extension QuestionDetailViewController: AnswerCommentViewDelegate {
    func answerCommentViewCommit(rateScore: String, commentText: String) {
        let postUrlString: String = String(format: XD_API_RATE_QUESTION, questionID, commentID)
        SSNetworkManager.shared().post(postUrlString, parameters: ["score": rateScore, "comment": commentText], success: { (dataTask, responseData) in
            self.reload()
            }, failure: { (dataTask, error) in
                XDPopView.toast(error.localizedDescription)
            })
    }
    
    func answerCommentViewDidDismiss() {
        
    }
}

// MARK: UserInfoEditViewControllerDelegate
extension QuestionDetailViewController: UserInfoEditViewControllerDelegate {
    func userInfoDidComplete() {
        XDPopView.loading()
        let urlStr = String(format: XD_API_QUESTION_REQUESTINFO, questionID, requestInfoCommentId)
        SSNetworkManager.shared().post(urlStr, parameters: nil, success: {
            [weak self] (task, responseObject) in
            self?.reload()
            XDPopView.hide()
        }) { (task, error) in
            XDPopView.toast(error.localizedDescription)
        }
    }
}
