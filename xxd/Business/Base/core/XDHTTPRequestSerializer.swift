//
//  XDHTTPRequestSerializer.swift
//  xxd
//
//  Created by remy on 2017/12/29.
//  Copyright © 2017年 com.smartstudy. All rights reserved.
//

private let XXD_TICKET = "X-xxd-ticket";
private let XXD_UID = "X-xxd-uid";
private let XXD_PUSH_ID = "x-xxd-push-reg-id";

class XDHTTPRequestSerializer: SSHTTPRequestSerializer {

    override init() {
        super.init()
        cachePolicy = .reloadIgnoringLocalCacheData
        timeoutInterval = 15
        setValue(UIDevice.UDID, forHTTPHeaderField: XXD_UID)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func request(withMethod method: String, urlString URLString: String, parameters: Any?, error: NSErrorPointer) -> NSMutableURLRequest {
        let request = super.request(withMethod: method, urlString: URLString, parameters: parameters, error: error)
        if XDUser.shared.hasLogin() {
            request.setValue(XDUser.shared.model.ticket, forHTTPHeaderField: XXD_TICKET)
        }
        if !XDEnvConfig.jpushRegistrationID.isEmpty {
            request.setValue(XDEnvConfig.jpushRegistrationID, forHTTPHeaderField: XXD_PUSH_ID)
        }
        return request
    }
    
    override func multipartFormRequest(withMethod method: String, urlString URLString: String, parameters: [String : Any]?, constructingBodyWith block: ((AFMultipartFormData) -> Void)?, error: NSErrorPointer) -> NSMutableURLRequest {
        return super.multipartFormRequest(withMethod: method, urlString: URLString, parameters: parameters, constructingBodyWith: block, error: error)
    }
}
