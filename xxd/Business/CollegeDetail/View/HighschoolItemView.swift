//
//  HighschoolItemView.swift
//  xxd
//
//  Created by remy on 2018/4/3.
//  Copyright © 2018年 com.smartstudy. All rights reserved.
//

import SSPhotoBrowser

let kTextUnfoldButtonTap = "kTextUnfoldButtonTap"
private let kDetailTitleHeight: CGFloat = 41
private protocol HighschoolDetailItemType {}
extension HighschoolDetailItemType where Self: UIView {
    func sectionTitle(_ text: String, fontSize: CGFloat = 18.0) {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: XDSize.screenWidth, height: kDetailTitleHeight))
        let titleLabel = UILabel(frame: .zero, text: text, textColor: XDColor.itemTitle, fontSize: fontSize, bold: true)!
        view.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(16)
            make.right.lessThanOrEqualToSuperview().offset(-16)
            make.bottom.equalToSuperview()
        }
        self.addSubview(view)
    }
}

private let tailTruncationString = "...          ."
private let kDetailTextLineHeight: CGFloat = 25
private var kLabelOriginTextKey: Void?
class HighschoolDetailTextView: UIView, HighschoolDetailItemType {
    
    var isHiddenSeparatorView: Bool = true {
        didSet {
            separatorView.isHidden = isHiddenSeparatorView
        }
    }
    private var numberOfLines: CGFloat = 4.0
    private var contentLabel: NIAttributedLabel!
    private lazy var separatorView: UIView = {
        let view: UIView = UIView(frame: CGRect.zero, color: XDColor.itemLine)
        view.isHidden = true
        return view
    }()
    var text = "" {
        didSet {
            contentLabel.text = text.replacingOccurrences(of: "\n", with: "，")
            objc_setAssociatedObject(contentLabel, &kLabelOriginTextKey, text, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            let labelWidth = XDSize.screenWidth - 32
            let size = contentLabel.sizeThatFits(CGSize(width: labelWidth, height: .greatestFiniteMagnitude))
            contentLabel.snp.makeConstraints { (make) in
                make.edges.equalToSuperview().inset(UIEdgeInsetsMake(56, 16, 19, 16))
                make.width.equalTo(labelWidth)
                make.height.equalTo(size.height)
            }
            let height = text.heightForFont(contentLabel.font, labelWidth, kDetailTextLineHeight)
            if height > kDetailTextLineHeight * 4 {
                addUnfoldButton()
            }
            separatorView.snp.makeConstraints { (make) in
                make.left.equalTo(16.0)
                make.right.equalTo(-16.0)
                make.bottom.equalToSuperview()
                make.height.equalTo(XDSize.unitWidth)
            }
        }
    }
    
    convenience init(title: String, fontSize: CGFloat = 18.0) {
        self.init(frame: .zero)
        backgroundColor = UIColor.white
        // 标题
        sectionTitle(title, fontSize: fontSize)
        // 内容
        contentLabel = NIAttributedLabel()
        contentLabel.tailTruncationString = tailTruncationString
        contentLabel.textColor = XDColor.itemTitle
        contentLabel.font = UIFont.systemFont(ofSize: 15)
        contentLabel.lineHeight = kDetailTextLineHeight
        contentLabel.numberOfLines = 6
        addSubview(contentLabel)
        addSubview(separatorView)
    }
    
    func configureDetailContent(_ text: String, numberOfLines: CGFloat = 4.0, isNeedLinebreak: Bool = false) {
        self.numberOfLines = numberOfLines
        if isNeedLinebreak {
            contentLabel.text = text
            contentLabel.tailTruncationString = "...         "
        } else {
            contentLabel.text = text.replacingOccurrences(of: "\n", with: "，")
        }
        objc_setAssociatedObject(contentLabel, &kLabelOriginTextKey, text, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        let labelWidth = XDSize.screenWidth - 32
        let size = contentLabel.sizeThatFits(CGSize(width: labelWidth, height: .greatestFiniteMagnitude))
        contentLabel.snp.makeConstraints { (make) in
            make.edges.equalToSuperview().inset(UIEdgeInsetsMake(56, 16, 19, 16))
            make.width.equalTo(labelWidth)
            make.height.equalTo(size.height)
        }
        let height = text.heightForFont(contentLabel.font, labelWidth, kDetailTextLineHeight)
        if height > kDetailTextLineHeight*numberOfLines {
            addUnfoldButton()
        }
        separatorView.snp.makeConstraints { (make) in
            make.left.equalTo(16.0)
            make.right.equalTo(-16.0)
            make.bottom.equalToSuperview()
            make.height.equalTo(XDSize.unitWidth)
        }
    }
    
    private func addUnfoldButton() {
        let btn = UIButton(frame: .zero, title: "", fontSize: 0, titleColor: UIColor.clear, target: self, action: #selector(unfoldTap(sender:)))!
        btn.backgroundColor = UIColor.white
        objc_setAssociatedObject(btn, &kLabelOriginTextKey, contentLabel, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        addSubview(btn)
        btn.snp.makeConstraints({ (make) in
            make.size.equalTo(CGSize(width: 48, height: kDetailTextLineHeight))
            make.right.equalToSuperview().offset(-16)
            make.bottom.equalTo(contentLabel)
        })
        let textLabel = UILabel(text: "unfold".localized, textColor: XDColor.main, fontSize: 15)!
        btn.addSubview(textLabel)
        textLabel.snp.makeConstraints({ (make) in
            make.right.top.height.equalTo(btn)
        })
    }
    
    //MARK:- Action
    @objc func unfoldTap(sender: UIButton) {
        contentLabel.tailTruncationString = ""
        contentLabel.numberOfLines = 0
        let text = objc_getAssociatedObject(contentLabel, &kLabelOriginTextKey) as! String
        contentLabel.text = text
        let size = contentLabel.sizeThatFits(CGSize(width: contentLabel.width, height: .greatestFiniteMagnitude))
        contentLabel.snp.updateConstraints({ (make) in
            make.height.equalTo(size.height)
        })
        separatorView.snp.updateConstraints { (make) in
            make.bottom.equalToSuperview()
        }
        sender.removeFromSuperview()
        // TODO: UI通过之后修改计算方式
        routerEvent(name: kTextUnfoldButtonTap, data: ["increasedHeight": size.height-kDetailTextLineHeight*numberOfLines-kDetailTitleHeight-9.0])
    }
}

class HighschoolDetailImageListView: UIView, HighschoolDetailItemType {
    
    private var dataArray = [String]()
    private var contentView: UIScrollView!
    
    convenience init?(title: String, data: [String]) {
        self.init(frame: .zero)
        backgroundColor = UIColor.white
        dataArray = data
        guard dataArray.count > 0 else { return nil }
        // 标题
        sectionTitle(title)
        // 内容
        contentView = UIScrollView()
        contentView.showsHorizontalScrollIndicator = false
        contentView.showsVerticalScrollIndicator = false
        contentView.alwaysBounceHorizontal = true
        addSubview(contentView)
        for (index, value) in dataArray.enumerated() {
            let left = CGFloat(index) * 207 + 16
            let imageView = UIImageView(frame: CGRect(x: left, y: 0, width: 197, height: 130))
            imageView.contentMode = .scaleAspectFill
            imageView.setOSSImage(urlStr: value, size: CGSize(width: 197, height: 130), policy: .fill)
            imageView.isUserInteractionEnabled = true
            imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(imageTap(gestureRecognizer:))))
            imageView.tag = index
            contentView.addSubview(imageView)
        }
        contentView.contentSize = CGSize(width: CGFloat(dataArray.count) * 207 + 16, height: 130)
        contentView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview().inset(UIEdgeInsetsMake(61, 0, 24, 0))
            make.width.equalTo(XDSize.screenWidth)
            make.height.equalTo(130)
        }
    }
    
    //MARK:- Action
    @objc func imageTap(gestureRecognizer: UIGestureRecognizer) {
        let index = (gestureRecognizer.view as! UIImageView).tag
        let imgUrl = dataArray[index]
        if let imageBrowser = SSPhotoBrowser(photoURLs: dataArray) {
            imageBrowser.displayToolbar = false
            imageBrowser.displayDoneButton = false
            imageBrowser.dismissOnTouch = true
            imageBrowser.displayActionButton = false
            imageBrowser.forceHideStatusBar = true
            imageBrowser.currentPageIndex = UInt(index)
            imageBrowser.longPressedAction = {
                image in
                guard let aImage = image else { return }
                let params = [
                    "title": "",
                    "description": "",
                    "coverUrl": imgUrl
                ]
                XDShareView.shared.showSharePanel(shareURL: imgUrl, shareInfo: params, coverImage: aImage)
            }
            UIApplication.topVC()?.present(imageBrowser, animated: true, completion: nil)
        }
    }
}

class HighschoolDetailFormView: UIView, HighschoolDetailItemType {
    
