//
//  NSErrorEx.swift
//  xxd
//
//  Created by remy on 2017/12/26.
//  Copyright © 2017年 com.smartstudy. All rights reserved.
//

import Foundation

enum XDErrorCode: Int {
    case XDCommonError
    case XDNetworkError
    case XDUnSignInError
}

extension NSError {
    
    static func error(msg: String) -> NSError {
        return error(type: .XDCommonError, msg: msg)
    }

    static func error(code: String, msg: String) -> NSError {
        let type: XDErrorCode
        if code == "SCHOOL_8" {
            type = .XDUnSignInError
        } else {
            type = .XDCommonError
        }
        return error(type: type, msg: msg)
    }
    
    static func error(type: XDErrorCode, msg: String) -> NSError {
        return NSError(domain: "com.smartstudy.xxd", code: type.rawValue, userInfo: [NSLocalizedDescriptionKey: msg])
    }
}
