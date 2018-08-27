//
//  QADetailRequestInfoView.swift
//  xxd
//
//  Created by Lisen on 2018/8/1.
//  Copyright © 2018 com.smartstudy. All rights reserved.
//

import UIKit

/// 问答详情中索要/发送 学生信息消息视图
class QADetailRequestInfoView: UIView {
    
    var replyText: String? {
        didSet {
            infoReplyLabel.text = replyText
        }
    }
    var checkText: String? {
        didSet {
            infoCheckLabel.text = checkText
        }
    }
    private lazy var infoReplyLabel: UILabel = UILabel(frame: CGRect.zero, text: "", textColor: XDColor.itemTitle, fontSize: 15.0)
    private(set) lazy var infoCheckLabel: UILabel = UILabel(frame: CGRect.zero, text: "点击完善信息", textColor: XDColor.main, fontSize: 14.0)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initContentViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }    
    
    private func initContentViews() {
        layer.cornerRadius = 4.0
        infoReplyLabel.numberOfLines = 0
        infoCheckLabel.isUserInteractionEnabled = true
        addSubview(infoReplyLabel)
        infoReplyLabel.snp.makeConstraints { (make) in
            make.top.equalTo(8.0)
            make.left.equalTo(12.0)
            make.right.equalTo(-12.0)
        }
        addSubview(infoCheckLabel)
        infoCheckLabel.snp.makeConstraints { (make) in
            make.left.right.equalTo(infoReplyLabel)
            make.height.equalTo(20.0)
            make.bottom.equalToSuperview().offset(-8.0)
        }
    }
}