    private let maxRows = 5
    private var contentHeight: CGFloat = 0
    private let textLineHeight: CGFloat = 21
    private var contentView: UIView!
    private var dataMap = [String : String]()
    private var dataArray = [String]()
    
    convenience init?(title: String, data: [String : String]) {
        self.init(frame: .zero)
        backgroundColor = UIColor.white
        dataMap = data.filter {
            return !$0.value.isEmpty
        }
        guard dataMap.count > 0 else { return nil }
        // 标题
        sectionTitle(title)
        // 内容
        contentView = UIView()
        addSubview(contentView)
        for (index, info) in dataMap.enumerated() {
            guard index < maxRows else { break }
            addMapItems(index, info)
        }
        contentView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview().inset(UIEdgeInsetsMake(49, 0, dataMap.count > maxRows ? 48 : 0, 0))
            make.width.equalTo(XDSize.screenWidth)
            make.height.equalTo(contentHeight)
        }
        if dataMap.count > maxRows {
            let btn = UIButton(frame: CGRect(x: 0, y: contentHeight + 49, width: XDSize.screenWidth, height: 48), title: "展开更多", fontSize: 15, titleColor: XDColor.main, target: self, action: #selector(unfoldMapList(sender:)))!
            addSubview(btn)
        }
    }
    
