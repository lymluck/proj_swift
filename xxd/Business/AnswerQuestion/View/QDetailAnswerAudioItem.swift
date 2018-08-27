//
//  QDetailAnswerAudioItem.swift
//  xxd
//
//  Created by remy on 2018/3/9.
//  Copyright © 2018年 com.smartstudy. All rights reserved.
//

import AVFoundation

class QDetailAnswerAudioItem: QDetailItem {
    
    fileprivate var attrText = NSAttributedString()
    fileprivate var contentTextHeight: CGFloat = 0
    fileprivate var contentTextTop: CGFloat = 0
    fileprivate var contentAudioTop: CGFloat = 0
    fileprivate var contentAudioWidth: CGFloat = 0
    fileprivate weak var currentCell: QDetailAnswerAudioItemCell?
    fileprivate var isPlaying = false
    fileprivate lazy var cellHeight: CGFloat = {
        // 顶部高度+内容高度+底部高度
        return contentAudioTop + audioHeight + (isAsker && showQuestionAfter ? 62 : contentPaddingBottom)
    }()
    
    override func cellClass() -> AnyClass! {
        return QDetailAnswerAudioItemCell.self
    }
    
    override func setup(targetUser: String, isFirst: Bool = false, isAsker: Bool = false) {
        super.setup(targetUser: targetUser, isFirst: isFirst, isAsker: isAsker)
        if isFirst {
            // 音频距离顶部高度
            contentAudioTop = topInfoHeight + 4
        } else {
            attrText = "回复 " + NSAttributedString(string: "@\(targetUser)").color(XDColor.main) + "："
            // 文字内容高度
            contentTextHeight = attrText.string.heightForFont(UIFont.systemFont(ofSize: 15), contentMaxWidth, 23)
            // 文字距离顶部高度
            contentTextTop = contentPaddingTop
            // 音频距离顶部高度
            contentAudioTop = contentTextTop + contentTextHeight + 14
        }
        // 音频内容宽度
//        contentAudioWidth = CGFloat(76 + (240 - 76) * (model.voiceDuration / 180))
        contentAudioWidth = 240
    }
    
    fileprivate func playAudio() {
        if isPlaying {
            AudioManager.shared.stopAllAudioPlay()
        } else {
            UtilHelper.downloadRemoteAudio(model.voiceURL) { (filePath, error) in
                if let fileURL = filePath?.fileURL {
                    if let data = try? Data(contentsOf: fileURL) {
                        let wavData = RCAMRDataConverter().decodeAMR(toWAVE: data)
                        AudioManager.shared.play(nil, data: wavData, delegate: self)
                        try? AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
                    }
                }
            }
        }
    }
}

extension QDetailAnswerAudioItem: AudioManagerDelegate {
    /// 音频即将播放
    func audioPlayerWillStartPlay(_ url: URL?) {
        UIDevice.current.isProximityMonitoringEnabled = true
        updatePlay(true)
    }
    
    /// 音频播放完毕
    func audioPlayerDidFinishPlay(_ url: URL?, finished: Bool) {
        UIDevice.current.isProximityMonitoringEnabled = false
        updatePlay(false)
    }
    
    /// 音频被暂停了
    func audioPlayerDidPaused(_ url: URL?) {
        UIDevice.current.isProximityMonitoringEnabled = false
        updatePlay(false)
    }
    
    /// 音频从中断恢复过来
    func audioPlayerDidResumed(_ url: URL?) {
        UIDevice.current.isProximityMonitoringEnabled = true
        updatePlay(true)
    }
    
    /// 音频别打断了
    func audioPlayerDidInterruptedToPause(_ url: URL?) {
        UIDevice.current.isProximityMonitoringEnabled = false
        updatePlay(false)
    }
    
    func updatePlay(_ isPlaying: Bool) {
        self.isPlaying = isPlaying
        if let currentCell = currentCell {
            currentCell.animated = isPlaying
        }
    }
}

class QDetailAnswerAudioItemCell: QDetailItemCell {
    
