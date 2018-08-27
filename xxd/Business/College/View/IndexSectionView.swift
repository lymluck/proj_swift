//
//  IndexSectionView.swift
//  xxd
//
//  Created by remy on 2018/4/9.
//  Copyright © 2018年 com.smartstudy. All rights reserved.
//

import Kingfisher


enum CollegeCategoryType: String {
    case viewed = "hottest"
    case selected = "mostSelected"
    
    func titleName() -> String {
        switch self {
        case .viewed:
            return "浏览热度排行"
        default:
            return "选校热度排行"
        }
    }
    var attributedColor: UIColor {
        switch self {
        case .viewed:
            return UIColor(0xFE5E3E)
        default:
            return UIColor(0xFF8A00)
        }
    }
}

private let kSectionTitleHeight: CGFloat = 67
private let kLabelTag: Int = 1001
@objc private protocol IndexSectionType {
    var titleName: String { get set }
    func reloadData(_ data: Any?)
    @objc func moreTap(sender: UIButton)
}
extension IndexSectionType where Self: UIView {
    func sectionTitle() {
        let wrap = UIView(frame: CGRect(x: 0, y: 0, width: self.width, height: kSectionTitleHeight))
        addSubview(wrap)
        
        let titleLabel = UILabel(frame: .zero, text: titleName, textColor: XDColor.itemTitle, fontSize: 19, bold: true)!
        titleLabel.tag = kLabelTag
        wrap.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(28)
            make.left.equalToSuperview().offset(16)
        }
        
        let moreBtn = UIButton(frame: .zero, title: "more".localized, fontSize: 13, titleColor: XDColor.itemText, target: self, action: #selector(moreTap(sender:)))!
        moreBtn.tag = tag
        moreBtn.contentHorizontalAlignment = .right
        moreBtn.setImage(UIImage(named: "more_right_arrow"), for: .normal)
        moreBtn.titleEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 10)
        moreBtn.imageEdgeInsets = UIEdgeInsetsMake(0, 93, 0, 0)
        wrap.addSubview(moreBtn)
        moreBtn.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(10)
            make.right.equalToSuperview().offset(-16)
            make.size.equalTo(CGSize(width: 100, height: kSectionTitleHeight - 10))
        }
    }
}

private var kSpecialItemKey: Void?
/// 首页专题模块
class IndexSpecialView: UIView, IndexSectionType {
    
    private var contentView: UIScrollView!
    var titleName = "hottest_special".localized
    var userType: UserTargetType?
    
    convenience init() {
        self.init(frame: CGRect(x: 0, y: 0, width: XDSize.screenWidth, height: 0.0))
        backgroundColor = UIColor.white
        // 标题
        sectionTitle()
        // 内容
        contentView = UIScrollView(frame: CGRect(x: 0, y: kSectionTitleHeight, width: XDSize.screenWidth, height: 161.0)) //120))
        contentView.showsHorizontalScrollIndicator = false
        contentView.showsVerticalScrollIndicator = false
        contentView.alwaysBounceHorizontal = true
        addSubview(contentView)
//        addSubview(UIView(frame: CGRect(x: 16, y: 207 - XDSize.unitWidth, width: XDSize.screenWidth - 32, height: XDSize.unitWidth), color: XDColor.itemLine))
    }
    
