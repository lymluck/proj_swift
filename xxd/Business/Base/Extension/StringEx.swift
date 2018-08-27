//
//  StringEx.swift
//  xxd
//
//  Created by remy on 2017/12/20.
//  Copyright © 2017年 com.smartstudy. All rights reserved.
//

public extension String {
    
    // https://stackoverflow.com/questions/25081757/whats-nslocalizedstring-equivalent-in-swift
    public var localized: String {
        return NSLocalizedString(self, comment: "")
    }
    
    public func localized(_ comment: String = "") -> String {
        return NSLocalizedString(self, comment: comment)
    }
    
    public static func localized(_ key: String, _ comment: String = "") -> String {
        return NSLocalizedString(key, comment: comment)
    }
    
    // https://stackoverflow.com/questions/30450434/figure-out-size-of-uilabel-based-on-string-in-swift
    public func heightForFont(_ font: UIFont, _ width: CGFloat, _ lineHeight: CGFloat? = nil) -> CGFloat {
        let size = CGSize(width: width, height: .greatestFiniteMagnitude)
        return sizeForFont(font, size, lineHeight).height
    }
    
    public func widthForFont(_ font: UIFont, _ lineHeight: CGFloat? = nil) -> CGFloat {
        let size = CGSize(width: CGFloat.greatestFiniteMagnitude, height: .greatestFiniteMagnitude)
        return sizeForFont(font, size, lineHeight).width
    }
    
    /// 根据UILabel控件来获取文本高度, 可设置显示的行数
    public func labelHeight(maxWidth: CGFloat, font: UIFont, numberOfLines: Int = 0) -> CGFloat {
        let label: UILabel = UILabel(frame: CGRect(x: 0.0, y: 0.0, width: maxWidth, height: CGFloat.greatestFiniteMagnitude))
        label.font = font
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = numberOfLines
        label.text = self
        label.sizeToFit()
        return label.size.height
    }
    
    public func sizeForFont(_ font: UIFont, _ size: CGSize, _ lineHeight: CGFloat? = nil) -> CGSize {
        var attr: [NSAttributedStringKey: Any] = [.font: font]
        if let l = lineHeight {
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.minimumLineHeight = l
            paragraphStyle.maximumLineHeight = l
            paragraphStyle.lineBreakMode = .byWordWrapping
            attr[.paragraphStyle] = paragraphStyle
        }
        let rect = self.boundingRect(with: size, options: [.usesLineFragmentOrigin, .usesFontLeading], attributes: attr, context: nil)
        return rect.size
    }
    
    public subscript(_ i: Int) -> String {
        get {
            if let index = validIndex(i, self) {
                return String(self[index])
            }
            return ""
        }
    }
    
    public func substring(from: Int) -> String {
        if let start = validStartIndex(from, self) {
            return String(self[start...])
        }
        return ""
    }
    
    public func substring(loc: Int, len: UInt) -> String {
        if let start = validStartIndex(loc, self) {
            let end = index(start, offsetBy: String.IndexDistance(len), limitedBy: endIndex) ?? endIndex
            return String(self[start..<end])
        }
        return ""
    }
    
    public func substring(to: Int) -> String {
        if let end = validEndIndex(to, self) {
            return String(self[..<end])
        }
        return ""
    }
    
    public var url: URL? {
        return URL(string: self)
    }
    
    public var fileURL: URL {
        return URL(fileURLWithPath: self, isDirectory: false)
    }
    
    public var dirURL: URL {
        return URL(fileURLWithPath: self, isDirectory: true)
    }
    
    public func appendingPathComponent(_ str: String) -> String {
        return (self as NSString).appendingPathComponent(str)
    }
}

@inline(__always) private func validIndex(_ i: Int, _ v: String) -> String.Index? {
    switch i {
    case ..<v.startIndex.encodedOffset:
        return v.index(v.endIndex, offsetBy: i, limitedBy: v.startIndex)
    case v.endIndex.encodedOffset...:
        return nil
    default:
        return v.index(v.startIndex, offsetBy: i, limitedBy: v.endIndex)
    }
}

@inline(__always) private func validStartIndex(_ i: Int, _ v: String) -> String.Index? {
    guard i < 0 else {
        return v.index(v.startIndex, offsetBy: i, limitedBy: v.endIndex)
    }
    return v.index(v.endIndex, offsetBy: i, limitedBy: v.startIndex) ?? v.startIndex
}

@inline(__always) private func validEndIndex(_ i: Int, _ v: String) -> String.Index? {
    guard i < 0 else {
        return v.index(v.startIndex, offsetBy: i, limitedBy: v.endIndex) ?? v.endIndex
    }
    return v.index(v.endIndex, offsetBy: i, limitedBy: v.startIndex)
}
