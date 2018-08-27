//
//  ShareView.swift
//  xxd
//
//  Created by Lisen on 2018/4/16.
//  Copyright © 2018年 com.smartstudy. All rights reserved.
//

import UIKit
import ZXingObjC

enum ShareType: Int {
    case wechatSession = 0
    case wechatTimeline
    case qq
    case qZone
    case sina
    case localSave
    case qrCode
    case copyLink
    case openInSafari
}

extension ShareType {
    /// 转换成友盟对应的分享平台
    var umplatfromTypes: UMSocialPlatformType {
        switch self {
        case .wechatSession:
            return .wechatSession
        case .wechatTimeline:
            return .wechatTimeLine
        case .qq:
            return .QQ
        case .qZone:
            return .qzone
        case .sina:
            return .sina
        default:
            return .unKnown
        }
    }
}

/// 自定义分享面板
class XDShareView: NSObject {
    
    private var availableTypes: [UMSocialPlatformType] {
        get {
            return platformTypes.filter { UMSocialManager.default().isInstall($0) }
        }
    }
    private lazy var platformTypes: [UMSocialPlatformType] = {
        return [UMSocialPlatformType.wechatSession, UMSocialPlatformType.wechatTimeLine, UMSocialPlatformType.QQ, UMSocialPlatformType.qzone, UMSocialPlatformType.sina]
    }()
    private lazy var backgroundView: UIView = {
        let view: UIView = UIView(frame: UIScreen.main.bounds, color: UIColor(white: 0.0, alpha: 0.4))
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(XDShareView.eventBackgroundGestureResponse(_:)))
        view.addGestureRecognizer(tap)
        return view
    }()
    private var shareView: ShareView?
    private var shareViewHeight: CGFloat = 0.0
    private var shareURL: String = ""
    private var shareInfo: [String: Any]?
    private var shareCoverImage: UIImage?
    private var qrCodeResult = ""
    static var shared: XDShareView = XDShareView()
    
    private override init() {
        super.init()
//        shareView = ShareView(frame: CGRect.zero, shareTypes: availableTypes) //(x: 0.0, y: XDSize.screenHeight, width: XDSize.screenWidth, height: shareViewHeight), shareTypes: avaliableTypes)
//        shareView!.delegate = self
//        backgroundView.addSubview(shareView!)
    }
    
    @objc func eventBackgroundGestureResponse(_ tap: UITapGestureRecognizer) {
        removeCustomShareViews()
    }
    
    @objc func image(_ image: UIImage, didFinisheSavingWithError error: Error?, contextInfo: UnsafeRawPointer?) {
        if error == nil {
            XDPopView.toast("保存图片成功")
        } else {
            XDPopView.toast("保存图片失败")
        }
    }
    
    /// 弹出分享面板
    func showSharePanel(shareURL: String, shareInfo: [String: Any], coverImage: UIImage? = nil) {
        self.shareURL = shareURL.removingPercentEncoding ?? ""
        self.shareInfo = shareInfo
        self.shareCoverImage = coverImage
        addCustomShareViews()
    }
    
    /// 添加自定义分享视图
    private func addCustomShareViews() {
        shareViewHeight = 340.0
        if availableTypes.count == 0 {
            shareViewHeight = 210.0
        }
        shareView = ShareView(frame: CGRect(x: 0.0, y: XDSize.screenHeight, width: XDSize.screenWidth, height: shareViewHeight), shareTypes: availableTypes)
        shareView!.delegate = self
        backgroundView.addSubview(shareView!)
//        shareView?.frame = CGRect(x: 0.0, y: XDSize.screenHeight, width: XDSize.screenWidth, height: shareViewHeight)
        var webShareType: [ShareType] = []
        if let sharedImage = self.shareCoverImage {
            qrCodeResult = ""
            let source = ZXCGImageLuminanceSource(cgImage: sharedImage.cgImage)
            let bitmap = ZXBinaryBitmap(binarizer: ZXHybridBinarizer(source: source))
            let hints = ZXDecodeHints.hints() as! ZXDecodeHints
            let reader = ZXMultiFormatReader.reader() as! ZXMultiFormatReader
            if let result = try? reader.decode(bitmap, hints: hints) {
                qrCodeResult = result.text.removingPercentEncoding ?? ""
                if !qrCodeResult.isEmpty {
                    webShareType.append(ShareType.qrCode)
                }
            } else {
                webShareType.append(ShareType.localSave)
            }
        } else {
            webShareType.append(ShareType.copyLink)
            webShareType.append(ShareType.openInSafari)
        }
        shareView?.configureShareViews(webShareType: webShareType)
        UIApplication.shared.keyWindow?.addSubview(backgroundView)
        UIView.animate(withDuration: 0.25) {
            self.shareView?.transform = CGAffineTransform(translationX: 0.0, y: -self.shareViewHeight)
        }
    }
    
    private func removeCustomShareViews() {
        UIView.animate(withDuration: 0.25, animations: {
            self.shareView?.transform = CGAffineTransform.identity
        }) { (_) in
            self.backgroundView.removeFromSuperview()
        }
    }
    
    private func saveImage() {
        if let image = shareCoverImage {
            XDPopView.loading()
            UIImageWriteToSavedPhotosAlbum(image, self, #selector(XDShareView.image(_:didFinisheSavingWithError:contextInfo:)), nil)
        }
    }
}