    func reloadData(_ data: Any?) {
        guard let data = data as? [[String : Any]], data.count > 0 else {
            isHidden = true
            height = 0.0
            return
        }
        isHidden = false
        height = 225.0
        contentView.removeAllSubviews()
        contentView.contentSize = CGSize(width: CGFloat(data.count) * 108.0 + 24.0, height: 161.0) //(width: CGFloat(data.count) * 225 + 16, height: 120)
        for (index, info) in data.enumerated() {
            let model: CollegeModel = CollegeModel.yy_model(with: info)!
            let left = CGFloat(index) * 108.0 + 16.0 //225 + 16
            let imageView = UIImageView(frame: CGRect(x: left, y: 0, width: 100.0, height: 100.0)) //width: 213, height: 120))
            imageView.isUserInteractionEnabled = true
            imageView.layer.cornerRadius = 3
            imageView.layer.masksToBounds = true
            imageView.contentMode = .scaleAspectFill
            objc_setAssociatedObject(imageView, &kSpecialItemKey, model, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(specialTap(gestureRecognizer:))))
            contentView.addSubview(imageView)
            imageView.setAutoOSSImage(urlStr: model.coverImage)
            
//            let layer = CAGradientLayer()
//            layer.frame = CGRect(x: 0, y: imageView.height * 0.5, width: imageView.width, height: imageView.height * 0.5)
//            layer.colors = [UIColor.black.withAlphaComponent(0).cgColor, UIColor.black.withAlphaComponent(0.2).cgColor]
//            imageView.layer.addSublayer(layer)
            
            let cNameLabel = UILabel(text: "", textColor: UIColor(0x26343F), fontSize: 14)!
            cNameLabel.text = model.chineseName
            contentView.addSubview(cNameLabel)
            cNameLabel.snp.makeConstraints { (make) in
                make.left.equalTo(imageView)
                make.top.equalTo(imageView.snp.bottom).offset(8.0)
                make.right.lessThanOrEqualTo(imageView)
            }
            let eNameLabel = UILabel(text: "", textColor: XDColor.itemText, fontSize: 11)!
            eNameLabel.text = model.englishName
            contentView.addSubview(eNameLabel)
            eNameLabel.snp.makeConstraints { (make) in
                make.left.equalTo(imageView)
                make.top.equalTo(cNameLabel.snp.bottom).offset(2.0)
                make.right.lessThanOrEqualTo(imageView)
            }
        }
    }
    
    //MARK:- Action
    func moreTap(sender: UIButton) {
        XDStatistics.click("8_A_subject_more_btn")
//        let vc = SpecialViewController()
        let vc = HistoryCollegeViewController()
        XDRoute.pushToVC(vc)
    }
    
    @objc func specialTap(gestureRecognizer: UIGestureRecognizer) {
        XDStatistics.click("8_A_specific_subject_btn")
        if let model = objc_getAssociatedObject(gestureRecognizer.view!, &kSpecialItemKey) as? CollegeModel, let type = userType {
//        XDRoute.pushWebVC([QueryKey.URLPath: model.specialURL])
//            switch type {
//            case .us(.highschool):
//                let vc = HighschoolDetailViewController()
//                vc.highschoolID = model.collegeID
//                XDRoute.pushToVC(vc)
//            default:
                let vc = CollegeDetailViewController()
                vc.collegeID = model.collegeID
                XDRoute.pushToVC(vc)
//            }
        }
    }
}

private var kRankItemKey: Void?
/// 首页排名模块
class IndexRankView: UIView, IndexSectionType {

    var titleName = "hottest_rank".localized
    var userType: UserTargetType?
    private var contentView: UIView!
    private lazy var itemWidth: CGFloat = ((XDSize.screenWidth - 32 - 4) * 0.5).rounded()
    private lazy var leftHeight = (70 / 170 * itemWidth).rounded()
    private lazy var rightHeight = (leftHeight * 3 + 4) * 0.5
    private lazy var viewHeight = leftHeight * 3 + 8
    private var imageList = [UIImageView]()
    private var titleList = [UILabel]()
    
    convenience init(type: UserTargetType) {
        self.init(frame: CGRect(x: 0, y: 0, width: XDSize.screenWidth, height: 0))
        self.userType = type
        height = kSectionTitleHeight + viewHeight + 20
        backgroundColor = UIColor.white
        // 标题
        sectionTitle()
        // 内容
        contentView = UIView(frame: CGRect(x: 16, y: kSectionTitleHeight, width: XDSize.screenWidth - 32, height: viewHeight))
        addSubview(contentView)
        addSubview(UIView(frame: CGRect(x: 16, y: height - XDSize.unitWidth, width: XDSize.screenWidth - 32, height: XDSize.unitWidth), color: XDColor.itemLine))
    }

