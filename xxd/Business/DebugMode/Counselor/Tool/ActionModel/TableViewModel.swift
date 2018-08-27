//
//  TableModel.swift
//  TableViewDemo
//
//  Created by chenyusen on 2017/11/14.
//  Copyright © 2017年 TechSen. All rights reserved.
//

import UIKit

public class SectionItem {
    
    var model: Any?
    
    var headerTitle: String?
    var footerTitle: String?
    
    var headerHeight: CGFloat?
    var footerHeight: CGFloat?
    
    var headerSectionViewClass: SectionView.Type?
    var footerSectionViewClass: SectionView.Type?
    
    var rows: Array<TableCellItem>!
    
    init(model: Any? = nil,
         headerTitle: String? = nil,
         footerTitle: String? = nil,
         headerHeight: CGFloat? = nil,
         footerHeight: CGFloat? = nil,
         headerSectionViewClass: SectionView.Type? = nil,
         footerSectionViewClass: SectionView.Type? = nil,
         rows: Array<TableCellItem>! = []
        ) {
        self.headerTitle = headerTitle
        self.footerTitle = footerTitle
        self.headerHeight = headerHeight
        self.footerHeight = footerHeight
        self.model = model
        self.headerSectionViewClass = headerSectionViewClass
        self.footerSectionViewClass = footerSectionViewClass
        self.rows = rows
    }
}

public class SectionView: UITableViewHeaderFooterView {
    
    static var shouldAppendSectionItemClassToReuseIdentifier = false
    
    var sectionItem: SectionItem?
    
    func updateSection(sectionItem: SectionItem?) {
        self.sectionItem = sectionItem
    }
    
    public override func prepareForReuse() {
        sectionItem = nil
        super.prepareForReuse()
    }
}

public class TableViewModel: NSObject {
    
    
    var sections: Array<SectionItem> = []
}

// MARK: - 增删改查
extension TableViewModel {
    /// 添加一个cellItem,默认添加到最后一个section的最后一个
    ///
    /// - Parameter cellItem: 待添加的cellItem
    /// - Returns: 返回最后一个section
    @discardableResult
    func add(_ cellItem: TableCellItem) -> Array<TableCellItem> {
        if sections.count == 0 {
            let section = SectionItem()
            sections.append(section)
        }
        let section = sections.last!
        section.rows.append(cellItem)
        return sections.last!.rows
    }
    
    
    /// 删除一个cellItem
    ///
    /// - Parameters:
    ///   - cellItem: 待删除的cellItem
    ///   - indexPath: cellItem所在位置
    /// - Returns: 返回sections
    @discardableResult
    func remove(cellItemAt indexPath: IndexPath) ->  Array<SectionItem> {
        assert(indexPath.section < sections.count)
        let section = sections[indexPath.section]
        assert(indexPath.row < section.rows.count)
        section.rows .remove(at: indexPath.row)
        return sections
    }
    
    func removeAll() {
        sections = []
    }
    
    /// 添加一组cellItem,默认添加到最后一个section后面
    ///
    /// - Parameter cellItems: 待添加的cellItems
    /// - Returns: 返回最后一组section
    @discardableResult
    func add(_ cellItems: Array<TableCellItem>) -> Array<TableCellItem> {
        if sections.count == 0 {
            let section = SectionItem()
            sections.append(section)
        }
        let section = sections.last!
        section.rows.append(contentsOf: cellItems)
        return sections.last!.rows
    }
    
    
    /// 添加一个section,默认添加到最后
    ///
    /// - Parameter section: 待添加的section
    /// - Returns: 返回sections
    @discardableResult
    func add(_ section: SectionItem) -> Array<SectionItem> {
        sections.append(section)
        return sections
    }
    
    
    /// 添加多section
    ///
    /// - Parameter sections: 待添加的section组
    /// - Returns: 返回sections
    @discardableResult
    func add(_ sections: Array<SectionItem>) -> Array<SectionItem> {
        self.sections.append(contentsOf: sections)
        return sections
    }
    
    func insert(_ cellItem: TableCellItem, at row: Int, _ section: Int = 0) {
        self.sections[section].rows.insert(cellItem, at: row)
    }
    
    func insert(_ cellItems: [TableCellItem], at row: Int, _ section: Int = 0) {
        self.sections[section].rows.insert(contentsOf: cellItems, at: row)
    }
    
    func remove(cellItem: TableCellItem) {
        for section in sections {
            for aCellItem in section.rows {
                if cellItem == aCellItem {
                    section.rows = section.rows.filter { $0 != cellItem }
                    return
                }
            }
        }
    }
    
    /// 获取指定索引对应的cellItem
    ///
    /// - Parameter indexPath: 索引
    /// - Returns: cellItem
    @discardableResult
    func cellItem(at indexPath: IndexPath) -> TableCellItem? {
        let section = indexPath.section
        let row = indexPath.row
        
        assert(section < sections.count)
        if section < sections.count {
            let rows = sections[section].rows
            if let rows = rows, rows.count != 0 {
                assert(row < rows.count)
                if row  < rows.count {
                    return rows[row]
                }
            }
            
        }
        return nil
    }
    
    func cellItems(at section: Int = 0) -> [TableCellItem] {
        if section < sections.count {
            return sections[section].rows
        }
        return []
    }
    
    func sectionItem(at section:Int) -> SectionItem? {
        if section < sections.count {
            return sections[section]
        }
        return nil
    }
}

extension TableViewModel: UITableViewDataSource {
    
    public func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count;
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        assert(section < sections.count || 0 == sections.count)
        if section < sections.count {
            return sections[section].rows.count
        }
        return 0
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let aCellItem = cellItem(at: indexPath)!
        if let cellClass = aCellItem.cellClass {
            return cell(with: cellClass, tableView: tableView, cellItem: aCellItem)
        } else if let cellNib = aCellItem.cellNib {
            return cell(with: cellNib, tableView: tableView, indexPath: indexPath, cellItem: aCellItem)
        }
        fatalError()
    }
    
    public func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        if let sectionItem = sectionItem(at: section) {
            return sectionItem.footerTitle
        }
        return nil
    }
    
    public func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if let sectionItem = sectionItem(at: section) {
            return sectionItem.headerTitle
        }
        return nil
    }
    
    public func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if let rowActions = cellItem(at: indexPath)?.rowActions {
            return rowActions.count > 0
        }
        return false
    }
}

extension TableViewModel {
    func cell(with cellClass:UITableViewCell.Type,
              tableView: UITableView,
              cellItem: TableCellItem) -> UITableViewCell {
        var identifier = "\(cellClass)"
        if (cellClass as! TableCell.Type).shouldAppendCellItemClassToReuseIdentifier {
            identifier.append("\(cellItem)")
        }
        
        var cell = tableView.dequeueReusableCell(withIdentifier: identifier)
        if cell == nil {
            cell = cellClass.init(style: .default, reuseIdentifier: identifier)
        }
        if let cell = cell as? TableCell {
            UIView.performWithoutAnimation {
                cell.updateCell(cellItem)
            }
        }
        return cell!
    }
    
    func cell(with cellNib: UINib,
              tableView: UITableView,
              indexPath: IndexPath,
              cellItem: TableCellItemProtocol) -> UITableViewCell {
        let identifier = "\(cellNib.self)"
        tableView.register(cellNib, forCellReuseIdentifier: identifier)
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath)
        if let cell = cell as? TableCell {
            UIView.performWithoutAnimation {
                cell.updateCell(cellItem)
            }
        }
        return cell
    }
}
