//
//  XDEnvConfig.swift
//  xxd
//
//  Created by remy on 2017/12/20.
//  Copyright © 2017年 com.smartstudy. All rights reserved.
//

let XDEnvTypeKey = "type"
let XDEnvAPIHostKey = "APIHost"
let XDEnvWebHostKey = "WebHost"

enum EnvType: String {
    case developer     // 开发环境API
    case distribution  // 个人环境API
    case personal      // 个人环境API
    case custom        // 自定义
}

class XDEnvConfig: NSObject {
    
    static let MeiqiaAppKey = "11342702eacdcfdc64e67be582aebbf5"
    static let UmengAppKey = "58fd67392ae85b7111002076"
    static let GrowingIOAppKey = "87ee52fe34f15339"
    static let JPushAppKey = "fe79cbd72874085128f45b24"

    static var apiHost = "https://api.smartstudy.com/school"
    static var webHost = "https://xxd.smartstudy.com"
    static var jpushRegistrationID = ""
    
    static func debugEnv() {
        if let type = Preference.CURRENT_ENVIRONMENT_TYPE.get() {
            appEnv = EnvType(rawValue: type)!
        } else {
            appEnv = EnvType.developer
        }
    }
        
    static var appEnv = EnvType.distribution {
        didSet {
            for env in envHosts {
                if env[XDEnvTypeKey] == appEnv.rawValue {
                    apiHost = env[XDEnvAPIHostKey]!
                    webHost = env[XDEnvWebHostKey]!
                }
            }
        }
    }
    
    static var envName: String {
        return envNameWithType(appEnv)
    }
    
    static func envNameWithType(_ type: EnvType) -> String {
        switch type {
        case .developer:
            return "开发环境"
        case .distribution:
            return "线上环境"
        case .personal:
            return "个人环境"
        default:
            return "自定义环境"
        }
    }
    
    static var envHosts: [[String: String]] = {
        var hosts = [
            [
                XDEnvTypeKey: EnvType.developer.rawValue,
//                XDEnvAPIHostKey: "http://blog.smartstudy.com:3000",
                XDEnvAPIHostKey: "http://api.beikaodi.com",
                XDEnvWebHostKey: "http://xxd.beikaodi.com"
            ],
            [
                XDEnvTypeKey: EnvType.distribution.rawValue,
                XDEnvAPIHostKey: "https://api.smartstudy.com/school",
                XDEnvWebHostKey: "http://xxd.smartstudy.com"
            ],
            [
                XDEnvTypeKey: EnvType.personal.rawValue,
                XDEnvAPIHostKey: "http://linkang.smartstudy.com:3000",
                XDEnvWebHostKey: "http://yongle.smartstudy.com:3100"
            ]
        ]
        if let customEnv = Preference.CUSTOM_ENVIRONMENT.get() {
            hosts.append(customEnv)
            return hosts
        } else {
            hosts.append([XDEnvTypeKey: EnvType.custom.rawValue])
            return hosts
        }
    }()
    
    static func customUserAgent() {
        let data = ["UserAgent":userAgent]
        UserDefaults.standard.register(defaults: data)
        UserDefaults.standard.synchronize()
    }
    
    static var userAgent: String = {
        let flag = "xxd/\(UIApplication.shared.appVersion!)"
        var arr = defaultUserAgent.components(separatedBy: " ")
        arr[0] = flag
        arr.append("Store/appstore")
        return arr.joined(separator: " ")
    }()
    
    static var defaultUserAgent: String = {
        let ua = UIWebView().stringByEvaluatingJavaScript(from: "navigator.userAgent")
        if let ua = ua {
            return ua
        } else {
            return ""
        }
    }()
    
    static var userBadgeCount: Int {
        return UIApplication.shared.applicationIconBadgeNumber
    }
}
