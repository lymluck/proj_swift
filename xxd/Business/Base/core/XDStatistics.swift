//
//  XDStatistics.swift
//  xxd
//
//  Created by remy on 2018/1/25.
//  Copyright © 2018年 com.smartstudy. All rights reserved.
//

import SensorsAnalyticsSDK

class XDStatistics {
    
    static func click(_ event: String) {
        #if !TEST_MODE
        umClick(event)
        #endif
    }
    
    static func pageStart(_ event: String) {
        #if !TEST_MODE
        umPageStart(event)
        #endif
    }
    
    static func pageEnd(_ event: String) {
        #if !TEST_MODE
        umPageEnd(event)
        #endif
    }
    
    // umeng统计
    static func umClick(_ event: String) {
        #if !TEST_MODE
        MobClick.event(event)
        #endif
    }
    
    static func umPageStart(_ event: String) {
        #if !TEST_MODE
        MobClick.beginLogPageView(event)
        #endif
    }
    
    static func umPageEnd(_ event: String) {
        #if !TEST_MODE
        MobClick.endLogPageView(event)
        #endif
    }
    
    // 神策统计
    static func scTrack(_ event: String, data: [String : Any]? = nil) {
        #if !TEST_MODE
        if let data = data {
            SensorsAnalyticsSDK.sharedInstance().track(event, withProperties: data)
        } else {
            SensorsAnalyticsSDK.sharedInstance().track(event)
        }
        #endif
    }
}
