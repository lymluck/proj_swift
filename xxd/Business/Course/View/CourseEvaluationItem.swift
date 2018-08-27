//
//  CourseEvaluationItem.swift
//  xxd
//
//  Created by remy on 2018/1/25.
//  Copyright © 2018年 com.smartstudy. All rights reserved.
//

class CourseEvaluationItem: SSCellItem {
    
    private(set) var dateString = ""
    var isHiddenBottomLine = false
    var model: CourseEvaluationModel!
    
    override init!(attributes: [AnyHashable : Any]! = [:]) {
        super.init(attributes: attributes)
        model = CourseEvaluationModel.yy_model(with: attributes)
        dateString = model.date.string(withFormat: "yyyy-MM-dd")!
    }
    
    override init!(cellClass: AnyClass!, userInfo: Any!) {
        super.init(cellClass: cellClass, userInfo: userInfo)
    }
    
    override func cellClass() -> AnyClass! {
        return CourseEvaluationItemCell.self
    }
}

class CourseEvaluationItemCell: SSTableViewCell {

    private var nicknameLabel: UILabel!
    private var dateLabel: UILabel!
    private var detailLabel: UILabel!
    private var bottomLine: UIView!
    private var portraitView: UIImageView!
    private var starLine: EvaluationStarLine!
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.backgroundColor = UIColor.white
        
        // 头像
        portraitView = UIImageView(frame: CGRect(x: 16, y: 16, width: 40, height: 40))
        contentView.addSubview(portraitView)
        
        // 名字
        nicknameLabel = UILabel(text: "", textColor: XDColor.itemTitle, fontSize: 16)
        contentView.addSubview(nicknameLabel)
        nicknameLabel.snp.makeConstraints { (make) in
            make.top.equalTo(contentView).offset(16)
            make.left.equalTo(portraitView.snp.right).offset(8)
            make.width.lessThanOrEqualTo(XDSize.screenWidth - 170)
        }
        
        // 日期
        dateLabel = UILabel(text: "", textColor: XDColor.itemText, fontSize: 12)
        contentView.addSubview(dateLabel)
        dateLabel.snp.makeConstraints { (make) in
            make.left.equalTo(portraitView.snp.right).offset(8)
            make.bottom.equalTo(portraitView)
        }
        
        // 内容
        detailLabel = UILabel(text: "", textColor: UIColor(0x58646E), fontSize: 14)
        detailLabel.numberOfLines = 0
        contentView.addSubview(detailLabel)
        detailLabel.snp.makeConstraints { (make) in
            make.left.equalTo(portraitView.snp.right).offset(8)
            make.edges.equalTo(contentView).inset(UIEdgeInsetsMake(67, 64, 15, 16))
        }
        
        // 星级
        starLine = EvaluationStarLine()
        contentView.addSubview(starLine)
        starLine.snp.makeConstraints { (make) in
            make.top.equalTo(contentView).offset(16)
            make.right.equalTo(contentView).offset(-16)
        }
        
        // 分割线
        bottomLine = UIView(frame: CGRect(x: 0, y: contentView.height - XDSize.unitWidth, width: contentView.width, height: XDSize.unitWidth), color: XDColor.itemLine)
        bottomLine.autoresizingMask = [.flexibleWidth, .flexibleTopMargin]
        contentView.addSubview(bottomLine)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func shouldUpdate(with object: Any!) -> Bool {
        if super.shouldUpdate(with: object), let object = object as? CourseEvaluationItem {
            portraitView.setCircleOSSImage(urlStr: object.model.portraitURL, placeholderImage: UIImage(named: "default_avatar")!)
            nicknameLabel.text = object.model.nickname
            detailLabel.setText(object.model.comment, lineHeight: 19)
            starLine.starCount = object.model.evaluation
            dateLabel.text = object.dateString
            bottomLine.isHidden = object.isHiddenBottomLine
        }
        return true
    }
}
