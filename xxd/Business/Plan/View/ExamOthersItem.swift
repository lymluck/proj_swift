//
//  ExamOthersItem.swift
//  xxd
//
//  Created by remy on 2018/5/29.
//  Copyright © 2018年 com.smartstudy. All rights reserved.
//

class ExamOthersItem: SSCellItem {
    
    var model: ExamineeModel!
    
    convenience init(model: ExamineeModel) {
        self.init()
        self.model = model
    }
    
    override func cellClass() -> AnyClass! {
        return ExamOthersItemCell.self
    }
}

class ExamOthersItemCell: SSTableViewCell {
    
    private var avatar: UIImageView!
    private var name: UILabel!
    private var checkinLabel: UILabel!
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.backgroundColor = UIColor.white
        
        // 头像
        avatar = UIImageView(frame: CGRect(x: 16, y: 16, width: 40, height: 40))
        avatar.layer.cornerRadius = 20
        avatar.layer.masksToBounds = true
        contentView.addSubview(avatar)
        
        // 坚持备考时间
        checkinLabel = UILabel(frame: .zero, text: "", textColor: UIColor(0xC4C9CC), fontSize: 14)
        contentView.addSubview(checkinLabel)
        checkinLabel.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().offset(-16)
        }
        
        // 昵称
        name = UILabel(frame: .zero, text: "", textColor: XDColor.itemTitle, fontSize: 15, bold: true)
        contentView.addSubview(name)
        name.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().offset(66)
            make.right.lessThanOrEqualTo(checkinLabel.snp.left).offset(-8)
        }
        
        // 分割线
        let bottomLine = UIView(frame: CGRect(x: 16, y: contentView.height - XDSize.unitWidth, width: contentView.width, height: XDSize.unitWidth), color: XDColor.mainBackground)
        bottomLine.autoresizingMask = [.flexibleWidth, .flexibleTopMargin]
        contentView.addSubview(bottomLine)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override class func height(for object: Any!, at indexPath: IndexPath!, tableView: UITableView!) -> CGFloat {
        return 72
    }
    
    override func shouldUpdate(with object: Any!) -> Bool {
        if super.shouldUpdate(with: object), let object = object as? ExamOthersItem {
            avatar.setAutoOSSImage(urlStr: object.model.avatar)
            name.text = object.model.name
            let attr = NSAttributedString(string: "\(object.model.checkinCount)", attributes: [NSAttributedStringKey.foregroundColor: XDColor.main, NSAttributedStringKey.font: UIFont.boldNumericalFontOfSize(16.0)])
            checkinLabel.attributedText = "已坚持备考 " + attr + " 天"
        }
        return true
    }
}
