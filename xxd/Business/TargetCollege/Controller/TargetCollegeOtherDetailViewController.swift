//
//  TargetCollegeOtherDetailViewController.swift
//  xxd
//
//  Created by Lisen on 2018/6/4.
//  Copyright © 2018年 com.smartstudy. All rights reserved.
//

import UIKit

/// 学生的选校信息主页
class TargetCollegeOtherDetailViewController: SSTableViewController {
    var userId: Int = 0
    var userName: String = ""
    
    private var isRequestCommentData: Bool = false
    private var isReset: Bool = false
    private var keyboardHeight: CGFloat = 0.0
    private var modelSections = [NITableViewModelSection]()
    private var sectionTitles: [String] = ["TA的选校: ", "选校评论"]
    private var likeCounts: Int = 0
    private var replyUserId: Int?
    private var selectedIndexPath: IndexPath?
    private lazy var likeButton: UIButton = {
        let button: UIButton = UIButton(frame: CGRect.zero, title: "0", fontSize: 14.0, titleColor: XDColor.itemText, backgroundColor: UIColor.white, target: self, action: #selector(eventButtonResponse(_:)))
        button.setImage(UIImage(named: "liked_flag"), for: .selected)
        button.setImage(UIImage(named: "like_gray"), for: .normal)
        button.setTitleColor(XDColor.main, for: .selected)
        button.titleEdgeInsets = UIEdgeInsets(top: 0.0, left: 7.0, bottom: 0.0, right: 0.0)
        button.layer.cornerRadius = 18.0
        button.layer.masksToBounds = true
        button.layer.borderWidth = XDSize.unitWidth
        return button
    }()
    private lazy var commentView: UIView = {
        let view: UIView = UIView(frame: CGRect(x: 0.0, y: tableView.bottom, width: XDSize.screenWidth, height: XDSize.tabbarHeight), color: UIColor(0xFAFBFC))
        view.layer.borderColor = UIColor(0xE4E5E6).cgColor
        view.layer.borderWidth = XDSize.unitWidth
        view.addSubview(textInputView)
        view.addSubview(commentButton)
        commentButton.snp.makeConstraints { (make) in
            make.centerY.equalTo(textInputView)
            make.right.equalTo(-16.0)
        }
        return view
    }()
    private lazy var textInputView: XDTextView = {
        let textView: XDTextView = XDTextView(frame: CGRect(x: 16.0, y: 7.0, width: XDSize.screenWidth-80.0, height: 35.0))
        textView.backgroundColor = UIColor.white
        textView.layer.cornerRadius = 6.0
        textView.layer.borderWidth = XDSize.unitWidth*2.0
        textView.layer.masksToBounds = true
        textView.layer.borderColor = UIColor(0xE4E5E6).cgColor
        textView.maxNumOfLines = 4
        textView.delegate = self
        return textView
    }()
    private lazy var commentButton: UIButton = {
        let button: UIButton = UIButton(frame: CGRect.zero, title: "评论", fontSize: 15.0, titleColor: XDColor.main, backgroundColor: UIColor.clear, target: self, action: #selector(eventButtonResponse(_:)))
        button.tag = 1
        return button
    }()
    private lazy var sectionFooterView: UIView = {
        let view: UIView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: XDSize.screenWidth, height: 96.0), color: UIColor.white)
        view.addSubview(likeButton)
        likeButton.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
            make.width.equalTo(107.0)
            make.height.equalTo(36.0)
        }
        return view
    }()
    
    convenience init() {
        self.init(query: nil)
        tableViewStyle = .grouped
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = userName + "的选校"
        autoresizesForKeyboard = true
        tableView.keyboardDismissMode = .onDrag
        canDragLoadMore = true
        let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(eventTableViewTapResponse(_:)))
        tapGesture.delegate = self
        tableView.addGestureRecognizer(tapGesture)
        tableView.frame = CGRect(x: 0, y: XDSize.topHeight, width: XDSize.screenWidth, height: XDSize.screenHeight - XDSize.topHeight - XDSize.tabbarHeight)
        view.addSubview(commentView)
        fetchUserCollegeSelectionDetails()
        
        tableViewActions.attach(to: TargetCollegeOtherItem.self, tap: { (object, target, indexPath) -> Bool in
            if self.textInputView.isFirstResponder {
                self.textInputView.blur()
            }
            return true
        })
        tableViewActions.attach(to: TargetCollegeCommentItem.self, tap: { (object, target, indexPath) -> Bool in
            if let object = object as? TargetCollegeCommentItem {
                self.replyUserId = object.model.commenterId
                self.textInputView.placeholder = "回复 @" + object.model.commenterName + ": "
                self.textInputView.focus()
                self.selectedIndexPath = indexPath
                if let indexPath = indexPath, let currentCell = self.tableView.cellForRow(at: indexPath) as? TargetCollegeCommentItemCell, self.keyboardHeight != 0.0 {
                    let topSpace: CGFloat = self.tableView.height-self.keyboardHeight-XDSize.tabbarHeight
                    let offsetY = ceil(currentCell.bottom) - self.tableView.top - topSpace + 15.0
                    self.tableView.setContentOffset(CGPoint(x: 0.0, y: offsetY), animated: true)
                }
            }
            return true
        })
    }

    override func createModel() {
        if isRequestCommentData {
            let urlString = String(format: XD_TARGET_COLLEGE_OTHER_COMMENTS, self.userId)
            let model = SSURLReqeustModel(httpMethod: .get, urlString: urlString, loadFromFile: false, isPaged: true)
            self.model = model
        }
    }
    
    override func didFinishLoad(with object: Any!) {
        if let responseObject = object as? [String: Any], let serverData = responseObject["data"] as? [String: Any] {
            let commentSection = NITableViewModelSection.section() as! NITableViewModelSection
            var cellItems: [TargetCollegeCommentItem] = []
            if let commentData = serverData["data"] as? [[String: Any]], commentData.count > 0 {
                for comment in commentData {
                    let item: TargetCollegeCommentItem = TargetCollegeCommentItem(attributes: comment)
                    cellItems.append(item)
                }
                cellItems.last?.isLast = true
                commentSection.rows = cellItems
            }
            if self.modelSections.count > 1 {
                if isReset {
                    self.modelSections.removeLast()
                    self.modelSections.append(commentSection)
                    isReset = false
                } else {
                    self.modelSections.last?.rows.append(contentsOf: cellItems)
                }
            } else {
                self.modelSections.append(commentSection)
            }
            tableViewModel.hasMore = cellItems.count >= SSConfig.defaultPageSize
            self.tableViewModel.sections = NSMutableArray(array: self.modelSections)
        }
    }
    
    override func showEmpty(_ show: Bool) {
        super.showEmpty(false)
    }
    
    @objc private func eventTableViewTapResponse(_ gesture: UITapGestureRecognizer) {
        if textInputView.isFirstResponder {
            textInputView.blur()
        }
    }
    
    override func keyboardWillAppear(_ animated: Bool, withBounds bounds: CGRect) {
        guard isViewAppearing else { return }
        keyboardHeight = bounds.height
        self.commentView.transform = CGAffineTransform(translationX: 0.0, y: -self.keyboardHeight+(XDSize.tabbarHeight-49.0))
        if let indexPath = selectedIndexPath, let currentCell = tableView.cellForRow(at: indexPath) as? TargetCollegeCommentItemCell {
            let topSpace: CGFloat = tableView.height-keyboardHeight-XDSize.tabbarHeight
            let offsetY = ceil(currentCell.bottom) - tableView.top - topSpace + 15.0
            tableView.setContentOffset(CGPoint(x: 0.0, y: offsetY), animated: true)
        }
    }
    
    override func keyboardWillDisappear(_ animated: Bool, withBounds bounds: CGRect) {
        if textInputView.text.isEmpty {
            textInputView.placeholder = ""
            replyUserId = nil
            selectedIndexPath = nil
        }
        self.commentView.transform = .identity
        tableView.contentInset = UIEdgeInsets(top: 0.0, left: 0.0, bottom: commentView.height, right: 0.0)
        keyboardHeight = 0.0
    }
    
    @objc private func eventButtonResponse(_ sender: UIButton) {
        if sender.tag == 0 {
            // 点赞
            // TODO: 应该有点赞失败提示的.....
            let urlString = String(format: XD_TARGET_COLLEGE_LIKE, userId)
            SSNetworkManager.shared().post(urlString, parameters: nil, success: { (dataTask, responseObject) in
                if let responseData = responseObject as? [String: Any], let serverData = responseData["data"] as? [Any] {
                    if let isLiked = serverData.last as? Bool, isLiked {
                        self.configureLikeButton(true, likeCount: self.likeCounts+1)
                    }
                }
            }) { (dataTask, error) in
                XDPopView.toast(error.localizedDescription)
            }
        } else {
            // 评论
            if !textInputView.text.trimmingCharacters(in: CharacterSet.whitespaces).isEmpty {
                var params: [String: Any] = ["content": textInputView.text]
                if let uid = replyUserId {
                    params["toUserId"] = uid
                }
                SSNetworkManager.shared().post(String(format: XD_TARGET_COLLEGE_COMMENT, userId), parameters: params, success: { (dataTask, responseObjec) in
                    self.textInputView.text = ""
                    self.isRequestCommentData = true
                    self.isReset = true
                    self.createModel()
                    self.textInputView.placeholder = ""
                    self.textInputView.blur()
                }) { (dataTask, error) in
                    XDPopView.toast(error.localizedDescription)
                }
            }
        }
    }
    
    /// 获取用户选校主页的详细信息
    private func fetchUserCollegeSelectionDetails() {
        let urlString = String(format: XD_TARGET_COLLEGE_OTHER_DETAIL, userId)
        SSNetworkManager.shared().get(urlString, parameters: nil, success: { (dataTask, responseObject) in
            if let object = responseObject as? [String: Any], let serverData = object["data"] as? [String: Any] {
                if self.tableView.tableHeaderView == nil {
                    let tableHeaderView: TargetCollegeOtherDetailHeaderView = TargetCollegeOtherDetailHeaderView(frame: CGRect(x: 0.0, y: 0.0, width: XDSize.screenWidth, height: 238.0))
                    tableHeaderView.userModel = OtherUserModel.yy_model(with: serverData["user"] as! [String: Any])
                    self.tableView.tableHeaderView = tableHeaderView
                    if let schoolNum = serverData["selectedSchoolsCount"] as? Int {
                        self.sectionTitles[0] = "TA的选校（共\(schoolNum)所）："
                    }
                    if let likeCounts = serverData["likesCount"] as? Int, let isLiked = serverData["liked"] as? Bool {
                        self.likeCounts = likeCounts
                        self.configureLikeButton(isLiked, likeCount: likeCounts)
                    }
                    if let schoolModels = serverData["selectedSchools"] as? [[String: Any]], schoolModels.count > 0 {
                        var cellItems: [TargetCollegeOtherItem] = []
                        let schoolSection = NITableViewModelSection.section() as! NITableViewModelSection
                        for school in schoolModels {
                            let item: TargetCollegeOtherItem = TargetCollegeOtherItem(attributes: school)
                            cellItems.append(item)
                        }
                        schoolSection.rows = cellItems
                        self.modelSections.append(schoolSection)
                    }
                    self.isRequestCommentData = true
                    self.createModel()
                }
            }
        }) { (dataTask, error) in
            // TODO: 处理请求出错的情况
            self.isRequestCommentData = false
//            XDPopView
        }
    }
    
    private func configureLikeButton(_ isLiked: Bool, likeCount: Int) {
        likeButton.isSelected = isLiked
        if isLiked {
            likeButton.layer.borderColor = UIColor(0x078CF1).cgColor
            likeButton.setTitle("\(likeCount)", for: .selected)
        } else {
            likeButton.layer.borderColor = UIColor(0xC4C9CC).cgColor
            likeButton.setTitle("\(likeCount)", for: .normal)
        }
    }
}

