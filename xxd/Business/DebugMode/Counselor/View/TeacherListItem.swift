//
//  TeacherListItem.swift
//  xxd
//
//  Created by chenyusen on 2018/3/5.
//  Copyright © 2018年 com.smartstudy. All rights reserved.
//

import UIKit

class TeacherListItem: SSCellItem {
    var model: TeacherListModel!
    var logoSize: CGSize?
    weak var currentCell: UITableViewCell?
    override func cellClass() -> AnyClass! {
        return TeacherListCell.self
    }
    
    override init!(attributes: [AnyHashable : Any]! = [:]) {
        super.init(attributes: attributes)
    }
    
    override init!(cellClass: AnyClass!, userInfo: Any!) {
        super.init(cellClass: cellClass, userInfo: userInfo)
    }
}

class NoAdjustColorLabel: UILabel {
    
    var customBackgroundColor: UIColor? {
        set {
            super.backgroundColor = newValue
        }
        get {
            return super.backgroundColor
        }
    }
    
    
    override var backgroundColor: UIColor? {
        set {}
        get { return nil }
    }
}

class TeacherListCell: SSTableViewCell {
    private var avatarView: UIImageView!
    private var nicknameLabel: UILabel!
    private var locationLabel: UILabel!
    private var positionLalbel: NoAdjustColorLabel! // 职位
    private var workYearLabel: NoAdjustColorLabel! // 工作年限
    private var schoolLabel: UILabel! // 毕业院校
    private var companyLabel: UILabel! // 公司
    private var companyLogoView: UIImageView!
    

    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.backgroundColor = .white
        avatarView = UIImageView()
        avatarView.layer.cornerRadius = 25
        avatarView.clipsToBounds = true
        contentView.addSubview(avatarView)
        avatarView.snp.makeConstraints({ (make) in
            make.left.equalTo(16)
            make.top.equalTo(20)
            make.size.equalTo(CGSize(width: 50, height: 50))
        })
        
        nicknameLabel = UILabel()
        nicknameLabel.textColor = UIColor(0x26343F)
        nicknameLabel.font = UIFont.systemFont(ofSize: 17)
        contentView.addSubview(nicknameLabel)
        nicknameLabel.snp.makeConstraints({ (make) in
            make.left.equalTo(82)
            make.top.equalTo(22)
            make.right.lessThanOrEqualTo(-16)
        })
        
        positionLalbel = NoAdjustColorLabel()
        positionLalbel.textColor = .white
        positionLalbel.layer.cornerRadius = 9
        positionLalbel.clipsToBounds = true
        positionLalbel.font = UIFont.systemFont(ofSize: 11)
        positionLalbel.customBackgroundColor = UIColor(0x77C4FF)
        contentView.addSubview(positionLalbel)
        positionLalbel.snp.makeConstraints({ (make) in
            make.left.equalTo(82)
            make.top.equalTo(48)
            make.height.equalTo(18)
            make.width.lessThanOrEqualTo(150)
        })
        
        workYearLabel = NoAdjustColorLabel()
        workYearLabel.textColor = .white
        workYearLabel.layer.cornerRadius = 9
        workYearLabel.clipsToBounds = true
        workYearLabel.font = UIFont.systemFont(ofSize: 11)
        workYearLabel.customBackgroundColor = UIColor(0xA5D7AC)
        contentView.addSubview(workYearLabel)
        workYearLabel.snp.makeConstraints({ (make) in
            make.left.equalTo(positionLalbel.snp.right).offset(4)
            make.top.equalTo(48)
            make.height.equalTo(18)
            make.width.lessThanOrEqualTo(150)
        })
        
        locationLabel = UILabel()
        locationLabel.textColor = UIColor(0x949BA1)
        locationLabel.font = UIFont.systemFont(ofSize: 12)
        contentView.addSubview(locationLabel)
        locationLabel.snp.makeConstraints({ (make) in
            make.top.equalTo(22)
            make.right.equalTo(-16)
        })
        
        schoolLabel = UILabel()
        schoolLabel.textColor = UIColor(0x949BA1)
        schoolLabel.font = UIFont.systemFont(ofSize: 12)
        contentView.addSubview(schoolLabel)
        schoolLabel.snp.makeConstraints({ (make) in
            make.left.equalTo(82)
            make.top.equalTo(76)
        })
        
        companyLabel = UILabel()
        companyLabel.textColor = UIColor(0x949BA1)
        companyLabel.font = UIFont.systemFont(ofSize: 12)
        contentView.addSubview(companyLabel)
        companyLabel.snp.makeConstraints({ (make) in
            make.left.equalTo(82)
            make.top.equalTo(94)
        })
        
        
        
        companyLogoView = UIImageView()
        companyLogoView.right = contentView.width - 16
        companyLogoView.bottom = contentView.height - 18
        companyLogoView.autoresizingMask = [.flexibleTopMargin, .flexibleLeftMargin]
        contentView.addSubview(companyLogoView)
        
        let bottomLine = UIView()
        bottomLine.backgroundColor = UIColor(0xE4E5E6)
        contentView.addSubview(bottomLine)
        bottomLine.snp.makeConstraints({ (make) in
            make.bottom.right.equalToSuperview()
            make.left.equalTo(82)
            make.height.equalTo(XDSize.unitWidth)
        })
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func shouldUpdate(with object: Any!) -> Bool {
        if super.shouldUpdate(with: object) {
            if let cellItem = item as? TeacherListItem, let model = cellItem.model {
                cellItem.currentCell = self
                resizeLogoView()
                avatarView.kf.setImage(with:URL(string:  model.avatar),
                                       placeholder: UIImage.getPlaceHolderImage(size: CGSize(width: 50, height: 50)))
                nicknameLabel.text = model.name
                locationLabel.text = model.location
                positionLalbel.text = "   " + model.title + "   "
                workYearLabel.text = "   从业\(model.workYear)年   "
                schoolLabel.text = "· " + model.school
                companyLabel.text = "· " + model.company
            }
            return true
        }
        return false
    }
    
    func resizeLogoView() {
        if let cellItem = item as? TeacherListItem, let model = cellItem.model {
            if let logoSize = cellItem.logoSize {
                companyLogoView.size = logoSize
                companyLogoView.right = contentView.width - 16
                companyLogoView.bottom = contentView.height - 18
                companyLogoView.autoresizingMask = [.flexibleTopMargin, .flexibleLeftMargin]
            } else {
                companyLogoView.kf.setImage(with: URL(string: model.logo), completionHandler: { (image, _, _, _) in
                    if let image = image {
                        let size = CGSize(width: CGFloat(32), height: CGFloat(32) * image.size.height / image.size.width)
                        cellItem.logoSize = size
                        (cellItem.currentCell as? TeacherListCell)?.resizeLogoView()
                    }
                })
            }
            
        }
    }
    
    override func prepareForReuse() {
        if (item as? TeacherListItem)?.currentCell == self {
            (item as? TeacherListItem)?.currentCell = nil
        }
        super.prepareForReuse()
    }
}
