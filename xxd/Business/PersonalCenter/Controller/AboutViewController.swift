//
//  AboutViewController.swift
//  xxd
//
//  Created by remy on 2017/11/6.
//  Copyright © 2017年 com.innobuddy. All rights reserved.
//

class AboutViewController: SSViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "关于选校帝"
        
        let logo = UIImageView(frame: CGRect(x: (view.width-76)/2, y: 104, width: 76, height: 76), imageName: "app_logo")!
        self.view.addSubview(logo)
        
        let title = UILabel(frame: CGRect(x: 0, y: logo.bottom+31, width: view.width, height: 25), text: "关于选校帝", textColor: UIColor(rgb: 0x26343F), fontSize: 18, bold: true)!
        title.textAlignment = .center
        self.view.addSubview(title)
        
        let version = String(format: "v%@", UIApplication.shared.appVersion!)
        let versionLabel = UILabel(frame: CGRect(x: 0, y: title.bottom+8, width: view.width, height: 18), text: version, textColor: UIColor(rgb: 0x26343F), fontSize: 13)!
        versionLabel.textAlignment = .center
        self.view.addSubview(versionLabel)
    }
}
