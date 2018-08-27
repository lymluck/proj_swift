//
//  TopLoadMoreRefreshControl.swift
//  counselor_t
//
//  Created by chenyusen on 2018/1/23.
//  Copyright © 2018年 TechSen. All rights reserved.
//

import UIKit

class TopLoadMoreRefreshControl: UIView {
    var observation: NSKeyValueObservation?
    var deltaHeight: CGFloat = 30
    var isAnimating = false
    var hasTouched = false
    var canExecuteBlock = true
    var neverDisplay = false {
        didSet {
            if neverDisplay {
                stopAnimating()
                invalidateObservation()
                if let tableView = superview as? UITableView {
                    UIView.animate(withDuration: 0.2, animations: {
                        tableView.contentInset.top -= self.deltaHeight
                    }, completion: { [weak self] (_) in
                        self?.removeFromSuperview()
                    })
                    
                }
                
            }
        }
    }
    
    private var refreshBlock: (() -> ())?
    private var activityIndicatorView: UIActivityIndicatorView!

    
    init(refreshBlock: (() -> ())? = nil) {
        super.init(frame: CGRect(x: 0, y: -deltaHeight, width: XDSize.screenWidth, height: deltaHeight))
        self.refreshBlock = refreshBlock
        activityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        activityIndicatorView.hidesWhenStopped = true
        activityIndicatorView.center = CGPoint(x: width * 0.5, y: height * 0.5)
        addSubview(activityIndicatorView)
//        activityIndicatorView.snp.makeConstraints { (make) in
//            make.center.equalToSuperview()
//        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
  
    func addObservation() {
        if let tableView = superview as? UITableView, observation == nil {
            observation = tableView.observe(\UITableView.contentOffset, options: [.new], changeHandler: { [weak self] (_, change) in
                guard let sSelf = self else { return }
                if tableView.isTracking { sSelf.hasTouched = true }
                if sSelf.hasTouched {
                    if let newContentOffset = change.newValue {
                        if newContentOffset.y < 0 {
                            
                            sSelf.startAnimating()
                            if !tableView.isDragging && sSelf.canExecuteBlock {
                                sSelf.canExecuteBlock = false
                                sSelf.refreshBlock?()
                                sSelf.hasTouched = false
                            }
                        }
                    }
                }
            })
        }
    }
    
    func invalidateObservation() {
        observation?.invalidate()
        observation = nil
    }
    
    deinit {
        invalidateObservation()
    }
}

extension TopLoadMoreRefreshControl {
    func stopAnimating() {
        if isAnimating {
            canExecuteBlock = true
            isAnimating = false
            activityIndicatorView.stopAnimating()
        }
        
    }

    func startAnimating() {
        if neverDisplay { return }
        if !isAnimating {
            isAnimating = true
            activityIndicatorView.startAnimating()
        }
        
    }
}
