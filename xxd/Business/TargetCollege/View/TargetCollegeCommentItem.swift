//
//  TargetCollegeCommentItem.swift
//  xxd
//
//  Created by Lisen on 2018/6/5.
//  Copyright © 2018年 com.smartstudy. All rights reserved.
//

import UIKit

class TargetCollegeCommentItem: SSCellItem {
    var model: TargetCollegeCommentUserModel!
    var isLast: Bool = false
    
    override init!(attributes: [AnyHashable : Any]! = [:]) {
        super.init(attributes: attributes)
        model = TargetCollegeCommentUserModel.yy_model(with: attributes)
    }
    
    override init!(cellClass: AnyClass!, userInfo: Any!) {
        super.init(cellClass: cellClass, userInfo: userInfo)
    }
    
    override func cellClass() -> AnyClass! {
        return TargetCollegeCommentItemCell.self
    }
    
}


class TargetCollegeCommentItemCell: SSTableViewCell {
    
    private lazy var userAvatar: UIImageView = {
        let imageView: UIImageView = UIImageView(frame: CGRect.zero)
        imageView.layer.cornerRadius = 20.0
        imageView.layer.masksToBounds = true
        return imageView
    }()
    private lazy var userNameLabel: UILabel = UILabel(frame: CGRect.zero, text: "", textColor: UIColor(0x263540), fontSize: 16.0)
    private lazy var timeLabel: UILabel = UILabel(frame: CGRect.zero, text: "", textColor: XDColor.itemText, fontSize: 12.0)
    private lazy var contentLabel: UILabel = UILabel(frame: CGRect.zero, text: "", textColor: UIColor(0x58646E), fontSize: 14.0)
    private lazy var bottomLine: UIView = UIView(frame: CGRect.zero, color: XDColor.itemLine)
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        initContentViews()
    }
    
    override static func height(for object: Any!, at indexPath: IndexPath!, tableView: UITableView!) -> CGFloat {
        if let object = object as? TargetCollegeCommentItem {
            var commentText = object.model.commentText
            if object.model.replyUserId != 0 {
                commentText = "回复 @"+object.model.replyUserName + ": " + object.model.commentText
            }
            let commentHeight = commentText.heightForFont(UIFont.systemFont(ofSize: 14.0), XDSize.screenWidth-80.0)
            return commentHeight + 80.0
        }
        return 90.0
    }
    
    override func shouldUpdate(with object: Any!) -> Bool {
        if super.shouldUpdate(with: object), let object = object as? TargetCollegeCommentItem {
            userAvatar.kf.setImage(with: URL(string: object.model.commenterAvatar), placeholder: UIImage(named: "default_avatar"))
            userNameLabel.text = object.model.commenterName
            timeLabel.text = object.model.commentTime
            if !object.model.replyUserName.isEmpty {
                contentLabel.attributedText = NSAttributedString(string: "回复 @"+object.model.replyUserName, attributes: [NSAttributedStringKey.foregroundColor: UIColor(0x078CF1), NSAttributedStringKey.font: UIFont.systemFont(ofSize: 14.0)]) + ": " + object.model.commentText
            } else {
                contentLabel.text = object.model.commentText
            }
            bottomLine.isHidden = object.isLast
        }
        return true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func initContentViews() {
        backgroundColor = UIColor.white
        contentLabel.numberOfLines = 0
        contentView.addSubview(userAvatar)
        userAvatar.snp.makeConstraints { (make) in
            make.left.equalTo(16.0)
            make.top.equalTo(16.0)
            make.width.height.equalTo(40.0)
        }
        contentView.addSubview(userNameLabel)
        userNameLabel.snp.makeConstraints { (make) in
            make.top.equalTo(18.0)
            make.left.equalTo(userAvatar.snp.right).offset(8.0)
            make.right.equalTo(-16.0)
        }
        contentView.addSubview(timeLabel)
        timeLabel.snp.makeConstraints { (make) in
            make.top.equalTo(userNameLabel.snp.bottom).offset(8.0)
            make.left.equalTo(userNameLabel)
        }
        contentView.addSubview(contentLabel)
        contentLabel.snp.makeConstraints { (make) in
            make.top.equalTo(timeLabel.snp.bottom).offset(11.0)
            make.left.equalTo(userNameLabel)
            make.right.equalTo(-16.0)
        }
        contentView.addSubview(bottomLine)
        bottomLine.snp.makeConstraints { (make) in
            make.left.equalTo(userNameLabel)
            make.right.equalTo(-16.0)
            make.bottom.equalToSuperview()
            make.height.equalTo(XDSize.unitWidth)
        }
    }
}
