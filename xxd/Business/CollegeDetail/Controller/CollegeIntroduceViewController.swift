//
//  CollegeIntroduceViewController.swift
//  xxd
//
//  Created by remy on 2018/2/2.
//  Copyright © 2018年 com.smartstudy. All rights reserved.
//

private let contentOffsetMinY: CGFloat = 50
private let contentOffsetMaxY: CGFloat = 130

class CollegeIntroduceViewController: SSModelViewController, UIScrollViewDelegate {
    
    var collegeID = 0
    private var backBtn: UIButton!
    private var topBar: CollegeTopBarView!
    private var overlayNameLabel: UILabel!
    private var scrollView: UIScrollView!
    private var headerView: CollegeHeaderView!
    private var acceptRateCell: CollegeIntroduceCell!
    private var feeCell: CollegeIntroduceCell!
    private var deadlineCell: CollegeIntroduceCell!
    private var phoneCell: CollegeIntroduceLinkCell!
    private var websiteCell: CollegeIntroduceLinkCell!
    private var addressCell: CollegeIntroduceLinkCell!
    private var costCell: CollegeIntroduceApplyCostCell!
    private var scoreCell: CollegeIntroduceScoreCell!
    private var detailBtn: UIButton!
    private var lastScale: CGFloat = -1
    
    override func needNavigationBar() -> Bool {
        return false
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        if topBar != nil {
            if topBar.alpha == 1 {
                return .default
            }
        }
        return .lightContent
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        lastScale = -1
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        edgesForExtendedLayout = []
        scrollView = UIScrollView(frame: view.bounds)
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.alwaysBounceVertical = true
        if #available(iOS 11.0, *) {
            scrollView.contentInsetAdjustmentBehavior = .never
        }
        view.addSubview(scrollView)
        
        backBtn = UIButton(frame: CGRect(x: 0, y: XDSize.statusBarHeight, width: XDSize.topBarHeight, height: XDSize.topBarHeight), title: "", fontSize: 0, titleColor: UIColor.clear, target: self, action: #selector(backTap(sender:)))
        backBtn.setImage(UIImage(named: "top_left_arrow")?.tint(UIColor.white), for: .normal)
        view.addSubview(backBtn)
        
        topBar = CollegeTopBarView()
        
        overlayNameLabel = UILabel(frame: .zero, text: "", textColor: UIColor.white, fontSize: 23, bold: true)
        overlayNameLabel.textAlignment = .center
        
        headerView = CollegeHeaderView()
        
        scrollViewDidScroll(scrollView)
    }
    