// MARK: ShareViewDelegate
extension XDShareView: ShareViewDelegate {
    func shareViewCancel() {
        removeCustomShareViews()
    }
    
    func shareView(shareIndex: Int) {
        var shareTitle = ""
        var shareText = ""
        if let title = (shareInfo?["title"] as? String)?.removingPercentEncoding {
            shareTitle = title
        }
        if let description = (shareInfo?["description"] as? String)?.removingPercentEncoding {
            shareText = description
        }
        let shareCoverURL = shareInfo?["coverUrl"] as? String
        let messageObject: UMSocialMessageObject = UMSocialMessageObject()
        let shareObject: UMShareImageObject = UMShareImageObject()
        if let shareImage = shareCoverImage {
            shareObject.shareImage = shareImage
            messageObject.text = shareTitle + shareURL.removingPercentEncoding!
            messageObject.shareObject = shareObject
        } else {
            var shareWebPageObject: UMShareWebpageObject = UMShareWebpageObject()
            if let coverURL = shareCoverURL, !coverURL.trimmingCharacters(in: CharacterSet.whitespaces).isEmpty {
                shareWebPageObject = UMShareWebpageObject.shareObject(withTitle: shareTitle, descr: shareText, thumImage: coverURL)
            } else {
                shareWebPageObject = UMShareWebpageObject.shareObject(withTitle: shareTitle, descr: shareText, thumImage: UIImage(named: "app_logo")!)
            }
            shareWebPageObject.webpageUrl = shareURL.removingPercentEncoding
            messageObject.shareObject = shareWebPageObject
        }
        if let shareType = ShareType(rawValue: shareIndex) {
            switch shareType {
            case .localSave:
                saveImage()
                return
            case .qrCode:
                if !qrCodeResult.isEmpty, let url = URL(string: qrCodeResult) {
                    UIApplication.shared.openURL(url)
                }
                return
            case .copyLink:
                UIPasteboard.general.string = shareURL
                XDPopView.toast("链接复制成功")
                return
            case .openInSafari:
                if !shareURL.isEmpty, let encodeStr = shareURL.removingPercentEncoding?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed), let url = URL(string: encodeStr) {
                    UIApplication.shared.openURL(url)
                }
                return
            case .sina:
                var shareIcon: Any? = UIImage(named: "app_logo")
                if let image = shareCoverImage {
                    shareIcon = image
                } else {
                    if let coverUrl = shareCoverURL, !coverUrl.trimmingCharacters(in: CharacterSet.whitespaces).isEmpty {
                        shareIcon = coverUrl
                    }
                }
                shareObject.shareImage = shareIcon
                messageObject.text = shareTitle + shareURL.removingPercentEncoding!
                messageObject.shareObject = shareObject
            default:
                break
            }
            UMSocialManager.default().share(to: shareType.umplatfromTypes, messageObject: messageObject, currentViewController: nil) { (result, error) in
                if let error = error as NSError? {
                    var alertString: String = "share_failure".localized
                    if error.code == 2009 {
                        alertString = "分享取消"
                    }
                    XDPopView.toast(alertString)
                } else {
                    XDPopView.toast("share_success".localized)
                }
            }
        }
    }
}

