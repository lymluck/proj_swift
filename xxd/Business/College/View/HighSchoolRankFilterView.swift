//
//  HighSchoolRankFilterView.swift
//  xxd
//
//  Created by Lisen on 2018/4/7.
//  Copyright © 2018年 com.smartstudy. All rights reserved.
//

import UIKit

class HighSchoolRankFilterView: UIView {
    // MARK: properties
    var rankParamClosure: ((String, String, String)->Void)?
    var leftDataSources: HighSchoolRankCategoryModel? {
        didSet {
            leftTableView.reloadData()
            if let rightData = leftDataSources?.options[lastLeftIndex].subOptions?.rankRange?.options {
                rightDataSources = rightData
                rightTableView.reloadData()
            }
        }
    }
    private var lastLeftIndex: Int = 1
    private var lastRightIndex: Int = -1
    private lazy var rightDataSources: [HighSchoolRankOptionsModel] = [HighSchoolRankOptionsModel]()
    private lazy var leftTableView: UITableView = {
        let tableView: UITableView = UITableView(frame: CGRect.zero, style: .plain)
        tableView.backgroundColor = UIColor(0xF5F6F7)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.showsVerticalScrollIndicator = false
        tableView.separatorStyle = .none
        return tableView
    }()
    private lazy var rightTableView: UITableView = {
        let tableView: UITableView = UITableView(frame: CGRect.zero, style: .plain)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.showsVerticalScrollIndicator = false
        tableView.tableFooterView = UIView()
        return tableView
    }()
    
    // MARK: life cycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        initContentViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: private methods
    private func initContentViews() {
        self.addSubview(leftTableView)
        self.addSubview(rightTableView)
        leftTableView.snp.makeConstraints { (make) in
            make.left.top.bottom.equalToSuperview()
            make.width.equalTo(166.0)
        }
        rightTableView.snp.makeConstraints { (make) in
            make.top.right.bottom.equalToSuperview()
            make.left.equalTo(leftTableView.snp.right)
        }
    }
}

extension HighSchoolRankFilterView: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == leftTableView {
            return leftDataSources?.options.count ?? 0
        }
        return rightDataSources.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == leftTableView {
            var cell: UITableViewCell? = tableView.dequeueReusableCell(withIdentifier: "filterCell")
            if cell == nil {
                cell = UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: "filterCell")
            }
            cell?.textLabel?.font = UIFont.systemFont(ofSize: 14.0)
            cell?.textLabel?.text = leftDataSources?.options[indexPath.row].optionName
            cell?.textLabel?.numberOfLines = 0
            cell?.textLabel?.textColor = UIColor(0x26343F)
            cell?.contentView.backgroundColor = UIColor(0xF5F6F7)
            cell?.selectedBackgroundView = UIView(frame: cell!.bounds, color: UIColor.white)                        
            return cell!
        } else {
            var cell: HighSchoolFilterCell? = tableView.dequeueReusableCell(withIdentifier: "rightCell") as? HighSchoolFilterCell
            if cell == nil {
                cell = HighSchoolFilterCell(style: UITableViewCellStyle.default, reuseIdentifier: "rightCell")
            }
            cell?.selectionStyle = .none
            cell?.filterName = rightDataSources[indexPath.row].optionName
            cell?.isClicked = rightDataSources[indexPath.row].isSelected
            if rightDataSources[indexPath.row].isSelected {
                lastRightIndex = indexPath.row
            }            
            return cell!
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 72.0
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if tableView == leftTableView {
            if (leftDataSources?.options[indexPath.row].isSelected)! {
                cell.isSelected = true
                lastLeftIndex = indexPath.row
            }
        }
    }
}

extension HighSchoolRankFilterView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == leftTableView {
            if lastLeftIndex != indexPath.row {
                tableView.cellForRow(at: IndexPath(row: lastLeftIndex, section: 0))?.isSelected = false
                leftDataSources?.options[lastLeftIndex].isSelected = false
            }
            lastLeftIndex = indexPath.row
            if let rightData = leftDataSources?.options[indexPath.row].subOptions?.rankRange?.options {
                rightDataSources.removeAll()
                rightDataSources.append(contentsOf: rightData)
                rightTableView.reloadData()
            }
        } else {
            if let rankCategoryId = leftDataSources?.options[lastLeftIndex].optionId, let title = leftDataSources?.options[lastLeftIndex].optionName.substring(to: 8) {
                let rankRange = rightDataSources[indexPath.row].optionId
                rankParamClosure!(rankCategoryId, rankRange, title)
            }
        }
    }
}

