//
//  MessageItem.swift
//  xxd
//
//  Created by remy on 2018/1/12.
//  Copyright © 2018年 com.smartstudy. All rights reserved.
//

import SSPhotoBrowser

class MessageItem: SSCellItem {
    
    var model: MessageModel!
    var cellClassType: AnyClass!
    var cellHeight: CGFloat = 0
    var bubbleSize = CGSize.zero
    var textSize = CGSize.zero
    var imageSize = CGSize.zero
    var whiteBoardSize = CGSize.zero
    
    override init?(attributes: [AnyHashable : Any]! = [:]) {
        super.init(attributes: attributes)
        model = MessageModel.yy_model(with: attributes)
        switch model.type {
        case .text:
            cellClassType = MessageTextCell.self
            let width = kMaxBubbleWidth - kMessageBubbleTextLeftPadding - kMessageBubbleTextRightPadding
            let height = model.text.heightForFont(UIFont.systemFont(ofSize: 15), width, kMessageTextLineHeight)
            bubbleSize = CGSize(width: width + kMessageBubbleTextLeftPadding + kMessageBubbleTextRightPadding, height: height + kMessageBubbleTextVPadding * 2)
            cellHeight = kMessageBubbleTop + bubbleSize.height + kMessageBubbleBottom
        case .image:
            cellClassType = MessageImageCell.self
            var tempSize = model.imageSize
            if tempSize.height < 60 {
                tempSize = CGSize(width: kMinImageBubbleHeight * tempSize.width / tempSize.height, height: kMinImageBubbleHeight)
            }
            if tempSize.width > kMaxImageBubbleWidth {
                tempSize = CGSize(width: kMaxImageBubbleWidth, height: kMaxImageBubbleWidth * tempSize.height / tempSize.width)
            }
            if tempSize.width > kMaxImageBubbleHeight {
                tempSize = CGSize(width: kMaxImageBubbleHeight * tempSize.width / tempSize.height, height: kMaxImageBubbleHeight)
            }
            bubbleSize = tempSize
            cellHeight = kMessageBubbleTop + bubbleSize.height + kMessageBubbleBottom
        case .textCard:
            cellClassType = MessageTextCardCell.self
            var maxTextCount = 53
            if XDSize.screenWidth > 320 {
                maxTextCount = 65
            } else if XDSize.screenWidth > 375 {
                maxTextCount = 74
            }
            let contentCount = maxTextCount - 13
            if model.text.count > contentCount {
                let text = model.text.substring(to: contentCount)
                model.text = "\(text)..."
            }
            let width = XDSize.screenWidth - 64
            let height = "你的问题：\"\(model.text)\"已经被人回复。点击查看".heightForFont(UIFont.systemFont(ofSize: 14), width, kMessageTextLineHeight)
            textSize = CGSize(width: width, height: height)
            cellHeight = kMessageBubbleTop + textSize.height + 16 + kMessageBubbleBottom
        case .invokeWeb:
            cellClassType = MessageInvokeWebCell.self
            let tempSize = CGSize(width: XDSize.screenWidth - kMessageWhiteBoardHMargin * 2, height: 100)
            let tempTextSize = model.text.sizeForFont(UIFont.systemFont(ofSize: 17), CGSize(width: tempSize.width - 2 * kMessageWhiteBoardHPadding, height: .greatestFiniteMagnitude), kMessageWhiteBoardTextLineHeight)
            let width = tempSize.width - 2 * kMessageWhiteBoardHPadding
            textSize = CGSize(width: tempTextSize.width, height: min(kMessageWhiteBoardTextLineHeight * 2, tempTextSize.height))
            imageSize = CGSize(width: width, height: (width / 16 * 9).rounded(.up))
            whiteBoardSize = CGSize(width: XDSize.screenWidth - kMessageWhiteBoardHMargin * 2, height: kMessageBubbleTextVPadding + textSize.height + 20 + imageSize.height + 49)
            cellHeight = kMessageWhiteBoardTop + whiteBoardSize.height + kMessageWhiteBoardBottom
        default:
            cellClassType = MessageTextCell.self
        }
    }
    
    override init!(cellClass: AnyClass!, userInfo: Any!) {
        super.init(cellClass: cellClass, userInfo: userInfo)
    }
    
    override func cellClass() -> AnyClass! {
        return cellClassType
    }
}

class MessageBaseCell: SSTableViewCell {
    
    var timeLabel: UILabel!
    var portraitView: UIImageView?
    
    override static func height(for object: Any!, at indexPath: IndexPath!, tableView: UITableView!) -> CGFloat {
        return (object as! MessageItem).cellHeight
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        timeLabel = UILabel(frame: CGRect(x: 0, y: 15, width: contentView.width, height: 15), text: "", textColor: XDColor.itemText, fontSize: 13)!
        timeLabel.textAlignment = .center
        timeLabel.autoresizingMask = [.flexibleWidth, .flexibleBottomMargin]
        contentView.addSubview(timeLabel)
        portraitView = UIImageView(frame: CGRect(x: 16, y: 41, width: 44, height: 44), imageName: "message_center_default_portrait_icon")
        contentView.addSubview(portraitView!)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func shouldUpdate(with object: Any!) -> Bool {
        if let object = object as? MessageItem, super.shouldUpdate(with: object) {
            timeLabel.text = object.model.date.displayString()
            return true
        }
        return false
    }
}

class MessageTextCell: MessageBaseCell {
    
