//
//  CollegeTopBarView.swift
//  xxd
//
//  Created by remy on 2018/2/27.
//  Copyright © 2018年 com.smartstudy. All rights reserved.
//

class CollegeTopBarView: UIView {
    
    private var contentView: UIView!
    private var bottomLine: UIView!
    private var backBtn: UIButton!
    var centerView: UILabel!
    var title = "" {
        didSet {
            centerView.text = title
        }
    }
    var leftView: UIView! {
        didSet {
            contentView.addSubview(leftView)
            let top = ((contentView.width - leftView.height) * 0.5).rounded(.down)
            leftView.origin = CGPoint(x: 0, y: top)
        }
    }
    
    convenience init() {
        self.init(frame: CGRect(x: 0, y: 0, width: XDSize.screenWidth, height: XDSize.topHeight))
        backgroundColor = UIColor.white
        
        contentView = UIView(frame: CGRect(x: 0, y: XDSize.statusBarHeight, width: XDSize.screenWidth, height: XDSize.topBarHeight))
        addSubview(contentView)
        
        centerView = UILabel(frame: CGRect(x: XDSize.topBarHeight, y: 0, width: XDSize.screenWidth - XDSize.topBarHeight * 2, height: contentView.height), text: "", textColor: XDColor.itemTitle, fontSize: 17, bold: true)!
        centerView.textAlignment = .center
        contentView.addSubview(centerView)
        
        backBtn = UIButton(frame: CGRect(x: 0, y: 0, width: XDSize.topBarHeight, height: XDSize.topBarHeight), title: "", fontSize: 0, titleColor: UIColor.clear, target: self, action: #selector(backTap(sender:)))
        backBtn.setImage(UIImage(named: "top_left_arrow"), for: .normal)
        contentView.addSubview(backBtn)
        
        bottomLine = UIView(frame: CGRect(x: 0, y: contentView.height - XDSize.unitWidth, width: XDSize.screenWidth, height: XDSize.unitWidth), color: XDColor.mainLine)
        contentView.addSubview(bottomLine)
    }
    
    //MARK:- Action
    @objc func backTap(sender: UIButton) {
        UIApplication.topVC()?.navigationController?.popViewController(animated: true)
    }
}
