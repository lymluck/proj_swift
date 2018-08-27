//
//  CollegeFilterContentView.swift
//  xxd
//
//  Created by remy on 2018/2/22.
//  Copyright © 2018年 com.smartstudy. All rights reserved.
//

let kEventCollegeFilterOptionChange = "kEventCollegeFilterOptionChange"
let kEventCollegeFilterOthersChange = "kEventCollegeFilterOthersChange"
private let kItemHeight: CGFloat = 56
private let kItemTitleTag = 1100
private let kItemStateTag = 1200
private var kItemDataKey: UInt8 = 0

class CollegeFilterOptionsView: UIView {
    
    private var itemList = [UIView]()
    private var lastIndex = 0
    var text = ""
    var value: String! {
        didSet {
            /// 由于筛选项是从服务器获取的,当用户选择了某个选项之后,由于重复赋值,会导致筛选框后面的✔️图片不显示, 故暂时屏蔽
//            if oldValue != value {
                for (index, data) in dataList.enumerated() {
                    if value == data[1] {
                        text = data[0]
                        let item = itemList[index]
                        (item.viewWithTag(kItemTitleTag) as! UILabel).textColor = XDColor.main
                        item.viewWithTag(kItemStateTag)!.isHidden = false
                        if lastIndex != index {
                            let lastItem = itemList[lastIndex]
                            (lastItem.viewWithTag(kItemTitleTag) as! UILabel).textColor = XDColor.itemTitle
                            lastItem.viewWithTag(kItemStateTag)!.isHidden = true
                        }
                        lastIndex = index
                        break
                    }
                }
//            }
        }
    }
    var dataList = [[String]]() {
        didSet {
            addOptions()
        }
    }
    
    convenience init() {
        self.init(frame: CGRect(x: 0, y: 0.0, width: XDSize.screenWidth, height: 0))
        backgroundColor = UIColor.white
        self.isHidden = true
    }
    
    private func addOptions() {
        removeAllSubviews()
        itemList = [UIView]()
        for (index, data) in dataList.enumerated() {
            let view = UIView(frame: CGRect(x: 0, y: kItemHeight * CGFloat(index), width: XDSize.screenWidth, height: kItemHeight))
            view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(itemTap(gestureRecognizer:))))
            objc_setAssociatedObject(view, &kItemDataKey, ["text":data[0], "value":data[1]], .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            self.addSubview(view)
            itemList.append(view)
            
            let label = UILabel(frame: CGRect(x: 16, y: 17, width: view.width - 63, height: 21), text: data[0], textColor: XDColor.itemTitle, fontSize: 15)!
            label.tag = kItemTitleTag
            view.addSubview(label)
            
            let state = UIImageView(frame: CGRect(x: view.width - 31, y: 20, width: 16, height: 12), imageName: "selected")!
            state.tag = kItemStateTag
            state.isHidden = true
            view.addSubview(state)
            
            view.addSubview(UIView(frame: CGRect(x: 0, y: kItemHeight - XDSize.unitWidth, width: XDSize.screenWidth, height: XDSize.unitWidth), color: XDColor.itemLine))
        }
        height = kItemHeight * CGFloat(dataList.count)
    }
    
    //MARK:- Action
    @objc func itemTap(gestureRecognizer: UIGestureRecognizer) {
        let item = gestureRecognizer.view!
        let data = objc_getAssociatedObject(item, &kItemDataKey) as! [String : String]
        if value != data["value"] {
            value = data["value"]!
            routerEvent(name: kEventCollegeFilterOptionChange, data: [:])
        }
    }
}

typealias heightDidChangeClosure = (_ height: CGFloat)->Void

class CollegeFilterOthersView: UIScrollView {
    
    var heightClosure: heightDidChangeClosure?
    private var titles = [String]()
    private var sectionList = [UIView]()
    private var itemList = [[UILabel]]()
    private var btnView: UIView!
    private var tempValues = [String]()
    private(set) var values = [String]()
    // 存在空字符串值,所以不能代表空
    private let emptyValue = "--"
    var dataList = [[[String]]]() {
        didSet {
            addSections()
            values = [String](repeating: emptyValue, count: dataList.count)
            resetState()
        }
    }
    var isEmpty: Bool {
        for value in values {
            if value != emptyValue { return false }
        }
        return true
    }
    override var isHidden: Bool {
        didSet {
            if isHidden {
                tempValues = values
                for i in 0..<tempValues.count {
                    updateItemsInSection(i)
                }
                updateSections()
            }
        }
    }
    
    convenience init(titles: [String]) {
        self.init(frame: CGRect(x: 0, y: 0.0, width: XDSize.screenWidth, height: 0))
        backgroundColor = UIColor.white
        showsHorizontalScrollIndicator = false
        showsVerticalScrollIndicator = false
        scrollsToTop = false
        bounces = false
        super.isHidden = true
        self.titles = titles
    }
    