    convenience init?(title: String, data: [Any]) {
        self.init(frame: .zero)
        backgroundColor = UIColor.white
        if let data = data as? [[String : String]] {
            // 含字典的数组类型数据
            data.forEach {
                let en = $0["englishName"] ?? ""
                let cn = $0["chineseName"] ?? ""
                if !en.isEmpty || !cn.isEmpty {
                    dataArray.append(en + " " + cn)
                }
            }
        } else if let data = data as? [String] {
            // 含字符串的数组类型数据
            dataArray = data.filter {
                return !$0.isEmpty
            }
        } else {
            return nil
        }
        guard dataArray.count > 0 else { return nil }
        // 标题
        sectionTitle(title)
        // 内容
        contentView = UIView()
        addSubview(contentView)
        for (index, text) in dataArray.enumerated() {
            guard index < maxRows else { break }
            addArrayItems(index, text)
        }
        contentView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview().inset(UIEdgeInsetsMake(49, 0, dataArray.count > maxRows ? 48 : 0, 0))
            make.width.equalTo(XDSize.screenWidth)
            make.height.equalTo(contentHeight)
        }
        if dataArray.count > maxRows {
            let btn = UIButton(frame: CGRect(x: 0, y: contentHeight + 49, width: XDSize.screenWidth, height: 48), title: "展开更多", fontSize: 15, titleColor: XDColor.main, target: self, action: #selector(unfoldArrayList(sender:)))!
            addSubview(btn)
        }
    }
    
