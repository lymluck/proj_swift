//
//  UIDeviceEx.swift
//  xxd
//
//  Created by remy on 2017/12/20.
//  Copyright © 2017年 com.smartstudy. All rights reserved.
//

import AdSupport
import UICKeyChainStore

public extension UIDevice {
    
    private static var UDIDValue = ""
    private static let kDefaultUDIDKey = "kDefaultUDIDKey"
    private static let keyChainUDIDKey = "keyChainUDIDKey"
    
    public static var IDFV: String? {
        return UIDevice.current.identifierForVendor?.uuidString
    }
    
    public static var IDFA: String {
        return ASIdentifierManager.shared().advertisingIdentifier.uuidString
    }
    
    public static var UDID: String {
        if UDIDValue.isEmpty {
            var udid = UserDefaults.standard.string(forKey: kDefaultUDIDKey) ?? ""
            if udid.isEmpty {
                udid = UICKeyChainStore.string(forKey: keyChainUDIDKey) ?? ""
                if udid.isEmpty {
                    udid = IDFV ?? ""
                    UICKeyChainStore.setString(udid, forKey: keyChainUDIDKey)
                }
                UserDefaults.standard.set(udid, forKey: kDefaultUDIDKey)
                UserDefaults.standard.synchronize()
            }
            UDIDValue = udid
        }
        return UDIDValue
    }
    
    public static var sysName: String {
        return UIDevice.current.systemName
    }
    
    public static var sysVersion: String {
        return UIDevice.current.systemVersion
    }
    
    public static var modelName: String {
        return UIDevice.current.model
    }
}
