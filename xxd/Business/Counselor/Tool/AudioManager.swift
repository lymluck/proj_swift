//
//  AudioManager.swift
//  counselor_t
//
//  Created by chenyusen on 2018/1/15.
//  Copyright © 2018年 TechSen. All rights reserved.
//

import UIKit
import AVFoundation


@objc public protocol AudioManagerDelegate: NSObjectProtocol {
    
    /// 音频即将播放
    @objc optional func audioPlayerWillStartPlay(_ url: URL?)
    
    /// 音频播放完毕
    @objc optional func audioPlayerDidFinishPlay(_ url: URL?, finished: Bool)
    
    /// 音频被暂停了
    @objc optional func audioPlayerDidPaused(_ url: URL?)
    
    /// 音频从暂停到播放
    @objc optional func audioPlayerDidResumed(_ url: URL?)
    
    /// 音频播放时被session打断了
    @objc optional func audioPlayerDidInterruptedToPause(_ url: URL?)
    
    /// 音频播放剩余时长和总时长
    @objc optional func audioPlayerIsPlaying(_ url: URL?, totalTime: TimeInterval, remainTime: TimeInterval)
}


public enum AudioPlayerItemType {
    case `default`, other
}


// MARK:- 播放器
public class AudioPlayerItem: NSObject {


    
    var type: AudioPlayerItemType = .default
    
    /// 播放文件的URL
    var playUrl: URL?
    var playData: Data?
    
    var isPlaying: Bool {
        return audioPlayer?.isPlaying ?? false
    }
    
    var audioPlayer: AVAudioPlayer?
    
    var timer: CADisplayLink?
    
    lazy var delegates: [WeakBox<AudioManagerDelegate>] = {
        return []
    }()
    
    override init() {
        super.init()
        // 注册音频异常打断通知
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(hanldeAudioSessionInterruption(_:)),
                                               name: .AVAudioSessionInterruption,
                                               object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    
    /// 播放音频
    ///
    /// - Parameters:
    ///   - url: 音频的url
    ///   - data: 音频的文件数据
    ///   - delegate: 代理
    func play(_ url: URL? = nil,
              data: Data? = nil,
              delegate: AudioManagerDelegate? = nil) {
        // 如果之前正在播放,则先停止
        if playUrl != nil || playData != nil {
            
            let stopOld = ((playUrl != nil && playUrl == url) || (playData != nil && playData == data)) && (delegate != nil && isContains(delegate!))
            stopAudioPlay()
            if stopOld { return }
        }
        
        
        delegates.removeAll()
        if let delegate = delegate {
            delegates.append(WeakBox(delegate))
        }
        audioPlayer?.stop()
        do {
            if let url = url {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
                playUrl = url
            } else if let data = data {
                audioPlayer = try AVAudioPlayer(data: data)
                playData = data
            }
            audioPlayer?.delegate = self
            audioPlayer?.numberOfLoops = 0
            
            // 准备播放
            if audioPlayer!.prepareToPlay() {
                audioPlayer?.play()
                audioPlayerWillStartPlay(url)
                addTimer()
                UIApplication.shared.isIdleTimerDisabled = false
            } else {
                assert(false, "can't prepare to play")
                audioPlayerDidFinishPlay(url, finished: false)
            }
            
            
        } catch {
//            SSLog("initial audioPlayer failed")
        }
    }
    
    
    /// 重新播放音频
    ///
    /// - Parameters:
    ///   - url: 重新播放音频的url
    ///   - data: 重新播放音频的文件
    ///   - delegate: 代理
    func resume(_ url: URL? = nil,
                data: Data? = nil,
                delegate: AudioManagerDelegate? = nil) {
        // 如果根本没建立过,那就谈不上重新播放
        guard let audioPlayer = audioPlayer else {
            return
        }
        if ((playUrl != nil && playUrl == url) || (data != nil && playData == data)) && audioPlayer.prepareToPlay() {
            audioPlayer.play()
            audioPlayerDidResumed(playUrl)
        } else { // 如果当前不是暂停状态, 则直接播放
            assert(false)
            play(url, delegate: delegate)
        }
    }
    
    func stopAudioPlay() {
        removeTimer()
        audioPlayer?.stop()
        audioPlayer = nil
        audioPlayerDidFinishPlay(playUrl, finished: false)
        playUrl = nil
        playData = nil
    }
    
    func pause(_ url: URL? = nil, data: Data? = nil) {
        if ((playUrl != nil && playUrl == url) || (playData != nil && playData == data)) {
            audioPlayer?.pause()
        } else {
            stopAudioPlay()
            assert(false, "warning : need url the same")
        }
        audioPlayerDidPaused(url)
        UIApplication.shared.isIdleTimerDisabled = false
    }

}


extension AudioPlayerItem {
    func addTimer() {
        removeTimer()
        timer = CADisplayLink(target: self, selector: #selector(updateRemainTime))
        timer?.frameInterval = 1
        timer?.add(to: RunLoop.main, forMode: .commonModes)
    }
    
    func removeTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    @objc func updateRemainTime() {
        guard let audioPlayer = audioPlayer, let url = playUrl else {
            return
        }
        
        let allTime = audioPlayer.duration
        let remainTime = allTime - audioPlayer.currentTime
        audioPlayerIsPlaying(url, totalTime: allTime, remainTime: remainTime)
    }
}

extension AudioPlayerItem {
    // 添加代理
    func add(_ delegate: AudioManagerDelegate) {
        // 每次add前,先清洗
        delegates = delegates.filter { $0.value != nil }
        // 判断是否已经包含, 如果没有则添加
        // 用一个weakbox封装,是为了当delegate被释放时, 不需要再deinit方法里面删除代理,减少代码耦合,只需要在用时判断一下就行
        if isContains(delegate) {
            delegates.append(WeakBox(delegate))
        }
    }
    