@objc protocol ShareViewDelegate {
    func shareViewCancel()
    func shareView(shareIndex: Int)
}

/// 友盟分享自定义视图
class ShareView: UIView {
    
    weak var delegate: ShareViewDelegate?
    var shareTypes: [UMSocialPlatformType]
    private var kViewTag: Int = 1000
    private lazy var topScrollView: UIScrollView = {
        let scrollView: UIScrollView = UIScrollView(frame: CGRect.zero)
        scrollView.showsHorizontalScrollIndicator = false
        return scrollView
    }()
    private lazy var bottomScrollView: UIScrollView = {
        let scrollView: UIScrollView = UIScrollView(frame: CGRect.zero)
        scrollView.showsHorizontalScrollIndicator = false
        return scrollView
    }()
    private lazy var stateLabel: UILabel = {
        let label: UILabel = UILabel(frame: CGRect.zero)
        label.text = "网页由 xxd.smartstudy.com 提供"
        label.textColor = UIColor(0x949BA1)
        label.font = UIFont.systemFont(ofSize: 12.0)
        return label
    }()
    private lazy var separatorView: UIView = UIView(frame: CGRect.zero, color: UIColor(0xC4C9CC))
    private lazy var cancelBtn: UIButton =  {
        let button = UIButton(frame: CGRect.zero)
        button.setTitle("取消", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18.0)
        button.setTitleColor(UIColor(0x263540), for: .normal)
        button.backgroundColor = UIColor.white
        button.tag = kViewTag - 1
        button.addTarget(self, action: #selector(ShareView.eventButtonResponse(_:)), for: .touchUpInside)
        return button
    }()
    
    init(frame: CGRect, shareTypes: [UMSocialPlatformType]) {
        self.shareTypes = shareTypes
        super.init(frame: frame)
        initContentViews()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func eventButtonResponse(_ sender: UIButton) {
        let index: Int = sender.tag - kViewTag
        if index == -1 {
            guard let _ = delegate?.shareViewCancel() else { return }
        } else {
            guard let _ = delegate?.shareView(shareIndex: index) else { return }
        }
    }
    
    func configureShareViews(webShareType: [ShareType]) {
        if shareTypes.count > 0 {
            configureWebShareViews(in: bottomScrollView, webShareTypes: webShareType)
        } else {
            configureWebShareViews(in: topScrollView, webShareTypes: webShareType)
        }
    }
    
    private func configureWebShareViews(in superView: UIView, webShareTypes: [ShareType]) {
        superView.removeAllSubviews()
        for (index, type) in webShareTypes.enumerated() {
            let button: UIButton = UIButton(frame: CGRect(x: 20.0+(64.0+20.0)*CGFloat(index), y: 0.0, width: 64.0, height: 64.0))
            button.addTarget(self, action: #selector(ShareView.eventButtonResponse(_:)), for: .touchUpInside)
            let shareLabel: UILabel = UILabel(frame: CGRect.zero)
            shareLabel.numberOfLines = 0
            shareLabel.textAlignment = .center
            shareLabel.font = UIFont.systemFont(ofSize: 11.0)
            shareLabel.textColor = UIColor(0x58646E)
            switch type {
            case .localSave:
                button.setImage(UIImage(named: "share_download"), for: .normal)
                button.tag = kViewTag + 5
                shareLabel.text = "保存至本地"
            case .qrCode:
                button.setImage(UIImage(named: "share_qrcode"), for: .normal)
                button.tag = kViewTag + 6
                shareLabel.text = "识别二维码"
            case .copyLink:
                button.setImage(UIImage(named: "share_copylink"), for: .normal)
                button.tag = kViewTag + 7
                shareLabel.text = "复制链接"
            case .openInSafari:
                button.setImage(UIImage(named: "share_browser"), for: .normal)
                button.tag = kViewTag + 8
                shareLabel.text = "在浏览器中打开"
            default: break
            }
            superView.addSubview(button)
            superView.addSubview(shareLabel)
            shareLabel.snp.makeConstraints { (make) in
                make.top.equalTo(button.snp.bottom).offset(7.0)
                make.left.right.equalTo(button)
            }
        }
    }
    
    private func initContentViews() {
        backgroundColor = UIColor(white: 1.0, alpha: 0.8)
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.light)
        let blurView = UIVisualEffectView(frame: self.bounds)
        blurView.effect = blurEffect
        insertSubview(blurView, at: 0)
        addSubview(stateLabel)
        stateLabel.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(12.0)
            make.centerX.equalToSuperview()
            make.height.equalTo(17.0)
        }
        addSubview(topScrollView)
        topScrollView.snp.makeConstraints { (make) in
            make.top.equalTo(stateLabel.snp.bottom).offset(16.0)
            make.left.right.equalToSuperview()
            make.height.equalTo(116.0)
        }
        addSubview(cancelBtn)
        cancelBtn.snp.makeConstraints { (make) in
            make.left.bottom.right.equalToSuperview()
            make.height.equalTo(49.0)
        }
        if shareTypes.count > 0 {
            topScrollView.contentSize = CGSize(width: 20.0+(64.0+20.0)*CGFloat(shareTypes.count), height: 0.0)
            addSubview(separatorView)
            addSubview(bottomScrollView)
            separatorView.snp.makeConstraints { (make) in
                make.top.equalTo(topScrollView.snp.bottom)
                make.left.equalToSuperview().offset(20.0)
                make.right.equalToSuperview().offset(-20.0)
                make.height.equalTo(XDSize.unitWidth)
            }
            bottomScrollView.snp.makeConstraints { (make) in
                make.top.equalTo(separatorView.snp.bottom).offset(14.0)
                make.left.right.equalToSuperview()
                make.height.equalTo(116.0)
            }
            for (index, type) in shareTypes.enumerated() {
                let button: UIButton = UIButton(frame: CGRect(x: 20.0+(64.0+20.0)*CGFloat(index), y: 0.0, width: 64.0, height: 64.0))
                button.addTarget(self, action: #selector(ShareView.eventButtonResponse(_:)), for: .touchUpInside)
                let shareLabel: UILabel = UILabel(frame: CGRect.zero)
                shareLabel.numberOfLines = 0
                shareLabel.textAlignment = .center
                shareLabel.font = UIFont.systemFont(ofSize: 11.0)
                shareLabel.textColor = UIColor(0x58646E)
                switch type {
                case .wechatSession:
                    button.setImage(UIImage(named: "share_wx"), for: .normal)
                    button.tag = kViewTag
                    shareLabel.text = "分享给微信好友"
                    break
                case .wechatTimeLine:
                    button.setImage(UIImage(named: "share_wx_timeline"), for: .normal)
                    button.tag = kViewTag + 1
                    shareLabel.text = "分享到微信朋友圈"
                case .QQ:
                    button.setImage(UIImage(named: "share_qq"), for: .normal)
                    button.tag = kViewTag + 2
                    shareLabel.text = "分享到QQ"
                case .qzone:
                    button.setImage(UIImage(named: "share_qzone"), for: .normal)
                    button.tag = kViewTag + 3
                    shareLabel.text = "分享到QQ空间"
                default:
                    button.setImage(UIImage(named: "share_wb"), for: .normal)
                    button.tag = kViewTag + 4
                    shareLabel.text = "分享到微博"
                }
                topScrollView.addSubview(button)
                topScrollView.addSubview(shareLabel)
                shareLabel.snp.makeConstraints { (make) in
                    make.top.equalTo(button.snp.bottom).offset(7.0)
                    make.left.right.equalTo(button)
                }
            }
        }
    }
    
}
