//
//  Config.swift
//  TSKitDemo
//
//  Created by chenyusen on 2017/9/29.
//  Copyright © 2017年 TechSen. All rights reserved.
//

import UIKit


/// 框架UI相关默认配置
public struct DefaultConfig {
    public enum NavigationBarStyle {
        case system, custom, none
    }
    
    public struct Style {
        public static var navigationBar: NavigationBarStyle = .system
        public static var statusBarStyle: UIStatusBarStyle = .default
    }
    
    /// 文案配置
    public struct Text {
        
        /// 页面正在加载时
        public static var loading: String = "正在加载..."
        /// 页面无数据
        public static var empty: String = "暂无数据"
        /// 数据加载错误
        public static var error: String = "数据加载错误"
        /// 无网络
        public static var noNetwork: String = "无网络"
    }
    
    
    /// 图片配置
    public struct Image {
        
        /// 页面正在加载时
        public static var loading: UIImage?
        /// 页面无数据
        public static var empty: UIImage?
        /// 数据加载错误
        public static var error: UIImage?
        /// 无网络
        public static var noNetwork: UIImage?
        /// 返回按钮图片
        public static var navBack: UIImage?
    }
    
    
    /// 布局参数配置
    public struct Layout {
        /// 居中状态视图距离垂直方向偏移量
        public static var centerYOffset: CGFloat = 0.0
        /// 分页页面的默认分页数
        public static var pageSize: Int = 15
    }
    
    /// 字体大小
    public struct FontSize {
        public static var navigationBarTitle: CGFloat = 17
        public static var navigationBarItemTitle: CGFloat = 16
    }
    
    /// 配色
    public struct Color {
        /// 默认控制器的背景色
        public static var background: UIColor = UIColor(red: 247.0/255.0, green: 247.0/255.0, blue: 247.0/255.0, alpha: 1)
        public static var navigationBarTitle: UIColor = UIColor(0x263540)
        public static var navigationBarItemTitle: UIColor = UIColor(0x263540)
        public static var navgationBarBackground: UIColor  = .white
    }
    
}
