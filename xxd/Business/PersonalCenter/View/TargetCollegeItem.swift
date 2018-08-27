//
//  TargetCollegeItem.swift
//  xxd
//
//  Created by remy on 2018/2/2.
//  Copyright © 2018年 com.smartstudy. All rights reserved.
//

protocol TargetCollegeItemDelegate: class {
    
    func targetCollegeItem(item: TargetCollegeItem, typeView: UIImageView)
}

class TargetCollegeItem: SSCellItem {
    
    var model: TargetCollegeModel!
    var isSample: Bool = false
    weak var delegate: TargetCollegeItemDelegate?
    
    override init!(attributes: [AnyHashable : Any]! = [:]) {
        super.init(attributes: attributes)
        model = TargetCollegeModel.yy_model(with: attributes)
    }
    
    override init!(cellClass: AnyClass!, userInfo: Any!) {
        super.init(cellClass: cellClass, userInfo: userInfo)
    }
    
    override func cellClass() -> AnyClass! {
        return TargetCollegeItemCell.self
    }
}

class TargetCollegeItemCell: SSTableViewCell {
    
    private var stageView: UIView!
    private var rankLabel: UILabel!
    private var titleLabel: UILabel!
    private var selectNumLabel: UILabel!
    private var notice: UIImageView!
    private var typeView: UIImageView!
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.backgroundColor = UIColor.clear
        
        let rankWidth: CGFloat = 49
        
        // 背景
        stageView = UIView(frame: CGRect(x: 16, y: 0, width: XDSize.screenWidth - 32, height: 66), color: UIColor.white)
        stageView.layer.shadowOpacity = 0.06
        stageView.layer.shadowColor = UIColor.black.cgColor
        stageView.layer.shadowRadius = 4
        stageView.layer.shadowOffset = CGSize(width: 0, height: 2)
        contentView.addSubview(stageView)
        
        // 排名
        rankLabel = UILabel(frame: CGRect(x: 0, y: 18, width: rankWidth, height: 20), text: "", textColor: XDColor.itemTitle, fontSize: 17)
        rankLabel.textAlignment = .center
        stageView.addSubview(rankLabel)
        let label = UILabel(frame: CGRect(x: 0, y: rankLabel.bottom, width: rankWidth, height: 12), text: "#", textColor: XDColor.itemText, fontSize: 10)!
        label.textAlignment = .center
        stageView.addSubview(label)
        
        // 标题
        titleLabel = UILabel(frame: .null, text: "", textColor: XDColor.itemTitle, fontSize: 17, bold: true)
        stageView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(17.0)
            make.left.equalTo(stageView).offset(rankWidth)
            make.right.lessThanOrEqualTo(stageView).offset(-51)
        }
        
        // 选择该校的人数
        selectNumLabel = UILabel(frame: CGRect.zero, text: "", textColor: UIColor(0x949BA1), fontSize: 12.0)
        stageView.addSubview(selectNumLabel)
        selectNumLabel.snp.makeConstraints { (make) in
            make.left.equalTo(titleLabel)
            make.top.equalTo(titleLabel.snp.bottom).offset(2.0)
            make.right.lessThanOrEqualTo(stageView).offset(-51.0)
        }
        
        // 类型
        typeView = UIImageView()
        typeView.contentMode = .left
        typeView.isUserInteractionEnabled = true
        stageView.addSubview(typeView)
        typeView.snp.makeConstraints { (make) in
            make.size.equalTo(CGSize(width: 42, height: stageView.height))
            make.right.equalTo(stageView)
        }
        let more = UIImageView(frame: .zero, imageName: "more")!
        stageView.addSubview(more)
        more.snp.makeConstraints { (make) in
            make.size.equalTo(CGSize(width: 3, height: 17))
            make.centerY.equalTo(stageView)
            make.right.equalTo(stageView).offset(-9)
        }
        typeView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(moreTap(gestureRecognizer:))))
        
        // 提醒
        notice = UIImageView(frame: .zero, imageName: "target_notice")!
        stageView.addSubview(notice)
        notice.snp.makeConstraints { (make) in
            make.size.equalTo(CGSize(width: 20, height: 20))
            make.centerY.equalTo(stageView)
            make.right.equalTo(typeView.snp.left).offset(-9)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override static func height(for object: Any!, at indexPath: IndexPath!, tableView: UITableView!) -> CGFloat {
        return 80
    }
    
    override func shouldUpdate(with object: Any!) -> Bool {
        if super.shouldUpdate(with: object), let object = object as? TargetCollegeItem {
            rankLabel.text = object.model.worldRank.isEmpty ? "N/A" : object.model.worldRank
            selectNumLabel.isHidden = object.isSample
            if object.isSample {
                titleLabel.attributedText = NSAttributedString(string: "哈佛大学", attributes: [NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 17.0)]) + NSAttributedString(string: "(Sample)", attributes: [NSAttributedStringKey.foregroundColor: UIColor(0xFE5225)])
                titleLabel.snp.updateConstraints { (make) in
                    make.top.equalTo(24.0)
                }
            } else {
                titleLabel.text = object.model.chineseName
                titleLabel.snp.updateConstraints { (make) in
                    make.top.equalTo(17.0)
                }
            }
            selectNumLabel.text = "已有\(object.model.selectedCount)人选择"
            if object.model.targetCollegeType == .bottom {
                typeView.image = UIImage(named: "target_bottom")
            } else if object.model.targetCollegeType == .middle {
                typeView.image = UIImage(named: "target_middle")
            } else {
                typeView.image = UIImage(named: "target_top")
            }
            if object.model.isMyTargetCountry {
                notice.isHidden = true
                titleLabel.snp.updateConstraints({ (make) in
                    make.right.lessThanOrEqualTo(stageView).offset(-51)
                })
            } else {
                notice.isHidden = false
                titleLabel.snp.updateConstraints({ (make) in
                    make.right.lessThanOrEqualTo(stageView).offset(-80)
                })
            }
        }
        return true
    }
    
    //MARK:- Action
    @objc func moreTap(gestureRecognizer: UIGestureRecognizer) {
        let item = self.item as! TargetCollegeItem
        item.delegate?.targetCollegeItem(item: item, typeView: typeView)
    }
}
