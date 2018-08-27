//
//  MessageView.swift
//  xxd
//
//  Created by remy on 2018/1/14.
//  Copyright © 2018年 com.smartstudy. All rights reserved.
//

import Kingfisher

let kMessageBubbleLeft: CGFloat = 66
let kMessageBubbleTop: CGFloat = 41
let kMessageBubbleBottom: CGFloat = 8
let kMessageBubbleMinRight: CGFloat = 16
let kMessageBubbleTextLeftPadding: CGFloat = 22
let kMessageBubbleTextRightPadding: CGFloat = 16
let kMessageBubbleTextVPadding: CGFloat = 20
let kMessageTextLineHeight: CGFloat = 20

let kMaxBubbleWidth: CGFloat = XDSize.screenWidth - kMessageBubbleLeft - kMessageBubbleMinRight
let kMaxImageBubbleWidth: CGFloat = 200
let kMaxImageBubbleHeight: CGFloat = 200
let kMinImageBubbleHeight: CGFloat = 60

let kMessageWhiteBoardTop: CGFloat = 41
let kMessageWhiteBoardBottom: CGFloat = 8
let kMessageWhiteBoardHMargin: CGFloat = 16
let kMessageWhiteBoardHPadding: CGFloat = 16;
let kMessageWhiteBoardVPadding: CGFloat = 20;
let kMessageWhiteBoardTextLineHeight: CGFloat = 22;

class MessageBubbleView: UIView {
    
    private var bubbleView: UIImageView!
    private lazy var textLabel: UILabel = {
        let view = UILabel(text: "", textColor: XDColor.itemTitle, fontSize: 15)!
        addSubview(view)
        return view
    }()
    lazy var imageView: UIImageView = {
        let view = UIImageView(frame: bounds)
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(view)
        return view
    }()
    var text: String = "" {
        willSet {
            if newValue != text {
                textLabel.setText(newValue, lineHeight: kMessageTextLineHeight)
                textLabel.frame = CGRect(x: kMessageBubbleTextLeftPadding, y: kMessageBubbleTextVPadding, width: width - kMessageBubbleTextLeftPadding - kMessageBubbleTextRightPadding, height: height - kMessageBubbleTextVPadding * 2)
            }
        }
    }
    private var _imageURL: String = ""
    private(set) var imageURL: String {
        get {
            return _imageURL
        }
        set {
            setImageURL(imageURL: newValue, size: CGSize(width: 100, height: 100))
        }
    }
    
    override var size: CGSize {
        get {
            return super.size
        }
        set {
            super.size = newValue
            let layer = CAShapeLayer()
            layer.frame = bounds
            layer.contents = UIImage(named: "message_bubble")?.cgImage
            layer.contentsCenter = CGRect(x: 0.6, y: 0.6, width: 0.1, height: 0.1)
            layer.contentsScale = UIScreen.main.scale
            bubbleView.layer.mask = layer
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        bubbleView = UIImageView(frame: bounds)
        bubbleView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        bubbleView.image = UIImage(named: "message_bubble")?.resizableImage(withCapInsets: UIEdgeInsetsMake(30, 22.5, 23, 22.5))
        layer.shadowOpacity = 0.05
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowRadius = 2
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shouldRasterize = true
        layer.rasterizationScale = UIScreen.main.scale
        addSubview(bubbleView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setImageURL(imageURL: String, size: CGSize) {
        if imageURL != _imageURL {
            _imageURL = imageURL
            imageView.kf.setImage(with: URL(string: imageURL), placeholder: UIImage.getPlaceHolderImage(size: size))
        }
    }
}

class MessageWhiteBoardView: UIButton {
    
    var text: String = ""
    var imageURL: String = ""
    var webURL: String = ""
    private var textLabel: UILabel!
    private var pictureView: UIImageView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        var image = UIImage(named: "message_center_board")!
        image = image.resizableImage(withCapInsets: UIEdgeInsetsMake(20, 20, 20, 20))
        var highlightImage = image.tint(XDColor.itemLine)
        highlightImage = highlightImage.resizableImage(withCapInsets: UIEdgeInsetsMake(20, 20, 20, 20))
        setBackgroundImage(image, for: .normal)
        setBackgroundImage(image, for: .highlighted)
        layer.shadowOpacity = 0.05
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowRadius = 2
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shouldRasterize = true
        layer.rasterizationScale = UIScreen.main.scale
        
        textLabel = UILabel(frame: CGRect(x: kMessageWhiteBoardHPadding, y: kMessageWhiteBoardVPadding, width: 0, height: 0), text: "", textColor: XDColor.itemTitle, fontSize: 17)!
        textLabel.numberOfLines = 2
        addSubview(textLabel)
        
        pictureView = UIImageView(frame: CGRect(x: kMessageWhiteBoardHPadding, y: 0, width: 0, height: 0))
        pictureView.layer.borderWidth = XDSize.unitWidth
        pictureView.layer.borderColor = XDColor.itemLine.cgColor
        addSubview(pictureView)
        
        let readAllLabel = UILabel(text: "read_all".localized, textColor: XDColor.itemText, fontSize: 13)!
        addSubview(readAllLabel)
        readAllLabel.snp.makeConstraints({ (make) in
            make.left.equalTo(self).offset(kMessageWhiteBoardHPadding)
            make.bottom.equalTo(self).offset(-16)
        })
        
        let arrowView = UIImageView(image: UIImage(named: "more_right_arrow"))
        addSubview(arrowView)
        arrowView.snp.makeConstraints({ (make) in
            make.right.equalTo(self).offset(-kMessageWhiteBoardHPadding)
            make.centerY.equalTo(readAllLabel)
        })
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func bindItem(_ item: MessageItem) {
        textLabel.size = item.textSize
        pictureView.top = textLabel.bottom + 20
        pictureView.size = item.imageSize
        textLabel.setText(item.model.text, lineHeight: kMessageWhiteBoardTextLineHeight)
        pictureView.kf.setImage(with: URL(string: item.model.imageURL), placeholder: UIImage.getPlaceHolderImage(size: item.imageSize))
    }
}
