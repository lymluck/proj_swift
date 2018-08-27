//
//  HighschoolDetailViewController.swift
//  xxd
//
//  Created by remy on 2018/4/3.
//  Copyright © 2018年 com.smartstudy. All rights reserved.
//

private let contentOffsetMinY: CGFloat = 0
private let contentOffsetMaxY: CGFloat = 80

class HighschoolDetailViewController: SSTableViewController {

    var highschoolID = 0
    private var backBtn: UIButton!
    private var topBar: CollegeTopBarView!
    private var lastScale: CGFloat = -1
    private var detailModel: HighschoolDetailModel!
    private var tableHeaderView: UIScrollView!
    private var detailHeaderView: HighschoolDetailHeaderView!
    private var lastView: UIView!
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        backBtn = UIButton(frame: CGRect(x: 0, y: XDSize.statusBarHeight, width: XDSize.topBarHeight, height: XDSize.topBarHeight), title: "", fontSize: 0, titleColor: UIColor.clear, target: self, action: #selector(backActionTap))
        backBtn.setImage(UIImage(named: "top_left_arrow")?.tint(UIColor.white), for: .normal)
        view.addSubview(backBtn)
        
        topBar = CollegeTopBarView()
        
        detailHeaderView = HighschoolDetailHeaderView()
        
        tableView.frame = CGRect(x: 0, y: 0, width: XDSize.screenWidth, height: XDSize.screenHeight - XDSize.tabbarHeight)
        tableView.isScrollEnabled = false
        
        scrollViewDidScroll(tableView)
    }
    
    override func showEmpty(_ show: Bool) {
        if show && detailModel != nil {
            super.showEmpty(false)
        } else {
            super.showEmpty(show)
        }
        // 没数据时 backBtn 被 SSStateView 挡住
        view.bringSubview(toFront: backBtn)
    }
    
    override func createModel() {
        let urlStr = String(format: XD_API_HIGHSCHOOL_DETAIL, highschoolID)
        model = SSURLReqeustModel(httpMethod: .get, urlString: urlStr, loadFromFile: false, isPaged: false)
    }

