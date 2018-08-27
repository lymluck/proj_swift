//
//  XDWebViewProgress.swift
//  xxd
//
//  Created by remy on 2018/2/2.
//  Copyright © 2018年 com.smartstudy. All rights reserved.
//

import WebKit

private let XDInitialProgressValue = 0.2
private let XDMiddleProgressValue = 0.6
private let XDFinalProgressValue = 0.95

class XDWebViewProgress: NSObject, WKNavigationDelegate {
    
    private var webView: WKWebView!
    private weak var proxyWKDelegate: WKNavigationDelegate!
    private var progressBarView: UIView!
    private var progressBar: UIView!
    private var currentURL: URL?
    private var progress = 0.0
    
    convenience init(webView: WKWebView, delegate: WKNavigationDelegate) {
        self.init()
        self.webView = webView
        proxyWKDelegate = delegate
        webView.navigationDelegate = self
        addProgressView()
    }
    
    private func addProgressView() {
        if let progressBarView = progressBarView {
            progressBarView.removeFromSuperview()
        } else {
            progressBarView = UIView(frame: webView.bounds)
            progressBarView.height = 2
            progressBarView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            progressBarView.alpha = 0
            
            progressBar = UIView(frame: progressBarView.bounds)
            progressBar.backgroundColor = XDColor.main
            progressBar.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            progressBarView.addSubview(progressBar)
        }
        progressBarView.isHidden = true
        webView.addSubview(progressBarView)
    }
    
    private func setProgress(progress: Double, duration: TimeInterval, completeBlock: (() -> Void)? = nil) {
        if progress > self.progress {
            self.progress = progress
            if (progressBar.layer.animationKeys()?.count ?? 0) > 0 {
                if let layer = progressBar.layer.presentation() {
                    progressBar.layer.removeAllAnimations()
                    progressBar.frame = layer.frame
                }
            }
            UIView.animate(withDuration: duration, delay: 0, options: .curveEaseInOut, animations: {
                [weak self] in
                if let sSelf = self {
                    sSelf.progressBar.width = sSelf.progressBarView.width * CGFloat(progress)
                }
            }, completion: { (finished) in
                if finished, let completeBlock = completeBlock {
                    completeBlock()
                }
            })
        }
    }
    
    private func startProgress() {
        progressBar.layer.removeAllAnimations()
        progressBar.width = progressBarView.width * CGFloat(XDInitialProgressValue)
        progressBarView.isHidden = false
        progress = XDInitialProgressValue
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: {
            [weak self] in
            if let sSelf = self {
                sSelf.progressBarView.alpha = 1
            }
        }, completion: nil)
        setProgress(progress: XDMiddleProgressValue, duration: 2) {
            [weak self] in
            if let sSelf = self {
                sSelf.setProgress(progress: XDFinalProgressValue, duration: 3)
            }
        }
    }
    
    private func completeProgress() {
        UIView.animate(withDuration: 0.6, delay: 0, options: .curveEaseInOut, animations: {
            [weak self] in
            if let sSelf = self {
                sSelf.progressBarView.alpha = 0
            }
        }, completion: {
            [weak self] (finished) in
            if let sSelf = self {
                sSelf.progressBarView.isHidden = true
            }
        })
    }
    
    //MARK:- WKNavigationDelegate
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        proxyWKDelegate?.webView?(webView, decidePolicyFor: navigationAction, decisionHandler: decisionHandler)
        if let url = navigationAction.request.url {
            var isHashChange = false
            if let fragment = url.fragment {
                let noHashURL = url.absoluteString.replacingOccurrences(of: "#\(fragment)", with: "")
                isHashChange = noHashURL == webView.url?.absoluteString
            }
            let isTopLevelNavigation = (navigationAction.targetFrame?.isMainFrame) ?? false
            let isHTTP = url.scheme == "http" || url.scheme == "https"
            if !isHashChange && isTopLevelNavigation && isHTTP {
                currentURL = navigationAction.request.url
                startProgress()
            }
        }
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        proxyWKDelegate?.webView?(webView, didFinish: navigation)
        if let currentURL = currentURL, currentURL == webView.url {
            completeProgress()
        }
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        proxyWKDelegate?.webView?(webView, didFail: navigation, withError: error)
        if let currentURL = currentURL, currentURL == webView.url {
            completeProgress()
        }
    }
}
