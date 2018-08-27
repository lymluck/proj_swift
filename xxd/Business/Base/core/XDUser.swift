//
//  XDUser.swift
//  xxd
//
//  Created by remy on 2017/12/21.
//  Copyright © 2017年 com.smartstudy. All rights reserved.
//

import SwiftyJSON
import SensorsAnalyticsSDK

class XDUser {
    
    private static let kUserAccountDB = "user_info.xd"
    static let shared = XDUser()
    var model = XDUserModel()
    
    static let mainCountryIDs = ["COUNTRY_226","COUNTRY_225","COUNTRY_40","COUNTRY_16"]
    
    private static var modelKeys: [String] = {
        var keys = [String]()
        var count: UInt32 = 0
        var properties: UnsafeMutablePointer<objc_property_t> = class_copyPropertyList(XDUserModel.self, &count)!
        for i in 0..<count {
            let name = property_getName(properties[Int(i)])
            let key = String(utf8String: name)!
            keys.append(key)
        }
        return keys
    }()
    
    init() {
        if !readFromFile() {
            reset()
        }
    }
    
    private func readFromFile() -> Bool {
        let userInfoPath = URL(string: UIApplication.shared.documentsPath)!.appendingPathComponent(XDUser.kUserAccountDB)
        if let userDict = NSDictionary(contentsOfFile: userInfoPath.absoluteString) {
            if let model = XDUserModel.yy_model(with: userDict as! [String : Any]) {
                self.model = model
                return true
            }
        }
        return false
    }
    
    func writeToFile() {
        if let userDict = model.yy_modelToJSONObject() as? NSDictionary {
            let userInfoPath = URL(string: UIApplication.shared.documentsPath)!.appendingPathComponent(XDUser.kUserAccountDB)
            userDict.write(toFile: userInfoPath.absoluteString, atomically: true)
        }
    }
    
    func setUserInfo(userInfo: [String : Any]) {
        //FIXME: XDUserUpdateModel属性可选值默认不是nil,yy_model设置默认为""
        if let model = XDUserUpdateModel.yy_model(with: userInfo) {
            for key in XDUser.modelKeys {
                let value = model.value(forKey: key)
                if let value = value as? String {
                    self.model.setValue(value, forKey: key)
                }
            }
            // 连接IM服务器
//            connectIMServer()
        }
        // 注册成功或登录成功后关联神策匿名ID
        SensorsAnalyticsSDK.sharedInstance().login(model.userID)
        writeToFile()
        NotificationCenter.default.post(name: NSNotification.Name.XD_NOTIFY_UPDATE_PERSONAL_INFO, object: nil)
        NotificationCenter.default.post(name: .XD_NOTIFY_UPDATE_UNREAD_MESSAGE, object: nil)
        // 更新问答tab未读状态
        NotificationCenter.default.post(name: .XD_NOTIFY_UPDATE_QA_UNREAD, object: nil, userInfo: ["unread": XDUser.shared.hasUnreadQuestions()])
    }
    
    private func reset() {
        resetUserInfo()
        writeToFile()
        resetCookie()
    }
    
    private func resetUserInfo() {
        model = XDUserModel()
    }
    
    private func resetCookie() {
        if let cookies = HTTPCookieStorage.shared.cookies {
            for key in cookies {
                HTTPCookieStorage.shared.deleteCookie(key)
            }
        }
    }
    
    func update() {
        #if TEST_MODE
            if UserDefaults.standard.bool(forKey: "kUnlimitedUnSignIn") {
                model.ticket = ""
                SSOpenID.setID("")
            }
        #endif
        // 同步个人信息
        if model.ticket.isEmpty {
            if let token = SSOpenID.id(), !token.isEmpty {
                SSNetworkManager.shared().get(XD_API_PERSONAL_INFO_V2, parameters: ["token":token,"needSsUser":true], success: {
                    [unowned self] (task, responseObject) in
                    let dict = responseObject as? [String : Any]
                    if let data = dict?["data"] as? [String : Any] {
                        self.setUserInfo(userInfo: data)
                    }
                }) {
                    [unowned self] (task, error) in
                    SSOpenID.setID("")
                    self.logout()
                }
            }
        } else {
            SSNetworkManager.shared().get(XD_API_PERSONAL_INFO_V2, parameters: ["needSsUser":true], success: {
                [unowned self] (task, responseObject) in
                let dict = responseObject as? [String : Any]
                if let data = dict?["data"] as? [String : Any] {
                    self.setUserInfo(userInfo: data)
                }
            }) {
                [unowned self] (task, error) in
                if (error as NSError).code == XDErrorCode.XDUnSignInError.rawValue {
                    self.logout()
                }
            }
        }
    }
    
