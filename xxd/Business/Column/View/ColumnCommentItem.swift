//
//  ColumnCommentItem.swift
//  xxd
//
//  Created by Lisen on 2018/7/19.
//  Copyright © 2018年 com.smartstudy. All rights reserved.
//

import UIKit

class ColumnCommentItem: SSCellItem {
    var model: ColumnCommentModel!
    
    override init!(attributes: [AnyHashable : Any]! = [:]) {
        super.init(attributes: attributes)
        model = ColumnCommentModel.yy_model(with: attributes)
    }
    
    override init!(cellClass: AnyClass!, userInfo: Any!) {
        super.init(cellClass: cellClass, userInfo: userInfo)
    }
    
    override func cellClass() -> AnyClass! {
        return ColumnCommentItemCell.self
    }
}

class ColumnCommentItemCell: SSTableViewCell {
    private lazy var commentParagh: NSMutableParagraphStyle = {
        let paragraph: NSMutableParagraphStyle = NSMutableParagraphStyle()
        paragraph.minimumLineHeight = 20.0
        paragraph.maximumLineHeight = 20.0
        paragraph.lineBreakMode = .byWordWrapping
        return paragraph
    }()
    private lazy var avatarView: UIImageView = {
        let imageView: UIImageView = UIImageView(frame: CGRect.zero)
        imageView.layer.cornerRadius = 20.0
        imageView.layer.masksToBounds = true
        return imageView
    }()
    private lazy var nameLabel: UILabel = UILabel(frame: CGRect.zero, text: "", textColor: XDColor.itemTitle, fontSize: 14.0, bold: true)
    private lazy var timeLabel: UILabel = UILabel(frame: CGRect.zero, text: "", textColor: UIColor(0xC4C9CC), fontSize: 12.0)
    private lazy var commentLabel: UILabel = UILabel(frame: CGRect.zero, text: "", textColor: XDColor.itemTitle, fontSize: 15.0)
    private lazy var lastCommentBackgroundView: UIView = {
        let view: UIView = UIView(frame: CGRect.zero, color: UIColor(0xF5F6F7))
        view.layer.cornerRadius = 4.0
        view.addSubview(lastCommentLabel)
        lastCommentLabel.snp.makeConstraints { (make) in
            make.edges.equalToSuperview().inset(UIEdgeInsetsMake(8.0, 10.0, 8.0, 10.0))
        }
        return view
    }()
    private lazy var lastCommentLabel: UILabel = UILabel(frame: CGRect.zero, text: "", textColor: XDColor.itemText, fontSize: 14.0)
    private lazy var separatorView: UIView = UIView(frame: CGRect.zero, color: XDColor.itemLine)
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        initContentViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override static func height(for object: Any!, at indexPath: IndexPath!, tableView: UITableView!) -> CGFloat {
        if let item = object as? ColumnCommentItem {
            let commentHeight: CGFloat = item.model.commentContent.heightForFont(UIFont.systemFont(ofSize: 15.0), XDSize.screenWidth-80.0, 23.0)
            if item.model.lastComment.commenterName.isEmpty {
                return ceil(commentHeight)+81.0
            } else {
                let lastCommentHeight: CGFloat = (item.model.lastComment.commentContent+" "+item.model.lastComment.commenterName).heightForFont(UIFont.systemFont(ofSize: 14.0), XDSize.screenWidth-100.0, 20.0)
                return ceil(commentHeight)+ceil(lastCommentHeight)+104.0
            }
        }
        return 0.0
    }
    
    override func shouldUpdate(with object: Any!) -> Bool {
        if super.shouldUpdate(with: object), let item = object as? ColumnCommentItem {
            avatarView.kf.setImage(with: URL(string: item.model.commenterAvatar), placeholder: UIImage(named: "default_avatar"))
            nameLabel.text = item.model.commenterName
            timeLabel.text = item.model.commentTime
            commentLabel.text(text: item.model.commentContent, lineHeight: 23.0)
            if !item.model.lastComment.commenterName.isEmpty {
                lastCommentBackgroundView.isHidden = false
                lastCommentLabel.attributedText = NSAttributedString(string: item.model.lastComment.commenterName, attributes: [NSAttributedStringKey.foregroundColor: XDColor.main, NSAttributedStringKey.paragraphStyle: commentParagh]) + " " +
                    NSAttributedString(string: item.model.lastComment.commentContent, attributes: [NSAttributedStringKey.paragraphStyle: commentParagh])
            } else {
                lastCommentBackgroundView.isHidden = true
            }
        }
        return true
    }
    
    private func initContentViews() {
        contentView.backgroundColor = UIColor.white
        commentLabel.numberOfLines = 0
        lastCommentLabel.numberOfLines = 0
        contentView.addSubview(avatarView)
        avatarView.snp.makeConstraints { (make) in
            make.left.equalTo(16.0)
            make.top.equalTo(16.0)
            make.width.height.equalTo(40.0)
        }
        contentView.addSubview(nameLabel)
        nameLabel.snp.makeConstraints { (make) in
            make.top.equalTo(22.0)
            make.height.equalTo(14.0)
            make.left.equalTo(avatarView.snp.right).offset(8.0)
        }
        contentView.addSubview(timeLabel)
        timeLabel.snp.makeConstraints { (make) in
            make.top.equalTo(nameLabel.snp.bottom).offset(6.0)
            make.height.equalTo(12.0)
            make.left.equalTo(nameLabel)
        }
        contentView.addSubview(lastCommentBackgroundView)
        lastCommentBackgroundView.snp.makeConstraints { (make) in
            make.top.equalTo(timeLabel.snp.bottom).offset(9.0)
            make.left.equalTo(nameLabel)
            make.right.equalTo(-16.0)
        }
        contentView.addSubview(commentLabel)
        commentLabel.snp.makeConstraints { (make) in
            make.left.equalTo(nameLabel)
            make.right.equalTo(-16.0)
            make.bottom.equalTo(-20.0)
        }
        contentView.addSubview(separatorView)
        separatorView.snp.makeConstraints { (make) in
            make.left.equalTo(nameLabel)
            make.bottom.equalToSuperview()
            make.right.equalToSuperview()
            make.height.equalTo(XDSize.unitWidth)
        }
    }
}
