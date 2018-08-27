//
//  ColumnDetailViewController.swift
//  xxd
//
//  Created by Lisen on 2018/7/17.
//  Copyright © 2018年 com.smartstudy. All rights reserved.
//

import UIKit
import WebKit
import SSPhotoBrowser
import SwiftyJSON

/// 距离顶部开始渐变的距离
private let kGradientSpace: CGFloat = 60.0
/// 专栏封面图高度
private let kCoverImageHeight: CGFloat = ceil(XDSize.screenWidth*9.0/16.0)

/// 专栏详情界面
class ColumnDetailViewController: SSViewController {
    
    var columnId: Int = 0
    var htmlString = ""
    private var isFirst: Bool = true
    private var isScrolled: Bool = false
    private var headerViewHeight: CGFloat = 0.0
    private var headerViewSpace: CGFloat = 0.0
    private var lastContentOffsetY: CGFloat = 0.0
    private var isLiked: Bool = false
    private var likeCounts: Int = 0
    private var isCollected: Bool = false
    private var imageParams: [String: String] = [String: String]()
    private lazy var backButton: UIButton = {
        let button: UIButton = UIButton(frame: CGRect(x: 0, y: XDSize.statusBarHeight, width: XDSize.topBarHeight, height: XDSize.topBarHeight), title: "", fontSize: 0, titleColor: UIColor.clear, target: self, action: #selector(eventBackbuttonResponse(_:)))
        button.setImage(UIImage(named: "top_left_arrow")?.tint(UIColor.white), for: .normal)
        return button
    }()
    private lazy var topBarView: ColumnDetailTopBarView = {
        let view: ColumnDetailTopBarView = ColumnDetailTopBarView(frame: CGRect(x: 0.0, y: 0.0, width: XDSize.screenWidth, height: XDSize.topHeight))
        view.alpha = 0.0
        return view
    }()
    private lazy var coverImageView: UIImageView = {
        let imageView: UIImageView = UIImageView(frame: CGRect.zero)
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    private lazy var titleLabel: UILabel = {
        let label: UILabel = UILabel(frame: CGRect.zero, text: "", textColor: XDColor.itemTitle, fontSize: 25.0, bold: true)
        label.numberOfLines = 0
        return label
    }()
    private lazy var userInfoView: ColumnHeaderUserInfoView = ColumnHeaderUserInfoView(frame: CGRect.zero)
    private lazy var userContentController: WKUserContentController = WKUserContentController()
    private lazy var columnView: WKWebView = {
        let webView: WKWebView = WKWebView(frame: CGRect.zero)
        webView.scrollView.isScrollEnabled = false
        webView.navigationDelegate = self
        return webView
    }()
    private lazy var backScrollView: UIScrollView = {
        let scrollView: UIScrollView = UIScrollView(frame: CGRect(x: 0.0, y: 0.0, width: XDSize.screenWidth, height: XDSize.screenHeight))
        scrollView.backgroundColor = UIColor.white
        scrollView.delegate = self
        return scrollView
    }()
    private lazy var tabbarView: ColumnTabBarView = {
        let view: ColumnTabBarView = ColumnTabBarView(frame: CGRect(x: 0.0, y: XDSize.screenHeight-XDSize.tabbarHeight, width: XDSize.screenWidth, height: XDSize.tabbarHeight))
        view.delegate = self
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 11, *) {
            backScrollView.contentInsetAdjustmentBehavior = .never
        } else {
            automaticallyAdjustsScrollViewInsets = false
        }
        requestColumnContent()
        backScrollView.addSubview(coverImageView)
        backScrollView.addSubview(titleLabel)
        backScrollView.addSubview(userInfoView)
        backScrollView.addSubview(columnView)
        view.addSubview(backScrollView)
        view.addSubview(backButton)
        view.addSubview(topBarView)
        view.addSubview(tabbarView)
    }
    
    override func needNavigationBar() -> Bool {
         return false
    }
    
    @objc private func eventBackbuttonResponse(_ sender: UIButton) {
        backActionTap()
    }
    
    private func requestColumnContent() {
        let urlString = String(format: XD_COLUMN_DETAIL, columnId)
        SSNetworkManager.shared().get(urlString, parameters: nil, success: { [weak self] (dataTask, responseObject) in
            if let responseData = (responseObject as! [String: Any])["data"] as? [String: Any], let strongSelf = self {
                if let columnModel: ColumnDetailModel = ColumnDetailModel.yy_model(with: responseData) {
                    strongSelf.configureColumnView(model: columnModel)
                }
            }
        }) { (dataTask, error) in
            XDPopView.toast(error.localizedDescription, self.view)
        }
    }
    
    private func configureColumnView(model: ColumnDetailModel) {
        let titleHeight: CGFloat = ceil(model.columnTitle.heightForFont(UIFont.boldSystemFont(ofSize: 25.0), XDSize.screenWidth-40.0, 35.0))
        headerViewSpace = titleHeight+24.0+16.0+19.0+32.0
        headerViewHeight = headerViewSpace+kCoverImageHeight
        coverImageView.frame = CGRect(x: 0.0, y: 0.0, width: XDSize.screenWidth, height: kCoverImageHeight)
        titleLabel.frame = CGRect(x: 20.0, y: kCoverImageHeight+24.0, width: XDSize.screenWidth-40.0, height: titleHeight)
        userInfoView.frame = CGRect(x: 0.0, y: titleLabel.bottom+16.0, width: XDSize.screenWidth, height: 18.0)
        columnView.frame = CGRect(x: 0.0, y: userInfoView.bottom+32.0, width: XDSize.screenWidth, height: 0.0)
        topBarView.avatarURL = model.authorAvatar
        topBarView.name = model.authorName
        topBarView.time = model.publishTime
        coverImageView.kf.setImage(with: URL(string: model.coverUrl), placeholder: UIImage(named: "default_placeholder"))
        titleLabel.setText(model.columnTitle, lineHeight: 35.0)
        userInfoView.avatarURL = model.authorAvatar
        userInfoView.name = model.authorName
        userInfoView.time = model.publishTime + "  " + "\(model.visitCount)" + " 浏览"
        htmlString = model.columnContent
        columnView.loadHTMLString(htmlString, baseURL: nil)
        likeCounts = model.likedCount
        isLiked = model.isLiked
        isCollected = model.isCollected
        tabbarView.likeView.title = "赞 \(likeCounts)"
        tabbarView.likeView.isSelected = isLiked
        tabbarView.collectView.isSelected = isCollected
        tabbarView.commentCounts = model.commentsCount
    }
    
    private func navigateWebImage() {
        if let page = imageParams["page"] {
            if page == "preview_img", let imgUrl = imageParams["imgUrl"]?.removingPercentEncoding, let imgArrStr = imageParams["imgArr"]?.removingPercentEncoding {
                let imgArr = JSON(parseJSON: imgArrStr).arrayObject as! [String]
                if let imageBrowser = SSPhotoBrowser(photoURLs: imgArr) {
                    imageBrowser.displayToolbar = false
                    imageBrowser.displayDoneButton = false
                    imageBrowser.dismissOnTouch = true
                    imageBrowser.displayActionButton = false
                    imageBrowser.forceHideStatusBar = true
                    imageBrowser.longPressedAction = {
                        image in
                        guard let aImage = image else { return }
                        let params = [
                            "title": "",
                            "description": "",
                            "coverUrl": imgUrl
                        ]
                        XDShareView.shared.showSharePanel(shareURL: imgUrl, shareInfo: params, coverImage: aImage)
                    }
                    for (index, str) in imgArr.enumerated() {
                        if imgUrl == str {
                            imageBrowser.currentPageIndex = UInt(index)
                            break
                        }
                    }
                    present(imageBrowser, animated: true, completion: nil)
                }
            }
        }
    }
    
}

// MARK: ColumnTabBarViewDelegate
extension ColumnDetailViewController: ColumnTabBarViewDelegate {
    func columnTabBarViewDidSelect(index: Int) {
        if index == 0 {
            if XDUser.shared.hasLogin() {
                let urlString = String(format: XD_API_GENERAL_LIKE, "columnNews", "\(columnId)")
                tabbarView.likeView.isUserInteractionEnabled = false
                if isLiked {
                    SSNetworkManager.shared().delete(urlString, parameters: nil, success: { [weak self](dataTask, responseObject) in
                        if let strongSelf = self {
                            strongSelf.tabbarView.likeView.isUserInteractionEnabled = true
                            strongSelf.likeCounts -= 1
                            strongSelf.isLiked = false
                            strongSelf.tabbarView.likeView.isSelected = false
                            strongSelf.tabbarView.likeView.title = "赞 \(strongSelf.likeCounts)"
                            XDPopView.toast("取消点赞", strongSelf.view)
                        }
                    }) { [weak self](dataTask, error) in
                        if let strongSelf = self {
                            strongSelf.tabbarView.likeView.isUserInteractionEnabled = true
                            XDPopView.toast(error.localizedDescription, strongSelf.view)
                        }
                    }
                } else {
                    SSNetworkManager.shared().post(urlString, parameters: nil, success: { [weak self](dataTask, responseObject) in
                        if let strongSelf = self {
                            strongSelf.tabbarView.likeView.isUserInteractionEnabled = true
                            strongSelf.likeCounts += 1
                            strongSelf.isLiked = true
                            strongSelf.tabbarView.likeView.title = "赞 \(strongSelf.likeCounts)"
                            strongSelf.tabbarView.likeView.isSelected = true
                            XDPopView.toast("点赞成功", strongSelf.view)
                        }
                    }) { [weak self](dataTask, error) in
                        if let strongSelf = self {
                            strongSelf.tabbarView.likeView.isUserInteractionEnabled = true
                            XDPopView.toast(error.localizedDescription, strongSelf.view)
                        }
                    }
                }
            } else {
                tabbarView.likeView.isSelected = false
                let signVC: SignInViewController = SignInViewController()
                present(signVC, animated: true, completion: nil)
            }
        } else if index == 1 {
            if XDUser.shared.hasLogin() {
                let urlString = String(format: XD_API_ADD_FAVORITE, "columnNews", "\(columnId)")
                tabbarView.collectView.isUserInteractionEnabled = false
                if isCollected {
                    SSNetworkManager.shared().delete(urlString, parameters: nil, success: { [weak self](dataTask, responseObject) in
                        if let strongSelf = self {
                            strongSelf.tabbarView.collectView.isUserInteractionEnabled = true
                            strongSelf.isCollected = false
                            strongSelf.tabbarView.collectView.isSelected = false
                             XDPopView.toast("取消收藏", strongSelf.view)
                        }
                    }) { [weak self](dataTask, error) in
                        if let strongSelf = self {
                            strongSelf.tabbarView.collectView.isUserInteractionEnabled = true
                            XDPopView.toast(error.localizedDescription, strongSelf.view)
                        }
                    }
                } else {
                    SSNetworkManager.shared().post(urlString, parameters: nil, success: { [weak self](dataTask, responseObject) in
                        if let strongSelf = self {
                            strongSelf.tabbarView.collectView.isUserInteractionEnabled = true
                            strongSelf.isCollected = true
                            strongSelf.tabbarView.collectView.isSelected = true
                            XDPopView.toast("收藏成功", strongSelf.view)
                        }
                    }) { [weak self](dataTask, error) in
                        if let strongSelf = self {
                            strongSelf.tabbarView.collectView.isUserInteractionEnabled = true
                            XDPopView.toast(error.localizedDescription, strongSelf.view)
                        }
                    }
                }
            } else {
                tabbarView.collectView.isSelected = false
                let signVC: SignInViewController = SignInViewController()
                present(signVC, animated: true, completion: nil)
            }
        } else if index == 2 {
            let commentVC: ColumnCommentViewController = ColumnCommentViewController()
            commentVC.columnId = columnId
            navigationController?.pushViewController(commentVC, animated: true)
        }
    }
}

// MARK: UIScrollViewDelegate
extension ColumnDetailViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        // 控制视图下拉放大
        if offsetY <= 0.0 {
            coverImageView.top = offsetY
            coverImageView.height = -offsetY+kCoverImageHeight
        }
        // 控制导航栏渐变显示
        let alphaValue = min(max(offsetY/kGradientSpace, 0.0), 1.0)
        topBarView.alpha = alphaValue
        // 控制底部tabbar的显示与消失
        if isFirst {
            isFirst = false
        } else if offsetY >= 0.0 {
            if lastContentOffsetY-offsetY >= 30.0 {
                if isScrolled {
                    UIView.animate(withDuration: 0.2) {
                        self.tabbarView.top -= XDSize.tabbarHeight
                    }
                    isScrolled = false
                }
                lastContentOffsetY = offsetY
            } else if offsetY-lastContentOffsetY >= 30.0 {
                if !isScrolled {
                    UIView.animate(withDuration: 0.2) {
                        self.tabbarView.top += XDSize.tabbarHeight
                    }
                    isScrolled = true
                }
                lastContentOffsetY = offsetY
            }
            if scrollView.contentSize.height-(offsetY+scrollView.bounds.height) <= 0.0 {
                if isScrolled {
                    UIView.animate(withDuration: 0.2) {
                        self.tabbarView.top -= XDSize.tabbarHeight
                    }
                    isScrolled = false
                }
            }
        }
    }
}

// MARK: WKNavigationDelegate
extension ColumnDetailViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if let url = navigationAction.request.url, let scheme = url.scheme {
            if scheme == "mobile" {
                if let type = url.host {
                    var query = [String: String]()
                    if let urlComponents = url.query?.components(separatedBy: "&") {
                        let _ = urlComponents.map {
                            let arr = $0.components(separatedBy: "=")
                            query[arr[0]] = arr[1]
                        }
                    }
                    if type == "navigate" {
                        imageParams = query
                        navigateWebImage()
                    }
                }
            }
            decisionHandler(.allow)
        }
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        webView.evaluateJavaScript("document.body.offsetHeight") { (result, error) in
            if let webViewHeight = result as? CGFloat {
                self.columnView.height = webViewHeight
                self.backScrollView.contentSize.height = self.columnView.bottom
            }
        }
    }
}
