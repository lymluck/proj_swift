//
//  ChatVoiceMessageCellItem.swift
//  counselor_t
//
//  Created by chenyusen on 2018/1/10.
//  Copyright © 2018年 TechSen. All rights reserved.
//

import UIKit
import AVFoundation

private let trumpetSize = UIImage(named: "left_play_audio_gif_03")!.size
private let timeFont: CGFloat = 16
private let unlistendPointRadius: CGFloat = 4

class ChatMessageVoiceCellLayout: ChatMessageCellLayout {
    var voiceButtonFrame: CGRect = CGRect.zero
    var timeFrame: CGRect = CGRect.zero
    var trumpetFrame: CGRect = CGRect.zero
    var unlistendPointFrame: CGRect = CGRect.zero
}

/// text message cell item
class ChatVoiceMessageCellItem: ChatMessageCellItem {
    override var cellClass: UITableViewCell.Type? {
        return ChatVoiceMessageCell.self
    }
    
    static var calTimeLabel = UILabel(frame: CGRect.zero, text: nil, fontSize: timeFont)!
    
    static func diplayDuration(_ duration: Int) -> String {
        let minutes = duration / 60
        let seconds = duration % 60
        if minutes > 0 {
            return "\(minutes)\'\(seconds)\""
        } else {
            return "\(seconds)\""
        }
    }
    
    var isPlaying: Bool = false
    var displayDurationTime: String = "0\""
    
    override var model: Any? {
        didSet {
            if let message = (model as? Message)?.content as? VoiceMessage {
                displayDurationTime = ChatVoiceMessageCellItem.diplayDuration(message.duration)
            }
        }
    }
    
    override func updateLayout() {
        if layout == nil {
            let layout = ChatMessageVoiceCellLayout()
            self.layout = layout
            
            /// 计算元素的frame
            if let message = (model as? Message)?.content as? VoiceMessage {
                let width = min(50 + message.duration * 5, 150)
                layout.bubbleFrame = calBubbleFrame(withContentSize:CGSize(width: width, height: 20) , isSelf: isSelf)
                layout.voiceButtonFrame = CGRect(origin: CGPoint.zero, size: layout.bubbleFrame.size)
                
                ChatVoiceMessageCellItem.calTimeLabel.text = displayDurationTime
                ChatVoiceMessageCellItem.calTimeLabel.size = CGSize(width: 1000, height: 50)
                ChatVoiceMessageCellItem.calTimeLabel.sizeToFit()
                ChatVoiceMessageCellItem.calTimeLabel.centerY = layout.voiceButtonFrame.midY
                if isSelf {
                    ChatVoiceMessageCellItem.calTimeLabel.left = 15
                    layout.trumpetFrame = CGRect(origin: CGPoint(x: layout.voiceButtonFrame.width - 18 - trumpetSize.width, y: (layout.voiceButtonFrame.height - trumpetSize.height) * 0.5),
                                                 size: trumpetSize)
                } else {
                    ChatVoiceMessageCellItem.calTimeLabel.right = layout.voiceButtonFrame.width - 18
                    layout.trumpetFrame = CGRect(origin: CGPoint(x: 15, y: (layout.voiceButtonFrame.height - trumpetSize.height) * 0.5),
                                                 size: trumpetSize)
                    layout.unlistendPointFrame = CGRect(x: layout.bubbleFrame.maxX + unlistendPointRadius * 2, y: layout.bubbleFrame.midY - unlistendPointRadius, width: unlistendPointRadius * 2, height: unlistendPointRadius * 2)
                }
                layout.timeFrame = ChatVoiceMessageCellItem.calTimeLabel.frame
                layout.cellHeight = layout.bubbleFrame.maxY + messageCellBottomMargin

            }
            super.updateLayout()
        }
    }
    
    override var cellHeight: CGFloat {
        return layout?.cellHeight ?? 0
    }
    
    
    func playAudio() {
        if let audioData = ((model as? Message)?.content as? VoiceMessage)?.wavAudioData {
            AudioManager.shared.play(data: audioData, delegate: self)
        }
    }
}

extension ChatVoiceMessageCellItem: AudioManagerDelegate {
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
        (currentCell as? ChatVoiceMessageCell)?.updateCell(self)
    }
}


