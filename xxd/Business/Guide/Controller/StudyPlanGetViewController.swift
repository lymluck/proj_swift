//
//  StudyPlanGetViewController.swift
//  xxd
//
//  Created by remy on 2018/1/15.
//  Copyright © 2018年 com.smartstudy. All rights reserved.
//

class StudyPlanGetViewController: SSViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "留学规划"
        
        let getNow = UIButton(frame: .zero, title: "立即领取", fontSize: 16, titleColor: UIColor.white, target: self, action: #selector(getNowTap(sender:)))!
        getNow.backgroundColor = XDColor.main
        getNow.layer.cornerRadius = 6
        view.addSubview(getNow)
        getNow.snp.makeConstraints({ (make) in
            make.centerX.equalTo(view)
            make.centerY.equalTo(view).offset(-30)
            make.size.equalTo(CGSize(width: 175, height: 42))
        })
        
        let desc = UILabel(frame: .zero, text: "还未领取你的留学规划", textColor: XDColor.itemText, fontSize: 20)!
        view.addSubview(desc)
        desc.snp.makeConstraints({ (make) in
            make.centerX.equalTo(view)
            make.bottom.equalTo(getNow.snp.top).offset(-20)
        })
    }
    
    //MARK:- Action
    @objc func getNowTap(sender: UIButton) {
        let vc = StudyPlanDetailViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
}
