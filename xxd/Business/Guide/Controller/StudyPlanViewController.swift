//
//  StudyPlanViewController.swift
//  xxd
//
//  Created by remy on 2018/1/15.
//  Copyright © 2018年 com.smartstudy. All rights reserved.
//

class StudyPlanViewController: SSViewController {
    
    override func needNavigationBar() -> Bool {
        return false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Preference.SHOW_STUDY_PLAN.set(true)
        view.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        
        var viewWidth: CGFloat = 300;
        var viewHeight: CGFloat = 400;
        if XDSize.screenWidth < 375 {
            viewWidth = XDSize.screenWidth - 75
            viewHeight = (viewWidth * 4 / 3).rounded(.up)
        }
        let imageView = UIImageView(frame: .zero, imageName: "study_plan")!
        imageView.isUserInteractionEnabled = true
        imageView.contentMode = .scaleAspectFill
        imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(enterTap)))
        view.addSubview(imageView)
        imageView.snp.makeConstraints({ (make) in
            make.centerX.equalTo(view)
            make.centerY.equalTo(view).offset(-12)
            make.size.equalTo(CGSize(width: viewWidth, height: viewHeight))
        })
        
        let closeBtn = UIButton(frame: .zero, title: "", fontSize: 0, titleColor: UIColor.clear, target: self, action: #selector(closeTap))!
        closeBtn.setImage(UIImage(named: "close_card"), for: .normal)
        view.addSubview(closeBtn)
        closeBtn.snp.makeConstraints({ (make) in
            make.right.equalTo(imageView)
            make.bottom.equalTo(imageView.snp.top).offset(-18)
            make.size.equalTo(CGSize(width: 30, height: 30))
        })
    }
    
    //MARK:- Action
    @objc func closeTap() {
        dismiss(animated: false, completion: nil)
    }
    
    @objc func enterTap() {
        XDPopView.loading()
        SSNetworkManager.shared().get(XD_API_ABROAD_TIMELINES, parameters: nil, success: { [weak self] (task, responseObject) in
            let dict = responseObject as? [String : Any]
            self?.gotoPlan(dict)
            XDPopView.hide()
        }) { [weak self] (task, error) in
            self?.gotoPlan(nil)
            XDPopView.hide()
        }
    }
    
    func gotoPlan(_ data: [String : Any]?) {
        dismiss(animated: false, completion: nil)
        let vc = StudyPlanDetailViewController()
        if let data = data?["data"] as? [Any] {
            vc.dataList = data
        }
        if let tabvc = presentingViewController as? UITabBarController {
            (tabvc.selectedViewController as! UINavigationController).pushViewController(vc, animated: true)
        }
    }
}