    private var commenterView: UIView!
    private var commenterAvatar: UIImageView!
    private var commenterName: UILabel!
    private var contentTextView: UILabel!
    private var contentAudioView: UIView!
    private var audioFlag: UIImageView!
    private var audioTime: UILabel!
    private var audioCover: CAGradientLayer!
    private var commentTime: UILabel!
    private var bottomLine: UIView!
    private lazy var authenImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "authen"))
        imageView.isHidden = true
        return imageView
    }()
    /// 评论背景视图
    private lazy var commentBackgroundView: UIView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: XDSize.screenWidth, height: 0.0), color: UIColor.white)
    /// 未评价视图
    private lazy var unratingBackgroundView: QDetailAnswerUnratingView = {
        let view: QDetailAnswerUnratingView = QDetailAnswerUnratingView(frame: CGRect.zero)
        view.isHidden = true
        contentView.addSubview(view)
        view.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview().offset(-XDSize.unitWidth)
            make.height.equalTo(93.0)
        }
        return view
    }()
    /// 已评价视图
    private lazy var ratingBackgroundView: QDetailAnswerRatingView = {
        let view: QDetailAnswerRatingView = QDetailAnswerRatingView(frame: CGRect.zero)
        view.isHidden = true
        contentView.addSubview(view)
        view.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview().offset(-XDSize.unitWidth)
        }
        return view
    }()
    private lazy var questionAfter: QuestionAfterBtn = {
        // 追问
        let view = QuestionAfterBtn(frame: .zero, title: "我要追问", fontSize: 14, titleColor: UIColor.white, target: self, action: #selector(askTap))!
        view.layer.cornerRadius = 15
        commentBackgroundView.addSubview(view)
        view.snp.makeConstraints { (make) in
            make.size.equalTo(CGSize(width: 80, height: 30))
            make.right.bottom.equalTo(commentBackgroundView).offset(-16)
        }
        return view
    }()
    var animated: Bool = false {
        didSet {
            if oldValue != animated {
                if animated {
                    audioFlag.startAnimating()
                } else {
                    audioFlag.stopAnimating()
                }
            }
        }
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(commentBackgroundView)
        // 个人信息
        commenterView = UIView(frame: CGRect(x: 0, y: 0, width: XDSize.screenWidth, height: topInfoHeight))
        commentBackgroundView.addSubview(commenterView)
        commenterAvatar = UIImageView(frame: CGRect(x: 16, y: 16, width: 40, height: 40))
        commenterAvatar.layer.cornerRadius = 20
        commenterAvatar.layer.masksToBounds = true
        commenterAvatar.isUserInteractionEnabled = true
        commenterAvatar.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(counsellorTap)))
        commenterView.addSubview(commenterAvatar)
        commenterView.addSubview(authenImageView)
        authenImageView.snp.makeConstraints { (make) in
            make.bottom.equalTo(commenterAvatar)
            make.right.equalTo(commenterAvatar).offset(4.0)
        }
        commenterName = UILabel(frame: .zero, text: "", textColor: XDColor.itemTitle, fontSize: 14, bold: true)
        commenterView.addSubview(commenterName)
        commenterName.snp.makeConstraints { (make) in
            make.centerY.equalTo(commenterAvatar)
            make.left.equalTo(commenterView).offset(contentPaddingLeft)
            make.width.lessThanOrEqualTo(contentMaxWidth)
        }
        
        // 文字内容
        contentTextView = UILabel(frame: CGRect(x: contentPaddingLeft, y: 0, width: contentMaxWidth, height: 0), text: "", textColor: XDColor.itemTitle, fontSize: 15)
        contentTextView.numberOfLines = 0
        commentBackgroundView.addSubview(contentTextView)
        // 音频内容
        contentAudioView = UIView(frame: CGRect(x: contentPaddingLeft, y: 0, width: 0, height: audioHeight))
        contentAudioView.layer.cornerRadius = 10
        contentAudioView.layer.masksToBounds = true
        contentAudioView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(audioTap(gestureRecognizer:))))
        commentBackgroundView.addSubview(contentAudioView)
        
        audioCover = CAGradientLayer()
        audioCover.startPoint = CGPoint(x: 0, y: 0.5)
        audioCover.endPoint = CGPoint(x: 1, y: 0.5)
        audioCover.colors = [UIColor(0x61BAFF).cgColor, UIColor(0x0C83FA).cgColor]
        contentAudioView.layer.addSublayer(audioCover)
        
        // 音频播放图标
        audioFlag = UIImageView(frame: .zero)
        var flags = [UIImage]()
        for name in ["soundFlag1","soundFlag2","soundFlag3"] {
            flags.append(UIImage(named: name)!)
        }
        audioFlag.image = UIImage(named: "soundFlag3")!
        audioFlag.animationImages = flags
        audioFlag.animationDuration = 2
        contentAudioView.addSubview(audioFlag)
        audioFlag.snp.makeConstraints { (make) in
            make.centerY.equalTo(contentAudioView)
            make.left.equalTo(contentAudioView).offset(12)
            make.size.equalTo(CGSize(width: 12, height: 17))
        }
        // 音频时间
        audioTime = UILabel(frame: .zero, text: "", textColor: UIColor.white, fontSize: 16)
        contentAudioView.addSubview(audioTime)
        audioTime.snp.makeConstraints { (make) in
            make.centerY.equalTo(contentAudioView)
            make.right.equalTo(contentAudioView).offset(-12)
        }
        // 时间
        commentTime = UILabel(frame: .zero, text: "", textColor: XDColor.itemText, fontSize: 12)
        commentBackgroundView.addSubview(commentTime)
        commentTime.snp.makeConstraints { (make) in
            make.bottom.equalTo(commentBackgroundView).offset(-16)
            make.left.equalTo(commentBackgroundView).offset(contentPaddingLeft)
        }
        // 分割线
        bottomLine = UIView(frame: CGRect(x: 0, y: contentView.height - XDSize.unitWidth, width: XDSize.screenWidth, height: XDSize.unitWidth), color: XDColor.itemLine)
        bottomLine.autoresizingMask = .flexibleTopMargin
        contentView.addSubview(bottomLine)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override class func height(for object: Any!, at indexPath: IndexPath!, tableView: UITableView!) -> CGFloat {
        if let item = object as? QDetailAnswerAudioItem {
            // 判断该问题是否是当前用户提出的
            if item.isAsker {
                if item.isLast {
                    if item.model.ratingScore == 0 {
                        return item.cellHeight + 93.0
                    } else {
                        if item.model.ratingComment.isEmpty {
                            return item.cellHeight + 62.0
                        } else {
                            //TODO: 返回评价视图的高度
                            return item.cellHeight + 62.0 + ceil(item.model.ratingComment.heightForFont(UIFont.systemFont(ofSize: 14.0), XDSize.screenWidth-80.0))
                        }
                    }
                } else {
                    return item.cellHeight
                }
                /// 查看其它用户的回答
            } else {
                // 最后一个item
                if item.isLast {
                    if item.model.ratingScore == 0 {
                        return item.cellHeight
                    } else {
                        if item.model.ratingComment.isEmpty {
                            return item.cellHeight + 62.0
                        } else {
                            //TODO: 返回评价视图的高度
                            return item.cellHeight + 62.0 + ceil(item.model.ratingComment.heightForFont(UIFont.systemFont(ofSize: 14.0), XDSize.screenWidth-80.0))
                        }
                    }
                } else {
                    return item.cellHeight
                }
            }
        }
        
        return (object as! QDetailAnswerAudioItem).cellHeight
    }
    
    override func prepareForReuse() {
        animated = false
        super.prepareForReuse()
    }
    
    @discardableResult
    override func shouldUpdate(with object: Any!) -> Bool {
        if super.shouldUpdate(with: object), let object = object as? QDetailAnswerAudioItem {
            object.currentCell = self
            // 第一条回复为语音回复
            if object.isFirst {
                commenterView.isHidden = false
                commenterAvatar.setAutoOSSImage(urlStr: object.model.commenterAvatar)
                commenterName.text = object.model.commenterName
                authenImageView.isHidden = object.model.schoolCertified
                contentTextView.isHidden = true
            } else {
                commenterView.isHidden = true
                contentTextView.isHidden = false
                contentTextView.attr(attr: object.attrText, lineHeight: contentTextLineHeight)
                contentTextView.height = object.contentTextHeight
                contentTextView.top = object.contentTextTop
            }
            contentAudioView.top = object.contentAudioTop
            contentAudioView.width = object.contentAudioWidth
            audioCover.frame = contentAudioView.bounds
            audioTime.text = object.model.voiceTimeStr
            animated = object.isPlaying
            commentBackgroundView.height = object.cellHeight
            if object.isAsker {
                questionAfter.isHidden = !object.showQuestionAfter
                if object.isLast  {
                    // 未评价
                    if object.model.ratingScore == 0 {
                        unratingBackgroundView.isHidden = false
                        ratingBackgroundView.isHidden = true
                    } else {
                        unratingBackgroundView.isHidden = true
                        ratingBackgroundView.isHidden = false
                        ratingBackgroundView.height = 62.0 + ceil(object.model.ratingComment.heightForFont(UIFont.systemFont(ofSize: 14.0), XDSize.screenWidth-80.0))
                        ratingBackgroundView.rateContent = object.model.ratingComment
                        ratingBackgroundView.rateScore = object.model.ratingScore
                    }
                } else {
                    unratingBackgroundView.isHidden = true
                    ratingBackgroundView.isHidden = true
                }
                // 非当前用户
            } else {
                if object.isLast && object.model.ratingScore != 0 {
                    ratingBackgroundView.isHidden = false
                    ratingBackgroundView.height = 62.0 + ceil(object.model.ratingComment.heightForFont(UIFont.systemFont(ofSize: 14.0), XDSize.screenWidth-80.0))
                    ratingBackgroundView.rateContent = object.model.ratingComment
                    ratingBackgroundView.rateScore = object.model.ratingScore
                } else {
                    ratingBackgroundView.isHidden = true
                }
            }
            commentTime.text = object.model.createTimeText
            bottomLine.left = object.isLast ? 0 : contentPaddingLeft
        }
        return true
    }
    
    //MARK:- Action
    @objc func counsellorTap() {
        routerEvent(name: kEventTeacherInfoTap, data: ["id": (item as! QDetailItem).model.imUserId])
    }
    
    @objc func askTap() {
        routerEvent(name: kEventAskAppendTap, data: ["view": self, "item": item])
    }
    
    @objc private func audioTap(gestureRecognizer: UIGestureRecognizer) {
        (item as! QDetailAnswerAudioItem).playAudio()
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        if let touchView = touches.first?.view {
            if touchView.isDescendant(of: unratingBackgroundView) {
                routerEvent(name: "unratingViewTap", data: ["view":self, "item": item])
            } else if touchView.isDescendant(of: ratingBackgroundView) {
            } else {
                routerEvent(name: kEventAskAppendTap, data: ["view": self, "item": item])
            }
        }
    }
}
