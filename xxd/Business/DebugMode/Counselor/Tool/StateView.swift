//
//  StateView.swift
//  TSKitDemo
//
//  Created by chenyusen on 2017/9/30.
//  Copyright © 2017年 TechSen. All rights reserved.
//

import UIKit
import SnapKit

class StateView: UIView {
    
    /// 数据为空时的文案
    var emptyText: String = DefaultConfig.Text.empty
    
    /// 错误时的文案
    var errorText: String = DefaultConfig.Text.error
    
    /// 无网络时的文案
    var noNetworkText: String = DefaultConfig.Text.noNetwork
    
    lazy var imageView: UIImageView? = {
        let aImageView = UIImageView()
        addSubview(aImageView)
        aImageView.snp.makeConstraints {
          $0.center.equalTo(self).offset(DefaultConfig.Layout.centerYOffset)
            
        }
        return aImageView
    }()
    var textLabel: UILabel?
    var subTextLabel: UILabel?
    
    
    enum State {
        case normal
        case empty
        case error
        case noNetwork
    }
    
    var state: State = .normal {
        didSet {
            switch state {
            case .normal:
                fatalError()
            case .empty:
                fatalError()
            case .error:
                fatalError()
            case .noNetwork:
                fatalError()
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