    func reloadData(_ data: Any?) {
        if let data = data as? [[String : Any]] {
            contentView.removeAllSubviews()
            let count = min(5, data.count)
            var pointList: [(CGFloat, CGFloat)] = []
            var sizeList: [(CGFloat, CGFloat)] = []
            switch count {
            case 1:
                pointList = [(0, 0)]
                sizeList = [(contentView.width, viewHeight)]
            case 2:
                pointList = [(0, 0), (0, rightHeight + 4)]
                sizeList = (0..<2).map { _ in (contentView.width, rightHeight) }
            case 3:
                pointList = [(0, 0), (0, leftHeight + 4), (0, leftHeight * 2 + 8)]
                sizeList = (0..<3).map { _ in (contentView.width, leftHeight) }
            case 4:
                pointList = [(0, 0), (0, rightHeight + 4), (itemWidth + 4, 0), (itemWidth + 4, rightHeight + 4)]
                sizeList = (0..<4).map { _ in (itemWidth, rightHeight) }
            case 5:
                pointList = [(0, 0), (0, leftHeight + 4), (0, leftHeight * 2 + 8), (itemWidth + 4, 0), (itemWidth + 4, rightHeight + 4)]
                sizeList = (0..<5).map { $0 < 3 ? (itemWidth, leftHeight) : (itemWidth, rightHeight) }
            default:
                break
            }
            (0..<count).forEach {
                let point = pointList[$0]
                let size = sizeList[$0]
                addRankItem(data[$0], point: CGPoint(x: point.0, y: point.1), size: CGSize(width: size.0, height: size.1))
            }
        }
    }
    
    private func addRankItem(_ data: [String : Any], point: CGPoint, size: CGSize) {
        let imageView = UIImageView(frame: CGRect(origin: point, size: size))
        imageView.isUserInteractionEnabled = true
        imageView.layer.cornerRadius = 4
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFill
        objc_setAssociatedObject(imageView, &kRankItemKey, data, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(rankTap(gestureRecognizer:))))
        if let urlStr = data["backgroundImage"] as? String {
            imageView.kf.setImage(with: URL(string: urlStr), placeholder: UIImage(named: "default_placeholder"))
        }
        contentView.addSubview(imageView)
        
        let year = data["year"] as? Int
        let type = (data["type"] as? String) ?? ""
        let title = (data["title"] as? String) ?? "排名"
        let name = "\(year == nil ? "" : String(year!))" + type + title
        let titleLabel = UILabel(frame: .zero, text: "", textColor: UIColor.white, fontSize: 13)!
        titleLabel.text = name
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 3
        imageView.addSubview(titleLabel)
        titleList.append(titleLabel)
        titleLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
            make.centerY.equalToSuperview()
        }
    }
    
    //MARK:- Action
    func moreTap(sender: UIButton) {
        guard let userType = userType else { return }
        XDStatistics.click("8_A_rank_more_btn")
        switch userType {
        case .us(.highschool):
            let vc = HighSchoolRankViewController()
            XDRoute.pushToVC(vc)
        default:
            let vc = RankViewController()
            XDRoute.pushToVC(vc)
        }
    }
    
    @objc func rankTap(gestureRecognizer: UIGestureRecognizer) {
        guard let userType = userType else { return }
        XDStatistics.click("8_A_specific_rank_btn")
        let data = objc_getAssociatedObject(gestureRecognizer.view!, &kRankItemKey) as! [String : Any]
        if let id = data["id"] as? Int {
            switch userType {
            case .us(.highschool):
                let vc = HighSchoolRankListViewController()
                vc.categoryID = id
                vc.rankTitle = (data["title"] as? String) ?? "tab_item_rank".localized
                XDRoute.pushToVC(vc)
            default:
                let vc = RankListViewController()
                vc.rankCategoryID = id
                vc.titleName = (data["title"] as? String) ?? "tab_item_rank".localized
                XDRoute.pushToVC(vc)
            }
        } else if let rankings = data["rankings"] as? [[String : Any]] {
            let vc = RankCategoryViewController()
            vc.titleName = (data["title"] as? String) ?? "tab_item_rank".localized
            vc.dataList = rankings
            XDRoute.pushToVC(vc)
        }
    }
}

