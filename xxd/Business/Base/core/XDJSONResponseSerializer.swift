//
//  XDJSONResponseSerializer.swift
//  xxd
//
//  Created by remy on 2017/12/29.
//  Copyright © 2017年 com.smartstudy. All rights reserved.
//

class XDJSONResponseSerializer: SSJSONResponseSerializer {
    
    override func responseObject(for response: URLResponse?, data: Data?, error: NSErrorPointer) -> Any? {
        let json = super.responseObject(for: response, data: data, error: error)
        if let json = json as? [String: Any] {
            if let code = json["code"] as? String, code != "0" {
                error?.pointee = NSError.error(code: "\(code)", msg: json["msg"] as! String)
            } else if let code = json["code"] as? Int, code != 0 {
                error?.pointee = NSError.error(code: "\(code)", msg: json["msg"] as! String)
            }
        }
        return json
    }
}
