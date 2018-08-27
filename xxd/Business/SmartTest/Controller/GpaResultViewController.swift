//
//  GpaResultViewController.swift
//  xxd
//
//  Created by remy on 2018/1/30.
//  Copyright © 2018年 com.smartstudy. All rights reserved.
//

class GpaResultViewController: SSViewController {
    
    var resultData = [[String : Any]]()
    private var scrollView: XDScrollView!
    private var descView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "GPA计算"
        
        scrollView = XDScrollView(frame: CGRect(x: 0, y: XDSize.topHeight, width: XDSize.screenWidth, height: XDSize.visibleHeight))
        view.addSubview(scrollView)
        
        for i in 0..<8 {
            addScoreItem(i)
        }
        
        descView = UIView(frame: CGRect(x: 0, y: CGFloat(resultData.count * 64), width: XDSize.screenWidth, height: 66))
        scrollView.addSubview(descView)
        
        let attr = NSAttributedString(string: "GPA算法说明").underline
        let desc = UILabel(text: "", textColor: XDColor.itemText, fontSize: 13)!
        desc.attributedText = attr
        desc.isUserInteractionEnabled = true
        desc.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(descTap(gestureRecognizer:))))
        descView.addSubview(desc)
        desc.snp.makeConstraints({ (make) in
            make.centerX.equalTo(descView).offset(11)
            make.centerY.equalTo(descView)
            make.height.equalTo(40)
        })
        
        let image = UIImage(named: "smart_major_info")!
        let imageView = UIImageView(image: image.tint(UIColor(0x999999)))
        descView.addSubview(imageView)
        imageView.snp.makeConstraints({ (make) in
            make.centerY.equalTo(descView)
            make.right.equalTo(desc.snp.left).offset(-6)
        })
    }
    
    func addScoreItem(_ index: Int) {
        let data = resultData[index]
        let view = UIView(frame: CGRect(x: 0, y: CGFloat(index * 64), width: XDSize.screenWidth, height: 64), color: UIColor.white)
        view.addSubview(UIView(frame: CGRect(x: 0, y: view.height - XDSize.unitWidth, width: XDSize.screenWidth, height: XDSize.unitWidth), color: XDColor.itemLine))
        scrollView.addSubview(view)
        
        let text = "•  \(data["name"] as! String)"
        let titleLabel = UILabel(text: text, textColor: XDColor.itemTitle, fontSize: 16)!
        view.addSubview(titleLabel)
        titleLabel.snp.makeConstraints({ (make) in
            make.left.equalTo(view).offset(16)
            make.centerY.equalTo(view)
        })
        
        let scoreLabel = UILabel(frame: .zero, text: data["gpaResult"] as! String, textColor: UIColor(0xFF9C08), fontSize: 20, bold: true)!
        view.addSubview(scoreLabel)
        scoreLabel.snp.makeConstraints({ (make) in
            make.right.equalTo(view).offset(-16)
            make.centerY.equalTo(view)
        })
    }
    
    //MARK:- Action
    @objc func descTap(gestureRecognizer: UIGestureRecognizer) {
        let vc = GpaDescViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
}