private var kCollegeItemKey: Void?
/// 首页院校模块
class IndexCollegeView: UIView, IndexSectionType {

    var titleName = "hottest_college".localized
    var userType: UserTargetType?
    var moreType: CollegeCategoryType = .viewed
    
    private var contentView: UIView!
    private lazy var itemSize: CGFloat = ((XDSize.screenWidth - 16 * 2 - itemSpace * 2) / 3).rounded()
    private lazy var logoSize = itemSize - logoSpace * 2
    private let logoSpace: CGFloat = 16
    private let itemSpace: CGFloat = 11
    private let titleHeight: CGFloat = 38

    convenience init(type: UserTargetType) {
        self.init(frame: CGRect(x: 0, y: 0, width: XDSize.screenWidth, height: 0))
        self.userType = type
        backgroundColor = UIColor.white
        // 标题
        sectionTitle()
        // 内容
        contentView = UIView(frame: CGRect(x: 0, y: kSectionTitleHeight, width: XDSize.screenWidth, height: 0))
        addSubview(contentView)
    }
    
    func reloadData(_ data: Any?) {
        if let titleLabel = viewWithTag(kLabelTag) as? UILabel, let type = userType {
            if type == .us(.highschool) {
                titleLabel.text = "hottest_college".localized
            } else {
                titleLabel.attributedText = NSAttributedString(string: titleName, attributes: [NSAttributedStringKey.foregroundColor: moreType.attributedColor]) + "选校"
            }
        }
        guard let data = data as? [[String : Any]], data.count > 0 else {
            height = 0.0
            return
        }
        contentView.removeAllSubviews()
        contentView.height = (CGFloat(data.count) / 3).rounded(.up) * (itemSize + titleHeight) + 4
        height = kSectionTitleHeight + contentView.height
        for (index, info) in data.enumerated() {
            let left = 16 + CGFloat(index % 3) * (itemSize + itemSpace)
            let top = CGFloat(index / 3) * (itemSize + titleHeight)
            let logoWrap = UIView(frame: CGRect(x: left, y: top, width: itemSize, height: itemSize))
            logoWrap.layer.borderWidth = 3
            logoWrap.layer.borderColor = XDColor.mainBackground.cgColor
            objc_setAssociatedObject(logoWrap, &kCollegeItemKey, info, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            logoWrap.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(collegeTap(gestureRecognizer:))))
            contentView.addSubview(logoWrap)
            
            let logo = UIImageView(frame: CGRect(x: logoSpace, y: logoSpace, width: logoSize, height: logoSize))
            logo.layer.cornerRadius = logoSize * 0.5
            logo.layer.masksToBounds = true
            logoWrap.addSubview(logo)
            let logoURL = UIImage.OSSImageURLString(urlStr: info["logo"] as! String, size: CGSize(width: logoSize, height: logoSize), policy: .pad)
            logo.kf.setImage(with: URL(string: logoURL), placeholder: UIImage(named: "default_college_logo"))
            
            let titleLabel = UILabel(frame: CGRect(x: 0, y: itemSize + 6, width: itemSize, height: 16), text: info["chineseName"] as! String, textColor: XDColor.itemTitle, fontSize: 13)!
            logoWrap.addSubview(titleLabel)
        }
        contentView.addSubview(UIView(frame: CGRect(x: 16, y: contentView.height - XDSize.unitWidth, width: XDSize.screenWidth - 32, height: XDSize.unitWidth), color: XDColor.itemLine))
    }

    //MARK:- Action
    func moreTap(sender: UIButton) {
        guard let userType = userType else { return }
        XDStatistics.click("8_A_school_more_btn")
        switch userType {
        case .us(.highschool):
            let vc = HighSchoolViewController()
            XDRoute.pushToVC(vc)
        default:
//            let vc = CollegeViewController()
            let vc = CollegeHotCategoryViewController()
            vc.categoryType = moreType
            XDRoute.pushToVC(vc)
        }
    }
    
    @objc func collegeTap(gestureRecognizer: UIGestureRecognizer) {
        guard let userType = userType else { return }
        XDStatistics.click("8_A_specific_school_btn")
        let data = objc_getAssociatedObject(gestureRecognizer.view!, &kCollegeItemKey) as! [String : Any]
        switch userType {
        case .us(.highschool):
            let vc = HighschoolDetailViewController()
            vc.highschoolID = data["id"] as! Int
            XDRoute.pushToVC(vc)
        default:
            let vc = CollegeDetailViewController()
            vc.collegeID = data["id"] as! Int
            XDRoute.pushToVC(vc)
        }
    }
}