// MARK: 学费筛选视图
class HighSchoolTuitionFilterView: UIView {
    // MARK: properties
    var tiotionParamsClosure: ((String, String)->Void)?
    var tuitionModel: HighSchoolRankCategoryModel? {
        didSet {
            if let _ = tuitionModel {
                tableView.reloadData()
            }
        }
    }
    private var lastIndex: Int = -1
    private lazy var tableView: UITableView = {
        let tableView: UITableView = UITableView(frame: CGRect.zero, style: .plain)
        tableView.dataSource = self
        tableView.delegate = self
        return tableView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        initContentViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: private methods
    private func initContentViews() {
        addSubview(tableView)
        tableView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }
}

extension HighSchoolTuitionFilterView: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tuitionModel?.options.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: HighSchoolFilterCell? = tableView.dequeueReusableCell(withIdentifier: "filterCell") as? HighSchoolFilterCell
        if cell == nil {
            cell = HighSchoolFilterCell(style: UITableViewCellStyle.default, reuseIdentifier: "filterCell")
        }
        cell?.selectionStyle = .none
        cell?.filterName = tuitionModel?.options[indexPath.row].optionName
        cell?.isClicked = (tuitionModel?.options[indexPath.row].isSelected)!
        if (tuitionModel?.options[indexPath.row].isSelected)! {
            lastIndex = indexPath.row
        }
        return cell!
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 56.0
    }
}

extension HighSchoolTuitionFilterView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if lastIndex != -1 {
            (tableView.cellForRow(at: IndexPath(row: lastIndex, section: 0)) as? HighSchoolFilterCell)?.isClicked = false
        }
        (tableView.cellForRow(at: indexPath) as? HighSchoolFilterCell)?.isClicked = true
        lastIndex = indexPath.row
        if let feeRange = tuitionModel?.options[indexPath.row].optionId, let title = tuitionModel?.options[indexPath.row].optionName {
            tiotionParamsClosure!(feeRange, title)
        }
    }
}

// MARK: 学费筛选cell
class HighSchoolFilterCell: UITableViewCell {
    // MARK: properties
    var filterName: String? {
        didSet {
            filterLabel.text = filterName
        }
    }
    var isClicked: Bool = false {
        didSet {
            selectedImg.isHidden = !isClicked
        }
    }
    private lazy var filterLabel: UILabel = {
        let label: UILabel = UILabel(frame: CGRect.zero)
        label.textColor = UIColor(0x26343F)
        label.font = UIFont.systemFont(ofSize: 16.0)
        return label
    }()
    private lazy var selectedImg: UIImageView = {
        let imageView: UIImageView = UIImageView(frame: CGRect.zero, image: UIImage(named: "selected"))
        imageView.isHidden = true
        return imageView
    }()
    // MARK: life cycle
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        initContentViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: event response
    
    // MARK: public methods
    
    // MARK: private methods
    private func initContentViews() {
        contentView.addSubview(filterLabel)
        contentView.addSubview(selectedImg)
        filterLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(16.0)
            make.width.equalTo(120.0)
            make.height.equalTo(16.0)
            make.centerY.equalToSuperview()
        }
        selectedImg.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().offset(-16.0)
        }
    }
}

// MARK: 其他选项筛选视图
class HighSchoolOptionsFilterView: UIView {
    // MARK: properties
    var dataModel: [HighSchoolRankCategoryModel]? {
        didSet {
            collectionView.reloadData()
        }
    }
    
