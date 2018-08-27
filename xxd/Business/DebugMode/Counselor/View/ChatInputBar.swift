//
//  ChatInputBar.swift
//  counselor_t
//
//  Created by chenyusen on 2017/12/8.
//  Copyright © 2017年 TechSen. All rights reserved.
//

import UIKit
import MobileCoreServices
import AVFoundation
import ZMJImageEditor

enum VoiceViewState {
    case normal
    case pressed(isIn: Bool)
    case shortDuration
}

class EmojiBoard: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.orange
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class VolumeView : UIView {
    
    var volume: Int = 0 {
        
        didSet {
            subviews.forEach {
                $0.isHidden = $0.tag >= volume
            }
        }
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        for index in 0...7 {
            let volumeLadder = UIImageView(image: UIImage(named: "volume\(7 - index)"))
            volumeLadder.tag = 7-index
            volumeLadder.isHidden = true
            addSubview(volumeLadder)
            volumeLadder.snp.makeConstraints({ (make) in
                if index == 0 {
                    make.width.equalToSuperview()
                }
                make.left.equalToSuperview()
                make.top.equalTo(index * 7)
                if index == 7 {
                    make.bottom.equalToSuperview()
                }
            })
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class RecordView: UIView {
    static var shared = RecordView()
    var micView: UIImageView!
    var volumeView: VolumeView!
    var titleLabel: UILabel!
    var cancelView: UIImageView!
    var shortView: UIImageView!
    var resetAfter = false
    var state: VoiceViewState = .pressed(isIn: true) {
        didSet {
            switch state {
            case .normal:
                resetAfter = true
                cancelView.isHidden = true
                micView.isHidden = false
                shortView.isHidden = true
                titleLabel.text = "松开发送，上划取消"
                titleLabel.textColor = UIColor.white.withAlphaComponent(0.9)
                volumeView.isHidden = false
            case let .pressed(isIn):
                resetAfter = true
                cancelView.isHidden = isIn
                shortView.isHidden = true
                micView.isHidden = !isIn
                titleLabel.text = isIn ? "松开发送，上划取消" : "松开手指，取消发送"
                volumeView.isHidden = false
                titleLabel.textColor = isIn ? UIColor.white.withAlphaComponent(0.9) : UIColor(0xFFD500)
                volumeView.isHidden = !isIn
            case .shortDuration:
                shortView.isHidden = false
                cancelView.isHidden = true
                micView.isHidden = true
                titleLabel.text = "录音时间太短"
                volumeView.isHidden = true
                titleLabel.textColor = UIColor.white.withAlphaComponent(0.9)
                resetAfter = false
                // 1秒后自动消失
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
                    guard let strongSelf = self else { return }
                    if !strongSelf.resetAfter {
                        strongSelf.removeFromSuperview()
                    }
                }
            }
        }
    }
    var volume: Int {  // 0 - 7
        set {
            volumeView.volume = newValue
        }
        get {
           return volumeView.volume
        }
    }
    override private init(frame: CGRect) {
        super.init(frame: CGRect(x: 0, y: 0, width: 155, height: 155))
        self.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        self.layer.cornerRadius = 6
        
        
        cancelView = UIImageView(image: UIImage(named: "record_cancel_icon"))
        cancelView.isHidden = true
        addSubview(cancelView)
        cancelView.snp.makeConstraints { (make) in
            make.top.equalTo(36)
            make.centerX.equalToSuperview()
        }
        
        micView = UIImageView(image: UIImage(named: "mic_icon"))
        addSubview(micView)
        micView.snp.makeConstraints { (make) in
            make.left.equalTo(41)
            make.top.equalTo(34)
        }
        
        shortView = UIImageView(image: UIImage(named: "audio_short"))
        addSubview(shortView)
        shortView.snp.makeConstraints { (make) in
            make.top.equalTo(36)
            make.centerX.equalToSuperview()
        }
        shortView.isHidden = true
        
        volumeView = VolumeView()
        addSubview(volumeView)
        volumeView.snp.makeConstraints { (make) in
            make.left.equalTo(92)
            make.top.equalTo(45)
        }
        
        
        
        titleLabel = UILabel(text: "松开发送，上划取消", textColor: UIColor.white.withAlphaComponent(0.9), fontSize: 14)
        addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(-12)
        }
    }
    
    func show() {
        UIApplication.topVC()?.view.addSubview(self)
        centerX = RecordView.shared.superview!.width * 0.5
        centerY = RecordView.shared.superview!.height * 0.4
    }
    
    deinit {
        RecordManager.shared.stopRecord()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


protocol VoiceInputBarDelegate: NSObjectProtocol {
    func voiceInputBar(_ voiceInputBar: VoiceInputBar, didFinshedRecord recordFile: Data, duration: Int)
}

class VoiceInputBar: UIView {
    
    var titleLabel: UILabel!
    var recordValid: Bool = false
    weak var delegate: VoiceInputBarDelegate?
    var touchDate: Date?
    
    var pressState: VoiceViewState = .normal {
        didSet {

            switch pressState {
            case .normal, .shortDuration:
                titleLabel.text = "按住 说话"
                titleLabel.backgroundColor = UIColor.clear
            case let .pressed(isIn):
                titleLabel.backgroundColor = UIColor(0xE4E5E6)
                if isIn {
                    titleLabel.text = "松开 发送"
                } else {
                    titleLabel.text = "松开 取消"
                }
            }
            RecordView.shared.state = pressState
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.borderColor = UIColor(0xE4E5E6).cgColor
        layer.cornerRadius = 6
        layer.borderWidth = 1
        clipsToBounds = true
        
        titleLabel = UILabel(frame: CGRect.zero, text: "按住 说话", textColor: UIColor(0x58646E), fontSize: 15, bold: true)
        titleLabel.textAlignment = .center
        addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
//        let longPressGR = UILongPressGestureRecognizer(target: self, action: #selector(longPressed(_:)))
//        longPressGR.allowableMovement = 0.1
//        longPressGR.delaysTouchesBegan = true
//        longPressGR.minimumPressDuration = 0.01
//        addGestureRecognizer(longPressGR)
//
        RecordManager.shared.delegate = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension VoiceInputBar {
    
//    @objc func longPressed(_ sender: UILongPressGestureRecognizer) {
//        switch sender.state {
//        case .began:
////            // 手势开始时,访问麦克风权限
////            AVAudioSession.sharedInstance().requestRecordPermission({ (grant) in
//
//                guard sender.numberOfTouches > 0 else { self.reset(); return }
//                guard UIApplication.shared.applicationState == .active else { return }
//                // 因为这个回调不会在主线程,而接下来需要UI操作
////                DispatchQueue.main.async { [weak self] in
//
////                    guard let strongSelf = self else { return }
////                    if grant { // 如果有访问麦克风的权限
//                        // 显示录音视图
//                        RecordView.shared.show()
//                        pressState = .pressed(isIn: true)
//                        // 保证UI层面上, 按钮已经变色
////                        strongSelf.setNeedsLayout()
////                        strongSelf.layoutIfNeeded()
//
//                        // 开始设置一个时间点用于判断长按时间是否达标,如果不超过1秒钟,则认为此次录音无效
//                        touchDate = Date()
//                        recordValid = true
//
//                        // 设置录音文件的路径
//                        if let recordUrl = UtilHelper.recordUrl("\(touchDate!.timeIntervalSince1970.int)") {
//                            RecordManager.shared.startRecord(recordUrl)
//                        } else {
//                            UIAlertController.show(title: "录音失败", message: "请检查磁盘空间是否已满", cancelTitle:"确定")
//                        }
////                    }
////                }
////            })
//        case .changed:
//            guard recordValid else { return } // 如果标记了录音无效,则直接返回
//            guard let touchDate = touchDate, -(touchDate.timeIntervalSinceNow) >= 1 else { return } // 长按时间超过1秒,才开始录音
//            let touchPoint = sender.location(in: self)
//            // 为了用户体验, 在点击后向上扩大了30点击距离
//            if UIEdgeInsetsInsetRect(bounds, UIEdgeInsets(top: -30, left: 0, bottom: 0, right: 0)).contains(touchPoint) {
//                pressState = .pressed(isIn: true)
//            } else {
//                pressState = .pressed(isIn: false)
//            }
//
//        case .cancelled, .ended, .failed, .possible:
//            guard recordValid else {
//                reset()
//                return
//            }
//            guard let touchDate = touchDate else {
//                reset()
//                return
//            }
//            // 如果录制的时间没超过1秒,则认为此次录音无效
//            if -(touchDate.timeIntervalSinceNow) < 1 {
//                recordValid = false
//                RecordManager.shared.stopRecord()
//                pressState = .shortDuration
//                return
//            } else {
//            let touchPoint = sender.location(in: self)
//                recordValid = UIEdgeInsetsInsetRect(bounds, UIEdgeInsets(top: -30.cgFloat, left: 0, bottom: 0, right: 0)).contains(touchPoint)
//                reset()
//            }
//        }
//    }
//
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        SSLog("touchesBegan")
        super.touchesBegan(touches, with: event)
        // 手势开始时,访问麦克风权限
        AudioManager.requestMicPermission({ [weak self] (grant, isFirst) in
            // 因为这个回调不会在主线程,而接下来需要UI操作
            guard let strongSelf = self else { return }
//            guard touches.count > 0 else {  strongSelf.reset(); return }
            guard !isFirst else { return }
            if grant { // 如果有访问麦克风的权限
                // 显示录音视图
                RecordView.shared.show()

                strongSelf.pressState = .pressed(isIn: true)
//                // 保证UI层面上, 按钮已经变色
//                strongSelf.setNeedsLayout()
//                strongSelf.setNeedsDisplay()
//                strongSelf.layoutIfNeeded()

                // 开始设置一个时间点用于判断长按时间是否达标,如果不超过1秒钟,则认为此次录音无效
                strongSelf.touchDate = Date()
                strongSelf.recordValid = true

                // 设置录音文件的路径
                if let recordUrl = UtilHelper.recordUrl("\(strongSelf.touchDate!.timeIntervalSince1970)") {
                    RecordManager.shared.startRecord(recordUrl)
                } else {
                    UIAlertController.show(title: "录音失败", message: "请检查磁盘空间是否已满", cancelTitle:"确定")
                }
            }
        })

    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        SSLog("touchesMoved")
        super.touchesMoved(touches, with: event)
        guard recordValid else { return } // 如果标记了录音无效,则直接返回
        guard let touchDate = touchDate, -(touchDate.timeIntervalSinceNow) >= 1 else { return } // 长按时间超过1秒,才开始录音
        if let touchPoint = touches.first?.location(in: self) {
            // 为了用户体验, 在点击后向上扩大了30点击距离
            if UIEdgeInsetsInsetRect(bounds, UIEdgeInsets(top: -30, left: 0, bottom: 0, right: 0)).contains(touchPoint) {
                pressState = .pressed(isIn: true)
            } else {
                pressState = .pressed(isIn: false)
            }
        }
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        touchFinished(touches, with: event)
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        touchFinished(touches, with: event)
    }
    
    override func pressesBegan(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
        SSLog("pressesBegan")
    }

    func touchFinished(_ touches: Set<UITouch>, with event: UIEvent?) {
        SSLog("touchFinished")
        guard recordValid else {
            reset()
            return
        }
        guard let touchDate = touchDate else {
            reset()
            return
        }
        // 如果录制的时间没超过1秒,则认为此次录音无效
        if -(touchDate.timeIntervalSinceNow) < 1 {
            recordValid = false
            RecordManager.shared.stopRecord()
            pressState = .shortDuration
            return
        } else {
            if let touchPoint = touches.first?.location(in: self) {
                recordValid = UIEdgeInsetsInsetRect(bounds, UIEdgeInsets(top: -CGFloat(30), left: 0, bottom: 0, right: 0)).contains(touchPoint)
            }
            reset()
        }
    }

    func reset() {
        pressState = .normal
        RecordManager.shared.stopRecord()
        RecordView.shared.removeFromSuperview()
    }
}

extension VoiceInputBar: RecordManagerDelegate {
    func recorder(_ recorder: AVAudioRecorder, didFinishedWithURL url: URL?) {
        SSLog("完成录制")
        if recordValid {
            if let url = url {
                do {
                    let audioData = try Data(contentsOf: url)
//                    if let data = RCAMRDataConverter.shared().encodeWAVE(toAMR: audioData, channel: 1, nBitsPerSample: 16) {
////                      try data.base64EncodedData().write(to: url)
//                        let amrURL = ("file://" + UIApplication.shared.documentsPath.appendingPathComponent("test.amr")).url!
//                        try data.write(to: amrURL)
//
//                        delay(3, task: {
//                            AudioManager.shared.play(amrURL, delegate: nil, type: .default)
//                        })
//
//
//                }
                    
                    let audioAsset = AVURLAsset(url: url)
                    let audioDuration = audioAsset.duration
                    let audiodurationSeconds = CMTimeGetSeconds(audioDuration)
                    delegate?.voiceInputBar(self, didFinshedRecord: audioData, duration: max(1, Int(audiodurationSeconds)))
                } catch {
                    SSLog("fetch audio data failed")
                }
            }
        }
    }
    
    func recorder(_ recorder: AVAudioRecorder, didUpdateMeter meter: Int) {
        RecordView.shared.volume = meter
    }
}

protocol ChatInputBarDelegate: class {
    
    func chatInputBarSend(_ message: CounselorIM.MessageType)
}

/// 聊天输入框
class ChatInputBar: UIView {
    weak var delegate: ChatInputBarDelegate?
    var contentView: UIView!
    var inputTextView: UITextView!
    var voiceInputBar: VoiceInputBar!
//    var extendView: UIView!
    var faceButton: UIButton!
    var imageButton: UIButton!
    var inputTypeButton: UIButton!
//    lazy var faceBoard: EmojiBoard = {
//       return EmojiBoard(frame: CGRect(x: 0, y: 0, width: UIScreen.main.width, height: 200))
//    }()
    

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor(0xFAFBFC)
        contentView = UIView()
//        contentView.backgroundColor = UIColor(0xFFFFFF)
        addSubview(contentView)
        contentView.snp.makeConstraints { (make) in
            make.left.top.right.equalToSuperview()
            make.height.equalTo(49)
        }
        
        
        // 输入框
        inputTextView = UITextView()
        inputTextView.layer.borderColor = UIColor(0xE4E5E6).cgColor
        inputTextView.layer.cornerRadius = 6
        inputTextView.layer.borderWidth = 1
        inputTextView.font = UIFont.systemFont(ofSize: 16)
        inputTextView.returnKeyType = .send
        inputTextView.textContainerInset = UIEdgeInsets(top: 7, left: 0, bottom: 0, right: 0)
        inputTextView.backgroundColor = .white
        inputTextView.delegate = self
        inputTextView.enablesReturnKeyAutomatically = true
        contentView.addSubview(inputTextView)
        inputTextView.snp.makeConstraints { (make) in
            make.left.equalTo(52)
            make.right.equalTo(-52)
            make.top.equalTo(7)
            make.bottom.equalTo(-7)
            make.centerY.equalToSuperview()
        }
        
        voiceInputBar = VoiceInputBar()
        voiceInputBar.delegate = self
        voiceInputBar.isHidden = true
        contentView.addSubview(voiceInputBar)
        voiceInputBar.snp.makeConstraints { (make) in
            make.left.equalTo(52)
            make.right.equalTo(-52)
            make.top.equalTo(7)
            make.bottom.equalTo(-7)
            make.centerY.equalToSuperview()
        }
        
        
        inputTypeButton = UIButton()
        inputTypeButton.setImage(UIImage(named: "chat_microphone"), for: .normal)
        inputTypeButton.setImage(UIImage(named: "chat_keyboard"), for: .selected)
        inputTypeButton.addTarget(self, action: #selector(inputTypeButtonPressed(sender:)), for: .touchUpInside)
        contentView.addSubview(inputTypeButton)
        inputTypeButton.snp.makeConstraints { (make) in
            make.left.bottom.equalToSuperview()
            make.size.equalTo(CGSize(width: 52, height: 49))
            
        }

        let topLine = UIView()
        topLine.backgroundColor = UIColor(0xE4E5E6);
        contentView.addSubview(topLine)
        topLine.snp.makeConstraints { (make) in
            make.left.right.top.equalToSuperview()
            make.height.equalTo(XDSize.unitWidth)
        }
        

        imageButton = UIButton()
        imageButton.addTarget(self, action: #selector(imageButtonPressed), for: .touchUpInside)
        imageButton .setImage(UIImage(named: "chat_image")!, for: .normal)
        contentView.addSubview(imageButton)
        imageButton.snp.makeConstraints { (make) in
            make.right.bottom.equalToSuperview()
            make.size.equalTo(CGSize(width: 52, height: 49))
        }
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// 表情按钮点击
    @objc func faceButtonPressed() {
        // TODO: 下个版本开发

    }
    
    
    /// 图片按钮点击
    @objc func imageButtonPressed() {
        let sheetActionAlertVC = UIAlertController(title: "选择图片", message: nil, preferredStyle: .actionSheet)
        
        let cancelAction = UIAlertAction(title: "取消", style: .cancel)
        
        let photoAction = UIAlertAction(title: "从相册选择", style: .default) { [weak self] (action) in
            SSLog("从相册中选择")
//            PhotoBrower.shared.show()
            let photoVC = UIImagePickerController()
            photoVC.delegate = self
            photoVC.allowsEditing = false
            photoVC.sourceType = .photoLibrary
            self?.viewController?.present(photoVC, animated: true)
        }
        
        let cameraAction = UIAlertAction(title: "拍照", style: .default) { [weak self] (action) in
            SSLog("拍照")
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                let camaraVC = UIImagePickerController()
                camaraVC.delegate = self
                camaraVC.allowsEditing = false
                camaraVC.sourceType = .camera
                // 判断用户是否有拍照的权限
                AVCaptureDevice.requestAccess(for: .video) { [weak self] (grant) in
                    if grant {
                        DispatchQueue.main.async {
                            self?.viewController?.present(camaraVC, animated: true)
                        }
                    } else {
                        DispatchQueue.main.async {
                            UIAlertController.show(title: "请在iPhone的”设置“-“隐私”选项中，允许留学顾问访问你的摄像头和麦克风", 
                                                   cancelTitle: "确认")
                        }
                    }
                }
            }
        }
        sheetActionAlertVC.addAction(photoAction)
        sheetActionAlertVC.addAction(cameraAction)
        sheetActionAlertVC.addAction(cancelAction)
        
        UIApplication.topVC()?.presentVC(sheetActionAlertVC, sourceView: imageButton)
    }
    
    @objc func inputTypeButtonPressed(sender: UIButton) {
        sender.isSelected = !sender.isSelected
        inputTextView.isHidden = sender.isSelected
        if sender.isSelected {
            self.endEditing(false)
        }
        voiceInputBar.isHidden = !sender.isSelected
    }
}

extension ChatInputBar: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            delegate?.chatInputBarSend(.text(textView.text))
            textView.text = nil
            return false
        }
        return true
    }
}

extension ChatInputBar: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let mediaType = info["UIImagePickerControllerMediaType"] as? String {
            // 图片
            if mediaType == (kUTTypeImage as String) {
                if let img = info["UIImagePickerControllerOriginalImage"] as? UIImage {
                    if picker.sourceType == .camera {
                        UIApplication.topVC()?.dismiss(animated: true, completion: { [weak self] in
                            self?.delegate?.chatInputBarSend(.image(img))
                        })
                    } else {
                        
                        let imageEditor = WBGImageEditor(image: img, delegate: self, dataSource: self)
                        picker.dismiss(animated: false) {
                            UIApplication.topVC()?.present(imageEditor!, animated: true, completion: nil)
                        }
                    }
                    
                }
            }
        } else {
            picker.dismiss(animated: true)
        }
        
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        SSLog("用户取消图片选择")
        picker.dismiss(animated: true)
    }
}

extension ChatInputBar: WBGImageEditorDelegate {
    func imageEditorDidCancel(_ editor: WBGImageEditor!) {
        editor.dismiss(animated: true, completion: nil)
    }
    
    func imageEditor(_ editor: WBGImageEditor!, didFinishEdittingWith image: UIImage!) {
        
        editor.dismiss(animated: true) { [weak self] in
            self?.delegate?.chatInputBarSend(.image(image))
        }
    }
}

extension ChatInputBar: WBGImageEditorDataSource {
    func imageItemsEditor(_ editor: WBGImageEditor!) -> [WBGMoreKeyboardItem]! {
        return []
    }
    
    func imageEditorCompoment() -> WBGImageEditorComponent {
        return WBGImageEditorComponent.wholeComponent
    }
}

extension ChatInputBar: VoiceInputBarDelegate {
    func voiceInputBar(_ voiceInputBar: VoiceInputBar, didFinshedRecord recordFile: Data, duration: Int) {
        delegate?.chatInputBarSend(.voice(recordFile, duration))
    }
}
