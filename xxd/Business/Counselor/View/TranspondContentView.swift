//
//  TranspondContentView.swift
//  counselor_t
//
//  Created by chenyusen on 2018/2/23.
//  Copyright © 2018年 TechSen. All rights reserved.
//

import UIKit

@objc protocol MainViewDelegate: NSObjectProtocol {
    @objc optional func detailButtonPressed()
    @objc optional func hasSendSuccess()
}

protocol TranspondContentViewDelegate: class {
    func hasSendSuccess()
}

class TranspondContentView: UIView {

    
    class MainView: UIView {
        weak var delegate: MainViewDelegate?
        var message: Message? {
            didSet {
                if let message = message, let id = targetId {
                    TeacherInfoHelper.shared.teacherInfo(id, completion: { [weak self] (info) in
                        guard let sSelf = self else { return }
                        sSelf.avatarView.kf.setImage(with: info?.avatar?.url)
                        sSelf.nicknameLabel.text = info?.name
                    })
                    let contentButton = UIButton()
                    centerView.addSubview(contentButton)
                    // 根据message的类型展示不同的内容
                    if let text = (message.content as? TextMessage)?.content {
                        contentButton.addTarget(self, action: #selector(detailButtonPressed), for: .touchUpInside)
                        contentButton.setBackgroundColor(UIColor(0xE4E4E4), for: .highlighted)
                        contentButton.setBackgroundColor(UIColor(0xF5F6F7), for: .normal)
                        let label = UILabel(frame: CGRect.zero, text: text, textColor: UIColor(0x949BA1), fontSize: 14, bold: false)!
//                        label.textAlignment = .left
                        label.numberOfLines = 2
                        contentButton.addSubview(label)
                        label.snp.makeConstraints({ (make) in
                            make.left.equalToSuperview()
                            make.right.equalTo(-20)
                            make.top.bottom.equalToSuperview()
                        })
                        
                        
                        let arrow = UIImageView(image: UIImage(named: "transpond_arrow"))
                        contentButton.addSubview(arrow)
                        arrow.snp.makeConstraints({ (make) in
                            make.centerY.equalTo(label)
                            make.right.equalToSuperview()
                        })
                        
                        contentButton.snp.makeConstraints({ (make) in
                            make.top.equalTo(13)
                            make.left.equalToSuperview().offset(20)
                            make.right.equalToSuperview().offset(-20)
                            make.bottom.equalTo(leaveMessageTextField.snp.top).offset(-13)
                        })
                        
                    } else if let image = (message.content as? ImageMessage)?.originalImage ?? (message.content as? ImageMessage)?.thumbnailImage {
                        // 最大宽度180
                        // 最大高度120
                        let maxWidth: CGFloat = 180
                        let maxHeight: CGFloat = 120
                        contentButton.setImage(image, for: .normal)
                        contentButton.adjustsImageWhenHighlighted = false
                        contentButton.snp.makeConstraints({ (make) in
                            make.centerX.equalToSuperview()
                            make.top.equalTo(16)
                            make.bottom.equalTo(leaveMessageTextField.snp.top).offset(-16)
                            var size = image.size
                            if image.size.width > maxWidth {
                                size = CGSize(width: maxWidth, height: image.size.height * maxWidth / image.size.width)
                            }
                            if size.height > maxHeight {
                                size = CGSize(width: image.size.width * maxHeight / image.size.height, height: maxHeight)
                            }
                            make.size.equalTo(size)
                        })
                        
                    }
                }
            }
        }
        var targetId: String?
        
        var avatarView: UIImageView!
        var nicknameLabel: UILabel!
        var centerView: UIView!
        var leaveMessageTextField: UITextField!
        
        
        class BottomBar: UIView {
            var sendButton: UIButton!
            override init(frame: CGRect) {
                super.init(frame: frame)
                
                // 顶部分割线
                let topLine = UIView()
                topLine.backgroundColor = UIColor(0xC4C9CC)
                addSubview(topLine)
                topLine.snp.makeConstraints { (make) in
                    make.top.right.left.equalToSuperview()
                    make.height.equalTo(XDSize.unitWidth)
                }
                
                let cancelButton = UIButton(frame: CGRect.zero, title: "取消", fontSize: 17, titleColor: UIColor(0x949BA1), target: self, action: #selector(cancelButtonPressed))!
                cancelButton.setBackgroundColor(UIColor(0xE4E4E4), for: .highlighted)
                addSubview(cancelButton)
                cancelButton.snp.makeConstraints { (make) in
                    make.left.top.bottom.equalToSuperview()
                    make.width.equalToSuperview().multipliedBy(0.5)
                }
                
                // 中间分割线
                let centerLine = UIView()
                centerLine.backgroundColor = UIColor(0xC4C9CC)
                addSubview(centerLine)
                centerLine.snp.makeConstraints { (make) in
                    make.centerX.equalToSuperview()
                    make.top.bottom.equalToSuperview()
                    make.width.equalTo(XDSize.unitWidth)
                }
                
                sendButton = UIButton(frame: CGRect.zero, title: "发送", fontSize: 17, titleColor: UIColor(0x078CF1), target: nil, action: nil)!
                sendButton.setBackgroundColor(UIColor(0xE4E4E4), for: .highlighted)
                addSubview(sendButton)
                sendButton.snp.makeConstraints { (make) in
                    make.right.top.bottom.equalToSuperview()
                    make.width.equalToSuperview().multipliedBy(0.5)
                }
            }
            
            required init?(coder aDecoder: NSCoder) {
                fatalError("init(coder:) has not been implemented")
            }
            
            
            @objc func cancelButtonPressed() {
                viewController?.dismiss(animated: false, completion: nil)
            }
        }
        
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            
            
            // 头部
            let headerView = UIView()
            addSubview(headerView)
            headerView.snp.makeConstraints { (make) in
                make.top.left.right.equalToSuperview()
                make.height.equalTo(104)
            }
            
            // 发送给
            
            let sendToLabel = UILabel(frame:CGRect.zero, text: "发送给:", textColor: UIColor(0x26343F), fontSize: 17, bold: true)!
            headerView.addSubview(sendToLabel)
            
            sendToLabel.snp.makeConstraints { (make) in
                make.top.equalTo(21)
                make.left.equalTo(20)
            }
            
            // 头像
            avatarView = UIImageView()
    
            avatarView.layer.cornerRadius = 20
            avatarView.clipsToBounds = true
            headerView.addSubview(avatarView)
            avatarView.snp.makeConstraints { (make) in
                make.size.equalTo(CGSize(width: 40, height: 40))
                make.left.equalTo(20)
                make.top.equalTo(50)
            }
            
            // 昵称
            
            nicknameLabel = UILabel(frame: CGRect.zero, text: nil, textColor: UIColor(0x26343F), fontSize: 17)!
            headerView.addSubview(nicknameLabel)
            nicknameLabel.snp.makeConstraints { (make) in
                make.left.equalTo(70)
                make.top.equalTo(58)
                make.right.lessThanOrEqualToSuperview().offset(-20)
            }
            
            // 分割线
            let divider = UIView()
            divider.backgroundColor = UIColor(0xC4C9CC)
            headerView.addSubview(divider)
            divider.snp.makeConstraints { (make) in
                make.left.equalTo(20)
                make.right.equalTo(-20)
                make.bottom.equalToSuperview()
                make.height.equalTo(XDSize.unitWidth)
            }
            
            // 底部发送
            let bottomBar = BottomBar()
            bottomBar.sendButton.addTarget(self, action: #selector(sendButtonPressed), for: .touchUpInside)
            addSubview(bottomBar)
            bottomBar.snp.makeConstraints { (make) in
                make.left.right.bottom.equalToSuperview()
                make.height.equalTo(50)
            }
            
            // 内容
            centerView = UIView()
            addSubview(centerView)
            centerView.snp.makeConstraints { (make) in
                make.top.equalTo(headerView.snp.bottom)
                make.bottom.equalTo(bottomBar.snp.top)
                make.width.equalToSuperview()
                make.centerX.equalToSuperview()
            }
            
            leaveMessageTextField = UITextField()
            centerView.addSubview(leaveMessageTextField)
            leaveMessageTextField.backgroundColor = .white
            leaveMessageTextField.layer.cornerRadius = 4
            leaveMessageTextField.layer.borderColor = UIColor(0xC4C9CC).cgColor
            leaveMessageTextField.layer.borderWidth = XDSize.unitWidth
            leaveMessageTextField.leftView = UIView(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: 12, height: 0)))
            leaveMessageTextField.leftViewMode = .always
            leaveMessageTextField.rightView = UIView(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: 12, height: 0)))
            leaveMessageTextField.rightViewMode = .always
            leaveMessageTextField.placeholder = "留言"
            leaveMessageTextField.snp.makeConstraints { (make) in
                make.left.equalTo(20)
                make.right.equalTo(-20)
                make.bottom.equalTo(-16)
                make.height.equalTo(36)
                
            }
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        
        @objc func sendButtonPressed() {
            guard let id = targetId else { return }
            var msgType: CounselorIM.MessageType!
            if let message = message, let text = (message.content as? TextMessage)?.content {
                msgType = .text(text)
            } else if let message = message, let image = (message.content as? ImageMessage)?.originalImage ?? (message.content as? ImageMessage)?.thumbnailImage {
                msgType = .image(image)
            }
            CounselorIM.shared.send(message: msgType, targetId: id, completion: { [weak self] (result) in
                
                switch result {
                case .success(_):
                    
                    if let levaveMsg = self?.leaveMessageTextField.text, levaveMsg.count > 0 {
                        CounselorIM.shared.send(message: .text(levaveMsg), targetId: id, completion: { (result) in
                            switch result {
                            case .success(_):
                                
                                XDPopView.toast("转发成功")
                                self?.delegate?.hasSendSuccess?()
                            default: SSLog("failed")
                            }
                        })
                    } else {
                        XDPopView.toast("转发成功")
                        self?.delegate?.hasSendSuccess?()
                    }
                default: SSLog("failed")
                }
            })
        }
        
