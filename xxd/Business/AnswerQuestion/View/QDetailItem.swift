//
//  QDetailItem.swift
//  xxd
//
//  Created by remy on 2018/3/9.
//  Copyright © 2018年 com.smartstudy. All rights reserved.
//

let kEventAskAppendTap = "kEventAskAppendTap"
let kEventTeacherInfoTap = "kEventTeacherInfoTap"
let kEventTeacherCheckInfoTap = "kEventCheckUserInfoTap"
let kEventStudentCheckInfoTap = "kEventStudentCheckInfoTap"

protocol QDetailItemStyle: class {
    
    var contentPaddingTop: CGFloat { get }
    var contentPaddingBottom: CGFloat { get }
    var contentPaddingLeft: CGFloat { get }
    var contentPaddingRight: CGFloat { get }
    var contentMaxWidth: CGFloat { get }
    var contentTextLineHeight: CGFloat { get }
    var topInfoHeight: CGFloat { get }
    var audioHeight: CGFloat { get }
}

extension QDetailItemStyle {
    
    var contentPaddingTop: CGFloat {
        return 14
    }
    var contentPaddingBottom: CGFloat {
        return 40
    }
    var contentPaddingLeft: CGFloat {
        return 64
    }
    var contentPaddingRight: CGFloat {
        return 16
    }
    var contentMaxWidth: CGFloat {
        return XDSize.screenWidth - 80
    }
    var contentTextLineHeight: CGFloat {
        return 23
    }
    var topInfoHeight: CGFloat {
        return 64
    }
    var audioHeight: CGFloat {
        return 40
    }
}

class QDetailItem: SSCellItem, QDetailItemStyle {
    
    var model: QuestionDetailModel!
    var isAsker = false
    var targetUser = ""
    var isFirst = false
    var isLast = false
    var showQuestionAfter = false
    
    func setup(targetUser: String, isFirst: Bool = false, isAsker: Bool = false) {
        self.targetUser = targetUser
        self.isFirst = isFirst
        self.isAsker = isAsker
    }
}

class QDetailItemCell: SSTableViewCell, QDetailItemStyle {
    
}

class QuestionAfterBtn: UIButton {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        super.backgroundColor = UIColor(0xFFB400)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var backgroundColor: UIColor? {
        get {
            return super.backgroundColor
        }
        set {
            // 点击整个 UITableViewCell 时,禁用 backgroundColor
        }
    }
}
