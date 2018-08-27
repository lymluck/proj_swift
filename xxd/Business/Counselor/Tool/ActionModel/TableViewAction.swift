//
//  TableViewAction.swift
//  TSKitDemo
//
//  Created by chenyusen on 2017/11/7.
//  Copyright © 2017年 TechSen. All rights reserved.
//

import UIKit


public typealias ActionBlock = (TableCellItem, IndexPath) -> (Bool)

public class TableViewAction: NSObject {
    weak var delegate: TableViewModel?
    var shouldScrollToTop = true
    var cellItemSet: Set<TableCellItem> = []
    var cellActionDict: Dictionary = [AnyHashable: ActionBlock]()
    var cellClassActionDict: Dictionary = [AnyHashable: ActionBlock]()
    
    public var scrollViewDidScrollBlock: ((UIScrollView) -> ())?
    

    public convenience init(with delegate: TableViewModel?) {
        self.init()
        self.delegate = delegate
    }
}


public extension TableViewAction {
    override func forwardingTarget(for aSelector: Selector!) -> Any? {
        return super.forwardingTarget(for: aSelector)
    }
}


public extension TableViewAction {
    public func tap(cellItem: TableCellItem, actionBlock: @escaping ActionBlock) {
        cellItemSet.insert(cellItem)
        cellActionDict[cellItem.hashValue] = actionBlock
    }
    
    public func tap(to cellItemClass: TableCellItem.Type, actionBlock: @escaping ActionBlock) {
        cellClassActionDict[cellItemClass.hash()] = actionBlock
    }
    
    public func scrollView(didScroll block:((UIScrollView) -> ())) {
        
    }
}

extension TableViewAction: UITableViewDelegate {
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if let cellItem = delegate?.cellItem(at: indexPath), cellItem.cellHeight > 0 {
            return cellItem.cellHeight
        }
        return tableView.rowHeight
    }
    
    
    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if let sectionItem = delegate?.sectionItem(at: section), let _ = sectionItem.headerSectionViewClass {
            if let headerHeight = sectionItem.headerHeight {
                return headerHeight
            }
            return tableView.sectionHeaderHeight
        }
        return 0
    }
    
    public func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if let sectionItem = delegate?.sectionItem(at: section), let _ = sectionItem.footerSectionViewClass {
            if let footerHeight = sectionItem.footerHeight {
                return footerHeight
            }
            return tableView.sectionFooterHeight
        }
        return 0
    }
    
    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if let sectionItem = delegate?.sectionItem(at: section), let headerSectionViewClass = sectionItem.headerSectionViewClass {
            return headerOrFootView(with: headerSectionViewClass, sectionItem: sectionItem, tableView: tableView)
        }
        return nil
    }

    public func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if let sectionItem = delegate?.sectionItem(at: section), let footerSectionViewClass = sectionItem.footerSectionViewClass {
            return headerOrFootView(with: footerSectionViewClass, sectionItem: sectionItem, tableView: tableView)
        }
        return nil
    }
    
    public func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        if let cellItem = delegate?.cellItem(at: indexPath) {
            return cellItem.rowActions
        }
        return nil
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cellItem = delegate?.cellItem(at: indexPath), let action = cellActionDict[cellItem.hashValue] {
            let returnValue = action(cellItem, indexPath)
            if returnValue {
                tableView.deselectRow(at: indexPath, animated: true)
            }
        } else if let cellItem = delegate?.cellItem(at: indexPath), let action = cellClassActionDict[type(of: cellItem).hash()] {
            let returnValue = action(cellItem, indexPath)
            if returnValue {
                tableView.deselectRow(at: indexPath, animated: true)
            }
        }
    }
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        scrollViewDidScrollBlock?(scrollView)
    }
    
    public func scrollViewShouldScrollToTop(_ scrollView: UIScrollView) -> Bool {
        return shouldScrollToTop
    }
}

extension TableViewAction {
    func headerOrFootView(with viewClass:UITableViewHeaderFooterView.Type,
                          sectionItem: SectionItem,
                          tableView: UITableView) -> UITableViewHeaderFooterView {
        var identifier = "\(viewClass)"
        if let viewClass = viewClass as? SectionView.Type {
            if viewClass.shouldAppendSectionItemClassToReuseIdentifier {
                identifier.append("\(sectionItem)")
            }
        }
        var sectionView = tableView.dequeueReusableHeaderFooterView(withIdentifier: identifier)
        if sectionView == nil {
            sectionView = viewClass.init(reuseIdentifier:identifier)
        }
        if let sectionView = sectionView as? SectionView {
            sectionView.updateSection(sectionItem: sectionItem)
        }
        return sectionView!
    }
}
