//
//  UILabelEx.swift
//  xxd
//
//  Created by remy on 2018/3/7.
//  Copyright © 2018年 com.smartstudy. All rights reserved.
//

public extension UILabel {
    
    public func attr(attr: NSAttributedString, lineHeight: CGFloat, mode: NSLineBreakMode = .byWordWrapping) {
        let attr = NSMutableAttributedString(attributedString: attr)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.minimumLineHeight = lineHeight
        paragraphStyle.maximumLineHeight = lineHeight
        paragraphStyle.lineBreakMode = mode
        attr.addAttribute(.paragraphStyle, value: paragraphStyle, range: NSMakeRange(0, attr.length))
        self.attributedText = attr
    }
    
    public func text(text: String, lineHeight: CGFloat, mode: NSLineBreakMode = .byWordWrapping) {
        let attr = NSMutableAttributedString(string: text)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.minimumLineHeight = lineHeight
        paragraphStyle.maximumLineHeight = lineHeight
        paragraphStyle.lineBreakMode = mode
        attr.addAttribute(.paragraphStyle, value: paragraphStyle, range: NSMakeRange(0, text.count))
        self.attributedText = attr
    }
    
    public func attr(attr: NSAttributedString, lineSpace: CGFloat, mode: NSLineBreakMode = .byWordWrapping) {
        let attr = NSMutableAttributedString(attributedString: attr)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = lineSpace
        paragraphStyle.lineBreakMode = mode
        attr.addAttribute(.paragraphStyle, value: paragraphStyle, range: NSMakeRange(0, attr.length))
        self.attributedText = attr
    }
    
    public func text(text: String, lineSpace: CGFloat, mode: NSLineBreakMode = .byWordWrapping) {
        let attr = NSMutableAttributedString(string: text)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = lineSpace
        paragraphStyle.lineBreakMode = mode
        attr.addAttribute(.paragraphStyle, value: paragraphStyle, range: NSMakeRange(0, text.count))
        self.attributedText = attr
    }
}