    private func addSections() {
        sectionList = [UIView]()
        itemList = [[UILabel]]()
        let maxCountInRow = XDSize.screenWidth < 375 ? 3 : 4
        let itemWidth = ((XDSize.screenWidth - 24 - (CGFloat(maxCountInRow) - 1) * 9) / CGFloat(maxCountInRow)).rounded()
        for (index, sectionData) in dataList.enumerated() {
            var sectionHeight: CGFloat = 0
            let view = UIView(frame: CGRect(x: 0, y: 0, width: XDSize.screenWidth, height: 0))
            self.addSubview(view)
            sectionList.append(view)
            if index > 0 {
                view.addSubview(UIView(frame: CGRect(x: 12, y: 0, width: XDSize.screenWidth - 24, height: XDSize.unitWidth), color: XDColor.itemLine))
            }
            
            if !titles[index].isEmpty {
                let titleText = titles[index]
                let titleLabel = UILabel(frame: CGRect(x: 12, y: 0, width: XDSize.screenWidth, height: 49), text: titleText, textColor: XDColor.itemTitle, fontSize: 15)!
                view.addSubview(titleLabel)
                sectionHeight += 49
            } else {
                sectionHeight += 16
            }
            
            var items = [UILabel]()
            for (i, data) in sectionData.enumerated() {
                let left = CGFloat(i % maxCountInRow) * (itemWidth + 9) + 12
                let top = CGFloat(i / maxCountInRow * 42) + 49
                let label = UILabel(frame: CGRect(x: left, y: top, width: itemWidth, height: 34), text: data[0], textColor: UIColor(0x58646E), fontSize: 13)!
                label.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(itemTap(gestureRecognizer:))))
                label.isUserInteractionEnabled = true
                label.textAlignment = .center
                label.layer.cornerRadius = 4
                label.layer.borderWidth = 0.5
                label.layer.borderColor = UIColor(0xC4C9CC).cgColor
                var info: [String : String] = ["text":data[0], "value":data[1], "section":"\(index)"]
                if data.count > 2 {
                    info["linkSection"] = data[2]
                }
                objc_setAssociatedObject(label, &kItemDataKey, info, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                view.addSubview(label)
                items.append(label)
            }
            itemList.append(items)
            sectionHeight += CGFloat(sectionData.count / maxCountInRow * 42 + 34)
            view.height = sectionHeight + 16
        }
        btnView = UIView(frame: CGRect(x: 0, y: 0, width: XDSize.screenWidth, height: 64))
        self.addSubview(btnView)
        let btnWidth = (XDSize.screenWidth - 36) / 2
        let reset = UIButton(frame: CGRect(x: 12, y: 12, width: btnWidth, height: 40), title: "reset".localized, fontSize: 16, titleColor: UIColor(0x58646E), target: self, action: #selector(resetState))!
        reset.layer.cornerRadius = 4
        reset.backgroundColor = XDColor.itemLine
        btnView.addSubview(reset)
        
        let finish = UIButton(frame: CGRect(x: reset.right + 12, y: 12, width: btnWidth, height: 40), title: "done".localized, fontSize: 16, titleColor: UIColor.white, target: self, action: #selector(finishState))!
        finish.layer.cornerRadius = 4
        finish.backgroundColor = XDColor.main
        btnView.addSubview(finish)
    }
    
    private func updateItemsInSection(_ index: Int) {
        let items = itemList[index]
        let value = tempValues[index]
        for item in items {
            let data = objc_getAssociatedObject(item, &kItemDataKey) as! [String : String]
            let itemValue = data["value"]!
            let isSelected = itemValue == value
            if isSelected {
                item.textColor = XDColor.main
                item.backgroundColor = XDColor.main.withAlphaComponent(0.1)
                item.layer.borderColor = XDColor.main.cgColor
            } else {
                item.textColor = UIColor(0x58646E)
                item.backgroundColor = UIColor.clear
                item.layer.borderColor = UIColor(0xC4C9CC).cgColor
            }
            if let linkSection = data["linkSection"] {
                let linkIndex = Int(linkSection)!
                sectionList[linkIndex].isHidden = !isSelected
                if !isSelected && !tempValues[linkIndex].isEmpty {
                    // 联动section隐藏后清空值
                    tempValues[linkIndex] = emptyValue
                    let items = itemList[linkIndex]
                    for item in items {
                        item.textColor = UIColor(0x58646E)
                        item.backgroundColor = UIColor.clear
                        item.layer.borderColor = UIColor(0xC4C9CC).cgColor
                    }
                }
            }
        }
    }
    
    private func updateSections() {
        var height: CGFloat = 0
        for view in sectionList {
            if !view.isHidden {
                view.top = height
                height += view.height
            }
        }
        btnView.top = height
        height += btnView.height
        self.height = min(XDSize.screenHeight - screenViewY, height)
        contentSize = CGSize(width: XDSize.screenWidth, height: height)
        if let closure = heightClosure {
            closure(height)
        }
    }
    
    //MARK:- Action
    @objc func itemTap(gestureRecognizer: UIGestureRecognizer) {
        let item = gestureRecognizer.view as! UILabel
        let data = objc_getAssociatedObject(item, &kItemDataKey) as! [String : String]
        let index = Int(data["section"]!)!
        if tempValues[index] == data["value"] {
            tempValues[index] = emptyValue
        } else {
            tempValues[index] = data["value"]!
        }
        updateItemsInSection(index)
        updateSections()
    }
    
    @objc func finishState() {
        values = tempValues
        routerEvent(name: kEventCollegeFilterOthersChange, data: [:])
    }
    
    @objc func resetState() {
        tempValues = [String](repeating: emptyValue, count: dataList.count)
//        values = [String](repeating: emptyValue, count: dataList.count)
//        tempValues = values
        for i in 0..<tempValues.count {
            updateItemsInSection(i)
        }
        updateSections()
    }
}