    // TODO: 进行优化, 定义成全局的闭包类型
    var sexParamsClosure: ((String)->Void)?
    var boardParamsClosure: ((String)->Void)?
    private var sexualType: String = ""
    private var boardType: String = ""
    private let kViewTag: Int = 500
    private var lastFirSection: Int = -1
    private var lastSecSection: Int = -1
    private lazy var collectionView: UICollectionView = {
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 81.0, height: 34.0)
        layout.headerReferenceSize = CGSize(width: 60.0, height: 37.0)
        layout.footerReferenceSize = CGSize(width: XDSize.screenWidth-12.0, height: XDSize.unitWidth)
        layout.minimumLineSpacing = 9.0
        layout.minimumInteritemSpacing = 9.0
        layout.sectionInset = UIEdgeInsets(top: 12.0, left: 12.0, bottom: 16.0, right: 12.0)
        let collectionView: UICollectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        collectionView.backgroundColor = UIColor.white
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.showsVerticalScrollIndicator = false
        collectionView.register(HighSchoolOptionsCell.classForKeyedArchiver(), forCellWithReuseIdentifier: "optionCell")
        collectionView.register(HighSchoolOptionsHeaderView.classForKeyedArchiver(), forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "optionsHeaderView")
        collectionView.register(UICollectionReusableView.classForKeyedArchiver(), forSupplementaryViewOfKind: UICollectionElementKindSectionFooter, withReuseIdentifier: "footerView")
        return collectionView
    }()
    private lazy var resetBtn: UIButton = {
        let button: UIButton = UIButton(frame: CGRect.zero)
        button.setTitle("重置", for: .normal)
        button.setBackgroundColor(UIColor(0xE4E5E6), for: .normal)
        button.setTitleColor(UIColor(0x58646E), for: .normal)
        button.layer.masksToBounds = true
        button.layer.cornerRadius = 4.0
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16.0)
        button.tag = kViewTag
        button.addTarget(self, action: #selector(HighSchoolOptionsFilterView.eventButtonResponse(_:)), for: .touchUpInside)
        return button
    }()
    private lazy var compBtn: UIButton = {
        let button: UIButton = UIButton(frame: CGRect.zero)
        button.setTitle("完成", for: .normal)
        button.setBackgroundColor(UIColor(0x078CF1), for: .normal)
        button.setTitleColor(UIColor.white, for: .normal)
        button.layer.masksToBounds = true
        button.layer.cornerRadius = 4.0
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16.0)
        button.tag = kViewTag + 1
        button.addTarget(self, action: #selector(HighSchoolOptionsFilterView.eventButtonResponse(_:)), for: .touchUpInside)
        return button
    }()
    
    // MARK: life cycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        initContentViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    // MARK: event response
    @objc private func eventButtonResponse(_ sender: UIButton) {
        let index = sender.tag - kViewTag
        if index == 0 {
            sexualType = ""
            boardType = ""
            if lastFirSection != -1  && lastFirSection != 0 {
                let lastCell = collectionView.cellForItem(at: IndexPath(item: lastFirSection, section: 0)) as! HighSchoolOptionsCell
                lastCell.isClicked = false
                let firstCell = collectionView.cellForItem(at: IndexPath(item: 0, section: 0)) as! HighSchoolOptionsCell
                firstCell.isClicked = true
                lastFirSection = 0
            }
            if lastSecSection != -1 && lastSecSection != 0 {
                let lastCell = collectionView.cellForItem(at: IndexPath(item: lastSecSection, section: 1)) as! HighSchoolOptionsCell
                lastCell.isClicked = false
                let firstCell = collectionView.cellForItem(at: IndexPath(item: 0, section: 1)) as! HighSchoolOptionsCell
                firstCell.isClicked = true
                lastSecSection = 0
            }
        } else {
            sexParamsClosure!(sexualType)
            boardParamsClosure!(boardType)
        }
    }
    
    // MARK: private methods
    private func initContentViews() {
        backgroundColor = UIColor.white
        addSubview(collectionView)
        addSubview(resetBtn)
        addSubview(compBtn)
        var adaptHeight: CGFloat = 202.0
        if UIScreen.isP35 || UIScreen.isP4 {
            adaptHeight = 245.0
        }
        collectionView.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.height.equalTo(adaptHeight)
        }
        resetBtn.snp.makeConstraints { (make) in
            make.top.equalTo(collectionView.snp.bottom).offset(12.0)
            make.height.equalTo(40.0)
            make.left.equalToSuperview().offset(12.0)
            make.right.equalTo(self.snp.centerX).offset(-5.5)
        }
        compBtn.snp.makeConstraints { (make) in
            make.top.equalTo(resetBtn)
            make.height.equalTo(resetBtn)
            make.left.equalTo(self.snp.centerX).offset(5.5)
            make.right.equalToSuperview().offset(-12.0)
        }
    }
}

