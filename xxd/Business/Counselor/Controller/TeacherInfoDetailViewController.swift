//
//  TeacherInfoDetailViewController.swift
//  xxd
//
//  Created by chenyusen on 2018/3/9.
//  Copyright © 2018年 com.smartstudy. All rights reserved.
//

import UIKit
import SwiftyJSON
import Lottie
import PFVideoPlayer

@objc protocol HeaderViewDelegate {
    func headerViewDidTapLikeImage(likeCount: Int)
}

/// 封面高度
private let headerVideoViewHeight = (XDSize.screenWidth / 375 * 211).rounded()

/// 问答详情中查看教师主页的头部视图
fileprivate class HeaderView: UIView {
    
    weak var delegate: HeaderViewDelegate?
    var likeCount: Int = 0 {
        didSet { 
            likeCountLabel.text = "\(likeCount)"
            if likeCount == 0 {
                likeViewBackgroundView.snp.updateConstraints { (make) in
                    make.width.equalTo(60.0)
                }
            } else {
                likeCountLabel.sizeToFit()
                let labelWidth: CGFloat = likeCountLabel.width+50.0+6.0
                likeViewBackgroundView.snp.updateConstraints { (make) in
                    make.width.equalTo(labelWidth)
                }
            }
        }
    }
    
    lazy var playerView: PFVideoPlayer = {
        let view = PFVideoPlayer(frame: CGRect(x: 0, y: 0, width: XDSize.screenWidth, height: headerVideoViewHeight))
        view.isFullScreenClick = true
        view.overlayView.controlsHidden = true
        view.delegate = self
        return view
    }()
    
    private lazy var videoView: UIImageView = {
        let view = UIImageView(frame: CGRect(x: 0, y: 0, width: XDSize.screenWidth, height: headerVideoViewHeight))
        view.contentMode = .scaleAspectFill
        view.isUserInteractionEnabled = true
        view.layer.masksToBounds = true
        // 背景模糊
        let blurEffect = UIBlurEffect(style: .light)
        let effectView = UIVisualEffectView(effect: blurEffect)
        effectView.frame = view.bounds
        view.addSubview(effectView)
        return view
    }()
    private lazy var animationView: LOTAnimationView = {
        let animationView: LOTAnimationView = LOTAnimationView(name: "likeAnimation")
        let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(HeaderView.eventLikeImageResponse(_:)))
        animationView.addGestureRecognizer(tapGesture)
        return animationView
    }()
    private lazy var likeViewBackgroundView: UIView = {
        let view: UIView = UIView(frame: CGRect.zero, color: UIColor(white: 0.0, alpha: 0.7))
        view.layer.cornerRadius = 16.0
        return view
    }()
    private lazy var likeCountLabel: UILabel = UILabel(frame: CGRect.zero, text: "0", textColor: UIColor.white, fontSize: 11.0)
    private var avatarView: UIImageView!
    private var nameLabel: UILabel!
    private var titleLabel: UILabel!
    private var workYearLabel: UILabel!
    // 记录用户在1秒间隔内点击的次数
    private var tapCount: Int = 0
    private var firstTapTime: CFAbsoluteTime?
    private var isFirstTap: Bool = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
        
        // 视频的图片背景
        addSubview(videoView)
        // 视频
        addSubview(playerView)
        // 点赞
        self.addSubview(likeViewBackgroundView)
        likeViewBackgroundView.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(16.0)
            make.width.equalTo(60.0)
            make.height.equalTo(32.0)
            make.bottom.equalTo(videoView).offset(-8.0)
        }
        likeViewBackgroundView.addSubview(animationView)
        animationView.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview().offset(-2.0)
            make.left.equalToSuperview()
            make.width.height.equalTo(40.0)
        }
        likeViewBackgroundView.addSubview(likeCountLabel)
        likeCountLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(34.0)
            make.centerY.equalToSuperview()
        }
        // 头像
        let logoWrap = UIView(frame: .zero, color: UIColor.white)
        logoWrap.layer.cornerRadius = 47
        addSubview(logoWrap)
        logoWrap.snp.makeConstraints { (make) in
            make.centerY.equalTo(videoView.snp.bottom)
            make.centerX.equalToSuperview()
            make.size.equalTo(CGSize(width: 94, height: 94))
        }
        avatarView = UIImageView(frame: CGRect(x: 2, y: 2, width: 90, height: 90))
        avatarView.layer.cornerRadius = 45
        avatarView.layer.masksToBounds = true
        logoWrap.addSubview(avatarView)
        // 名字
        nameLabel = UILabel()
        nameLabel.textColor = UIColor(0x26343F)
        nameLabel.font = UIFont.systemFont(ofSize: 20)
        addSubview(nameLabel)
        nameLabel.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.top.equalTo(avatarView.snp.bottom).offset(16.0)
            make.width.lessThanOrEqualTo(XDSize.screenWidth - 100)
        }
        let tagContainer = UIView()
        addSubview(tagContainer)
        tagContainer.snp.makeConstraints { (make) in
            make.bottom.equalTo(-20.0) //(-37)
            make.centerX.equalToSuperview()
        }
        // 头衔
        titleLabel = UILabel()
        titleLabel.textColor = .white
        titleLabel.layer.cornerRadius = 9
        titleLabel.clipsToBounds = true
        titleLabel.font = UIFont.systemFont(ofSize: 11)
        titleLabel.backgroundColor = UIColor(0x77C4FF)
        tagContainer.addSubview(titleLabel)
        titleLabel.snp.makeConstraints({ (make) in
            make.left.top.bottom.equalToSuperview()
            make.height.equalTo(18)
            make.width.lessThanOrEqualTo(150)
        })
        // 工作年限
        workYearLabel = UILabel()
        workYearLabel.textColor = .white
        workYearLabel.layer.cornerRadius = 9
        workYearLabel.clipsToBounds = true
        workYearLabel.font = UIFont.systemFont(ofSize: 11)
        workYearLabel.backgroundColor = UIColor(0xA5D7AC)
        tagContainer.addSubview(workYearLabel)
        workYearLabel.snp.makeConstraints({ (make) in
            make.right.top.bottom.equalToSuperview()
            make.left.equalTo(titleLabel.snp.right).offset(4)
            make.height.equalTo(18)
            make.width.lessThanOrEqualTo(150)
        })
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func bind(info: TeacherInfo) {
        videoView.kf.setImage(with: URL(string: info.avatar ?? ""))
        nameLabel.text = info.name
        avatarView.kf.setImage(with: URL(string: info.avatar ?? ""))
        titleLabel.text = "   " + info.title! + "   "
        workYearLabel.text = "   从业" + info.workYear! + "年   "
        // 有视频则播放,否则显示图片
        if let video = info.video, !video.isEmpty {
            playerView.assetURL = URL(string: video)
            playerView.isHidden = false
            videoView.isHidden = true
            playerView.isSuperControllerExist = true
        } else {
            playerView.assetURL = nil
            playerView.isHidden = true
            videoView.isHidden = false
            playerView.isSuperControllerExist = false
        }
    }
    
    @objc func eventLikeImageResponse(_ gesture: UITapGestureRecognizer) {
        animationView.play()
        // 点赞每隔一分钟提交一次
        let current: CFAbsoluteTime = CFAbsoluteTimeGetCurrent()
        if let firstTime = firstTapTime {
            isFirstTap = false
            if current - firstTime <= 60.0 {
                tapCount += 1
            } else {
                guard let _ = self.delegate?.headerViewDidTapLikeImage(likeCount: self.tapCount) else { return }
                firstTapTime = current
                tapCount = 1
            }
        } else {
            // 第一次的情况
            firstTapTime = current
            isFirstTap = true
            tapCount = 1
            if self.isFirstTap {
                guard let _ = self.delegate?.headerViewDidTapLikeImage(likeCount: self.tapCount) else { return }
                self.tapCount = 0
            }
        }
    }
}