    // 删除代理
    func remove(_ delegate: AudioManagerDelegate) {
        delegates = Array(delegates.drop { $0.value === delegate })
        
    }
    
    // 是否包含代理
    func isContains(_ delegate: AudioManagerDelegate) -> Bool {
        return delegates.contains { ($0.value)! === delegate }
    }
}


extension AudioPlayerItem: AVAudioPlayerDelegate {
    
    // 此处把 audiosession的通知回调也放在这里,完全是为了业务管理方便
    @objc func hanldeAudioSessionInterruption(_ noti: Notification) {
        if let playUrl = playUrl {
            if let event = noti.userInfo?[AVAudioSessionInterruptionOptionKey] as? AVAudioSessionInterruptionType {
                switch event {
                case .began:
//                    SSLog("play is Interruption")
                    audioPlayerDidInterruptedToPause(playUrl)
                case .ended:
                    // 需要从中断中自动恢复
                    if let option = noti.userInfo?[AVAudioSessionInterruptionOptionKey] as? AVAudioSessionInterruptionOptions,
                        option == .shouldResume {
                        resume(playUrl, delegate: delegates.first?.value)
                    } else {
                        
                    }
                    
                }
            }
        }
    }
    
    public func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        removeTimer()
        audioPlayer?.stop()
        audioPlayer = nil
        playData = nil
        audioPlayerDidFinishPlay(playUrl, finished: flag)
        playUrl = nil
        UIApplication.shared.isIdleTimerDisabled = false
    }
}

// MARK: - 多代理分发
extension AudioPlayerItem: AudioManagerDelegate {
    
    public func audioPlayerWillStartPlay(_ url: URL?) {
        delegates.forEach { $0.value?.audioPlayerWillStartPlay?(url) }
    }
    
    public func audioPlayerDidResumed(_ url: URL?) {
        delegates.forEach { $0.value?.audioPlayerDidResumed?(url) }
    }

    public func audioPlayerDidPaused(_ url: URL?) {
        delegates.forEach { $0.value?.audioPlayerDidPaused?(url) }
    }
    
    public func audioPlayerDidInterruptedToPause(_ url: URL?) {
        delegates.forEach { $0.value?.audioPlayerDidInterruptedToPause?(url) }
    }
   
    public func audioPlayerIsPlaying(_ url: URL?, totalTime: TimeInterval, remainTime: TimeInterval) {
        delegates.forEach { $0.value?.audioPlayerIsPlaying?(url, totalTime: totalTime, remainTime: remainTime) }
    }
 
    public func audioPlayerDidFinishPlay(_ url: URL?, finished: Bool) {
        delegates.forEach { $0.value?.audioPlayerDidFinishPlay?(url, finished: finished) }
    }
}

/// 用于统一调度播放音频
open class AudioManager: NSObject {
    var isPlaying: Bool {
        return playItemWithType(.default).isPlaying
    }
    static let shared = AudioManager()
    var playItems: [AudioPlayerItemType: AudioPlayerItem] = {
        var aPlayItems: [AudioPlayerItemType: AudioPlayerItem] = [:]
        let enumCases = [AudioPlayerItemType.default, AudioPlayerItemType.other]
        for type in enumCases {
            let playItem = AudioPlayerItem()
            playItem.type = type
            aPlayItems[type] = playItem
        }
        return aPlayItems
    }()
    
    
    private override init() {
        super.init()
    }
    
    public func play(_ url: URL? = nil,
                     data: Data? = nil,
                     delegate: AudioManagerDelegate? = nil,
                     type: AudioPlayerItemType = .default) {
        let playItem = playItemWithType(type)
        playItem.play(url, data: data, delegate: delegate)
    }
    
    private func playItemWithType(_ type: AudioPlayerItemType) -> AudioPlayerItem {
        return playItems[type]!
    }
    
    public func stopAllAudioPlay() {
        playItems.forEach { (_, playItem) in
            playItem.stopAudioPlay()
        }
    }
}


// MARK: - 类方法
extension AudioManager {
    /// 申请麦克风权限
    ///
    /// - Parameter completion: 申请结果
    class func requestMicPermission(_ completion: @escaping (Bool, Bool) -> ()) {
        AVAudioSession.sharedInstance().requestRecordPermission { (result) in
            if result {
                if Thread.isMainThread {
                    completion(true, false)
                } else {
                    DispatchQueue.main.async {
                        completion(true, true)
                    }
                }
            } else {
                if Thread.isMainThread {
                    UIAlertController.show(title: "开启录音权限",
                                           message: "检测到您关闭了录音权限，请允许“留学顾问”访问你的手机麦克风",
                                           actionTitle: "设置",
                                           cancelTitle: "取消",
                                           action: {
                                            let url = URL(string: UIApplicationOpenSettingsURLString)!
                                            UIApplication.shared.openURL(url) })
                    completion(false, true)
                } else {
                    DispatchQueue.main.async {
                        completion(false, false)
                    }
                }
            }
        }
    }
}






extension AudioManager {
    @objc func WillEnterForeground(_ noti: Notification) {
        
    }
}
