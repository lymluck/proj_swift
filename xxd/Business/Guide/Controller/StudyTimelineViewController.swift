//
//  StudyTimelineViewController.swift
//  xxd
//
//  Created by remy on 2018/1/15.
//  Copyright © 2018年 com.smartstudy. All rights reserved.
//

let kEventMoveTimeline = "kEventMoveTimeline"
private var kReferLabelViewKey: UInt8 = 0
private var kLabelOriginTextKey: UInt8 = 0
private let tailTruncationString = "...         ."

class StudyTimelineViewController: SSViewController, UIScrollViewDelegate {
    
    var dataList = [StudyTimelineModel]()
    var stageView: UIView!
    var model: StudyTimelineModel!
    var stageList = [UIView]()
    var currentIndex = 0
    var currentStageBubble: UIView?
    private var scrollView: UIScrollView!
    
    override func needNavigationBar() -> Bool {
        return false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let line = UIView(frame: .zero, color: XDColor.itemLine)
        view.addSubview(line)
        line.snp.makeConstraints({ (make) in
            make.top.bottom.equalTo(view)
            make.left.equalTo(view).offset(28)
            make.width.equalTo(2)
        })
        
        scrollView = UIScrollView(frame: CGRect(x: 0, y: 0, width: XDSize.screenWidth, height: XDSize.visibleHeight - 40))
        scrollView.backgroundColor = UIColor.clear
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.scrollsToTop = false
        scrollView.alwaysBounceVertical = true
        scrollView.delegate = self
        view.addSubview(scrollView)
        
        var lastSatgeView: UIView!
        for (index, model) in dataList.enumerated() {
            stageView = UIView(frame: .zero, color: UIColor.clear)
            scrollView.addSubview(stageView)
            stageView.snp.makeConstraints({ (make) in
                if lastSatgeView == nil {
                    make.top.equalTo(scrollView)
                } else {
                    make.top.equalTo(lastSatgeView.snp.bottom)
                }
                make.left.equalTo(scrollView)
                make.width.equalTo(XDSize.screenWidth)
                if index == dataList.count - 1 {
                    make.bottom.equalTo(scrollView)
                }
            })
            stageList.append(stageView)
            lastSatgeView = stageView
            self.model = model
            addTopSection()
        }
    }
    
    func addTopSection() {
        let topBubble = UIView(frame: CGRect(x: 60, y: 22, width: XDSize.screenWidth - 76, height: 0), color: UIColor.white)
        topBubble.layer.cornerRadius = 12
        stageView.addSubview(topBubble)
        
        let flag = UIView(frame: CGRect(x: -52, y: 4, width: 42, height: 42), color: XDColor.mainBackground)
        flag.layer.cornerRadius = 21
        topBubble.addSubview(flag)
        let layer = CAGradientLayer()
        layer.frame = CGRect(x: 4, y: 4, width: 34, height: 34)
        layer.cornerRadius = 17
        layer.colors = [UIColor(0x11C0F9).cgColor, UIColor(0x078CF1).cgColor]
        flag.layer.addSublayer(layer)
        let flagTitle = UILabel(text: model.grade, textColor: UIColor.white, fontSize: 12)!
        flag.addSubview(flagTitle)
        flagTitle.snp.makeConstraints({ (make) in
            make.center.equalTo(flag)
        })
        
        addBubbleArrow(topBubble, flag)
        addBubbleTitle("关键词", topBubble, false)
        
        if let keywords = model.keywords, keywords.count > 0 {
            var lastLabel: UILabel!
            var offset: CGFloat = 0
            for keyword in keywords {
                let width = keyword.widthForFont(UIFont.systemFont(ofSize: 13)) + 16
                var top: CGFloat = 41 + offset * 34
                var left: CGFloat = 16
                if lastLabel != nil {
                    if width + lastLabel.right + 22 > topBubble.width {
                        top += 34
                        offset += 1
                    } else {
                        left = lastLabel.right + 6
                    }
                }
                let keyLabel = UILabel(frame: CGRect(x: left, y: top, width: width, height: 26), text: keyword, textColor: XDColor.main, fontSize: 13)!
                keyLabel.textAlignment = .center
                keyLabel.layer.cornerRadius = 4
                keyLabel.backgroundColor = XDColor.main.withAlphaComponent(0.08)
                keyLabel.layer.borderWidth = XDSize.unitWidth
                keyLabel.layer.borderColor = XDColor.main.cgColor
                topBubble.addSubview(keyLabel)
                lastLabel = keyLabel
            }
            topBubble.height = 41 + (offset + 1) * 34 + 4
        }
        addMiddleSection(topBubble)
    }
    
    func addMiddleSection(_ lastBubble: UIView) {
        var lastBubble = lastBubble
        if let models = model.subModels {
            for (index, model) in models.enumerated() {
                let bubble = UIView(frame: .zero, color: UIColor.white)
                bubble.layer.cornerRadius = 12
                stageView.addSubview(bubble)
                bubble.snp.makeConstraints({ (make) in
                    make.top.equalTo(lastBubble.snp.bottom).offset(16)
                    make.left.equalTo(stageView).offset(60)
                    make.right.equalTo(stageView).offset(-16)
                    if index == models.count - 1 {
                        make.bottom.equalTo(stageView).offset(-16)
                    }
                })
                
                addBubbleFlag(bubble, model.isCurrentStage)
                addBubbleTitle(model.time, bubble, model.isCurrentStage)
                addBubbleName(model.name, bubble)
                addBubbleContent(model.items!, bubble)
                
                lastBubble = bubble
                if model.isCurrentStage {
                    currentStageBubble = bubble
                }
            }
        }
    }
    