    var bubbleView: MessageBubbleView!
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        bubbleView = MessageBubbleView(frame: CGRect(x: kMessageBubbleLeft, y: 41, width: 20, height: 60))
        contentView.addSubview(bubbleView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func shouldUpdate(with object: Any!) -> Bool {
        if let object = object as? MessageItem, super.shouldUpdate(with: object) {
            bubbleView.size = object.bubbleSize
            bubbleView.text = object.model.text
            return true
        }
        return false
    }
}

class MessageImageCell: MessageBaseCell, IDMPhotoBrowserDelegate {
    
    var bubbleView: MessageBubbleView!
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        bubbleView = MessageBubbleView(frame: CGRect(x: kMessageBubbleLeft, y: 41, width: 20, height: 60))
        bubbleView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(bubbleViewPressed(gestureRecognizer:))))
        contentView.addSubview(bubbleView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func shouldUpdate(with object: Any!) -> Bool {
        if let object = object as? MessageItem, super.shouldUpdate(with: object) {
            bubbleView.size = object.bubbleSize
            bubbleView.setImageURL(imageURL: object.model.lowQualityImageURL, size: object.bubbleSize)
            return true
        }
        return false
    }
    
    //MARK:- Action
    @objc func bubbleViewPressed(gestureRecognizer: UIGestureRecognizer) {
        let item = self.item as! MessageItem
        if let photoBrowser = SSPhotoBrowser(photoURLs: [item.model.imageURL], placeholderImages: [bubbleView.imageView.image!], animatedFrom: bubbleView.imageView) {
            photoBrowser.delegate = self
            photoBrowser.displayToolbar = false
            photoBrowser.displayDoneButton = false
            photoBrowser.dismissOnTouch = true
            UIApplication.topVC()?.present(photoBrowser, animated: true, completion: nil)
        }
    }
}

class MessageTextCardCell: MessageBaseCell {
    
    var cardView: UIView!
    var label: UILabel!
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        portraitView?.removeFromSuperview()
        portraitView = nil
        cardView = UIView(frame: CGRect(x: kMessageWhiteBoardHMargin, y: kMessageWhiteBoardTop, width: XDSize.screenWidth - 32, height: 0), color: UIColor.clear)
        cardView.backgroundColor = UIColor.black.withAlphaComponent(0.15)
        cardView.layer.cornerRadius = 4
        cardView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(cardViewPressed(gestureRecognizer:))))
        contentView.addSubview(cardView)
        label = UILabel(frame: CGRect(x: 16, y: 8, width: cardView.width - 32, height: 0), text: "", textColor: UIColor.white, fontSize: 14)
        label.numberOfLines = 0
        label.backgroundColor = UIColor.clear
        cardView.addSubview(label)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func shouldUpdate(with object: Any!) -> Bool {
        if let object = object as? MessageItem, super.shouldUpdate(with: object) {
            let attr = NSAttributedString(string: "你的问题：\"\(object.model.text)\"已经被人回复。") + NSAttributedString(string: "点击查看").color(XDColor.main)
            label.attributedText = attr
            label.size = object.textSize
            cardView.height = object.textSize.height + 16
            return true
        }
        return false
    }
    
    //MARK:- Action
    @objc func cardViewPressed(gestureRecognizer: UIGestureRecognizer) {
        let item = self.item as! MessageItem
        let url = URL(string: item.model.linkURL)!
        let urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false)!
        let queryItems = urlComponents.queryItems!
        var questionID = 0
        for item in queryItems {
            if item.name == "id", let value = item.value {
                questionID = Int(value)!
            }
        }
        let vc = QuestionDetailViewController()
        vc.questionID = questionID
        XDRoute.pushToVC(vc)
    }
}

class MessageInvokeWebCell: MessageBaseCell {
    
    var whiteContentBoard: MessageWhiteBoardView!
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        portraitView?.removeFromSuperview()
        portraitView = nil
        whiteContentBoard = MessageWhiteBoardView(frame: CGRect(x: kMessageWhiteBoardHMargin, y: kMessageWhiteBoardTop, width: 0, height: 0))
        whiteContentBoard.addTarget(self, action: #selector(whiteContentBoardPressed(gestureRecognizer:)), for: .touchUpInside)
        contentView.addSubview(whiteContentBoard)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func shouldUpdate(with object: Any!) -> Bool {
        if let object = object as? MessageItem, super.shouldUpdate(with: object) {
            whiteContentBoard.size = object.whiteBoardSize
            whiteContentBoard.bindItem(object)
            return true
        }
        return false
    }
    
    //MARK:- Action
    @objc func whiteContentBoardPressed(gestureRecognizer: UIGestureRecognizer) {
        let item = self.item as! MessageItem
        if let url = URL(string: item.model.linkURL) {
            XDRoute.schemeRoute(url: url)
        }
    }
}