        @objc func detailButtonPressed() {
            delegate?.detailButtonPressed?()
        }
    }
    class DetailView: UIView {
        var backButton: UIButton!
        var contentView: UIView!
        var message: Message! {
            didSet {
                if let message = message {
                    if let text = (message.content as? TextMessage)?.content {
                        let scrollView = UIScrollView()
                        contentView.addSubview(scrollView)
                        scrollView.snp.makeConstraints({ (make) in
                            make.edges.equalToSuperview()
                        })
                        
                        let container = UIView()
                        scrollView.addSubview(container)
                        container.snp.makeConstraints({ (make) in
                            make.edges.equalToSuperview()
                            make.width.equalToSuperview()
                        })
                        
                        let label = UILabel(frame: CGRect.zero, text: text, textColor: UIColor(0x26343F), fontSize: 16)!
                        label.numberOfLines = 0
                        label.textAlignment = .center
                        container.addSubview(label)
                        label.snp.makeConstraints({ (make) in
                            make.left.equalTo(20)
                            make.right.equalTo(-20)
                            make.top.bottom.equalToSuperview()
                            make.height.greaterThanOrEqualTo(self.contentView.snp.height)
                        })
                    }
                }
            }
        }
        override init(frame: CGRect) {
            super.init(frame: frame)
            
            backgroundColor = UIColor(0xF5F6F7)
            
            let headerView = UIView()
            addSubview(headerView)
            headerView.snp.makeConstraints { (make) in
                make.top.left.right.equalToSuperview()
                make.height.equalTo(50)
            }
            
            backButton = UIButton()
            backButton.adjustsImageWhenHighlighted = false
            backButton.setTitle("返回", for: .normal)
            backButton.titleLabel?.font = UIFont.systemFont(ofSize: 16)
            backButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: -5)
            backButton.setTitleColor(UIColor(0x078CF1), for: .normal)
            
            backButton.setImage(UIImage(named: "transpond_back_icon"), for: .normal)
            headerView.addSubview(backButton)
            backButton.snp.makeConstraints { (make) in
                make.centerY.equalToSuperview()
                make.left.equalTo(16)
            }
            
            let bottomLine = UIView()
            bottomLine.backgroundColor = UIColor(0xC4C9CC)
            headerView.addSubview(bottomLine)
            bottomLine.snp.makeConstraints { (make) in
                make.bottom.left.right.equalToSuperview()
                make.height.equalTo(XDSize.unitWidth)
            }
            
            contentView = UIView()
            addSubview(contentView)
            contentView.snp.makeConstraints { (make) in
                make.left.right.bottom.equalToSuperview()
                make.top.equalTo(headerView.snp.bottom)
            }
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
    weak var delegate: TranspondContentViewDelegate?
    var message: Message? {
        didSet {
            mainView.message = message
            detailView.message = message
        }
    }
    var targetId: String? {
        didSet {
            mainView.targetId = targetId
        }
    }
    
    var mainView: MainView!
    var detailView: DetailView!
    
    var avatarView: UIImageView!
    var nicknameView: UILabel!
    

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor(0xF5F6F7)
        layer.cornerRadius = 6
        clipsToBounds = true
        
        mainView = MainView()
        mainView.delegate = self
        addSubview(mainView)
        mainView.snp.makeConstraints { (make) in
            make.width.equalTo(311)
            make.edges.equalToSuperview()
        }
        
        detailView = DetailView()
        detailView.backButton.addTarget(self, action: #selector(backButtonPressed), for: .touchUpInside)
        addSubview(detailView)
        detailView.snp.makeConstraints { (make) in
            make.size.equalToSuperview()
            make.top.equalToSuperview()
            make.left.equalTo(mainView.snp.right)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension TranspondContentView: MainViewDelegate {
    func detailButtonPressed() {
        
        UIView.animate(withDuration: 0.25) {
            self.detailView.snp.remakeConstraints({ (make) in
                make.size.equalToSuperview()
                make.top.equalToSuperview()
                make.left.equalTo(self.mainView.snp.left)
            })
            self.layoutIfNeeded()
        }
    }
    
    func hasSendSuccess() {
        viewController?.dismiss(animated: false, completion: nil)
        delegate?.hasSendSuccess()
    }
}

extension TranspondContentView {
    @objc func backButtonPressed() {
        UIView.animate(withDuration: 0.25) {
            self.detailView.snp.remakeConstraints({ (make) in
                make.size.equalToSuperview()
                make.top.equalToSuperview()
                make.left.equalTo(self.mainView.snp.right)
            })
            self.layoutIfNeeded()
        }
    }
}
