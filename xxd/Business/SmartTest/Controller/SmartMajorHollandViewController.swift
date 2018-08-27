//
//  SmartMajorHollandViewController.swift
//  xxd
//
//  Created by remy on 2018/2/2.
//  Copyright © 2018年 com.smartstudy. All rights reserved.
//

class SmartMajorHollandViewController: SSViewController {
    
    private var scrollView: XDScrollView!
    private var webView: XDWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "holland_test".localized
        
        scrollView = XDScrollView(frame: CGRect(x: 0, y: XDSize.topHeight, width: XDSize.screenWidth, height: XDSize.visibleHeight))
        scrollView.backgroundColor = UIColor.white
        scrollView.bottomSpace = 48
        scrollView.isHidden = true
        view.addSubview(scrollView)
        
        let titleLabel = UILabel(frame: CGRect(x: 0, y: 24, width: XDSize.screenWidth, height: 30), text: "holland_test".localized, textColor: XDColor.itemTitle, fontSize: 22, bold: true)!
        titleLabel.textAlignment = .center
        scrollView.addSubview(titleLabel)
        
        let params = ["a":37.5,"r":50,"i":87.5,"e":12.5,"c":25,"s":37.5]
        let query: [String : Any] = ["fileName":"hollandRadar","params":params]
        let size = XDSize.screenWidth - 50
        webView = XDWebView(frame: CGRect(x: 25, y: 80, width: size, height: size), query: query)
        XDPopView.loading()
        webView.completionHandler = {
            [weak self] in
            self?.scrollView.isHidden = false
            XDPopView.hide()
        }
        scrollView.addSubview(webView)
        
        let text = "holland_test_desc".localized
        let descLabel = UILabel(frame: CGRect(x: 24, y: scrollView.contentBottom + 20, width: XDSize.screenWidth - 48, height: 0), text: "", textColor: XDColor.itemTitle, fontSize: 15)!
        descLabel.numberOfLines = 0
        descLabel.setText(text, lineHeight: 27)
        descLabel.height = text.heightForFont(descLabel.font, descLabel.width, 27)
        scrollView.addSubview(descLabel)
    }
}