/// 首页热门专业选校
class IndexMajorView: UIView, IndexSectionType {
    var titleName: String = ""
    private let kCellWidth: CGFloat = (XDSize.screenWidth-50.0)/3.0
    private var majorIds: [Int] = [Int]()
    private var contentView: UIView!
    
    convenience init() {
        self.init(frame: CGRect(x: 0.0, y: 0.0, width: XDSize.screenWidth, height: 200.0))
        backgroundColor = UIColor.white
        sectionTitle()
        contentView = UIView(frame: CGRect(x: 0.0, y: kSectionTitleHeight, width: XDSize.screenWidth, height: 0.0), color: UIColor.white)
        addSubview(contentView)
        if let titleLabel = viewWithTag(kLabelTag) as? UILabel {
            titleLabel.attributedText = NSAttributedString(string: "热门专业", attributes: [NSAttributedStringKey.foregroundColor: UIColor(0x078CF1)]) + "选校"
        }
    }
    
    func reloadData(_ data: Any?) {
        if let serverData = data as? [[String: Any]], serverData.count > 0 {
            var leftMargin: CGFloat = 16.0
            var topMargin: CGFloat = 0.0
            for data in serverData {
                let majorView: MajorListCell = MajorListCell(frame: CGRect(x: leftMargin, y: topMargin, width: kCellWidth, height: 34.0))
                majorView.majorName = data["chineseName"] as? String
                if let id = data["id"] as? Int {
                    majorIds.append(id)
                } else {
                    majorIds.append(0)
                }
                majorView.tag = majorIds.count
                let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(eventMajorTapResponse(_:)))
                majorView.addGestureRecognizer(tapGesture)
                contentView.addSubview(majorView)
                leftMargin += (kCellWidth+9.0)
                if leftMargin >= (XDSize.screenWidth-32.0) {
                    leftMargin = 16.0
                    topMargin += (34.0+16.0)
                }
            }
            contentView.height = topMargin-16.0
            isHidden = false
            height = contentView.bottom+20.0
            addSubview(UIView(frame: CGRect(x: 16, y: height - XDSize.unitWidth, width: XDSize.screenWidth - 32, height: XDSize.unitWidth), color: XDColor.itemLine))
        } else {
            isHidden = true
            height = 0.0
        }
    }
    
    func moreTap(sender: UIButton) {
        let majorVC: MasterHottestMajorIndexViewController = MasterHottestMajorIndexViewController()
        XDRoute.pushToVC(majorVC)
    }
    
    @objc private func eventMajorTapResponse(_ gesture: UITapGestureRecognizer) {
        if let touchView = gesture.view as? MajorListCell {
            let majorDetailVC: MasterMajorDetailViewController = MasterMajorDetailViewController()
            majorDetailVC.majorName = touchView.majorName
            majorDetailVC.majorId = majorIds[touchView.tag-1]
            XDRoute.pushToVC(majorDetailVC)
        }
    }
}

