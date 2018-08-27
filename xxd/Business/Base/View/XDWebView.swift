//
//  XDWebView.swift
//  xxd
//
//  Created by remy on 2018/2/2.
//  Copyright © 2018年 com.smartstudy. All rights reserved.
//

import WebKit

class XDWebView: UIView, WKNavigationDelegate, WKScriptMessageHandler {
    
    var completionHandler: (() -> Void)?
    private var jsonStr: String?
    private var fileName = ""
    private var webView: WKWebView!
    
    convenience init(frame: CGRect, query: [String : Any]?) {
        self.init(frame: frame)
        webView = WKWebView(frame: bounds)
        webView.backgroundColor = UIColor.clear
        webView.scrollView.isScrollEnabled = false
        webView.scrollView.showsHorizontalScrollIndicator = false
        webView.scrollView.showsVerticalScrollIndicator = false
        webView.navigationDelegate = self
        addSubview(webView)
        
        if let query = query {
            if let params = query["params"] as? NSDictionary {
                jsonStr = params.yy_modelToJSONString()
            }
            fileName = query["fileName"] as! String
            initData()
        }
    }
    
    private func initData() {
        let filePath = Bundle.main.path(forResource: fileName, ofType: "html")!
        let fileURL = URL(fileURLWithPath: filePath, isDirectory: false)
        webView.loadFileURL(fileURL, allowingReadAccessTo: fileURL)
    }
    
    //MARK:- WKNavigationDelegate
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        decisionHandler(WKNavigationActionPolicy.allow)
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        let jsCode = "window.appInit(\(jsonStr ?? "null"));"
        webView.evaluateJavaScript(jsCode, completionHandler: nil)
        if let completionHandler = completionHandler {
            completionHandler()
        }
    }
    
    //MARK:- WKScriptMessageHandler
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {}
}
