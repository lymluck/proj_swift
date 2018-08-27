//
//  CourseSearchItem.swift
//  xxd
//
//  Created by remy on 2018/1/23.
//  Copyright © 2018年 com.smartstudy. All rights reserved.
//

class CourseSearchItem: SSCellItem {
    
    var model: CourseModel!
    
    override init!(attributes: [AnyHashable : Any]! = [:]) {
        super.init(attributes: attributes)
        model = CourseModel.yy_model(with: attributes)
    }
    
    override init!(cellClass: AnyClass!, userInfo: Any!) {
        super.init(cellClass: cellClass, userInfo: userInfo)
    }
    
    override func cellClass() -> AnyClass! {
        return CourseSearchItemCell.self
    }
}

class CourseSearchItemCell: SSTableViewCell {
    
    private var titleLabel: UILabel!
    private var visitCountLabel: UILabel!
    private var rateLabel: UILabel!
    private var coverView: UIImageView!
    private var bottomLine: UIView!
    private var starViews = [UIImageView]()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.backgroundColor = UIColor.white
        
        // 封面
        coverView = UIImageView()
        coverView.contentMode = .scaleAspectFill
        contentView.addSubview(coverView)
        coverView.snp.makeConstraints { (make) in
            make.left.equalTo(contentView).offset(16)
            make.centerY.equalTo(contentView)
            make.size.equalTo(CGSize(width: 100, height: 56))
        }
        
        // 标题
        titleLabel = UILabel(text: "", textColor: XDColor.itemTitle, fontSize: 15)
        titleLabel.numberOfLines = 2
        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (make) in
            make.top.equalTo(contentView).offset(12)
            make.left.equalTo(coverView.snp.right).offset(12)
            make.right.lessThanOrEqualToSuperview().offset(-16)
        }
        
        // 星级
        var lastView: UIView!
        for _ in 0..<5 {
            let starView = UIImageView(image: UIImage(named: "course_evaluation_small_star_normal"))
            starView.contentMode = .scaleAspectFit
            starViews.append(starView)
            contentView.addSubview(starView)
            starView.snp.makeConstraints { (make) in
                if lastView != nil {
                    make.left.equalTo(lastView.snp.right).offset(2)
                } else {
                    make.left.equalTo(coverView.snp.right).offset(12)
                }
                make.bottom.equalTo(coverView)
                make.size.equalTo(CGSize(width: 12, height: 11))
            }
            lastView = starView
        }
        
        // 评分
        rateLabel = UILabel(frame: .null, text: "", textColor: XDColor.itemText, fontSize: 11)
        contentView.addSubview(rateLabel)
        rateLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(lastView)
            make.left.equalTo(lastView.snp.right).offset(4)
        }
        
        // 访问人数
        visitCountLabel = UILabel(text: "", textColor: XDColor.itemText, fontSize: 11)
        contentView.addSubview(visitCountLabel)
        visitCountLabel.snp.makeConstraints { (make) in
            make.right.equalTo(contentView).offset(-16)
            make.centerY.equalTo(lastView)
        }

        // 分割线
        bottomLine = UIView(frame: CGRect(x: 16, y: 80 - XDSize.unitWidth, width: XDSize.screenWidth - 32, height: XDSize.unitWidth), color: XDColor.itemLine)
        contentView.addSubview(bottomLine)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override static func height(for object: Any!, at indexPath: IndexPath!, tableView: UITableView!) -> CGFloat {
        return 80
    }
    
    override func shouldUpdate(with object: Any!) -> Bool {
        if super.shouldUpdate(with: object), let object = object as? CourseSearchItem {
            bottomLine.isHidden = object.bottomLineType == .none
            titleLabel.text = object.model.name
            visitCountLabel.text = String(format: "abroad_stage_visit_count".localized, object.model.visitCount)
            let size = CGSize(width: 100, height: 56)
            coverView.setOSSImage(urlStr: object.model.coverURL, size: size, policy: .fill, placeholderImage: UIImage.getPlaceHolderImage(size: size))
            rateLabel.text = object.model.rate
            let rate = Double(object.model.rate)!
            for (index, view) in starViews.enumerated() {
                let score = Double(index + 1)
                if score <= rate {
                    view.image = UIImage(named: "course_evaluation_small_star_selected")
                } else {
                    if score == rate.rounded(.up) {
                        view.image = UIImage(named: "course_evaluation_small_star_half")
                    } else {
                        view.image = UIImage(named: "course_evaluation_small_star_normal")
                    }
                }
            }
        }
        return true
    }
}
