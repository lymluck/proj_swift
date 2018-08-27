//
//  UserDefaultsEx.swift
//  xxd
//
//  Created by remy on 2017/12/7.
//  Copyright © 2017年 com.smartstudy. All rights reserved.
//

public enum Preference {
    
    public struct key<T>: RawRepresentable {
        
        public typealias RawValue = String
        
        public var rawValue: String
        
        public init(rawValue: String) {
            self.rawValue = rawValue
        }
        
        public init(_ rawValue: String) {
            self.rawValue = rawValue
        }
        
        public func set(_ v: T) {
            UserDefaults.standard.set(v, forKey: self.rawValue)
        }
        
        public func get() -> T? {
            return UserDefaults.standard.object(forKey: self.rawValue) as? T
        }
    }
    
    public static func synchronize() {
        UserDefaults.standard.synchronize()
    }
}
