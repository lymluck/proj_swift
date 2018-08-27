//
//  ToTranspondUserCellItem.swift
//  counselor_t
//
//  Created by chenyusen on 2018/2/9.
//  Copyright © 2018年 TechSen. All rights reserved.
//

import UIKit

class ToTranspondUserCellItem: TableCellItem {

    override var cellClass: UITableViewCell.Type? {
        return ToTranspondUserCell.self
    }
    var avatar: String?
    var nickname: String?
    
    override var model: Any? {
        didSet {
            if let conversation = model as? Conversation {
                TeacherInfoHelper.shared.teacherInfo(conversation.targetId) { [weak self] (studentInfo) in
                    if let studentInfo = studentInfo {
                        self?.avatar = studentInfo.avatar
                        self?.nickname = studentInfo.name
                        self?.update()
                    }
                }
            }
        }
    }
    
    override var cellHeight: CGFloat {
        return 60
    }
    
    func update() {
        (currentCell as? TableCell)?.updateCell(self)
    }
}

class ToTranspondUserCell: TableCell {
    var avatarView: UIImageView! // 用户头像
    var nicknameLabel: UILabel! // 用户昵称
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        avatarView = UIImageView()
        contentView.addSubview(avatarView)
        avatarView.snp.makeConstraints { (make) in
            make.left.equalTo(16)
            make.centerY.equalToSuperview()
            make.size.equalTo(CGSize(width: 40, height: 40))
        }
        
        nicknameLabel = UILabel(frame: CGRect.zero, text: nil, textColor: UIColor(0x26343F), fontSize: 17)!
        contentView.addSubview(nicknameLabel)
        nicknameLabel.snp.makeConstraints { (make) in
            make.left.equalTo(72)
            make.centerY.equalToSuperview()
            make.right.lessThanOrEqualTo(contentView.snp.right).offset(-16)
        }
        
        let bottomLine = UIView()
        bottomLine.backgroundColor = UIColor(0xE4E5E6)
        contentView.addSubview(bottomLine)
        bottomLine.snp.makeConstraints { (make) in
            make.left.equalTo(16)
            make.bottom.right.equalToSuperview()
            make.height.equalTo(XDSize.unitWidth)
        }
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func updateCell(_ cellItem: TableCellItemProtocol?) {
        super.updateCell(cellItem)
        if let cellItem = cellItem as? ToTranspondUserCellItem {
            nicknameLabel.text = cellItem.nickname
            avatarView.kf.setImage(with: cellItem.avatar?.url)
        }
    }
}
