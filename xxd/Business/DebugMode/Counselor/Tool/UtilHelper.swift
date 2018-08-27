//
//  UtilHelper.swift
//  counselor_t
//
//  Created by chenyusen on 2017/12/28.
//  Copyright © 2017年 TechSen. All rights reserved.
//

import Foundation

struct UtilHelper {
    static func displayWeekdayWith(date: Date) -> String {
        switch date.weekday {
        case 1: return "周日"
        case 2: return "周一"
        case 3: return "周二"
        case 4: return "周三"
        case 5: return "周四"
        case 6: return "周五"
        case 7: return "周六"
        default: return "周几"
        }
    }

    
    /// 获取一个用于录音的文件路径
    ///
    /// - Parameter name: 录音文件的文件名
    /// - Returns: 录音文件绝对路径
    static func recordUrl(_ name: String) -> URL? {
        let userId = XDUser.shared.model.ID
        let path = UIApplication.shared.documentsPath.appendingPathComponent(userId).appendingPathComponent("chat_record")
        let fileName = name + ".wav"
        // 先检查有没有创建好的
        var isDir: ObjCBool = true
        if !FileManager.default.fileExists(atPath: path, isDirectory: &isDir) { // 文件不存在
            do {
                try FileManager.default.createDirectory(atPath: path, withIntermediateDirectories: true, attributes: nil)
            } catch { // 如果创建路径失败, 则返回
                return nil
            }
        }
        let url = ("file://" + path.appendingPathComponent(fileName)).url
        
        return url
    }
    
    static let audioTempDirName = "xxd_audio_temp_dir"
    
    static func downloadRemoteAudio(_ urlStr: String, completionHandler: @escaping (String?, Error?) -> Void) {
        if let filePath = localAudioPath(urlStr) {
            completionHandler(filePath, nil)
        } else {
            if let fileName = urlStr.components(separatedBy: "/").last {
                let path = UIApplication.shared.tempPath.appendingPathComponent(audioTempDirName)
                var isDir: ObjCBool = true
                if !FileManager.default.fileExists(atPath: path, isDirectory: &isDir) {
                    do {
                        try FileManager.default.createDirectory(atPath: path, withIntermediateDirectories: true, attributes: nil)
                    } catch {
                        return
                    }
                }
                let filePath = path.appendingPathComponent(fileName)
                let request = URLRequest(url: urlStr.url!)
                let dataTask = URLSession.shared.downloadTask(with: request, completionHandler: { (location, response, error) in
                    var fp: String?
                    if error == nil {
                        let path = location?.path
                        do {
                            try FileManager.default.moveItem(atPath: path!, toPath: filePath)
                            fp = filePath
                        } catch {
                        }
                    }
                    DispatchQueue.main.async(execute: {
                        completionHandler(fp, error)
                    })
                })
                dataTask.resume()
            }
        }
    }
    
    static func localAudioPath(_ urlStr: String) -> String? {
        if let fileName = urlStr.components(separatedBy: "/").last {
            let filePath = UIApplication.shared.tempPath.appendingPathComponent("\(audioTempDirName)/\(fileName)")
            var isDir: ObjCBool = false
            if FileManager.default.fileExists(atPath: filePath, isDirectory: &isDir) {
                return filePath
            }
        }
        return nil
    }
}