extension TargetCollegeOtherDetailViewController {
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView: UIView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: XDSize.screenWidth, height: 50.0), color: UIColor.white)
        let bottomLine: UIView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: XDSize.screenWidth, height: 12.0), color: XDColor.mainBackground)
        let titleLabel: UILabel = UILabel(frame: CGRect(x: 16.0, y: 36.0, width: XDSize.screenWidth-32.0, height: 18.0), text: "", textColor: UIColor(0x26343F), fontSize: 18.0, bold: true)
        let emptyLabel: UILabel = UILabel(frame: CGRect(x: 0.0, y: titleLabel.bottom+24.0, width: XDSize.screenWidth, height: 16.0), text: "暂无评论", textColor: UIColor(0x949BA1), fontSize: 16.0)
        titleLabel.text = sectionTitles[section]
        headerView.addSubview(bottomLine)
        headerView.addSubview(titleLabel)
        if section == 1 {
            emptyLabel.textAlignment = .center
            headerView.addSubview(emptyLabel)
            if let _ = modelSections.last?.rows {
                emptyLabel.isHidden = true
            } else {
                emptyLabel.isHidden = false
            }
        }
        return headerView
    }
    
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if section == 0 {
            return sectionFooterView
        }
        return UIView(frame: CGRect(x: 0.0, y: 0.0, width: XDSize.screenWidth, height: 1.0), color: UIColor.clear)
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 58.0
        }
        if let _ = modelSections.last?.rows {
            return 62.0
        }
        return 62.0 + 40.0
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == 0 {
            return 84.0
        }
        return 1.0
    }
}

// MARK: XDTextViewDelegate
extension TargetCollegeOtherDetailViewController: XDTextViewDelegate {
    func textViewTextHeightDidChange(text: String, textHeight: CGFloat) {
        self.textInputView.height = textHeight
        self.commentView.height = textHeight + 14.0
        self.commentView.top = XDSize.screenHeight-self.keyboardHeight-self.commentView.height
    }
}

// MARK: UIGestureRecognizerDelegate
extension TargetCollegeOtherDetailViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if let touchView = touch.view, NSStringFromClass(touchView.classForCoder) == "UITableViewCellContentView" {
            return false
        }
        return true
    }
}
