//
//  SettingViewController.swift
//  xxd
//
//  Created by remy on 2018/1/10.
//  Copyright © 2018年 com.smartstudy. All rights reserved.
//

import Kingfisher

class SettingViewController: SSViewController {
    
    var scrollView: UIScrollView!
    var cacheSize: UILabel!
    var itemList = [XDItemView]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "user_setting".localized
        
        scrollView = UIScrollView(frame: CGRect(x: 0, y: XDSize.topHeight, width: XDSize.screenWidth, height: XDSize.visibleHeight))
        scrollView.backgroundColor = UIColor.clear
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.alwaysBounceVertical = true
        view.addSubview(scrollView)
        
        let itemFeedback = XDItemView(frame: CGRect(x: 0, y: 12.0, width: XDSize.screenWidth, height: 66), type: .top)
        itemFeedback.isRightArrow = true
        itemFeedback.addSubview(UILabel(frame: CGRect(x: 20, y: 21, width: XDSize.screenWidth, height: 24), text: "user_feedback".localized, textColor: XDColor.itemTitle, fontSize: 17))
        
        let itemShare = XDItemView(frame: CGRect(x: 0, y: itemFeedback.bottom, width: XDSize.screenWidth, height: 66), type: .middle)
        itemShare.isRightArrow = true
        itemShare.addSubview(UILabel(frame: CGRect(x: 20, y: 21, width: XDSize.screenWidth, height: 24), text: "user_share".localized, textColor: XDColor.itemTitle, fontSize: 17))
        
        let itemAbout = XDItemView(frame: CGRect(x: 0, y: itemShare.bottom, width: XDSize.screenWidth, height: 66), type: .bottom)
        itemAbout.isRightArrow = true
        itemAbout.addSubview(UILabel(frame: CGRect(x: 20, y: 21, width: XDSize.screenWidth, height: 24), text: "user_about".localized, textColor: XDColor.itemTitle, fontSize: 17))
        
        let itemCacheClear = XDItemView(frame: CGRect(x: 0, y: itemAbout.bottom + 12.0, width: XDSize.screenWidth, height: 66), type: .single)
        itemCacheClear.addSubview(UILabel(frame: CGRect(x: 20, y: 21, width: XDSize.screenWidth, height: 24), text: "user_cache_clear".localized, textColor: XDColor.itemTitle, fontSize: 17))
        cacheSize = UILabel(frame: CGRect(x: 0, y: 21, width: XDSize.screenWidth - 20, height: 24), text: "", textColor: XDColor.itemTitle, fontSize: 17)
        cacheSize.textAlignment = .right
        itemCacheClear.addSubview(cacheSize)
        
        let itemSignout = XDItemView(frame: CGRect(x: 0, y: itemCacheClear.bottom + 12.0, width: XDSize.screenWidth, height: 66), type: .single)
        itemSignout.isRightArrow = true
        itemSignout.addSubview(UILabel(frame: CGRect(x: 20, y: 21, width: XDSize.screenWidth, height: 24), text: "sign_out".localized, textColor: XDColor.itemTitle, fontSize: 17))
        
        itemList = [itemFeedback,itemShare,itemAbout,itemCacheClear,itemSignout]
        for i in 0..<itemList.count {
            let item = itemList[i]
            item.info = ["index":i]
            item.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(itemTap(gestureRecognizer:))))
            scrollView.addSubview(item)
        }
        
        itemSignout.isHidden = !XDUser.shared.hasLogin()
        refreshView()
    }
    
    func refreshView() {
        KingfisherManager.shared.cache.calculateDiskCacheSize {
            [weak self] (size) in
            let s = Float(size + SSNetworkManager.getCacheSize())
            self?.cacheSize.text = String(format: "%.1fM", s / 1024 / 1024)
        }
    }
    
    @objc func itemTap(gestureRecognizer: UIGestureRecognizer) {
        if let item = gestureRecognizer.view as? XDItemView {
            let index = item.info["index"] as! Int
            switch index {
            case 0:
                let vc = FeedbackViewController()
                navigationController?.pushViewController(vc, animated: true)
            case 1:
                appShare()
            case 2:
                let vc = AboutViewController()
                navigationController?.pushViewController(vc, animated: true)
            case 3:
                cacheClear()
            case 4:
                signOutTap()
            default:
                break
            }
        }
    }
    
    func appShare() {
        XDShareView.shared.showSharePanel(shareURL: XD_WEB_APP_DOWNLOAD_URL, shareInfo: ["title":"app_name".localized,"description":"app_desc".localized])
    }
    
    func cacheClear() {
        XDPopView.loading()
        DispatchQueue.global().async(execute: {
            KingfisherManager.shared.cache.clearMemoryCache()
            let group = DispatchGroup()
            group.enter()
            KingfisherManager.shared.cache.clearDiskCache(completion: {
                group.leave()
            })
            group.enter()
            SSNetworkManager.clearCache(completion: { (success) in
                group.leave()
            })
            group.notify(queue: .main) {
                self.refreshView()
                XDPopView.toast("user_cache_clear_finish".localized)
            }
        })
    }
    
    func signOutTap() {
        let actionSheet = UIAlertController(title: "sign_out_confirm".localized, message: nil, preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "cancel".localized, style: .cancel, handler: nil))
        actionSheet.addAction(UIAlertAction(title: "confirm".localized, style: .destructive, handler: { [unowned self] (action) in
            self.logout()
        }))
        self.presentVC(actionSheet, sourceView: itemList.last)
    }
    
    func logout() {
        XDPopView.loading()
        SSNetworkManager.shared().get(XD_API_USER_LOGOUT, parameters: nil, success: { [weak self] (task, responseObject) in
            self?.signOutSuccess()
        }) { [weak self] (task, error) in
            self?.signOutSuccess()
        }
    }
    
    func signOutSuccess() {
        XDUser.shared.logout()
        XDPopView.toast("sign_out".localized)
    }
}
