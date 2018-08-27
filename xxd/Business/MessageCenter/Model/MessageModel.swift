//
//  MessageModel.swift
//  xxd
//
//  Created by remy on 2018/1/12.
//  Copyright © 2018年 com.smartstudy. All rights reserved.
//

enum MessageType: Int {
    case text
    case image
    case invokeWeb
    case textCard
    case unknown
}

class MessageModel: NSObject {
    
    @objc var messageId = 0
    @objc var text = ""
    @objc var linkURL = ""
    @objc var date = Date()
    @objc var imageURL = ""
    lazy var lowQualityImageURL: String = {
        if !imageURL.isEmpty {
            return "\(imageURL)?x-oss-process=image/resize,m_lfit,w_400"
        }
        return ""
    }()
    @objc var _type = ""
    lazy var type: MessageType = {
        switch _type {
        case "feed":
            return .invokeWeb
        case "image":
            return .image
        case "question-notify":
            return .textCard
        case "text":
            return .text
        default:
            return .unknown
        }
    }()
    @objc var data = [String : Any]()
    lazy var imageSize: CGSize = {
        if let imageWidth = data["imageWidth"] as? Double, let imageHeight = data["imageHeight"] as? Double {
            return CGSize(width: imageWidth, height: imageHeight)
        }
        return .zero
    }()
    
    @objc static func modelCustomPropertyMapper() -> Dictionary<String, Any> {
        return [
            "imageURL": "imageUrl",
            "date": "pushTime",
            "linkURL": "linkUrl",
            "_type": "type",
            "messageId": "id"
        ]
    }
}
