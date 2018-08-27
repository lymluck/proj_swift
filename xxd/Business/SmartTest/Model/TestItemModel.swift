//
//  TestItemModel.swift
//  xxd
//
//  Created by remy on 2018/1/31.
//  Copyright © 2018年 com.smartstudy. All rights reserved.
//

enum TestItemType {
    case selector
    case text
}

class TestItemModel: NSObject {
    
    @objc var title: UILabel!
    @objc var content: UIView!
    @objc var index = 0
    @objc var paramKey = ""
    @objc var paramValue = ""
    @objc var paramSelectIndex = 0
    @objc var titleText = ""
    @objc var defaultTitleText = ""
    var type = TestItemType.selector
    var subModels = [TestItemModel]()
}
