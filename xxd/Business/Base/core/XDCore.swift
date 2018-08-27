//
//  XDCore.swift
//  xxd
//
//  Created by remy on 2017/12/20.
//  Copyright © 2017年 com.smartstudy. All rights reserved.
//

struct XDSize {
    static let statusBarHeight: CGFloat = UIApplication.shared.statusBarFrame.size.height
    /// 44
    static let topBarHeight: CGFloat = 44
    static let topHeight: CGFloat = XDSize.statusBarHeight + XDSize.topBarHeight
    static let tabbarHeight: CGFloat = UIDevice.isIPhoneX ? 83 : 49
    static let unitWidth: CGFloat = 1.0 / UIScreen.main.scale
    static let screenWidth: CGFloat = UIScreen.width
    static let screenHeight: CGFloat = UIScreen.height
    static let visibleHeight: CGFloat = XDSize.screenHeight - XDSize.topHeight
    static let visibleSize: CGSize = CGSize(width: XDSize.screenWidth, height: XDSize.visibleHeight)
    static let visibleRect: CGRect = CGRect(origin: CGPoint(x: 0, y: XDSize.topHeight), size: XDSize.visibleSize)
    static let contentHeight: CGFloat = XDSize.visibleHeight - XDSize.tabbarHeight
    static let contentSize: CGSize = CGSize(width: XDSize.screenWidth, height: XDSize.contentHeight)
    static let contentRect: CGRect = CGRect(origin: CGPoint(x: 0, y: XDSize.topHeight), size: XDSize.contentSize)
    /// 屏幕比例
    static let scaleRatio: CGFloat = XDSize.screenWidth/375.0
    /// 筛选操作栏视图的高度
    static let kFilterBarHeight: CGFloat = 40.0
}

struct XDColor {
    /// 0xF5F7F8
    static let mainBackground = UIColor(0xF5F7F8)
    /// 0x078CF1
    static let main = UIColor(0x078CF1)
    /// 0xBBBBBB
    static let mainLine = UIColor(0xBBBBBB)
    /// 0xE4E5E6
    static let itemLine = UIColor(0xE4E5E6)
    /// 0x26343F
    static let itemTitle = UIColor(0x26343F)
    /// 0x949BA1
    static let itemText = UIColor(0x949BA1)
    /// 0xCCCCCC
    static let textPlaceholder = UIColor(0xCCCCCC)
}

struct QueryKey {
    static let DegreeType = "kDegreeType"
    static let CollegeID = "kCollegeID"
    static let CategoryID = "kCategoryID"
    static let URLPath = "kURLPath"
    static let CountryID = "kCountryID"
    static let CourseID = "kCourseID"
    static let QuestionID = "kCourseID"
    static let TitleName = "kCourseID"
}

struct UMShareKey {
    static let wxAppKey = "wx84afe226d5061c83";
    static let wxAppSecret = "c05d4a58cf6640503cb05e6e98573ea8";
    static let qqAppKey = "1106051599";
    static let qqAppSecret = "L7ocsvEK8u5xzwkd";
    static let wbAppKey = "3533801049";
    static let wbAppSecret = "6160dd4c9a6dce0c8a366a6029d965a4";
}

func SSLog<T>(_ message: T,
              file: String = #file,
              method: String = #function,
              line: Int = #line) {
    #if DEBUG
        print("\((file as NSString).lastPathComponent)[\(line)], \(method): \(message)")
    #endif
}

protocol MetaType {}
extension MetaType {
    public var metaTypeName: String {
        return String(describing: type(of: self))
    }
    public static var metaTypeName: String {
        return String(describing: self)
    }
}
extension NSObject: MetaType {}
