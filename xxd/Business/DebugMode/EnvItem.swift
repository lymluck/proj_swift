//
//  EnvItem.swift
//  xxd
//
//  Created by remy on 2017/12/21.
//  Copyright © 2017年 com.smartstudy. All rights reserved.
//

import SnapKit

class EnvItem: SSCellItem {
    
    var envType: EnvType!
    var title: String!
    var apiHost: String?
    var webHost: String?
    var isCurrentEnv: Bool!
    
    override init!(attributes: [AnyHashable : Any]! = [:]) {
        super.init(attributes: attributes)
        envType = EnvType(rawValue: attributes[XDEnvTypeKey] as! String)!
        title = XDEnvConfig.envNameWithType(envType)
        apiHost = attributes[XDEnvAPIHostKey] as? String ?? ""
        webHost = attributes[XDEnvWebHostKey] as? String ?? ""
        isCurrentEnv = XDEnvConfig.appEnv == envType
    }
    
    override init!(cellClass: AnyClass!, userInfo: Any!) {
        super.init(cellClass: cellClass, userInfo: userInfo)
    }
    
    override func cellClass() -> AnyClass! {
        return EnvItemCell.self
    }
}

class EnvItemCell: SSTableViewCell {
    
    private var titleLabel: UILabel!
    private var apiHostLabel: UILabel!
    private var webHostLabel: UILabel!
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        titleLabel = UILabel(frame: .null, text: "", textColor: .black, fontSize: 16, bold: true)
        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (make) in
            make.top.left.equalTo(contentView).offset(10)
        }
        apiHostLabel = UILabel(text: "", textColor: .black, fontSize: 13)
        contentView.addSubview(apiHostLabel)
        apiHostLabel.snp.makeConstraints { (make) in
            make.left.equalTo(contentView).offset(16)
            make.top.equalTo(titleLabel.snp.bottom).offset(5)
        }
        webHostLabel = UILabel(text: "", textColor: .black, fontSize: 13)
        contentView.addSubview(webHostLabel)
        webHostLabel.snp.makeConstraints { (make) in
            make.left.equalTo(contentView).offset(16)
            make.top.equalTo(apiHostLabel.snp.bottom).offset(5)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func shouldUpdate(with object: Any!) -> Bool {
        if super.shouldUpdate(with: object), let object = object as? EnvItem {
            titleLabel.text = object.title
            apiHostLabel.text = "APIHost:\(object.apiHost ?? "")"
            webHostLabel.text = "WEBHost:\(object.webHost ?? "")"
            contentView.backgroundColor = object.isCurrentEnv ? XDColor.itemLine : .white
        }
        return true
    }
}