/// 首页专栏
class IndexColumnView: UIView, IndexSectionType {
    var titleName: String = "专栏"
    private var contentView: UIView!
    convenience init() {
        self.init(frame: CGRect(x: 0.0, y: 0.0, width: XDSize.screenWidth, height: 0.0))
        backgroundColor = UIColor.white
        contentView = UIView(frame: CGRect(x: 0.0, y: kSectionTitleHeight, width: XDSize.screenWidth, height: 0.0), color: UIColor.white)
        sectionTitle()
        addSubview(contentView)
    }
    
    func reloadData(_ data: Any?) {
        if let serverData = data as? [[String: Any]], serverData.count > 0 {
            var topSpace: CGFloat = 20.0
            var bottomSpace: CGFloat = 20.0
            var itemViewHeight: CGFloat = 110.0
            var totalHeight: CGFloat = 0.0
            for (index, value) in serverData.enumerated() {
                if index == 0 {
                    topSpace = 0.0
                    bottomSpace = 12.0
                } else if index == 1 {
                    topSpace = 20.0
                    itemViewHeight = 130.0
                    totalHeight = 110.0
                } else {
                    bottomSpace = 20.0
                    itemViewHeight = 138.0
                    totalHeight = 240.0
                }
                let itemView: ColumnItemView = ColumnItemView(frame: CGRect(x: 0.0, y: totalHeight, width: XDSize.screenWidth, height: itemViewHeight), topSpace: topSpace, bottomSpace: bottomSpace, leftEdge: 16.0)
                let model: ColumnListModel = ColumnListModel.yy_model(with: value)!
                itemView.viewData = model
                contentView.addSubview(itemView)
                contentView.height = itemView.bottom
            }
            isHidden = false
            height = contentView.bottom
        } else {
            isHidden = true
            height = 0.0
        }
    }
    
    func moreTap(sender: UIButton) {
        let columnListVC: ColumnListViewController = ColumnListViewController()
        XDRoute.pushToVC(columnListVC)
    }
    
}

@objc protocol IndexRecommendViewDelegate {
    func indexRecommendViewConfimDeleteCardView(_ cardView: CardView)
    func indexRecommendViewDidTap(_ cardView: CardView)
}

/// 卡片推荐视图
class IndexRecommendView: UIView, IndexSectionType {
    weak var delegate: IndexRecommendViewDelegate?
    var titleName: String = ""
    var userType: UserTargetType?
    var countryType: UserCountryType?
    /// 判断用户是否删除了意向地对比
    var isTargetCountryRecommendDeleted = false
    private let cardWidth: CGFloat = round(343*XDSize.scaleRatio)
    private let cardHeight: CGFloat = round(165.0*XDSize.scaleRatio)
    
    /// 意向国家对比
    lazy var targetCountryView: CardView = {
        let cardView: CardView = CardView(frame: CGRect(x: 0.0, y: 16.0, width: cardWidth, height: cardHeight))
        cardView.cardImage = "target_refer_entry"
        cardView.centerX = self.centerX
        cardView.delegate = self
        cardView.isHidden = true
        return cardView
    }()
    /// 推荐课程
    private lazy var courseView: CardView = {
        let cardView: CardView = CardView(frame: CGRect(x: 0.0, y: 0.0, width: cardWidth, height: cardHeight))
        cardView.centerX = self.centerX
        cardView.delegate = self
        cardView.isHidden = true
        cardView.isCourseRecommend = true
        return cardView
    }()
    private lazy var bottomLine: UIView = UIView(frame: CGRect(x: 16, y: height - XDSize.unitWidth, width: XDSize.screenWidth - 32, height: XDSize.unitWidth), color: XDColor.itemLine)
    