extension HeaderView: PFVideoPlayerDelegate {
    func fullScreenResponse(view: PFVideoPlayer, isFullScreen: Bool) {
        view.isFullScreenClick = !isFullScreen
        if !isFullScreen {
            view.overlayView.controlsHidden = true
            self.insertSubview(view, at: 0)
        }
    }
}

fileprivate class CellView: UIView {
    private var titleLabel: UILabel!
    
    init(frame: CGRect, title: String?) {
        super.init(frame: frame)
        backgroundColor = .white
        titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.textColor = UIColor(0x26343F)
        titleLabel.font = UIFont.boldSystemFont(ofSize: 16)
        addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (make) in
            make.left.equalTo(16)
            make.top.equalTo(20)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

fileprivate class SchoolView: CellView {
    var schoolNameLabel: UILabel!
    var certifiedView: UIImageView!
    var certifiedTitleLabel: UILabel!
    
    override init(frame: CGRect, title: String?) {
        super.init(frame: frame, title: title)
        
        let certifiedContainer = UIView()
        addSubview(certifiedContainer)
        certifiedContainer.snp.makeConstraints { (make) in
            make.right.equalTo(-16)
            make.centerY.equalToSuperview()
        }
        
        certifiedView = UIImageView()
        certifiedView.highlightedImage = UIImage(named: "company_certified_icon")
        certifiedView.image = UIImage(named: "company_uncertified_icon")
        certifiedContainer.addSubview(certifiedView)
        certifiedView.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview()
        }
        
        certifiedTitleLabel = UILabel()
        certifiedTitleLabel.textColor = UIColor(0x949BA1).withAlphaComponent(0.7)
        certifiedTitleLabel.font = UIFont.systemFont(ofSize: 12)
        certifiedContainer.addSubview(certifiedTitleLabel)
        certifiedTitleLabel.snp.makeConstraints { (make) in
            make.bottom.left.right.equalToSuperview()
            make.top.equalTo(certifiedView.snp.bottom).offset(6)
        }
        
        schoolNameLabel = UILabel()
        schoolNameLabel.textColor = UIColor(0x949BA1)
        schoolNameLabel.font = UIFont.systemFont(ofSize: 14)
        addSubview(schoolNameLabel)
        schoolNameLabel.snp.makeConstraints { (make) in
            make.left.equalTo(16)
            make.top.equalTo(48)
            make.right.lessThanOrEqualTo(certifiedContainer.snp.left).offset(-16)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func bind(schooName: String?, isCertified: Bool?) {
        schoolNameLabel.text = schooName
        set(certified: isCertified ?? false)
    }
    
    func set(certified: Bool) {
        if certified {
            certifiedView.isHighlighted = true
            certifiedTitleLabel.textColor = UIColor(0xFF9C08)
            certifiedTitleLabel.text = "已认证"
        } else {
            certifiedView.isHighlighted = false
            certifiedTitleLabel.textColor = UIColor(0x949BA1).withAlphaComponent(0.7)
            certifiedTitleLabel.text = "未认证"
        }
    }
}

fileprivate class CompanyView: CellView {
    var companyLogoView: UIImageView!
    var companyNameLabel: UILabel!
    var companySubTitleLabel: UILabel!
    var actionButton: UIButton!
    
    override init(frame: CGRect, title: String?) {
        super.init(frame: frame, title: title)
        
        actionButton = UIButton()
        addSubview(actionButton)
        actionButton.setBackgroundColor(UIColor.white, for: .normal)
        actionButton.setBackgroundColor(UIColor(0xF2F2F2), for: .highlighted)
        actionButton.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        insertSubview(actionButton, at: 0)
        
        companyLogoView = UIImageView()
        companyLogoView.layer.borderColor = UIColor(0xC4C9CC).cgColor
        companyLogoView.layer.borderWidth = XDSize.unitWidth
        companyLogoView.layer.cornerRadius = 20
        companyLogoView.clipsToBounds = true
        addSubview(companyLogoView)
        companyLogoView.snp.makeConstraints { (make) in
            make.left.equalTo(16)
            make.bottom.equalTo(-20)
            make.size.equalTo(CGSize(width: 40, height: 40))
        }
        
        companyNameLabel = UILabel()
        companyNameLabel.textColor = UIColor(0x26343F)
        companyNameLabel.font = UIFont.systemFont(ofSize: 14)
        addSubview(companyNameLabel)
        companyNameLabel.snp.makeConstraints { (make) in
            make.left.equalTo(68)
            make.top.equalTo(57)
        }
        
        companySubTitleLabel = UILabel()
        companySubTitleLabel.textColor = UIColor(0x949BA1)
        companySubTitleLabel.font = UIFont.systemFont(ofSize: 14)
        addSubview(companySubTitleLabel)
        companySubTitleLabel.snp.makeConstraints { (make) in
            make.left.equalTo(68)
            make.top.equalTo(77)
        }
        
        let arrowView = UIImageView(image: UIImage(named: "item_right_arrow"))
        addSubview(arrowView)
        arrowView.snp.makeConstraints { (make) in
            make.right.equalTo(-16)
            make.centerY.equalTo(companyLogoView)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func bind(logoUrl: String?, companyName: String?, subTitle: String?) {
        companyLogoView.kf.setImage(with: URL(string: logoUrl ?? ""))
        companyNameLabel.text = companyName
        companySubTitleLabel.text = subTitle
    }
    
    func add(target: AnyObject, action: Selector) {
        actionButton.addTarget(target, action: action, for: .touchUpInside)
    }
}

class TeacherInfoDetailViewController: TableViewController {
    var userId: String!
    var updated = false
    var teacherName: String = ""
    var jsonData: JSON?
    var teacherInfo: TeacherInfo?
    private lazy var headerView: HeaderView = {
        let header = HeaderView()
        header.delegate = self
        return header
    }()
    override init(query: [String : Any]?) {
        super.init(query: query)
        userId = query?[IMUserID] as? String
        assert(userId != nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationBar?.transparent = true
        let backButtonItem = NavigationBarButtonItem(image: UIImage(named: "nav_back_arrow")!.tint(.white), target: self, action:#selector(backToLastController))
        navigationBar?.leftButtonItems = [backButtonItem]
        
        tableView.separatorStyle = .none
        
        let headerHeight: CGFloat = headerVideoViewHeight + 135
        let schoolHeight: CGFloat = 82
        let companyHeight: CGFloat = 112
        let cellDelta: CGFloat = 12
        let container = UIView(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: view.width, height: headerHeight + schoolHeight + companyHeight + 3 * cellDelta)))

        container.addSubview(headerView)
        headerView.snp.makeConstraints { (make) in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(headerHeight)
        }
        
        let schoolView = SchoolView(frame: CGRect.zero, title: "毕业院校")
        container.addSubview(schoolView)
        schoolView.snp.makeConstraints { (make) in
            make.top.equalTo(headerView.snp.bottom).offset(cellDelta)
            make.left.right.equalToSuperview()
            make.height.equalTo(schoolHeight)
        }
        
        let companyView = CompanyView(frame: CGRect.zero, title: "所在组织")
        companyView.add(target: self, action: #selector(companyViewPressed))
        container.addSubview(companyView)
        companyView.snp.makeConstraints { (make) in
            make.top.equalTo(schoolView.snp.bottom).offset(cellDelta)
            make.left.right.equalToSuperview()
            make.height.equalTo(112)
        }
        
        TeacherInfoHelper.shared.teacherInfo(userId, needCompany: true) { [weak self] (info) in
            if let info = info {
                self?.teacherInfo = info
                self?.teacherName = info.name ?? ""
                self?.headerView.bind(info: info)
                self?.headerView.likeCount = info.likesNum ?? 0 
                schoolView.bind(schooName: info.school, isCertified: info.schoolCertified)
                companyView.bind(logoUrl: info.companyLogo, companyName: info.company, subTitle: info.companySubTitle)
            }
        }
        
        tableViewAction.tap(to: TeacherAnswerItem.self) { (cellItem, _) -> (Bool) in
            XDStatistics.click("19_A_question_detail_cell")
            if let cellItem = cellItem as? TeacherAnswerItem, let questionID = (cellItem.model as? QuestionModel)?.questionID {
                let vc = QuestionDetailViewController()
                vc.questionID = questionID
                XDRoute.pushToVC(vc)
            }
            return true
        }
        
        tableView.tableHeaderView = container
    }
    
    @objc func companyViewPressed() {
        navigationController?.pushViewController(TeacherCompanyViewController(query: [IMUserID: userId]), animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if !updated {
            if let jsonData = jsonData {
                processData(data: jsonData)
            } else {
                updateData()
            }
        }
        if let _ = headerView.playerView.assetURL, headerView.playerView.playerState == .paused {
            headerView.playerView.pauseOrPlayVideos()
            headerView.playerView.isSuperControllerExist = true
        }
    }        
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if headerView.playerView.playerState == .playing {
            headerView.playerView.isSuperControllerExist = false
            headerView.playerView.pauseOrPlayVideos()
        }
    }
    
    func updateData() {
        SSNetworkManager.shared().get(XD_FETCH_TEACHER_INFO, parameters: ["imUserId": userId], success: {
            [weak self] (_, response) in
            guard let res = response, let sSelf = self else { return }
            sSelf.processData(data: JSON(res))
        }, failure: { (_, error) in
        })
    }
    
    func processData(data: JSON) {
        updated = true
        let jsonArrays = data["data"]["answeredQuestions"]["data"].arrayObject
        if let jsonArrays = jsonArrays {
            SSLog(jsonArrays)
            let questionModels: [QuestionModel] = NSArray.yy_modelArray(with: QuestionModel.self, json: jsonArrays) as! [QuestionModel]
            let cellItems: [TeacherAnswerItem] = questionModels.map {
                let cellItem = TeacherAnswerItem()
                cellItem.model = $0
                return cellItem
            }
            cellItems.last?.isLast = true
            if cellItems.count > 0 {
                let answerHeaderItem = AnswerHeaderItem()
                answerHeaderItem.delegate = self
                answerHeaderItem.count = data["data"]["answeredQuestions"]["pagination"]["count"].intValue
                var nCellItems: [TableCellItem] = cellItems
                nCellItems.insert(answerHeaderItem, at: 0)
                tableViewModel.add(nCellItems)
                tableView.reloadData()
            }
        }
    }
}

extension TeacherInfoDetailViewController: AnswerHeaderItemDelegate {
    func moreQuestionButtonPressed() {
        XDRoute.pushToVC(TeacherAnsweredListViewController(query: [IMUserID: userId, TeacherName: teacherName]))
    }
}

extension TeacherInfoDetailViewController: HeaderViewDelegate {
    func headerViewDidTapLikeImage(likeCount: Int) {
        SSNetworkManager.shared().post(XD_LIKE_FOR_TEACHER, parameters: ["imUserId": userId, "amount": likeCount], success: { (dataTask, responseObject) in
            if let responseDic = responseObject as? [String: Any], let responseData = responseDic["data"] as? [String: Any] {
                if let likeNum = responseData["count"] as? Int {
                    self.headerView.likeCount = likeNum
                    if self.teacherInfo != nil {
                        self.teacherInfo?.likesNum = likeNum
                        TeacherInfoHelper.shared.updateTeacherInfos([(self.teacherInfo?.id)!])
                    }
                }
            }
        }) { (dataTask, error) in
            
        }
    }
}