    override func didFinishLoad(with object: Any!) {
        if let data = (object as! [String : Any])["data"] as? [String : Any] {
            if let model = HighschoolDetailModel.yy_model(with: data), tableView.tableHeaderView == nil {
                detailModel = model
                // tableHeaderView
                tableHeaderView = UIScrollView(frame: tableView.bounds)
                tableHeaderView.backgroundColor = XDColor.mainBackground
                tableHeaderView.showsHorizontalScrollIndicator = false
                tableHeaderView.showsVerticalScrollIndicator = false
                tableHeaderView.scrollsToTop = false
                tableHeaderView.alwaysBounceVertical = true
                tableHeaderView.delegate = self
                if #available(iOS 11.0, *) {
                    tableHeaderView.contentInsetAdjustmentBehavior = .never
                }
                tableView.tableHeaderView = tableHeaderView
                // 导航栏
                topBar.title = model.chineseName
                view.addSubview(topBar)
                // 学校信息
                detailHeaderView.model = model
                tableHeaderView.addSubview(detailHeaderView)
                lastView = detailHeaderView
                // 学校简介
                addTextSection("学校简介", model.introduction, topSpace: 0)
                // 学校图片
                addImageListSection("学校图片（\(model.photos.count)张）", model.photos)
                // 学校概况
                var formData = [
                    "建校年份": model.establishmentYear,
                    "学校地址": model.address,
                    "校园面积": model.area,
                    "所在国家": model.countryName,
                    "所在州省": model.provinceName,
                    "所在城市": model.cityName,
                    "寄宿校/走读校": model.boarderTypeName,
                    "男女校": model.sexualTypeName,
                    "学校类型": model.schoolTypeName,
                    "城市/乡村": model.locationTypeName,
                    "宗教": model.religonName
                ]
                addMapFormSection("学校概况", formData)
                // 学校数据
                formData = [
                    "开设年级": model.grades,
                    "班级大小": model.classSize,
                    "AP课程数": model.apCourseCount,
                    "学生人数": model.studentAmount,
                    "师生比": model.facultyStudentRatio,
                    "国际学生比": model.internationalStudentRatio,
                    "寄宿学生比": model.boarderRatio,
                    "高级教师比": model.seniorFacultyRatio,
                    "SAT平均分": model.scoreSat
                ]
                addMapFormSection("学校数据", formData)
                // 费用预算
                formData = [
                    "学费": model.feeTuition,
                    "校友捐赠": model.alumniFund,
                    "奖学金": model.scholarship
                ]
                addMapFormSection("费用预算", formData)
                // 申请情况
                formData = [
                    "申请截止日期": model.applicationDeadline,
                    "托福送分代码": model.toeflCode,
                    "SSAT送分代码": model.ssatCode,
                    "ISEE送分代码": model.iseeCode,
                    "面试方式": model.interview,
                    "申请认可成绩": model.acceptScores,
                    "中国学生申请人数": model.chineseApplicationAmount,
                    "中国学生录取人数": model.chineseAdmissionAmount,
                    "中国学生在校人数": model.chineseStudentAmount,
                    "中国学生开设年级": model.gradesForChineseStudent,
                    "中国学生招收人数": model.amountForChineseStudent,
                    "中国学生第三方面试": model.chineseThirdpartyPreinterview,
                    "中国学生TOEFL平均分": model.chineseToeflAverage,
                    "中国学生TOEFL最低分": model.chineseToeflLowest,
                    "中国学生SSAT平均分": model.chineseSsatAverage,
                    "中国学生SSAT最低分": model.chineseSsatLowest
                ]
                addMapFormSection("申请情况", formData)
                // 暑期学校
                formData = [
                    "暑期学校主页": model.ssWebsite,
                    "开始日期": model.ssStartTime,
                    "结束日期": model.ssEndTime,
                    "开设年级": model.ssGrades,
                    "年龄要求": model.ssAges,
                    "性别要求": model.ssGenders,
                    "学费": model.ssFeeTuition,
                    "ESL课程": model.ssEslCourse,
                    "申请事项": model.ssChecklist,
                    "联系电话": model.ssTel,
                    "联系邮箱": model.ssEmail
                ]
                addMapFormSection("暑期学校", formData)
                // 联系信息
                formData = [
                    "联系电话": model.tel,
                    "联系邮箱": model.email,
                    "招生电话": model.applicationTel,
                    "招生邮箱": model.applicationEmail
                ]
                addMapFormSection("联系信息", formData)
                // 体育
                addArrayFormSection("体育", model.sports)
                // AP课程
                addArrayFormSection("AP课程", model.apCourses)
                // 社团
                addArrayFormSection("社团", model.communities)
                // 学校特色
                addArrayFormSection("学校特色", model.features)
                // 学校优势
                addArrayFormSection("学校优势", model.pros)
                // 学校荣誉
                addArrayFormSection("学校荣誉", model.honors)
                // 学校设施
                addArrayFormSection("学校设施", model.facilities)
                // ESL课程
                addTextSection("ESL课程", model.eslCourse)
                // 最后一项用于动态布局
                let stickView = UIView()
                tableHeaderView.addSubview(stickView)
                stickView.snp.updateConstraints { (make) in
                    make.top.equalTo(lastView.snp.bottom)
                    make.left.bottom.equalToSuperview()
                }
                // tabbar
                let tabbar = HighschoolTabbarView()
                tabbar.model = model
                view.addSubview(tabbar)
            }
        } 
    }
    
    private func addTextSection(_ title: String, _ content: String, topSpace: CGFloat = 12) {
        if !content.isEmpty {
            let view = HighschoolDetailTextView(title: title)
            view.text = content
            addToTableHeaderView(view, topSpace)
        }
    }
    
    private func addImageListSection(_ title: String, _ data: [String]) {
        if let view = HighschoolDetailImageListView(title: title, data: data) {
            addToTableHeaderView(view, 12)
        }
    }
    
    private func addMapFormSection(_ title: String, _ data: [String : String]) {
        if let view = HighschoolDetailFormView(title: title, data: data) {
            addToTableHeaderView(view, 12)
        }
    }
    
    private func addArrayFormSection(_ title: String, _ data: [Any]) {
        if let view = HighschoolDetailFormView(title: title, data: data) {
            addToTableHeaderView(view, 12)
        }
    }
    
    private func addToTableHeaderView(_ view: UIView, _ topSpace: CGFloat) {
        tableHeaderView.addSubview(view)
        view.snp.makeConstraints { (make) in
            make.top.equalTo(lastView.snp.bottom).offset(topSpace)
            make.left.equalToSuperview()
            make.width.equalTo(XDSize.screenWidth)
        }
        lastView = view
    }
    
    //MARK:- UIScrollViewDelegate
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let contentOffsetY = scrollView.contentOffset.y
        let scale = min(max((contentOffsetY - contentOffsetMinY) / (contentOffsetMaxY - contentOffsetMinY), 0), 1)
        if scale == lastScale { return }
        backBtn.alpha = 1 - scale
        topBar.alpha = scale
        topBar.isUserInteractionEnabled = scale == 1
        detailHeaderView.wrap.alpha = pow(1 - scale, 4)
        setNeedsStatusBarAppearanceUpdate()
        lastScale = scale
    }
    
    override func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        scrollViewDidEndDecelerating(scrollView)
    }
    
    override func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let contentOffsetY = scrollView.contentOffset.y
        if contentOffsetY < contentOffsetMaxY && contentOffsetY > 0 {
            let y = contentOffsetY > 50 ? contentOffsetMaxY : 0
            scrollView.setContentOffset(CGPoint(x: 0, y: y), animated: true)
        }
    }
}
