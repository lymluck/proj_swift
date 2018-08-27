//
//  NSAttributedStringEx.swift
//  AndKit
//
//  Created by remy on 2017/12/13.
//  Copyright © 2017年 remy. All rights reserved.
//

#if os(macOS)
    import Cocoa
#else
    import UIKit
#endif

public extension NSMutableAttributedString {
    
    fileprivate override func applying(attributes: [NSAttributedStringKey: Any]) -> NSMutableAttributedString {
        let range = NSMakeRange(0, string.count)
        addAttributes(attributes, range: range)
        return self
    }
}

public extension NSAttributedString {
    
    @objc fileprivate func applying(attributes: [NSAttributedStringKey: Any]) -> NSAttributedString {
        let copy = NSMutableAttributedString(attributedString: self)
        let range = NSMakeRange(0, string.count)
        copy.addAttributes(attributes, range: range)
        return copy
    }
    
    public var underline: NSAttributedString {
        return applying(attributes: [.underlineStyle: NSUnderlineStyle.styleSingle.rawValue])
    }
    
    public var strikethrough: NSAttributedString {
        return applying(attributes: [.strikethroughStyle: NSUnderlineStyle.styleSingle.rawValue])
    }
    
    public func lineHeight(_ height: CGFloat) -> NSAttributedString {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.minimumLineHeight = height
        paragraphStyle.maximumLineHeight = height
        paragraphStyle.lineBreakMode = .byWordWrapping
        return applying(attributes: [.paragraphStyle: paragraphStyle])
    }
    
    #if os(macOS)
    public func color(_ color: NSColor) -> NSAttributedString {
        return applying(attributes: [.foregroundColor: color])
    }
    #else
    public func color(_ color: UIColor) -> NSAttributedString {
        return applying(attributes: [.foregroundColor: color])
    }
    
    public func font(_ fontName: String, _ fontSize: CGFloat) -> NSAttributedString {
        let font = UIFont(name: fontName, size: fontSize) ?? UIFont.systemFont(ofSize: fontSize)
        return applying(attributes: [.font: font])
    }
    
    public func boldSystemFont(_ fontSize: CGFloat) -> NSAttributedString {
        return applying(attributes: [.font: UIFont.boldSystemFont(ofSize: fontSize)])
    }
    
    public func italicSystemFont(_ fontSize: CGFloat) -> NSAttributedString {
        return applying(attributes: [.font: UIFont.italicSystemFont(ofSize: fontSize)])
    }
    #endif
    
    public func heightForFont(_ width: CGFloat) -> CGFloat {
        let size = CGSize(width: width, height: .greatestFiniteMagnitude)
        return sizeForFont(size).height
    }
    
    public func widthForFont() -> CGFloat {
        let size = CGSize(width: CGFloat.greatestFiniteMagnitude, height: .greatestFiniteMagnitude)
        return sizeForFont(size).width
    }
    
    public func sizeForFont(_ size: CGSize) -> CGSize {
        let rect = self.boundingRect(with: size, options: [.usesLineFragmentOrigin, .usesFontLeading], context: nil)
        return rect.size
    }
}

public func += (lhs: inout NSAttributedString, rhs: NSAttributedString) {
    let ns = NSMutableAttributedString(attributedString: lhs)
    ns.append(rhs)
    lhs = ns
}

public func += (lhs: inout NSAttributedString, rhs: String) {
    let ns = NSMutableAttributedString(attributedString: lhs)
    ns.append(NSAttributedString(string: rhs))
    lhs = ns
}

public func += (lhs: inout NSMutableAttributedString, rhs: NSAttributedString) {
    lhs.append(rhs)
}

public func += (lhs: inout NSMutableAttributedString, rhs: String) {
    lhs.append(NSAttributedString(string: rhs))
}

public func + (lhs: NSAttributedString, rhs: NSAttributedString) -> NSAttributedString {
    let ns = NSMutableAttributedString(attributedString: lhs)
    ns.append(rhs)
    return NSAttributedString(attributedString: ns)
}

public func + (lhs: NSAttributedString, rhs: String) -> NSAttributedString {
    return lhs + NSAttributedString(string: rhs)
}

public func + (lhs: String, rhs: NSAttributedString) -> NSAttributedString {
    return NSAttributedString(string: lhs) + rhs
}