class VoiceButton: UIButton {
    // 时间
    var timeLabel: UILabel!
    // 喇叭
    var voiceImageView: UIImageView!
    var animated: Bool = false {
        didSet {
            if oldValue != animated {
                if animated {
                    voiceImageView.startAnimating()
                } else {
                    voiceImageView.stopAnimating()
                }
            }
        }
    }
    var duration: String = "" {
        didSet {
            timeLabel.text = duration
            timeLabel.sizeToFit()
        }
    }
    var isSelf: Bool = false {
        didSet {
            if isSelf {
                voiceImageView.image = UIImage(named: "right_play_audio_gif_03")
                voiceImageView.animationImages = [UIImage(named: "right_play_audio_gif_01")!,
                                                  UIImage(named: "right_play_audio_gif_02")!,
                                                  UIImage(named: "right_play_audio_gif_03")!]
                timeLabel.textColor = .white
            } else {
                voiceImageView.image = UIImage(named: "left_play_audio_gif_03")
                voiceImageView.animationImages = [UIImage(named: "left_play_audio_gif_01")!,
                                                  UIImage(named: "left_play_audio_gif_02")!,
                                                  UIImage(named: "left_play_audio_gif_03")!]
                timeLabel.textColor = UIColor(0x26343F)
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        voiceImageView = UIImageView(frame: CGRect(x: 18, y: 0, width: 12, height: 17))
        voiceImageView.image = UIImage(named: "left_play_audio_gif_03")
        
        voiceImageView.animationImages = [UIImage(named: "left_play_audio_gif_01")!,
                                          UIImage(named: "left_play_audio_gif_02")!,
                                          UIImage(named: "left_play_audio_gif_03")!]
        voiceImageView.animationDuration = 0.9
        
        
        timeLabel = UILabel(frame: CGRect.zero, text: nil, textColor: .white, fontSize: timeFont)!
        addSubview(timeLabel)
        addSubview(voiceImageView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

/// text message cell
class ChatVoiceMessageCell: ChatMessageCell {
    
    var voiceButton: VoiceButton!
    var unlistendPoint: UIView!
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        voiceButton = VoiceButton()
        unlistendPoint = UIView()
        unlistendPoint.backgroundColor = UIColor(0xFF4046)
        unlistendPoint.layer.cornerRadius = unlistendPointRadius
        unlistendPoint.clipsToBounds = true
        contentView.addSubview(unlistendPoint)
        voiceButton.addTarget(self, action: #selector(voiceButtonPressed(_:)), for: .touchUpInside)
        
        
    }
    
    override func updateCell(_ cellItem: TableCellItemProtocol?) {
        super.updateCell(cellItem)
        if let cellItem = cellItem as? ChatVoiceMessageCellItem,
            let layout = cellItem.layout as? ChatMessageVoiceCellLayout,
            let message = cellItem.model as? Message {
            bubbleView.frame = layout.bubbleFrame
            voiceButton.frame = layout.voiceButtonFrame
            voiceButton.timeLabel.frame = layout.timeFrame
            voiceButton.voiceImageView.frame = layout.trumpetFrame
            bubbleView.content = voiceButton
            voiceButton.isSelf = cellItem.isSelf
            voiceButton.duration = cellItem.displayDurationTime
            voiceButton.animated = cellItem.isPlaying
            unlistendPoint.frame = layout.unlistendPointFrame
            unlistendPoint.isHidden = message.receivedStatus == .ReceivedStatus_LISTENED
        }
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        voiceButton.animated = false
        super.prepareForReuse()
    }
    
    override func bubbleViewDidLongPressed() {
        if let cellItem = cellItem as? ChatVoiceMessageCellItem, let message = cellItem.model as? Message {
            var buttonTypes: [ChatPopView.ButtonType] = []
            if cellItem.isSelf {
                if !CounselorIM.shared.isMessageExpire(message) { // 只有没超时的消息才能被撤回
                    buttonTypes.append(.recall)
                }
            }
            if !buttonTypes.isEmpty {
                ChatPopView.shared.setButtonTypes(buttonTypes)
                ChatPopView.shared.delegate = self
                ChatPopView.shared.show(referTo: bubbleView)
                bubbleView.showCover = true
            }
        }
    }
}

extension ChatVoiceMessageCell {
    @objc func voiceButtonPressed(_ sender: VoiceButton) {
        if let cellItem = cellItem as? ChatVoiceMessageCellItem,
            let message = cellItem.model as? Message {
            cellItem.playAudio()
            guard message.receivedStatus != .ReceivedStatus_LISTENED else { return }
            if CounselorIM.shared.setMessage(messageId: message.messageId, receivedStatus: .ReceivedStatus_LISTENED) {
                message.receivedStatus = .ReceivedStatus_LISTENED
                NotificationCenter.default.post(name: .IMMessageReciveStatusChanged, object: nil, userInfo: [UserInfo.Message: message])
                unlistendPoint.isHidden = true
            }
        }
    }
}

extension ChatVoiceMessageCell: ChatPopViewDelegate {
    func chatPopView(didPressed buttonType: ChatPopView.ButtonType) {
        switch buttonType {
        case .transpond:
            SSLog("转发")
        case .recall:
            if let message = cellItem?.model as? Message {
                CounselorIM.shared.recallMessage(message)
            }
        case .delete:
            SSLog("删除")
            if let message = cellItem?.model as? Message {
                CounselorIM.shared.deleteMessages([message.messageId])
                NotificationCenter.default.post(name: .IMMessageDeleted,
                                                object: nil,
                                                userInfo: [UserInfo.MessageId: message.messageId])
            }
        default:
            SSLog("未实现功能")
        }
    }
}
