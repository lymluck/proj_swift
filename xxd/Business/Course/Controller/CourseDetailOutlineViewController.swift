//
//  CourseDetailOutlineViewController.swift
//  xxd
//
//  Created by remy on 2018/1/19.
//  Copyright © 2018年 com.smartstudy. All rights reserved.
//

import ZKUIKit

private let kSectionHeight: CGFloat = 56

class CourseDetailOutlineViewController: SSTableViewController, CourseOutlineSectionViewDelegate {
    
    var courseID = 0
    private var fectchPlayURLTask: URLSessionDataTask?
    private var timer: Timer?
    private var needRefresh = false
    private var canScrollContentOffset = false
    private weak var videoViewController: XDVideoViewController?
    private var beginPlayDate = Date()
    private var sectionHeightList = [CGFloat]()
    private var sectionItems = [CourseOutlineSectionItem]()
    private var selectedSectionItem: CourseOutlineSectionItem?
    
    override func needNavigationBar() -> Bool {
        return false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reloadIfNeeded()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.showsVerticalScrollIndicator = false
        tableView.register(CourseOutlineSectionView.self, forHeaderFooterViewReuseIdentifier: CourseOutlineSectionView.metaTypeName)
//        tableViewActions.tableViewCellSelectionStyle = .none
        tableViewActions.attach(to: CourseOutlineItem.self, tap: {
            [unowned self] (object, target, indexPath) -> Bool in
            self.fetchPlayURLString(object as! CourseOutlineItem)
            return true
        })
        NotificationCenter.default.addObserver(self, selector: #selector(userHasLogin(notification:)), name: .XD_NOTIFY_SIGN_IN, object: nil)
    }
    
    deinit {
        fectchPlayURLTask?.cancel()
        invalidate()
    }
    
    override func shouldReload() -> Bool {
        return super.shouldReload() || needRefresh
    }
    
    override func createModel() {
        let urlStr = String(format: XD_API_COURSE_OUTLINE, courseID)
        model = SSURLReqeustModel(httpMethod: .get, urlString: urlStr, loadFromFile: false, isPaged: false)
    }
    
    // 获取播放的URL
    private func fetchPlayURLString(_ item: CourseOutlineItem) {
        XDPopView.loading()
        fectchPlayURLTask?.cancel()
        let params = ["productId":courseID,"sectionId":item.model.ID]
        fectchPlayURLTask = SSNetworkManager.shared().get(XD_API_FETCH_COURSE_PLAY_URL, parameters: params, success: {
            [weak self] (task, responseObject) in
            if let strongSelf = self, let dict = (responseObject as? [String : Any])!["data"] as? [String : Any] {
                if let urlStr = dict["hd"] as? String {
                    strongSelf.playVideo(urlStr: urlStr, beginTime: item.model.lastPlayTime * 0.001, item: item)
                    XDPopView.hide()
                } else {
                    XDPopView.toast("暂时无法播放")
                }
            } else {
                XDPopView.hide()
            }
        }) { (task, error) in
            if (error as NSError).code != NSURLErrorCancelled {
                XDPopView.toast(error.localizedDescription)
            }
        }
    }
    
    // 播放某个视频,beginTime单位为秒
    private func playVideo(urlStr: String, beginTime: Double, item: CourseOutlineItem) {
        if isViewAppearing {
            let videoVC = XDVideoViewController(beginTime: beginTime, from: .zero, customPresentAnimation: false)
            videoVC.videoView.source = urlStr
            videoViewController = videoVC
            videoVC.onDismiss = {
                [weak self] (playbackInfo) in
                if let strongSelf = self {
                    if XDUser.shared.hasLogin() {
                        // 对于已经登录的用户,需要上传观看时间点
                        var currentTime = (playbackInfo["currentTime"] as! Double) * 1000
                        currentTime = min(max(currentTime, 0), item.model.duration)
                        strongSelf.uploadPlay(duration: currentTime, item: item)
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: XD_NOTIFY_HAS_WATCH_VIDEO), object: nil, userInfo: [QueryKey.CourseID: strongSelf.courseID, "classID": item.model.ID, "currentTime": currentTime])
                    }
                    strongSelf.invalidate()
                    strongSelf.removePlaystateObserver()
                }
            }
            addPlaystateObserver()
            present(videoVC, animated: true, completion: {
                [weak self] in
                self?.beginPlayDate = Date()
                videoVC.videoView.playerState = .playing
            })
        }
    }
    
    // 上传播放时间未知,单位毫秒
    private func uploadPlay(duration: Double, item: CourseOutlineItem) {
        let playDuration = Int(Date().timeIntervalSince(beginPlayDate) * 1000)
        let params = ["productId": courseID, "sectionId": item.model.ID, "playTime": duration, "playDuration": playDuration] as [String : Any]
        SSNetworkManager.shared().put(XD_API_FETCH_COURSE_PLAY_URL, parameters: params, success: {
            [weak self] (task, responseObject) in
            self?.tryToEvaluate()
        }) { (task, error) in
        }
    }
    
    private func addPlaystateObserver() {
        videoViewController?.videoView.addObserver(self, forKeyPath: "playerState", options: .new, context: nil)
    }
    
    private func removePlaystateObserver() {
        videoViewController?.videoView.removeObserver(self, forKeyPath: "playerState")
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "playerState" {
            if let playerState = PlayerState(rawValue: change![.newKey] as! UInt) {
                switch playerState {
                case .playing where !XDUser.shared.hasLogin():
                    startCheckTimer()
                case .complete:
                    videoViewController?.dismiss(animated: true, completion: nil)
                default:
                    break
                }
            }
        }
    }
    
    private func startCheckTimer() {
        invalidate()
        timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(checkCurrentTime), userInfo: nil, repeats: true)
        timer?.fire()
    }
    
    @objc private func checkCurrentTime() {
        if let videoViewController = videoViewController {
            let currentTime = videoViewController.videoView.currentTime
            if currentTime > 30 {
                // 试看内容超过30秒范围外
                invalidate()
                guard !(UIApplication.topVC() is SignInViewController) else { return }
                videoViewController.videoView.playerState = .paused
                let vc = SignInViewController()
                vc.dismissedHandler = {
                    [weak self] (loginSuccess) in
                    if let strongSelf = self {
                        if loginSuccess {
                            videoViewController.videoView.playerState = .playing
                        } else {
                            videoViewController.videoView.playerState = .paused
                            strongSelf.invalidate()
                        }
                    }
                }
                XDRoute.presentToVC(vc)
            }
        } else {
            invalidate()
        }
    }
    
    private func invalidate() {
        timer?.invalidate()
        timer = nil
    }
    
    override func didFinishLoad(with object: Any!) {
        needRefresh = false
        if let data = (object as! [String : Any])["data"] {
            if let sectionModels = NSArray.yy_modelArray(with: CourseOutlineSectionModel.self, json: data) as? [CourseOutlineSectionModel] {
                var sections = [NITableViewModelSection]()
                sectionItems = [CourseOutlineSectionItem]()
                sectionHeightList = [CGFloat]()
                let isUserInteractionEnabled = sectionModels.count > 1
                for (index, sectionModel) in sectionModels.enumerated() {
                    var height = kSectionHeight
                    let sectionItem = CourseOutlineSectionItem()
                    sectionItem.index = index
                    sectionItem.title = sectionModel.name
                    sectionItem.isUserInteractionEnabled = isUserInteractionEnabled
                    var items = [CourseOutlineItem]()
                    for (index, model) in sectionModel.subModels.enumerated() {
                        let item = CourseOutlineItem()!
                        item.model = model
                        item.index = index
                        items.append(item)
                        height += item.model.chapterName.isEmpty ? 48 : 96
                    }
                    sectionItem.realCellItems = items
                    sectionItem.isSelected = index == 0
                    sectionItems.append(sectionItem)
                    sectionHeightList.append(height)
                    let section = NITableViewModelSection()
                    section.rows = sectionItem.cellItems
                    sections.append(section)
                }
                selectedSectionItem = sectionItems.first
                tableViewModel.sections = NSMutableArray(array: sections)
            }
        }
    }
    
    private func tryToEvaluate() {
        // 判断今天是否已经弹过窗,没有则弹窗
        let date = UserDefaults.standard.value(forKey: "kLastCourseEvaluationPopTime") as? NSDate
        var isToday = date?.isToday ?? false
        #if TEST_MODE
            let switchOn = UserDefaults.standard.bool(forKey: "kEvaluateAfterWatchingKey")
            if switchOn {
                isToday = false
            }
        #endif
        // 如果上次弹窗不是今天,则弹窗
        if !isToday {
            var parentVC = self as UIViewController
            while true {
                if let vc = parentVC.parent {
                    if let vc = vc as? CourseDetailViewController {
                        vc.tryPopCommentBoard()
                        break
                    }
                    parentVC = vc
                }
            }
            UserDefaults.standard.set(Date(), forKey: "kLastCourseEvaluationPopTime")
        }
    }
    
    //MARK:- Notification
    @objc func userHasLogin(notification: Notification) {
        needRefresh = true
    }
    
    //MARK:- UITableviewDelegate
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return kSectionHeight
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: CourseOutlineSectionView.metaTypeName) as! CourseOutlineSectionView
        view.item = sectionItems[section]
        view.delegate = self
        return view
    }
    
    //MARK:- UIScrollViewDelegate
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        canScrollContentOffset = false
    }
    
    //MARK:- CourseOutlineSectionViewDelegate
    func courseOutlineSectionViewDidPress(item: CourseOutlineSectionItem) {
        let currentSection = tableViewModel.sections[item.index] as! NITableViewModelSection
        currentSection.rows = item.cellItems
        let indexSet: IndexSet = [item.index]
        tableView.reloadSections(indexSet, with: .none)
        selectedSectionItem = item.isSelected ? item : nil
        var top: CGFloat = 0
        for i in 0..<item.index {
            top += sectionItems[i].isSelected ? sectionHeightList[i] : kSectionHeight
        }
        canScrollContentOffset = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            [weak self] in
            if let strongSelf = self, strongSelf.canScrollContentOffset {
                if let _ = strongSelf.selectedSectionItem {
                    strongSelf.tableView.setContentOffset(CGPoint(x: 0, y: top), animated: true)
                } else {
                    if top < strongSelf.tableView.contentOffset.y {
                        strongSelf.tableView.setContentOffset(CGPoint(x: 0, y: top), animated: true)
                    }
                }
            }
        }
    }
}
