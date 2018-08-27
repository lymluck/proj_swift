//
//  ColumnItem.swift
//  xxd
//
//  Created by Lisen on 2018/7/16.
//  Copyright © 2018年 com.smartstudy. All rights reserved.
//

import UIKit

class ColumnItem: SSCellItem {
    var model: ColumnListModel!
    
    override init!(attributes: [AnyHashable : Any]! = [:]) {
        super.init(attributes: attributes)
        model = ColumnListModel.yy_model(with: attributes)
    }
    
    override init!(cellClass: AnyClass!, userInfo: Any!) {
        super.init(cellClass: cellClass, userInfo: userInfo)
    }
    
    override func cellClass() -> AnyClass! {
        return ColumnItemCell.self
    }
}

class ColumnItemCell: SSTableViewCell {
    
    private lazy var itemView: ColumnItemView = ColumnItemView(frame: CGRect(x: 0.0, y: 0.0, width: XDSize.screenWidth, height: 130.0), topSpace: 20.0, bottomSpace: 12.0)
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(itemView)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) { }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) { }
    
    override static func height(for object: Any!, at indexPath: IndexPath!, tableView: UITableView!) -> CGFloat {
        return 130.0
    }
    
    override func shouldUpdate(with object: Any!) -> Bool {
        if super.shouldUpdate(with: object), let item = object as? ColumnItem {
            itemView.viewData = item.model
        }
        return true
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
}

/// 专栏列表视图, 为了方便不同界面的复用,将该视图拆分出来
class ColumnItemView: UIView {
    var viewData: ColumnListModel? {
        didSet {
            if let model = viewData {
                titleLabel.text = model.columnTitle
                userNameLabel.text = model.authorName
                watchNumBtn.setTitle("\(model.visitCount)", for: .normal)
                likeNumBtn.setTitle("\(model.likesCount)", for: .normal)
                userAvatar.kf.setImage(with: URL(string: model.authorAvatar), placeholder: UIImage(named: "default_avatar"))
                coverImageView.kf.setImage(with: URL(string: model.coverUrl), placeholder: UIImage(named: "default_placeholder"))
            }
        }
    }
    private var topSpace: CGFloat = 0.0
    private var bottomSpace: CGFloat = 0.0
    private var leftEdge: CGFloat = 0.0
    private lazy var titleLabel: UILabel = {
        let label: UILabel = UILabel(frame: CGRect.zero, text: "", textColor: XDColor.itemTitle, fontSize: 16.0, bold: true)
        label.numberOfLines = 2
        return label
    }()
    private lazy var userAvatar: UIImageView = {
        let imageView: UIImageView = UIImageView(frame: CGRect.zero)
        imageView.layer.cornerRadius = 9.0
        imageView.layer.masksToBounds = true
        return imageView
    }()
    private lazy var coverImageView: UIImageView = UIImageView(frame: CGRect.zero)
    private lazy var userNameLabel: UILabel = UILabel(frame: CGRect.zero, text: "", textColor: XDColor.itemText, fontSize: 11.0)
    private lazy var watchNumBtn: UIButton = {
        let button: UIButton = UIButton(frame: CGRect.zero)
        button.setImage(UIImage(named: "page_view"), for: .normal)
        button.setTitleColor(XDColor.itemText, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 11.0)
        button.titleEdgeInsets = UIEdgeInsets(top: 0.0, left: 4.0, bottom: 0.0, right: -4.0)
        return button
    }()
    private lazy var likeNumBtn: UIButton = {
        let button: UIButton = UIButton(frame: CGRect.zero)
        button.setImage(UIImage(named: "like_column_small"), for: .normal)
        button.setTitleColor(XDColor.itemText, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 11.0)
        button.titleEdgeInsets = UIEdgeInsets(top: 0.0, left: 4.0, bottom: 0.0, right: -4.0)
        return button
    }()
    private lazy var separatorView: UIView = UIView(frame: CGRect.zero, color: XDColor.itemLine)
    
    convenience init(frame: CGRect, topSpace: CGFloat = 20.0, bottomSpace: CGFloat = 12.0, leftEdge: CGFloat = 0.0) {
        self.init(frame: frame)
        self.topSpace = topSpace
        self.bottomSpace = bottomSpace
        self.leftEdge = leftEdge
        initContentViews()
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        if let columnId = viewData?.columnId {
            let columnDetailVC: ColumnDetailViewController = ColumnDetailViewController()
            columnDetailVC.columnId = columnId
            XDRoute.pushToVC(columnDetailVC)
        }
    }
    
    private func initContentViews() {
        backgroundColor = UIColor.white
        addSubview(coverImageView)
        coverImageView.snp.makeConstraints { (make) in
            make.top.equalTo(topSpace)
            make.right.equalTo(-16.0)
            make.width.equalTo(120.0)
            make.height.equalTo(68.0)
        }
        addSubview(likeNumBtn)
        likeNumBtn.snp.makeConstraints { (make) in
            make.top.equalTo(coverImageView.snp.bottom).offset(15.0)
            make.width.lessThanOrEqualTo(60.0)
            make.right.equalTo(-18.0)
        }
        addSubview(watchNumBtn)
        watchNumBtn.snp.makeConstraints { (make) in
            make.top.equalTo(likeNumBtn)
            make.width.lessThanOrEqualTo(60.0)
            make.right.equalTo(likeNumBtn.snp.left).offset(-14.0)
        }
        addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (make) in
            make.top.equalTo(topSpace)
            make.left.equalTo(16.0)
            make.right.equalTo(coverImageView.snp.left).offset(-24.0)
        }
        addSubview(userAvatar)
        userAvatar.snp.makeConstraints { (make) in
            make.left.equalTo(16.0)
            make.bottom.equalTo(-bottomSpace)
            make.width.height.equalTo(18.0)
        }
        addSubview(userNameLabel)
        userNameLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(userAvatar)
            make.left.equalTo(userAvatar.snp.right).offset(6.0)
            make.right.lessThanOrEqualTo(titleLabel.snp.right)
        }
        addSubview(separatorView)
        separatorView.snp.makeConstraints { (make) in
            make.left.equalTo(leftEdge)
            make.right.equalTo(-leftEdge)
            make.bottom.equalToSuperview()
            make.height.equalTo(XDSize.unitWidth)
        }
    }
    
}