extension HighSchoolOptionsFilterView: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return dataModel?.count ?? 0
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataModel![section].options.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: HighSchoolOptionsCell = collectionView.dequeueReusableCell(withReuseIdentifier: "optionCell", for: indexPath) as! HighSchoolOptionsCell
        cell.cellTitle = dataModel![indexPath.section].options[indexPath.row].optionName
        cell.isClicked = dataModel![indexPath.section].options[indexPath.row].isSelected
        if indexPath.section == 0 {
            if dataModel![indexPath.section].options[indexPath.row].isSelected {
              lastFirSection = indexPath.row
            }
        } else {
            if dataModel![indexPath.section].options[indexPath.row].isSelected {
                lastSecSection = indexPath.row
            }
        }
        
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionElementKindSectionHeader {
            let header: HighSchoolOptionsHeaderView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "optionsHeaderView", for: indexPath) as! HighSchoolOptionsHeaderView
            header.backgroundColor = UIColor.white
            // TODO: 解决强制解包的问题
            header.headerTitle = dataModel?[indexPath.section].rankTitle
            return header
        } else {
            let footerView: UICollectionReusableView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionFooter, withReuseIdentifier: "footerView", for: indexPath)
            footerView.backgroundColor = UIColor(0xE1E2E3)
            return footerView
        }
    }
}

extension HighSchoolOptionsFilterView: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            if lastFirSection != -1 {
                let lastCell = collectionView.cellForItem(at: IndexPath(item: lastFirSection, section: 0)) as! HighSchoolOptionsCell
                lastCell.isClicked = false
            }
            (collectionView.cellForItem(at: indexPath) as! HighSchoolOptionsCell).isClicked = true
            lastFirSection = indexPath.item
            if let optionId = dataModel?[0].options[indexPath.item].optionId {
                sexualType = optionId
            }
        } else {
            if lastSecSection != -1 {
                let lastCell = collectionView.cellForItem(at: IndexPath(item: lastSecSection, section: 1)) as! HighSchoolOptionsCell
                lastCell.isClicked = false
            }
            (collectionView.cellForItem(at: indexPath) as! HighSchoolOptionsCell).isClicked = true
            lastSecSection = indexPath.item
            if let optionId = dataModel?[1].options[indexPath.item].optionId {
                boardType = optionId
            }
        }
    }
}

class HighSchoolOptionsHeaderView: UICollectionReusableView {
    // MARK: properties
    var headerTitle: String? {
        didSet {
            titleLabel.text = headerTitle
        }
    }
    private lazy var titleLabel: UILabel = {
        let label: UILabel = UILabel(frame: CGRect.zero)
        label.textColor = UIColor(0x26343F)
        label.text = "学校类型"
        label.font = UIFont.systemFont(ofSize: 15.0)
        return label
    }()
    
    // MARK: life cycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        initContentViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: private methods
    private func initContentViews() {
        addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(12.0)
            make.top.equalToSuperview().offset(16.0)
            make.bottom.equalToSuperview()
            make.width.equalTo(80.0)
        }
    }
}

// MARK: 筛选条件cell
class HighSchoolOptionsCell: UICollectionViewCell {
    // MARK: properties
    var cellTitle: String? {
        didSet {
            optionLabel.text = cellTitle
        }
    }
    var isClicked: Bool = false {
        didSet {
            if isClicked {
                optionLabel.backgroundColor = UIColor(0x078CF1, 0.1)
                optionLabel.layer.borderColor = UIColor(0x078CF1).cgColor
                optionLabel.textColor = UIColor(0x078CF1)
            } else {
                optionLabel.textColor = UIColor(0x58646E)
                optionLabel.backgroundColor = UIColor.white
                optionLabel.layer.borderColor = UIColor(0xC4C9CC).cgColor
            }
        }
    }
    private lazy var optionLabel: UILabel = {
        let label: UILabel = UILabel(frame: CGRect.zero)
        label.textColor = UIColor(0x58646E)
        label.layer.cornerRadius = 4.0
        label.layer.masksToBounds = true
        label.layer.borderWidth = 0.5
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 13.0)
        return label
    }()
    
    // MARK: life cycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        initContentViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: private methods
    private func initContentViews() {
        backgroundColor = UIColor.white
        contentView.addSubview(optionLabel)
        optionLabel.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }
}

