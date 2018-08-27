//
//  QDetailAnswerTextItem.swift
//  xxd
//
//  Created by remy on 2018/3/9.
//  Copyright © 2018年 com.smartstudy. All rights reserved.
//

class QDetailAnswerTextItem: QDetailItem {
    
    fileprivate var attrText = NSAttributedString()
    /// 消息内容高度
    fileprivate var contentTextHeight: CGFloat = 0
    /// 消息内容距离顶部高度
    fileprivate var contentTextTop: CGFloat = 0
    /// 索要信息视图高度
    fileprivate var infoViewHeight: CGFloat = 0.0
    /// 索要信息视图顶部间距
    fileprivate var infoViewTopSpace: CGFloat = 0.0
    fileprivate lazy var cellHeight: CGFloat = {
        // 顶部高度+内容高度+底部高度+信息视图高度
        return contentTextTop + contentTextHeight + infoViewTopSpace + infoViewHeight + (isAsker && showQuestionAfter ? 62 : contentPaddingBottom)
    }()
    
    override func cellClass() -> AnyClass! {
        return QDetailAnswerTextItemCell.self
    }
    
    override func setup(targetUser: String, isFirst: Bool = false, isAsker: Bool = false) {
        super.setup(targetUser: targetUser, isFirst: isFirst, isAsker: isAsker)
        if isFirst {
            if model.infoActionType != nil {
                attrText = NSAttributedString(string: "")
                if isAsker {
                    contentTextHeight = 0.0
                    infoViewTopSpace = 0.0
                    infoViewHeight = model.content.heightForFont(UIFont.systemFont(ofSize: 15.0), contentMaxWidth-24.0, 23.0) + 44.0
                } else {
                    attrText = NSAttributedString(string: model.content)
                    contentTextHeight = attrText.string.heightForFont(UIFont.systemFont(ofSize: 15), contentMaxWidth, 23)
                    infoViewTopSpace = 0.0
                    infoViewHeight = 0.0
                }
            } else {
                attrText = NSAttributedString(string: model.content)
                contentTextHeight = attrText.string.heightForFont(UIFont.systemFont(ofSize: 15), contentMaxWidth, 23)
                infoViewTopSpace = 0.0
                infoViewHeight = 0.0
            }
            contentTextTop = topInfoHeight
        } else {
            let prefixText = "回复 " + NSAttributedString(string: "@\(targetUser)").color(XDColor.main) + "："
            if model.infoActionType != nil {
                attrText = prefixText
                if isAsker {
                    contentTextHeight = 0.0
                    infoViewTopSpace = 16.0
                    infoViewHeight = model.content.heightForFont(UIFont.systemFont(ofSize: 15.0), contentMaxWidth-24.0, 23.0) + 44.0
                } else {
                    attrText = prefixText + model.content
                    contentTextHeight = attrText.string.heightForFont(UIFont.systemFont(ofSize: 15), contentMaxWidth, 23)
                    infoViewTopSpace = 0.0
                    infoViewHeight = 0.0
                }
            } else {
                attrText = prefixText + model.content
                contentTextHeight = attrText.string.heightForFont(UIFont.systemFont(ofSize: 15), contentMaxWidth, 23)
                infoViewTopSpace = 0.0
            }
            contentTextTop = contentPaddingTop
        }
    }
    
}
    
///
class QDetailAnswerTextItemCell: QDetailItemCell {
    