    convenience init(type: UserTargetType) {
        self.init(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: XDSize.screenWidth, height: 0.0)))
        backgroundColor = UIColor.white
        addSubview(targetCountryView)
        addSubview(courseView)
        addSubview(bottomLine)
    }    
    
    func reloadData(_ data: Any?) {
        switch countryType! {
        case .other:
            if isTargetCountryRecommendDeleted {
                targetCountryView.isHidden = true
                height = 0.0
            } else {
                targetCountryView.isHidden = false
                height = targetCountryView.bottom
            }
            if let recommendData = data as? [String: Any] {
                let model: CourseModel? = CourseModel.yy_model(with: recommendData)
                courseView.cardName = model?.name
                courseView.cardImage = "recommend_course"
                courseView.cardModel = model
                courseView.isHidden = false
                courseView.top = targetCountryView.bottom
                height = courseView.bottom
            } else {
                courseView.isHidden = true
            }
        case .us:
            targetCountryView.isHidden = true
            if let recommendData = data as? [String: Any] {
                let model: CourseModel? = CourseModel.yy_model(with: recommendData)
                courseView.cardImage = "recommend_course"
                courseView.cardName = model?.name
                courseView.cardModel = model
                courseView.isHidden = false
                courseView.top = 16.0
                height = courseView.bottom
            } else {
                courseView.isHidden = true
                courseView.cardModel = nil
                height = 0.0
            }
        default:
            courseView.isHidden = true
            courseView.cardModel = nil
            height = 0.0
        }
        bottomLine.top = height == 0 ? 0.0 : height-XDSize.unitWidth
    }
    
    /// 移除卡片
    func removeCardViewFromScreen(_ cardView: CardView) {
        if cardView == targetCountryView {
            if courseView.isHidden {
                height = 0.0
            } else {
                courseView.top = 16.0
                height = courseView.bottom
            }
        } else {
            if targetCountryView.isHidden {
                height = 0.0
            } else {
                height = targetCountryView.bottom
            }
        }
        cardView.isHidden = true
        bottomLine.top = height == 0 ? 0.0 : height-XDSize.unitWidth
    }
    
    func moreTap(sender: UIButton) {
        
    }
    
    override func routerEvent(name: String, data: Dictionary<String, Any>) {
        if name == "CardTapResponse", let cardView = data["cardView"] as? CardView {
            guard let _ = delegate?.indexRecommendViewDidTap(cardView) else { return }
        }        
    }
    
}

extension IndexRecommendView: CardViewDelegate {
    func cardViewDidClickClose(_ cardView: CardView) {
        guard let _ = delegate?.indexRecommendViewConfimDeleteCardView(cardView) else { return }
    }
}

@objc protocol CardViewDelegate {
    func cardViewDidClickClose(_ cardView: CardView)
}

/// 首页的卡片视图
class CardView: UIView {
    weak var delegate: CardViewDelegate?
    var cardModel: CourseModel?
    var isCourseRecommend: Bool = false
    var cardImage: String = "" {
        didSet {
            cardImageView.image = UIImage(named: cardImage)
        }
    }
    var cardName: String? {
        didSet {
            if let text = cardName {
                cardLabel.isHidden = false
                cardLabel.text = "  " + text + "  "
            } else {
                cardLabel.isHidden = true
            }
        }
    }
    private lazy var cardImageView: UIImageView = {
        let imageView: UIImageView = UIImageView(frame: CGRect.zero)
        imageView.image = UIImage(named: "target_graduate_bg")
        return imageView
    }()
    private lazy var closeButton: UIButton = {
        let button: UIButton = UIButton(frame: CGRect.zero)
        button.setImage(UIImage(named: "index_card_close"), for: .normal)
        button.addTarget(self, action: #selector(CardView.eventCloseButtonResponse(_:)), for: .touchUpInside)
        button.imageEdgeInsets = UIEdgeInsets(top: -2.0, left: 0.0, bottom: -2.0, right: 0.0)
        return button
    }()
    lazy var cardLabel: UILabel = {
        let label: UILabel = UILabel(frame: CGRect.zero, text:" ", textColor: UIColor.white, fontSize: 15.0, bold: true)
        label.backgroundColor = UIColor.black
        label.isHidden = true
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initContentViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
            routerEvent(name: "CardTapResponse", data: ["cardView": self])
    }
    
    @objc func eventCloseButtonResponse(_ sender: UIButton) {
        guard let _ = delegate?.cardViewDidClickClose(self) else { return }
    }
    
    private func initContentViews() {
        addSubview(cardImageView)
        addSubview(closeButton)
        addSubview(cardLabel)
        cardImageView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        closeButton.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(12.0)
            make.top.equalToSuperview().offset(-12.0)
            make.width.height.equalTo(40.0)
        }
        cardLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(24.0*XDSize.scaleRatio)
            make.bottom.equalToSuperview().offset(-38.0*XDSize.scaleRatio)
            make.height.equalTo(25.0)
        }
    }
}

