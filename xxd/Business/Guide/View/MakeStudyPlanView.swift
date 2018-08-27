//
//  MakeStudyPlanView.swift
//  xxd
//
//  Created by remy on 2018/1/15.
//  Copyright © 2018年 com.smartstudy. All rights reserved.
//

let kEventStudyPlanMakeTap = "kEventStudyPlanMakeTap"
let kEventStudyPlanItemTap = "kEventStudyPlanItemTap"
private let kItemHeight: CGFloat = 64

class MakeStudyPlanView: UIScrollView {
    
    private var userItems = [XDItemView]()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.clear
        showsHorizontalScrollIndicator = false
        showsVerticalScrollIndicator = false
        scrollsToTop = false
        alwaysBounceVertical = true
        
        let panelHeight = (height - 444) / 2 - 5
        let panel = UIView(frame: CGRect(x: 24, y: panelHeight, width: XDSize.screenWidth - 48, height: 444), color: UIColor.white)
        panel.layer.cornerRadius = 12
        panel.layer.shadowOpacity = 0.1
        panel.layer.shadowColor = UIColor.black.cgColor
        panel.layer.shadowRadius = 8
        panel.layer.shadowOffset = CGSize(width: 0, height: 2)
        addSubview(panel)
        
        let titleLabel = UILabel(frame: .zero, text: "留学规划", textColor: XDColor.itemTitle, fontSize: 20, bold: true)!
        panel.addSubview(titleLabel)
        titleLabel.snp.makeConstraints({ (make) in
            make.top.equalTo(panel).offset(51)
            make.centerX.equalTo(panel)
        })
        
        let keys = ["留学项目", "当前年级"];
        let paramKeys = ["targetDegreeId", "currentGradeId"];
        for (index, key) in keys.enumerated() {
            let item = XDItemView(frame: CGRect(x: 16, y: 129 + kItemHeight * CGFloat(index), width: panel.width - 32, height: kItemHeight), type: .bottom)
            item.isRightArrow = true
            item.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(itemTap(gestureRecognizer:))))
            panel.addSubview(item)
            userItems.append(item)
            
            let titleLabel = UILabel(frame: CGRect(x: 16, y: 21, width: 85, height: 22), text: key, textColor: XDColor.itemText, fontSize: 16)!
            item.addSubview(titleLabel)
            
            let content = UILabel(frame: CGRect(x: 101, y: 21, width: item.width - 133, height: 22), text: "", textColor: XDColor.itemTitle, fontSize: 16)!
            item.addSubview(content)
            
            item.info = ["content":content,"title":titleLabel,"paramKey":paramKeys[index],"value":"","name":""]
        }
        
        let desc = UILabel(frame: .zero, text: "", textColor: XDColor.itemText, fontSize: 12)!
        desc.setText("此智能留学规划系统仅适用于申请美本和美研的用户", lineHeight: 16)
        desc.textAlignment = .center
        desc.numberOfLines = 0
        panel.addSubview(desc)
        desc.snp.makeConstraints({ (make) in
            make.bottom.equalTo(panel).offset(-24)
            make.centerX.equalTo(panel)
            make.width.equalTo(panel.width - 140)
        })
        
        let getPlan = UIButton(frame: .zero, title: "获取留学规划", fontSize: 16, titleColor: UIColor.white, target: self, action: #selector(getPlan(sender:)))!
        getPlan.backgroundColor = XDColor.main
        getPlan.layer.cornerRadius = 6
        panel.addSubview(getPlan)
        getPlan.snp.makeConstraints({ (make) in
            make.bottom.equalTo(desc.snp.top).offset(-24)
            make.centerX.equalTo(panel)
            make.size.equalTo(CGSize(width: panel.width - 84, height: 42))
        })
        
        refreshItemStatus()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func clearItem(index: Int) {
        let item = userItems[index]
        item.info["value"] = ""
        item.info["name"] = ""
        (item.info["content"] as! UILabel).text = ""
    }
    
    func refreshItemStatus() {
        userItems[1].enabled = !(userItems[0].info["value"] as! String).isEmpty
    }
    
    //MARK:- Action
    @objc func getPlan(sender: UIButton) {
        routerEvent(name: kEventStudyPlanMakeTap, data: [:])
    }
    
    @objc func itemTap(gestureRecognizer: UIGestureRecognizer) {
        if let item = gestureRecognizer.view as? XDItemView, item.enabled {
            routerEvent(name: kEventStudyPlanItemTap, data: ["item":item])
        }
    }
}
