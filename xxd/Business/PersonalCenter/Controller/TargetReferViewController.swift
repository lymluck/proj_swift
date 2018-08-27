//
//  TargetReferViewController.swift
//  xxd
//
//  Created by remy on 2018/1/11.
//  Copyright © 2018年 com.smartstudy. All rights reserved.
//

private var kTargetReferKey: UInt8 = 0

/// 意向国家对比
class TargetReferViewController: SSViewController {
    var isFromIndexVC: Bool = false {
        didSet {
            isGesturePopEnable = false
        }
    }
    let scrollView = XDScrollView(frame: CGRect(x: 0, y: XDSize.topHeight, width: XDSize.screenWidth, height: XDSize.visibleHeight))
    private lazy var targetCountryVC: EditInfoViewController = {
        let vc = EditInfoViewController(title: "意向国家", type: .list)
        vc.defaultValue = XDUser.shared.model.value(forKey: "targetCountryId") as! String
        vc.isFromInfoVC = false
        return vc
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        XDStatistics.click("5_B_compare_countries")
        title = "title_target_place_refer".localized
        navigationBar.bottomLine.isHidden = true
        
        scrollView.bottomSpace = 10
        scrollView.backgroundColor = UIColor.white
        view.addSubview(scrollView)
        
        let imageNames = ["target_highschool_bg","target_undergraduate_bg","target_graduate_bg"]
        let urlPaths = [XD_WEB_HIGHSCHOOL_REFER_DETAIL,XD_WEB_UNDERGRADUATE_REFER_DETAIL,XD_WEB_GRADUATE_REFER_DETAIL]
        let titleTexts = "target_place_refer_desc".localized.components(separatedBy: ",")
        
        for i in 0..<imageNames.count {
            let view = UIView(frame: CGRect(x: 0.0, y: 16 + (171.0/375.0*XDSize.screenWidth) * CGFloat(i), width: XDSize.screenWidth, height: 171.0/375.0*XDSize.screenWidth), color: UIColor.clear)
//            view.layer.shadowOpacity = 0.1
//            view.layer.shadowColor = UIColor.white.cgColor
            view.layer.shadowRadius = 6
//            view.layer.shadowOffset = CGSize(width: 0, height: 2)
            objc_setAssociatedObject(view, &kTargetReferKey, [QueryKey.URLPath:urlPaths[i],QueryKey.TitleName:titleTexts[i]], .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(gotoTargetReferDetail(gestureRecognizer:))))
            scrollView.addSubview(view)
            
            let imageView = UIImageView(frame: CGRect(x: 8.0, y: 0, width: 359.0/375.0*XDSize.screenWidth, height: 171.0/375.0*XDSize.screenWidth), imageName: imageNames[i])!
//            imageView.contentMode = .center
//            imageView.layer.masksToBounds = true
//            imageView.layer.cornerRadius = 6
//            imageView.layer.shadowColor = UIColor.white.cgColor
//            imageView.layer.shadowRadius = 8
//            imageView.layer.shadowOffset = CGSize(width: 0, height: 2)
            view.addSubview(imageView)
            
//            let titleView = UILabel(frame: CGRect(x: 0, y: 61, width: view.width, height: 25), text: titleTexts[i], textColor: UIColor.white, fontSize: 18, bold: true)!
//            titleView.textAlignment = .center
//            if i == 2 {
//                titleView.top = 48
//                let subTitleView = UILabel(frame: CGRect(x: 0, y: titleView.bottom, width: view.width, height: 18), text: "target_place_refer_desc_tip".localized, textColor: UIColor.white, fontSize: 13)!
//                subTitleView.textAlignment = .center
//                view.addSubview(subTitleView)
//            }
//            view.addSubview(titleView)
        }
    }
    
    @objc func gotoTargetReferDetail(gestureRecognizer: UIGestureRecognizer) {
        if let dict = objc_getAssociatedObject(gestureRecognizer.view!, &kTargetReferKey) as? [String: String] {
            XDRoute.pushWebVC(dict)
        }
    }
    
    override func backActionTap() {
        if isFromIndexVC {
            let alertVC: UIAlertController = UIAlertController(title: "要修改目前的意向国家吗", message: nil, preferredStyle: UIAlertControllerStyle.alert)
            let doneAction: UIAlertAction = UIAlertAction(title: "修改", style: UIAlertActionStyle.default) { (_) in
                self.isFromIndexVC = false
                self.requestTargetCountryData()
                XDRoute.pushToVC(self.targetCountryVC)
            }
            alertVC.addAction(doneAction)
            let cancelAction: UIAlertAction = UIAlertAction(title: "不修改", style: UIAlertActionStyle.cancel) { (_) in
                self.isFromIndexVC = false
                self.backActionTap()
            }
            alertVC.addAction(cancelAction)
            self.present(alertVC, animated: true, completion: nil)
        }
        super.backActionTap()
    }
    
    private func requestTargetCountryData() {
        XDPopView.loading()
        SSNetworkManager.shared().get(XD_API_PERSONAL_INFO_V2, parameters: nil, success: {
            [weak self] (task, responseObject) in
            if let data = (responseObject as? [String : Any])!["data"] as? [String : Any], let strongSelf = self {
                if let tartgetSection = data["targetSection"] as? [String: Any], let targetCountry = tartgetSection["targetCountry"] as? [String: Any], let targetCountryOptions = targetCountry["options"] as? [[String: Any]] {
                    print(targetCountryOptions)
                    if let dataList = NSArray.yy_modelArray(with: EditInfoModel.self, json: targetCountryOptions) as? [EditInfoModel] {
                        strongSelf.targetCountryVC.dataList = dataList
                    }
                }
            }
            XDPopView.hide()
        }) { (task, error) in
            XDPopView.toast(error.localizedDescription)
        }
    }
}