@objc protocol IndexToolGuideViewDelegate {
    func indexToolGuideViewDidDelete()
    func indexToolGuideViewDidCancel()
}

/// 首页意向地推荐页面删除指导
class IndexToolGuideView: UIView {
    weak var delegate: IndexToolGuideViewDelegate?
    private lazy var guideImageView: UIImageView = {
        let imageView: UIImageView = UIImageView(frame: CGRect.zero)
        imageView.image = UIImage(named: "toolGuide")
        return imageView
    }()
    private lazy var deleteBtn: UIButton = {
        let button: UIButton = UIButton(frame: CGRect.zero, title: "删除", fontSize: 16.0, titleColor: UIColor.white, target: self, action: #selector(IndexToolGuideView.eventButtonResponse(_:)))
        button.backgroundColor = UIColor(0xFF4046)
        button.layer.cornerRadius = 20.0
        button.layer.masksToBounds = true
        button.tag = 0
        return button
    }()
    private lazy var cancelBtn: UIButton = {
        let button: UIButton = UIButton(frame: CGRect.zero, title: "取消", fontSize: 16.0, titleColor: UIColor.white, target: self, action: #selector(IndexToolGuideView.eventButtonResponse(_:)))
        button.backgroundColor = UIColor.clear
        button.tag = 1
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initContentViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    @objc func eventButtonResponse(_ sender: UIButton) {
        dismissGuideShow()
        if sender.tag == 0 {
            guard let _ = delegate?.indexToolGuideViewDidDelete() else {
                return
            }
        } else {
            guard let _ = delegate?.indexToolGuideViewDidCancel() else { return }
        }
    }
    
    func showGuideView() {
        self.backgroundColor = UIColor.clear
        UIView.animate(withDuration: 0.25) {
            self.backgroundColor = UIColor(white: 0.0, alpha: 0.6)
        }
    }
    
    private func initContentViews() {
        addSubview(guideImageView)
        addSubview(deleteBtn)
        addSubview(cancelBtn)
        guideImageView.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            if UIDevice.isIPhoneX {
                make.top.equalToSuperview().offset(188.0*XDSize.scaleRatio+67.0)
            }  else {
                make.top.equalToSuperview().offset(188.0*XDSize.scaleRatio)
            }
            make.width.equalTo(350.0*XDSize.scaleRatio)
            make.height.equalTo(248.0*XDSize.scaleRatio)
        }
        deleteBtn.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.top.equalTo(guideImageView.snp.bottom).offset(100.0*XDSize.scaleRatio)
            make.width.equalTo(244.0)
            make.height.equalTo(40.0)
        }
        cancelBtn.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.top.equalTo(deleteBtn.snp.bottom).offset(18.0)
            make.height.equalTo(40.0)
        }
    }
    
    //
    private func dismissGuideShow() {
        UIView.animate(withDuration: 0.25, animations: {
            self.backgroundColor = UIColor.clear
            self.removeFromSuperview()
        }) { (_) in
            
        }
    }
}
