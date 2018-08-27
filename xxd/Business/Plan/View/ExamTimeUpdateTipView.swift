//
//  ExamTimeUpdateTipView.swift
//  xxd
//
//  Created by Lisen on 2018/5/25.
//  Copyright © 2018年 com.smartstudy. All rights reserved.
//

import UIKit

/// 出国考试时间查询界面顶部考试时间更新提示视图
class ExamTimeUpdateTipView: UIView {
    var updateTime: String = "" {
        didSet {
            tipLabel.text = "本次考试时间更新于" + updateTime
        }
    }
    private lazy var warningImageView: UIImageView = {
        let imageView: UIImageView = UIImageView(frame: CGRect.zero, imageName: "info")
        return imageView
    }()
    private lazy var tipLabel: UILabel = UILabel(frame: CGRect.zero, text: "", textColor: UIColor(0xE1944D), fontSize: 13.0)
    private lazy var closeButton: UIButton = {
        let button: UIButton = UIButton(frame: CGRect.zero)
        button.setImage(UIImage(named: "update_warning_close"), for: .normal)
        button.addTarget(self, action: #selector(eventCloseButtonResponse(_:)), for: .touchUpInside)
        return button
    }()
    override init(frame: CGRect) {
        super.init(frame: frame)
        initContentViews()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    @objc private func eventCloseButtonResponse(_ sender: UIButton) {
        if var savedDic = UserDefaults.standard.value(forKey: "updateTimeDictionary") as? [String: Any] {
            savedDic["isClosed"] = true
            UserDefaults.standard.setValue(savedDic, forKey: "updateTimeDictionary")
        }
        routerEvent(name: "ExamTimeUpdateTipView", data: [: ])
    }

    private func initContentViews() {
        backgroundColor = UIColor(0xFFFDEA)
        addSubview(warningImageView)
        warningImageView.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(12.0)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(16.0)
        }
        addSubview(tipLabel)
        tipLabel.snp.makeConstraints { (make) in
            make.left.equalTo(warningImageView.snp.right).offset(6.0)
            make.centerY.equalToSuperview()
        }
        addSubview(closeButton)
        closeButton.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().offset(-12.0)
            make.width.height.equalTo(20.0)
        }
    }
}
