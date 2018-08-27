//
//  QDetailAskItem.swift
//  xxd
//
//  Created by remy on 2018/3/9.
//  Copyright © 2018年 com.smartstudy. All rights reserved.
//

class QDetailAskTextItem: QDetailItem {
    
    fileprivate var attrText = NSAttributedString()
    fileprivate var contentTextHeight: CGFloat = 0
    /// 索要信息视图高度
    fileprivate var infoViewHeight: CGFloat = 0.0
    fileprivate var cellHeight: CGFloat = 0
    
    override func cellClass() -> AnyClass! {
        return QDetailAskTextItemCell.self
    }
    
    override func setup(targetUser: String, isFirst: Bool = false, isAsker: Bool = false) {
        super.setup(targetUser: targetUser, isFirst: isFirst, isAsker: isAsker)
        let prefixText = NSAttributedString(string: "追问 @\(targetUser)").color(UIColor(0xFFB400)) + "："
        if model.infoActionType != nil {
            infoViewHeight = model.content.heightForFont(UIFont.systemFont(ofSize: 15.0), contentMaxWidth-24.0, 23.0) + 44.0
            contentTextHeight = 0.0
        } else {
            attrText = prefixText + model.content
            infoViewHeight = 0.0
            // 文字内容高度
            contentTextHeight = attrText.string.heightForFont(UIFont.systemFont(ofSize: 15), contentMaxWidth, 23)
        }
        // 顶部高度+内容高度+底部高度+信息高度
        cellHeight = contentPaddingTop + contentTextHeight + contentPaddingBottom + infoViewHeight
    }
}

/// 学生的追问消息
class QDetailAskTextItemCell: QDetailItemCell {
    
    private var contentTextView: UILabel!
    private var commentTime: UILabel!
    private var bottomLine: UIView!
    /// 评论背景视图
    private lazy var commentBackgroundView: UIView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: XDSize.screenWidth, height: 0.0), color: UIColor.white)
    /// 个人信息消息视图
    private lazy var infoView: QADetailRequestInfoView = QADetailRequestInfoView(frame: CGRect(x: contentPaddingLeft, y: contentPaddingRight, width: contentMaxWidth, height: 0))
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
        // 文字内容
        contentTextView = UILabel(frame: CGRect(x: contentPaddingLeft, y: contentPaddingTop, width: contentMaxWidth, height: 0), text: "", textColor: XDColor.itemTitle, fontSize: 15)
        contentTextView.numberOfLines = 0
        commentBackgroundView.addSubview(contentTextView)
        // 信息消息
        infoView.backgroundColor = UIColor(0xF5F6F7)
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
    
    override class func height(for object: Any!, at indexPath: IndexPath!, tableView: UITableView!) -> CGFloat {
        if let item = object as? QDetailAskTextItem {
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
        return (object as! QDetailAskTextItem).cellHeight
    }
    
    override func shouldUpdate(with object: Any!) -> Bool {
        if super.shouldUpdate(with: object), let object = object as? QDetailAskTextItem {
            commentBackgroundView.height = object.cellHeight
            contentTextView.height = object.contentTextHeight
            contentTextView.attr(attr: object.attrText, lineHeight: contentTextLineHeight)
            commentTime.text = object.model.createTimeText
            bottomLine.left = object.isLast ? 0 : contentPaddingLeft
            if object.model.infoActionType != nil {
                infoView.isHidden = false
            } else {
                infoView.isHidden = true
            }
            infoView.replyText = object.model.content
            infoView.checkText = "点击查看基本信息"
            infoView.height = object.infoViewHeight
            if object.isAsker {
                if object.isLast  {
                    if object.model.ratingScore == 0 {
                        unratingBackgroundView.isHidden = false
                        ratingBackgroundView.isHidden = true
                    } else {
                        unratingBackgroundView.isHidden = true
                        ratingBackgroundView.isHidden = false
                        ratingBackgroundView.rateContent = object.model.ratingComment
                        ratingBackgroundView.rateScore = object.model.ratingScore
                        ratingBackgroundView.height = 62.0 + ceil(object.model.ratingComment.heightForFont(UIFont.systemFont(ofSize: 14.0), XDSize.screenWidth-80.0))
                    }
                } else {
                    unratingBackgroundView.isHidden = true
                    ratingBackgroundView.isHidden = true
                }
            } else {
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
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        if let touchView = touches.first?.view {
            if touchView.isDescendant(of: unratingBackgroundView) {
                routerEvent(name: "unratingViewTap", data: ["view":self, "item": item])
            } else if touchView.isDescendant(of: infoView.infoCheckLabel) {
                routerEvent(name: kEventStudentCheckInfoTap, data: ["item": item])
            }
        }
    }
    
}
