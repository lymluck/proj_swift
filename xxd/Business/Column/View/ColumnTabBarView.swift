//
//  ColumnTabBarView.swift
//  xxd
//
//  Created by Lisen on 2018/7/20.
//  Copyright © 2018年 com.smartstudy. All rights reserved.
//

import UIKit

private let kButtonLikeViewTapEvent: String = "kCustomButtonLikeTapEvent"
private let kButtonLikeViewTag: Int = 100

@objc protocol ColumnTabBarViewDelegate {
    func columnTabBarViewDidSelect(index: Int)
}

/// 文章详情界面的底部视图
class ColumnTabBarView: UIView {
    weak var delegate: ColumnTabBarViewDelegate?
    var likeCounts: Int = 0 {
        didSet {
            likeView.title = "赞 \(likeCounts)"
        }
    }
    var commentCounts: Int = 0 {
        didSet {
            commentView.title = "评论 \(commentCounts)"
        }
    }
    private let btnWidth: CGFloat = XDSize.screenWidth/3.0
    private lazy var topLine: UIView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: XDSize.screenWidth, height: XDSize.unitWidth), color: XDColor.textPlaceholder)
    lazy var likeView: CustomButtonLikeView = {
        let view: CustomButtonLikeView = CustomButtonLikeView(frame: CGRect(x: 0.0, y: 0.0, width: btnWidth, height: 49.0), normalImage: "like_column_normal", selectedImage: "like_column_selected", selectedColor: XDColor.main)
        view.title = "赞 0"
        view.tag = kButtonLikeViewTag
        return view
    }()
    lazy var collectView: CustomButtonLikeView = {
        let view: CustomButtonLikeView = CustomButtonLikeView(frame: CGRect(x: btnWidth, y: 0.0, width: btnWidth, height: 49.0), normalImage: "collect_normal", selectedImage: "collect_selected", selectedColor: XDColor.main)
        view.title = "收藏"
        view.tag = kButtonLikeViewTag+1
        return view
    }()
    private lazy var commentView: CustomButtonLikeView = {
        let view: CustomButtonLikeView = CustomButtonLikeView(frame: CGRect(x: btnWidth*2.0, y: 0.0, width: btnWidth, height: 49.0), normalImage: "comment", selectedImage: "comment", selectedColor: XDColor.itemText)
        view.title = "评论 0"
        view.tag = kButtonLikeViewTag+2
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.white
        addSubview(topLine)
        addSubview(likeView)
        addSubview(collectView)
        addSubview(commentView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func routerEvent(name: String, data: Dictionary<String, Any>) {
        if name == kButtonLikeViewTapEvent, let buttonTag = data["viewTag"] as? Int {
            guard let _ = delegate?.columnTabBarViewDidSelect(index: buttonTag-kButtonLikeViewTag) else { return }
        }
    }
}

/// 图片在上文字在下控件封装
class CustomButtonLikeView: UIView {
    var title: String? {
        didSet {
            titleLabel.text = title
        }
    }
    private var normalImage: String!
    private var selectedImage: String!
    private var selectedColor: UIColor!
    var isSelected: Bool = false {
        didSet {
            if isSelected {
                titleLabel.textColor = selectedColor
                iconImageView.image = UIImage(named: selectedImage)
            } else {
                titleLabel.textColor = XDColor.itemText
                iconImageView.image = UIImage(named: normalImage)
            }
        }
    }
    private lazy var iconImageView: UIImageView = UIImageView(frame: CGRect.zero)
    private lazy var titleLabel: UILabel = UILabel(frame: CGRect.zero, text: "", textColor: XDColor.itemText, fontSize: 10.0)
    
    init(frame: CGRect, normalImage: String, selectedImage: String, selectedColor: UIColor) {
        self.normalImage = normalImage
        self.selectedImage = selectedImage
        self.selectedColor = selectedColor
        super.init(frame: frame)
        initContentViews()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        isSelected = !isSelected
        routerEvent(name: kButtonLikeViewTapEvent, data: ["viewTag": tag])
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    private func initContentViews() {
        iconImageView.image = UIImage(named: self.normalImage)
        addSubview(iconImageView)
        iconImageView.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.top.equalTo(5.0)
        }
        addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (make) in
            make.top.equalTo(iconImageView.snp.bottom).offset(1.0)
            make.centerX.equalToSuperview()
        }
    }
}