    func addBubbleFlag(_ superView: UIView, _ isCurrent: Bool) {
        var flag: UIView!
        if isCurrent {
            flag = UIImageView(frame: CGRect(x: -43, y: 11, width: 24, height: 24), imageName: "current_stage_flag")
            superView.addSubview(flag)
        } else {
            flag = UIView(frame: CGRect(x: -39, y: 15, width: 16, height: 16), color: XDColor.mainBackground)
            flag.layer.cornerRadius = 8
            superView.addSubview(flag)
            let circle = UIView(frame: CGRect(x: 4, y: 4, width: 8, height: 8), color: XDColor.main)
            circle.layer.cornerRadius = 4
            flag.addSubview(circle)
        }
        addBubbleArrow(superView, flag)
    }
    
    func addBubbleArrow(_ superView: UIView, _ referView: UIView) {
        let arrow = UIView(frame: .zero, color: UIColor.white)
        arrow.transform = CGAffineTransform(rotationAngle: .pi / 4)
        superView.addSubview(arrow)
        arrow.snp.makeConstraints({ (make) in
            make.centerY.equalTo(referView)
            make.left.equalTo(superView).offset(-5)
            make.size.equalTo(CGSize(width: 10, height: 10))
        })
    }
    
    func addBubbleTitle(_ text: String, _ superView: UIView, _ isCurrent: Bool) {
        let view = UILabel(frame: .zero, text: text, textColor: XDColor.itemTitle, fontSize: 17, bold: true)!
        if isCurrent {
            view.text = "\(text)（当前位置）"
            view.textColor = UIColor(0xFF9C08)
        }
        superView.addSubview(view)
        view.snp.makeConstraints({ (make) in
            make.right.equalTo(superView).offset(-16)
            make.left.equalTo(superView).offset(16)
            make.top.equalTo(superView).offset(12)
        })
    }
    
    func addBubbleName(_ text: String, _ superView: UIView) {
        let view = UILabel(frame: .zero, text: text, textColor: XDColor.itemText, fontSize: 13)!
        superView.addSubview(view)
        view.snp.makeConstraints({ (make) in
            make.right.equalTo(superView).offset(-16)
            make.left.equalTo(superView).offset(16)
            make.top.equalTo(superView).offset(39)
        })
    }
    
    func addBubbleContent(_ texts: [String], _ superView: UIView) {
        let text = texts.joined(separator: "，")
        let view = NIAttributedLabel()
        view.tailTruncationString = tailTruncationString
        view.textColor = XDColor.itemTitle
        view.font = UIFont.systemFont(ofSize: 14)
        view.numberOfLines = 4
        view.lineHeight = 20
        view.text = text
        objc_setAssociatedObject(view, &kLabelOriginTextKey, texts, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        superView.addSubview(view)
        let labelWidth = XDSize.screenWidth - 82
        let size = view.sizeThatFits(CGSize(width: labelWidth, height: .greatestFiniteMagnitude))
        view.snp.makeConstraints({ (make) in
            make.edges.equalTo(superView).inset(UIEdgeInsetsMake(64, 16, 12, 16))
            make.height.equalTo(size.height)
        })
        let height = text.heightForFont(view.font, labelWidth, 20)
        if height > 80 {
            addUnfoldButton(superView, view)
        }
    }
    
    func addUnfoldButton(_ referView: UIView, _ label: UILabel) {
        let btn = UIButton(frame: .zero, title: "", fontSize: 0, titleColor: UIColor.clear, target: self, action: #selector(unfoldTap(sender:)))!
        objc_setAssociatedObject(btn, &kReferLabelViewKey, label, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        referView.addSubview(btn)
        btn.snp.makeConstraints({ (make) in
            make.size.equalTo(CGSize(width: 48, height: 20))
            make.right.equalTo(referView).offset(-16)
            make.bottom.equalTo(referView).offset(-12)
        })
        let textLabel = UILabel(text: "unfold".localized, textColor: XDColor.main, fontSize: 14)!
        textLabel.backgroundColor = UIColor.white
        btn.addSubview(textLabel)
        textLabel.snp.makeConstraints({ (make) in
            make.right.top.height.equalTo(btn)
        })
    }
    
    //MARK:- UIScrollViewDelegate
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        var index = 3
        if offsetY < stageList[1].top {
            index = 0
        } else if offsetY < stageList[2].top {
            index = 1
        } else if offsetY < stageList[3].top {
            index = 2
        }
        if index != currentIndex {
            currentIndex = index
            routerEvent(name: kEventMoveTimeline, data: ["index":index])
        }
    }
    
    //MARK:- Action
    func moveToStage(index: Int) {
        currentIndex = index
        scrollView.setContentOffset(CGPoint(x: 0, y: stageList[index].top), animated: false)
    }
    
    func moveToStagePoint() {
        if let currentStageBubble = currentStageBubble {
            let top = currentStageBubble.top + currentStageBubble.superview!.top - 16
            scrollView.setContentOffset(CGPoint(x: 0, y: top), animated: false)
        }
    }
    
    @objc func unfoldTap(sender: UIButton) {
        let label = objc_getAssociatedObject(sender, &kReferLabelViewKey) as! NIAttributedLabel
        label.tailTruncationString = ""
        label.numberOfLines = 0
        let texts = objc_getAssociatedObject(label, &kLabelOriginTextKey) as! [String]
        label.text = texts.joined(separator: "\n\n")
        let size = label.sizeThatFits(CGSize(width: label.width, height: .greatestFiniteMagnitude))
        label.snp.updateConstraints({ (make) in
            make.height.equalTo(size.height)
        })
        sender.removeFromSuperview()
    }
}
