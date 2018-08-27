//
//  CourseDetailIntroduceViewController.swift
//  xxd
//
//  Created by remy on 2018/1/19.
//  Copyright © 2018年 com.smartstudy. All rights reserved.
//

import SnapKit

class CourseDetailIntroduceViewController: SSModelViewController {
    
    var courseID = 0
    var topSpace: CGFloat = 0
    private var scrollView: UIScrollView!
    
    override func needNavigationBar() -> Bool {
        return false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView = UIScrollView(frame: CGRect(x: 0, y: 0, width: XDSize.screenWidth, height: XDSize.screenHeight - topSpace))
        view.addSubview(scrollView)
    }
    
    private func addIntroView(model: CourseIntroduceModel) {
        scrollView.removeAllSubviews()
        let view = CourseIntroduceView(model: model)
        scrollView.addSubview(view)
        view.snp.makeConstraints { (make) in
            make.width.equalTo(XDSize.screenWidth)
            make.left.top.bottom.equalTo(scrollView)
        }
    }
    
    override func createModel() {
        let urlStr = String(format: XD_API_COURSE_INTRO, courseID)
        model = SSURLReqeustModel(httpMethod: .get, urlString: urlStr, loadFromFile: false, isPaged: false)
    }
    
    override func didFinishLoad(with object: Any!) {
        if let data = (object as! [String : Any])["data"] as? [String : Any] {
            if let model = CourseIntroduceModel.yy_model(with: data) {
                addIntroView(model: model)
            }
        }
    }
}
