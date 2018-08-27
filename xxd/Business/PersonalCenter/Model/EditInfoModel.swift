//
//  EditInfoModel.swift
//  xxd
//
//  Created by remy on 2018/1/3.
//  Copyright © 2018年 com.smartstudy. All rights reserved.
//

class EditInfoModel: NSObject {
    
    @objc var value = ""
    @objc var hint = ""
    @objc var groupName = ""
    @objc var isMultiple = false
    @objc var options = [[String : Any]]()
    lazy var subModels: [EditInfoModel] = {
        if options.count > 0 {
            return NSArray.yy_modelArray(with: EditInfoModel.self, json: options) as! [EditInfoModel]
        }
        return [EditInfoModel]()
    }()
    @objc var name = ""
    lazy var cellHeight: CGFloat = {
        if !name.isEmpty {
            return name.heightForFont(UIFont.systemFont(ofSize: 16), XDSize.screenWidth - 64) + 28
        }
        return 0
    }()
    
    @objc static func modelCustomPropertyMapper() -> Dictionary<String, Any> {
        return [
            "value": "id",
            "name": ["name", "value"],
            "groupName": "group"
        ]
    }
}

class EditInfoResultModel: NSObject {
    
    @objc var value = ""
    @objc var name = ""
}
