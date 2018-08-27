//
//  XDLocalConfig.swift
//  xxd
//
//  Created by remy on 2017/12/20.
//  Copyright © 2017年 com.smartstudy. All rights reserved.
//

extension Preference {
    // 智能选校引导
    static let SMART_COLLEGE_GUIDE = key<Bool>("xdDefaultsSmartCollegeGuide")
    // 意向国家对比引导
    static let TARGET_COUNTRY_GUIDE = key<Bool>("xdDefaultTargetCountryGuide")
    // 备考计划视图
    static let SHOW_EXAM_PLAN_PREPARED = key<Bool>("xdShowExamPlanPrepared")
    // 智能选专业引导
    static let SMART_MAJOR_GUIDE = key<Bool>("xdDefaultsSmartMajorGuide")
    // 当前应用本号
    static let CURRENT_APP_VERSION = key<String>("kCurrentAppVersion")
    // 引导页
    static let GUIDE = key<Bool>("kGuide")
    // 启动广告页时间
    static let LAUNCH_AD_DATE = key<String>("kLaunchADDate")
    // 启动广告页信息
    static let LAUNCH_AD_INFO = key<Dictionary<String, Any>>("kLaunchADInfo")
    // 是否新注册账号
    static let IS_CREATED = key<Bool>("kIsCreated")
    // 引导评分信息
    static let APP_GRADE = key<String>("kLaunchAppGrade")
    // 首页显示留学规划
    static let SHOW_STUDY_PLAN = key<Bool>("kShowStudyPlan")
    // 当前服务器api环境
    static let CURRENT_ENVIRONMENT_TYPE = key<String>("kCurrentEnvironmentType")
    // 自定义服务器环境key
    static let CUSTOM_ENVIRONMENT = key<Dictionary<String, String>>("kCurrentCustomEnvironment")
}

extension Notification.Name {
    // 登录
    public static let XD_NOTIFY_SIGN_IN = NSNotification.Name("xdNotifySignIn")
    // 更新个人信息
    public static let XD_NOTIFY_UPDATE_PERSONAL_INFO = NSNotification.Name("xdUpdatePersonalInfo")
    // 更新问答tab未读状态
    public static let XD_NOTIFY_UPDATE_QA_UNREAD = NSNotification.Name("xdUpdateQaUnread")
    // 更新我的消息列表未读消息
    public static let XD_NOTIFY_UPDATE_UNREAD_MESSAGE = NSNotification.Name("xdUpdateUnreadMessage")
    // 更新问答列表
    public static let XD_NOTIFY_UPDATE_QA_LIST = NSNotification.Name("xdUpdateQAList")
}

// 登出
let XD_NOTIFY_SIGN_OUT = "xdNotifySignOut"
// 添加选校
let XD_NOTIFY_ADD_MY_TARGET = "xdNotifyAddMyTarget"
// 取消选校
let XD_NOTIFY_REMOVE_MY_TARGET = "xdNotifyRemoveMyTarget"
// 评论课程成功
let XD_NOTIFY_EVALUATE_COURSE_SUC = "xdNotifyEvaluateCourseSuc"
// 收到消息中心有新消息通知
let XD_NOTIFY_GET_NEW_MESSAGE = "xdNotifyGetNewMessage"
// 已经观看了视频的通知
let XD_NOTIFY_HAS_WATCH_VIDEO = "xdNotifyHasWatchVideo"
