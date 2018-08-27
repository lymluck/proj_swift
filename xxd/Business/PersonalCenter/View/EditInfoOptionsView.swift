//
//  EditInfoOptionsView.swift
//  xxd
//
//  Created by remy on 2018/1/8.
//  Copyright © 2018年 com.smartstudy. All rights reserved.
//

class EditInfoOptionsView: UITableViewCell {
    
    var topLine: UIView!
    var middleLine: UIView!
    var bottomLine: UIView!
    private var titleLabel: UILabel!
    private var hintLabel: UILabel!
    private var selectedView: UIImageView!
    private var isMulti: Bool = false
    // 分别设置单选框和多选框的视图
    var isSingleOption: Bool = true {
        didSet {
            if isSingleOption {
                isMulti = false
                selectedView.image = UIImage(named: "selected")
                selectedView.snp.updateConstraints { (make) in
                    make.size.equalTo(CGSize(width: 16.0, height: 12.0))
                }
            } else {
                isMulti = true
                selectedView.image = UIImage(named: "add")
                selectedView.isHidden = false
                selectedView.snp.updateConstraints { (make) in
                    make.size.equalTo(CGSize(width: 22.0, height: 22.0))
                }
            }
        }
    }
    var isOptionSelected = false {
        didSet {
            if isMulti {
                if isOptionSelected {
                    selectedView.image = UIImage(named: "add_selected")
                } else {
                    selectedView.image = UIImage(named: "add")
                }
            } else {
                selectedView.isHidden = !isOptionSelected
            }
        }
    }
    var model: EditInfoModel! {
        didSet {
            if model.hint.isEmpty {
                hintLabel.isHidden = true
            } else {
                hintLabel.isHidden = false
                hintLabel.text = model.hint
            }
            titleLabel.text = model.name
        }
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = UIColor.white
        
        // 标题
        titleLabel = UILabel(text: "", textColor: XDColor.itemTitle, fontSize: 16)
        titleLabel.numberOfLines = 0
        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(contentView)
            make.left.equalTo(contentView).offset(16)
            make.right.lessThanOrEqualToSuperview().offset(-48)
        }
        
        // 副标题
        hintLabel = UILabel(text: "", textColor: XDColor.itemText, fontSize: 14)
        hintLabel.isHidden = true
        contentView.addSubview(hintLabel)
        hintLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(contentView)
            make.left.equalTo(titleLabel.snp.right).offset(8)
        }
        
        // 选择状态
        selectedView = UIImageView(frame: .zero)
        contentView.addSubview(selectedView)
        selectedView.snp.makeConstraints { (make) in
            make.centerY.equalTo(contentView)
            make.right.equalTo(contentView).offset(-16)
            make.size.equalTo(CGSize(width: 0.0, height: 0.0))
        }
        
        // 分割线
        topLine = UIView(frame: CGRect(x: 0, y: 0, width: XDSize.screenWidth, height: XDSize.unitWidth), color: XDColor.itemLine)
        contentView.addSubview(topLine)
        
        middleLine = UIView(frame: .zero, color: XDColor.itemLine)
        contentView.addSubview(middleLine)
        middleLine.snp.makeConstraints { (make) in
            make.left.equalTo(contentView).offset(16)
            make.bottom.equalTo(contentView).offset(-XDSize.unitWidth)
            make.size.equalTo(CGSize(width: XDSize.screenWidth - 16, height: XDSize.unitWidth))
        }
        
        bottomLine = UIView(frame: .zero, color: XDColor.itemLine)
        contentView.addSubview(bottomLine)
        bottomLine.snp.makeConstraints { (make) in
            make.bottom.equalTo(contentView).offset(-XDSize.unitWidth)
            make.size.equalTo(CGSize(width: XDSize.screenWidth, height: XDSize.unitWidth))
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class EditInfoSectionHeader: UITableViewHeaderFooterView {
    
    private var titleLabel: UILabel!
    var model: EditInfoModel! {
        didSet {
            titleLabel.text = model.groupName
        }
    }
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        contentView.backgroundColor = XDColor.mainBackground
        
        // 标题
        titleLabel = UILabel(frame: .zero, text: "", textColor: XDColor.itemTitle, fontSize: 15, bold: true)
        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (make) in
            make.top.left.equalTo(contentView).offset(16)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
