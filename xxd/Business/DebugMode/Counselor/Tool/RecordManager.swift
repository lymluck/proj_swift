//
//  RecordManager.swift
//  counselor_t
//
//  Created by chenyusen on 2018/1/10.
//  Copyright © 2018年 TechSen. All rights reserved.
//

import Foundation
import AVFoundation

protocol RecordManagerDelegate: NSObjectProtocol {
    func recorder(_ recorder: AVAudioRecorder, didFinishedWithURL url: URL?)
    func recorder(_ recorder: AVAudioRecorder, didUpdateMeter meter: Int) // 0-7
}

class RecordManager: NSObject {
    static var shared = RecordManager()
    weak var delegate: RecordManagerDelegate?
    var audioRecorder: AVAudioRecorder?
    var timer: CADisplayLink?
    var url: URL?
    private override init() {
        super.init()
    }
    
    func addTimer() {
        removeTimer()
        timer = CADisplayLink(target: self,
                              selector: #selector(refreshMeter))
        timer?.frameInterval = 1
        timer?.add(to: RunLoop.main, forMode: .commonModes)
    }
    
    func removeTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    func startRecord(_ url: URL) {
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayAndRecord)
        } catch {
            SSLog("error setting audio categroy")
        }
        
        do {
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            SSLog("Error activating audio session")
        }
        
        
        self.url = url
        let settings: [String : Any] = [AVFormatIDKey: kAudioFormatLinearPCM,
                        AVSampleRateKey: 8000,
                        AVNumberOfChannelsKey: 1,
                        AVLinearPCMBitDepthKey: 16,
                        AVLinearPCMIsNonInterleaved: false,
                        AVLinearPCMIsFloatKey: false,
                        AVLinearPCMIsBigEndianKey: false]
        do {
            audioRecorder = try AVAudioRecorder(url: url, settings: settings)
        } catch {
            SSLog("create audio recorder failed")
        }
        
        
        audioRecorder?.isMeteringEnabled = true // 开启音量监测
        audioRecorder?.delegate = self
        
        audioRecorder?.prepareToRecord()
        resume()
    }
    
    func pauseRecord() {
        removeTimer()
        audioRecorder?.pause()
        
    }
    
    func stopRecord() {
        removeTimer()
        audioRecorder?.stop()
        try? AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
    }
    
    func resume() {
        addTimer()
        guard let audioRecorder = audioRecorder, !audioRecorder.isRecording else {
            return
        }
        audioRecorder.record()
    }
    
    @objc func refreshMeter() {
        guard let audioRecorder = audioRecorder else {
            return
        }
        audioRecorder.updateMeters()
        
        let result = pow(10, 0.05 * audioRecorder.peakPower(forChannel: 0))
        SSLog(result)
//        const double ALPHA = 0.05;
//        double peakPowerForChannel = pow(10, (0.05 * peakPower));
//        lowPassResults = ALPHA * peakPowerForChannel + (1.0 - ALPHA) * lowPassResults;
        
        
        var meter: Int = 0
        if 0 < result && result <= 0.125 {
            meter = 0
        } else if 0.125 < result && result <= 0.150 {
            meter = 1
        } else if 0.150 < result && result <= 0.2 {
            meter = 2
        } else if 0.2 < result && result <= 0.250 {
            meter = 3
        } else if 0.250 < result && result <= 0.3 {
            meter = 4
        } else if 0.3 < result && result <= 0.4 {
            meter = 5
        } else if 0.4 < result && result <= 0.5 {
            meter = 6
        } else if result > 0.5 {
            meter = 7
        }
   
        delegate?.recorder(audioRecorder, didUpdateMeter: meter)
    }
    
}


extension RecordManager: AVAudioRecorderDelegate {
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if flag {
            delegate?.recorder(recorder, didFinishedWithURL: url!)
        }
        try? FileManager.default.removeItem(at: url!)
    }
    
    func audioRecorderEncodeErrorDidOccur(_ recorder: AVAudioRecorder, error: Error?) {
        
    }
    
    
    
}
