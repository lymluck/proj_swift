//
//  ChatBubbleView.swift
//  counselor_t
//
//  Created by chenyusen on 2017/12/12.
//  Copyright © 2017年 TechSen. All rights reserved.
//

import UIKit

/// 气泡
public class ChatBubbleView: UIView {
    var showCover: Bool = false {
        didSet {
            if showCover != oldValue {
                bringSubview(toFront: cover)
                cover.isHidden = !showCover
            }
        }
    }
    public var cover: UIView!

    lazy var contentLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        return layer
    }()
    
    public var content: UIView? {
        didSet {
            if content != oldValue {
                oldValue?.removeFromSuperview()
                if let content = content {
                    addSubview(content)
                }
//                    insertSubview(content, belowSubview: progressCover)
//                }
            }
            resetContentLayer()
        }
    }
    
    private var shapeLayer: CAShapeLayer!
    private var backgroundView: UIImageView!
    enum Side {
        case left, right
    }
    var side: Side = .left {
        didSet {
            if side != oldValue {
                switch side {
                case .left:
                    backgroundView.image = whiteBubble
                //                    shapeLayer.contents = whiteBubble.cgImage
                case .right:
                    //                    shapeLayer.contents = blueBubble.cgImage
                    backgroundView.image = blueBubble
                }
            }
            self.layer.mask = shapeLayer
            
        }
    }

    
    private let whiteBubble: UIImage = {
        let bubble = UIImage(named: "chat_bubble_white")!
        let stretchableBubble = bubble.stretchableImage(withLeftCapWidth: Int(bubble.size.width * 0.5), topCapHeight: 26)
        return stretchableBubble
    }()
    
    private let blueBubble: UIImage = {
        let bubble = UIImage(named: "chat_bubble_blue")!
        let stretchableBubble = bubble.stretchableImage(withLeftCapWidth: Int(bubble.size.width * 0.5), topCapHeight: 26)
        return stretchableBubble
    }()
    
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundView = UIImageView(frame: bounds)
        backgroundView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(backgroundView)
        backgroundView.image = whiteBubble
        
        cover = UIView()
        cover.isUserInteractionEnabled = false
        cover.backgroundColor = UIColor.black.withAlphaComponent(0.15)
        cover.frame = self.bounds
        cover.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        cover.isHidden = true
        addSubview(cover)
        resetContentLayer()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func resetContentLayer() {
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        contentLayer.frame = self.bounds
        contentLayer.contents = backgroundView.image?.cgImage
        contentLayer.contentsCenter = CGRect(x: 0.5, y: 0.66, width: 0.1, height: 0.1)
        contentLayer.contentsScale = UIScreen.main.scale
        self.layer.mask = contentLayer
        CATransaction.commit()
    }
}