    private func addMapItems(_ index: Int, _ info: (key: String, value: String)) {
        let itemView = UIView(frame: CGRect(x: 16, y: contentHeight, width: XDSize.screenWidth - 32, height: 0))
        contentView.addSubview(itemView)
        // 行标题
        let titleLabel = UILabel(frame: CGRect(x: 0, y: 13, width: 0, height: textLineHeight), text: "", textColor: XDColor.itemText, fontSize: 15)!
        titleLabel.setText(info.key + ":", lineHeight: textLineHeight)
        titleLabel.width = info.key.widthForFont(titleLabel.font, textLineHeight) + 20
        itemView.addSubview(titleLabel)
        // 行内容
        let contentLabel = UILabel(frame: CGRect(x: titleLabel.right, y: 13, width: itemView.width - titleLabel.right, height: 0), text: "", textColor: XDColor.itemTitle, fontSize: 15)!
        contentLabel.numberOfLines = 0
        let attr = NSMutableAttributedString(string: info.value)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.minimumLineHeight = textLineHeight
        paragraphStyle.maximumLineHeight = textLineHeight
        paragraphStyle.alignment = .right
        attr.addAttribute(.paragraphStyle, value: paragraphStyle, range: NSMakeRange(0, info.value.count))
        contentLabel.attributedText = attr
        let height = info.value.heightForFont(contentLabel.font, contentLabel.width, textLineHeight)
        contentLabel.height = height
        itemView.addSubview(contentLabel)
        // 行
        itemView.height = height + 27
        contentHeight += itemView.height
        if index < dataMap.count - 1 {
            itemView.addSubview(UIView(frame: CGRect(x: 0, y: itemView.height - XDSize.unitWidth, width: itemView.width, height: XDSize.unitWidth), color: XDColor.itemLine))
        }
    }
    
    private func addArrayItems(_ index: Int, _ text: String) {
        let itemView = UIView(frame: CGRect(x: 16, y: contentHeight, width: XDSize.screenWidth - 32, height: 0))
        contentView.addSubview(itemView)
        // 行内容
        let contentLabel = UILabel(frame: CGRect(x: 0, y: 13, width: itemView.width, height: 0), text: "", textColor: XDColor.itemTitle, fontSize: 15)!
        contentLabel.numberOfLines = 0
        let text = "• " + text
        contentLabel.setText(text, lineHeight: textLineHeight)
        let height = text.heightForFont(contentLabel.font, contentLabel.width, textLineHeight)
        contentLabel.height = height
        itemView.addSubview(contentLabel)
        // 行
        itemView.height = height + 27
        contentHeight += itemView.height
        if index < dataArray.count - 1 {
            itemView.addSubview(UIView(frame: CGRect(x: 0, y: itemView.height - XDSize.unitWidth, width: itemView.width, height: XDSize.unitWidth), color: XDColor.itemLine))
        }
    }
    
    //MARK:- Action
    @objc func unfoldMapList(sender: UIButton) {
        for (index, info) in dataMap.enumerated() {
            guard index >= maxRows else { continue }
            addMapItems(index, info)
        }
        contentView.snp.updateConstraints { (make) in
            make.edges.equalToSuperview().inset(UIEdgeInsetsMake(49, 0, 0, 0))
            make.height.equalTo(contentHeight)
        }
        sender.removeFromSuperview()
    }
    
    @objc func unfoldArrayList(sender: UIButton) {
        for (index, text) in dataArray.enumerated() {
            guard index >= maxRows else { continue }
            addArrayItems(index, text)
        }
        contentView.snp.updateConstraints { (make) in
            make.edges.equalToSuperview().inset(UIEdgeInsetsMake(49, 0, 0, 0))
            make.height.equalTo(contentHeight)
        }
        sender.removeFromSuperview()
    }
}