    // 1.ticket空,openId空:新用户或删除app重装又没登录iCloud,强制登录
    // 2.ticket空,openId不为空:删除app重装的用户,自动登录
    // 3.ticket不为空,openId不为空:普通用户(包括点击退出登录的用户),自动登录
    func hasLogin() -> Bool {
        return !model.ticket.isEmpty || !(SSOpenID.id() ?? "").isEmpty
    }
    
    func logout() {
        // 退出登录后调用神策
        SensorsAnalyticsSDK.sharedInstance().logout()
        
        reset()
        SSOpenID.setID("")
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: XD_NOTIFY_SIGN_OUT), object: nil)
    }
    
    func setUnreadMessageCount(_ count: Int) {
        let messageCount = Int(model.unreadMessageCount)!
        if messageCount != count {
            model.unreadMessageCount = String(count)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: XD_NOTIFY_GET_NEW_MESSAGE), object: nil)
        }
    }
    
    func hasUnreadMessage() -> Bool {
        return XDUser.shared.model.unreadMessageCount != "0"
    }
    
    /// 我的问答列表未读状态,不要用 model.hasUnreadQuestions
    func hasUnreadQuestions() -> Bool {
        return XDUser.shared.model.hasUnreadQuestions == "1"
    }
    
    func connectIMServer(_ count: Int = 0) {
        if count > 2 { return } // 连接数超过3次 不再重新请求
        // 如果当前已经连接,或则正在尝试连接,则不再请求
        guard CounselorIM.shared.connectionStatus != .connected && CounselorIM.shared.connectionStatus != .connecting else {
            return
        }
        
        if !model.imToken.isEmpty {
            
            CounselorIM.shared.connect(withToken: model.imToken, completion: { [weak self] (result) in
                guard let sSelf = self else { return }
                switch result {
                case let .success(id):
                    SSLog("登录融云服务器成功:" + id!)
                    RCIMClient.shared().currentUserInfo = RCUserInfo(userId: sSelf.model.imUserId ,
                                                                     name: sSelf.model.nickname,
                                                                     portrait: sSelf.model.avatarURL)
                case let .failure(code):
                    SSLog("登录融云失败,错误码:\(code)")
                }
                DispatchQueue.main.async {
                    NotificationCenter.default.post(name: .IMConnectFinished,
                                                    object: nil)
                }
                }, tokenIncorrect: { [weak self] in
                    DispatchQueue.main.async {
                        NotificationCenter.default.post(name: .IMConnectFinished,
                                                        object: nil)
                    }
                    SSLog("融云token过期,尝试获取最新的token")
                    
                    
                    self?.updateIMToken(count: count + 1)
            })
    
        } else {
//            XDPopView.toast("nil rytoken")
            updateIMToken(count: 0)
        }
    }
    
    private func updateIMToken(count: Int = 0) {
        
        if count > 2 { return } // 连接数超过3次 不再重新请求
        
        SSNetworkManager.shared().post(XD_REFRESH_IM_TOKEN,
                                       parameters: nil,
                                       success: { [weak self] (_, response) in
                                        let json = JSON(response!)
                                        if let newIMToken = json["data"]["imToken"].string {
                                            XDUser.shared.model.imToken = newIMToken
                                            self?.writeToFile()
                                            self?.connectIMServer(count + 1)
                                        } else {
                                            assert(false, "unknown error")
                                        }
            }, failure: { [weak self] (_, error) in
                SSLog(error.localizedDescription)
                self?.updateIMToken(count: count + 1)
        })
    }
}


