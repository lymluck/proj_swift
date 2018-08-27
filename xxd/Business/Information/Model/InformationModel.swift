//
//  InformationModel.swift
//  xxd
//
//  Created by remy on 2018/1/18.
//  Copyright © 2018年 com.smartstudy. All rights reserved.
//

enum InformationModelType: Int {
    case normal   // 正常
    case cover    // 带封面
}

// 资讯列表 model
class InformationModel: NSObject {
    
    @objc var infoID = 0
    @objc var title = ""
    @objc var visitCount = 0
    @objc var _coverURL = ""
    lazy var coverURL: String = {
        if !_coverURL.isEmpty {
            return UIImage.OSSImageURLString(urlStr: _coverURL, size: CGSize(width: 114, height: 85), policy: .fillAndClip)
        }
        return ""
    }()
    lazy var URLPath: String = {
        return String(format: XD_WEB_NEWS_DETAIL, infoID)
    }()
    lazy var type: InformationModelType = {
        return _coverURL.isEmpty ? .normal : .cover
    }()
    @objc var tags = [[String : Any]]()
    lazy var tagName: String = {
        if tags.count > 0 {
            for dict in tags {
                if dict["type"] as? String == "stage" {
                    return dict["name"] as! String
                }
            }
        }
        return ""
    }()
    
    @objc static func modelCustomPropertyMapper() -> Dictionary<String, Any> {
        return [
            "infoID": "id",
            "_coverURL": "coverUrl"
        ]
    }
}

/// 资讯页tab
class InformationTagModel: NSObject {
    
    var tagID: Int = 0
    var name: String = ""
}