    private var commenterView: UIView!
    private var commenterAvatar: UIImageView!
    private lazy var authenImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "authen"))
        imageView.isHidden = true
        return imageView
    }()
    private var commenterName: UILabel!
    private var contentTextView: UILabel!
    private var commentTime: UILabel!
    private var bottomLine: UIView!
    /// 评论背景视图
    private lazy var commentBackgroundView: UIView = {
        let view: UIView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: XDSize.screenWidth, height: 0.0), color: UIColor.white)
        return view
    }()
    /// 索要个人信息视图
    private lazy var infoView: QADetailRequestInfoView = QADetailRequestInfoView(frame: CGRect(x: contentPaddingLeft, y: 0.0, width: contentMaxWidth, height: 0))
    // 追问
    private lazy var questionAfter: QuestionAfterBtn = {
        let view = QuestionAfterBtn(frame: .zero, title: "我要追问", fontSize: 14, titleColor: UIColor.white, target: self, action: #selector(askTap))!
        view.layer.cornerRadius = 15
        commentBackgroundView.addSubview(view)
        view.snp.makeConstraints { (make) in
            make.size.equalTo(CGSize(width: 80, height: 30))
            make.right.bottom.equalTo(commentBackgroundView).offset(-16)
        }
        return view
    }()
    /// 未评价视图
    private lazy var unratingBackgroundView: QDetailAnswerUnratingView = {
        let view: QDetailAnswerUnratingView = QDetailAnswerUnratingView(frame: CGRect.zero)
        view.isHidden = true
        contentView.addSubview(view)
        view.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview().offset(-XDSize.unitWidth)
            make.height.equalTo(93.0)
        }
        return view
    }()
    /// 已评价视图
    private lazy var ratingBackgroundView: QDetailAnswerRatingView = {
        let view: QDetailAnswerRatingView = QDetailAnswerRatingView(frame: CGRect.zero)
        view.isHidden = true
        contentView.addSubview(view)
        view.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview().offset(-XDSize.unitWidth)
        }
        return view
    }()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(commentBackgroundView)
        // 个人信息
        commenterView = UIView(frame: CGRect(x: 0, y: 0, width: XDSize.screenWidth, height: topInfoHeight))
        commentBackgroundView.addSubview(commenterView)
        commenterAvatar = UIImageView(frame: CGRect(x: 16, y: 16, width: 40, height: 40))
        commenterAvatar.layer.cornerRadius = 20
        commenterAvatar.layer.masksToBounds = true
        commenterAvatar.isUserInteractionEnabled = true
        commenterAvatar.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(counsellorTap)))
        commenterView.addSubview(commenterAvatar)
        commenterView.addSubview(authenImageView)
        authenImageView.snp.makeConstraints { (make) in
            make.bottom.equalTo(commenterAvatar)//.offset(1.0)
            make.right.equalTo(commenterAvatar).offset(4.0)
        }
        commenterName = UILabel(frame: .zero, text: "", textColor: XDColor.itemTitle, fontSize: 14, bold: true)
        commenterView.addSubview(commenterName)
        commenterName.snp.makeConstraints { (make) in
            make.centerY.equalTo(commenterAvatar)
            make.left.equalTo(commenterView).offset(contentPaddingLeft)
            make.width.lessThanOrEqualTo(contentMaxWidth)
        }
        // 文字内容
        contentTextView = UILabel(frame: CGRect(x: contentPaddingLeft, y: 0, width: contentMaxWidth, height: 0), text: "", textColor: XDColor.itemTitle, fontSize: 15)
        contentTextView.backgroundColor = UIColor.white
        contentTextView.numberOfLines = 0
        commentBackgroundView.addSubview(contentTextView)
        // 个人信息消息
        infoView.backgroundColor = UIColor(0xE6F3FD)
        commentBackgroundView.addSubview(infoView)
        // 时间
        commentTime = UILabel(frame: .zero, text: "", textColor: XDColor.itemText, fontSize: 12)
        commentBackgroundView.addSubview(commentTime)
        commentTime.snp.makeConstraints { (make) in
            make.bottom.equalTo(commentBackgroundView).offset(-16.0)
            make.left.equalTo(commentBackgroundView).offset(contentPaddingLeft)
        }
        // 分割线
        bottomLine = UIView(frame: CGRect(x: 0, y: contentView.height - XDSize.unitWidth, width: XDSize.screenWidth, height: XDSize.unitWidth), color: XDColor.itemLine)
        bottomLine.autoresizingMask = .flexibleTopMargin
        contentView.addSubview(bottomLine)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        
    }
    
    override class func height(for object: Any!, at indexPath: IndexPath!, tableView: UITableView!) -> CGFloat {
        if let item = object as? QDetailAnswerTextItem {
            if item.isAsker {
                if item.isLast {
                    if item.model.ratingScore == 0 {
                        return item.cellHeight + 93.0
                    } else {
                        if item.model.ratingComment.isEmpty {
                            return item.cellHeight + 62.0
                        } else {
                            return item.cellHeight + 62.0 + ceil(item.model.ratingComment.heightForFont(UIFont.systemFont(ofSize: 14.0), XDSize.screenWidth-80.0))
                        }
                    }
                } else {
                    return item.cellHeight
                }
            } else {
                if item.isLast {
                    if item.model.ratingScore == 0 {
                        return item.cellHeight
                    } else {
                        if item.model.ratingComment.isEmpty {
                            return item.cellHeight + 62.0
                        } else {
                            return item.cellHeight + 62.0 + ceil(item.model.ratingComment.heightForFont(UIFont.systemFont(ofSize: 14.0), XDSize.screenWidth-80.0))
                        }
                    }
                } else {
                    return item.cellHeight
                }
            }
        }
        return (object as! QDetailAnswerTextItem).cellHeight
    }
    
    override func shouldUpdate(with object: Any!) -> Bool {
        if super.shouldUpdate(with: object), let object = object as? QDetailAnswerTextItem {
            if object.isFirst {
                commenterView.isHidden = false
                commenterAvatar.setAutoOSSImage(urlStr: object.model.commenterAvatar)
                commenterName.text = object.model.commenterName
                authenImageView.isHidden = object.model.schoolCertified
            } else {
                commenterView.isHidden = true
            }
            commentBackgroundView.height = object.cellHeight
            contentTextView.top = object.contentTextTop
            contentTextView.height = object.contentTextHeight
            contentTextView.attr(attr: object.attrText, lineHeight: contentTextLineHeight)
            commentTime.text = object.model.createTimeText
            bottomLine.left = object.isLast ? 0 : contentPaddingLeft
            infoView.height = object.infoViewHeight
            if object.isAsker {
                infoView.top = object.contentTextTop
                questionAfter.isHidden = !object.showQuestionAfter
                if object.model.infoActionType != nil {
                    infoView.isHidden = false
                    infoView.replyText = object.model.content
                } else {
                    infoView.isHidden = true
                }
                if object.isLast {
                    if object.model.ratingScore == 0 {
                        unratingBackgroundView.isHidden = false
                        ratingBackgroundView.isHidden = true
                    } else {
                        unratingBackgroundView.isHidden = true
                        ratingBackgroundView.isHidden = false
                        ratingBackgroundView.height = 62.0 + ceil(object.model.ratingComment.heightForFont(UIFont.systemFont(ofSize: 14.0), XDSize.screenWidth-80.0))
                        ratingBackgroundView.rateContent = object.model.ratingComment
                        ratingBackgroundView.rateScore = object.model.ratingScore
                    }
                } else {
                    unratingBackgroundView.isHidden = true
                    ratingBackgroundView.isHidden = true
                }
            } else {
                infoView.isHidden = true
                if object.isLast && object.model.ratingScore != 0 {
                    ratingBackgroundView.isHidden = false
                    ratingBackgroundView.height = 62.0 + ceil(object.model.ratingComment.heightForFont(UIFont.systemFont(ofSize: 14.0), XDSize.screenWidth-80.0))
                    ratingBackgroundView.rateContent = object.model.ratingComment
                    ratingBackgroundView.rateScore = object.model.ratingScore
                } else {
                    ratingBackgroundView.isHidden = true
                }
            }
        }
        return true
    }
    
    //MARK:- Action
    @objc func counsellorTap() {
        routerEvent(name: kEventTeacherInfoTap, data: ["id": (item as! QDetailItem).model.imUserId])
    }
    
    @objc func askTap() {
        routerEvent(name: kEventAskAppendTap, data: ["view": self, "item": item])
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        if let touchView = touches.first?.view {
            if touchView.isDescendant(of: unratingBackgroundView) {
                routerEvent(name: "unratingViewTap", data: ["view":self, "item": item])
            } else if touchView.isDescendant(of: ratingBackgroundView) {
            } else if touchView.isDescendant(of: infoView.infoCheckLabel) {                
                routerEvent(name: kEventTeacherCheckInfoTap, data: ["item": item])
            } else {
                routerEvent(name: kEventAskAppendTap, data: ["view": self, "item": item])
            }
        }
    }
}