    private func initView() {
        view.addSubview(topBar)
        view.addSubview(overlayNameLabel)
        scrollView.addSubview(headerView)
        
        acceptRateCell = CollegeIntroduceCell()
        acceptRateCell.title = "school_intro_cell_admissionRate".localized
        scrollView.addSubview(acceptRateCell)
        acceptRateCell.snp.makeConstraints { (make) in
            make.top.equalTo(headerView.snp.bottom)
            make.left.equalTo(scrollView)
            make.size.equalTo(CGSize(width: XDSize.screenWidth, height: 80))
        }
       
        feeCell = CollegeIntroduceCell()
        feeCell.title = "school_intro_cell_fee".localized
        scrollView.addSubview(feeCell)
        feeCell.snp.makeConstraints { (make) in
            make.top.equalTo(acceptRateCell.snp.bottom).offset(10)
            make.left.equalTo(scrollView)
            make.size.equalTo(CGSize(width: XDSize.screenWidth, height: 80))
        }
        
        scoreCell = CollegeIntroduceScoreCell()
        scrollView.addSubview(scoreCell)
        scoreCell.snp.makeConstraints { (make) in
            make.top.equalTo(feeCell.snp.bottom).offset(10)
            make.left.equalTo(scrollView)
            make.size.equalTo(CGSize(width: XDSize.screenWidth, height: 116))
        }
        
        deadlineCell = CollegeIntroduceCell()
        deadlineCell.title = "school_intro_cell_deadline".localized
        scrollView.addSubview(deadlineCell)
        deadlineCell.snp.makeConstraints { (make) in
            make.top.equalTo(scoreCell.snp.bottom).offset(10)
            make.left.equalTo(scrollView)
            make.size.equalTo(CGSize(width: XDSize.screenWidth, height: 80))
        }
        
        costCell = CollegeIntroduceApplyCostCell()
        scrollView.addSubview(costCell)
        costCell.snp.makeConstraints { (make) in
            make.top.equalTo(deadlineCell.snp.bottom).offset(10)
            make.left.equalTo(scrollView)
            make.size.equalTo(CGSize(width: XDSize.screenWidth, height: 80))
        }
        
        phoneCell = CollegeIntroduceLinkCell()
        phoneCell.title = "school_intro_cell_phone".localized
        phoneCell.icon = UIImage(named: "school_intro_phone")
        scrollView.addSubview(phoneCell)
        phoneCell.snp.makeConstraints { (make) in
            make.top.equalTo(costCell.snp.bottom).offset(10)
            make.left.equalTo(scrollView)
            make.width.equalTo(XDSize.screenWidth)
        }
        
        websiteCell = CollegeIntroduceLinkCell()
        websiteCell.title = "school_intro_cell_website".localized
        websiteCell.icon = UIImage(named: "school_intro_website")
        scrollView.addSubview(websiteCell)
        websiteCell.snp.makeConstraints { (make) in
            make.top.equalTo(phoneCell.snp.bottom).offset(10)
            make.left.equalTo(scrollView)
            make.width.equalTo(XDSize.screenWidth)
        }
        
        addressCell = CollegeIntroduceLinkCell()
        addressCell.title = "school_intro_cell_address".localized
        addressCell.icon = UIImage(named: "school_intro_address")
        scrollView.addSubview(addressCell)
        addressCell.snp.makeConstraints { (make) in
            make.top.equalTo(websiteCell.snp.bottom).offset(10)
            make.left.equalTo(scrollView)
            make.width.equalTo(XDSize.screenWidth)
        }
        
        detailBtn = UIButton(frame: .zero, title: "school_intro_view_more".localized, fontSize: 16, titleColor: UIColor.white, target: self, action: #selector(detailTap(sender:)))
        detailBtn.backgroundColor = XDColor.main
        scrollView.addSubview(detailBtn)
        detailBtn.snp.makeConstraints { (make) in
            make.top.equalTo(addressCell.snp.bottom).offset(24)
            make.left.bottom.equalTo(scrollView)
            make.size.equalTo(CGSize(width: XDSize.screenWidth, height: 49))
        }
    }
    
    override func createModel() {
        let model = SSURLReqeustModel(httpMethod: .get, urlString: XD_API_COLLEGE_INTRO, loadFromFile: false, isPaged: false)
        model?.parameters = ["id":collegeID]
        self.model = model
    }
    
    override func didFinishLoad(with object: Any!) {
        if let data = (object as! [String : Any])["data"] as? [String : Any] {
            if let model = CollegeIntroduceModel.yy_model(with: data) {
                if detailBtn == nil {
                    initView()
                }
                
                scrollView.delegate = self
                topBar.title = model.chineseName
                overlayNameLabel.text = model.chineseName
                overlayNameLabel.sizeToFit()
                overlayNameLabel.centerX = XDSize.screenWidth * 0.5
                headerView.model = model
                acceptRateCell.detailText = model.acceptRate
                feeCell.detailText = model.fee
                deadlineCell.detailText = model.deadline
                addressCell.detailText = model.address
                phoneCell.detailText = model.phone
                websiteCell.detailText = model.website
                costCell.interviewType = model.interviewType
                costCell.cost = model.applyFee
                scoreCell.model = model
                lastScale = -1
                scrollViewDidScroll(scrollView)
            }
        }
    }
    
    //MARK:- UIScrollViewDelegate
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let contentOffsetY = scrollView.contentOffset.y
        let scale = min(max((contentOffsetY - contentOffsetMinY) / (contentOffsetMaxY - contentOffsetMinY), 0), 1)
        if scale == lastScale { return }
        backBtn.alpha = 1 - scale
        topBar.alpha = scale
        topBar.centerView.isHidden = scale != 1
        topBar.isUserInteractionEnabled = scale == 1
        headerView.isHiddenName = scale != 0
        overlayNameLabel.isHidden = scale == 1 || scale == 0
        overlayNameLabel.centerY = 206 - contentOffsetMinY - (206 - contentOffsetMinY - XDSize.statusBarHeight - 20) * scale
        overlayNameLabel.font = UIFont.boldSystemFont(ofSize: 23 - (23 - 17) * scale)
        overlayNameLabel.textColor = UIColor(start: UIColor.white, end: XDColor.itemTitle, ratio: scale)
        setNeedsStatusBarAppearanceUpdate()
        lastScale = scale
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        scrollViewDidEndDecelerating(scrollView)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let contentOffsetY = scrollView.contentOffset.y
        if contentOffsetY < contentOffsetMaxY && contentOffsetY > 0 {
            let y = contentOffsetY > 100 ? contentOffsetMaxY : 0
            scrollView.setContentOffset(CGPoint(x: 0, y: y), animated: true)
        }
    }
    
    //MARK:- Action
    @objc func detailTap(sender: UIButton) {
        let vc = CollegeDetailViewController()
        vc.collegeID = collegeID
        XDRoute.pushToVC(vc)
    }
    
    @objc func backTap(sender: UIButton) {
        backActionTap()
    }
}
