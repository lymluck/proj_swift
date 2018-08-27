//
//  TableCellItem.swift
//  TableViewDemo
//
//  Created by chenyusen on 2017/11/14.
//  Copyright © 2017年 TechSen. All rights reserved.
//

import UIKit
//
//func ==(lhs: TableCellItemProtocol , rhs:TableCellItemProtocol) -> Bool {
//    return lhs.hashValue == rhs.hashValue
//}

public protocol TableCellItemProtocol {
    
    /// 当前cellItem所需要绑定的cell类型
    var cellClass: UITableViewCell.Type? { get }
    /// 当前cellItem所需要
    var cellNib: UINib? { get }
    /// 当前cellItem正在绑定的cell
    var currentCell: UITableViewCell? { get set }
    /// 当前cellItem所持有的用于渲染cell的数据信息
    var model: Any? { get set }
    /// 当前cellItem所持有cell的高度
    var cellHeight: CGFloat { get }
    /// 所支持的侧滑
    var rowActions: [UITableViewRowAction]? { get }
}

public extension TableCellItemProtocol {
    var cellClass: UITableViewCell.Type? {
        return nil
    }
    
    var cellNib: UINib? {
        if cellClass == nil {
            fatalError("you should implement cellClass or cellNib")
        }
        return nil
    }
    
    var cellHeight: CGFloat? {
        return -1
    }
    
    var rowActions: [UITableViewRowAction]? {
        return nil
    }
}


public protocol TableCellProtocol {
    func updateCell(_ cellItem: TableCellItemProtocol?)
}

public extension TableCellProtocol {
    static var shouldAppendCellItemClassToReuseIdentifier: Bool {
        return false
    }
}

open class TableCellItem: NSObject, TableCellItemProtocol {
    public var rowActions: [UITableViewRowAction]? {
        return nil
    }

    
    public var cellHeight: CGFloat {
        return 40
    }
    
    public var currentCell: UITableViewCell?
    public var model: Any?
    
    public var cellClass: UITableViewCell.Type? {
        
        if cellNib == nil {
            fatalError("you should override one of cellClass and cellNib")
        }
        return nil
    }
    
    public var cellNib: UINib? {
        if cellClass == nil {
            fatalError("you should override one of cellClass and cellNib")
        }
        return nil
    }
    
    public init(attributes:[AnyHashable: Any]? = nil) {
        
    }
}

open class TableCell: UITableViewCell, TableCellProtocol {
    
    public override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
//        selectionStyle = .none
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    class var shouldAppendCellItemClassToReuseIdentifier: Bool {
        return false
    }
  
    public var cellItem: TableCellItemProtocol?
    public func updateCell(_ cellItem: TableCellItemProtocol?) {
        self.cellItem = cellItem
        (self.cellItem as? TableCellItem)?.currentCell = self
    }
    
    open override func prepareForReuse() {
//        (cellItem as? TableCellItem)?.currentCell = nil
        if let currentCell = (cellItem as? TableCellItem)?.currentCell, currentCell == self {
            (cellItem as? TableCellItem)?.currentCell = nil
        }
        cellItem = nil
        super.prepareForReuse()
    }
}

