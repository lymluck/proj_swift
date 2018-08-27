//
//  PopViewController.swift
//  counselor_t
//
//  Created by chenyusen on 2018/2/23.
//  Copyright © 2018年 TechSen. All rights reserved.
//

import UIKit

class PopViewController: BaseViewController {
    
    convenience init(contentView: UIView) {
        self.init(query: nil)
        self.contentView = contentView
    }
    
    func show() {
        UIApplication.topVC()?.presentModalTranslucentViewController(self, animated: false, completion: nil)
    }
    
    func dismiss() {
        coverPressed()
    }
    
    var contentView: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()

        
        navigationBar?.isHidden = true
        view.backgroundColor = .clear
        
        
        let cover = UIButton(frame: view.bounds)
        cover.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        cover.alpha = 0
        cover.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(cover)
        cover.addTarget(self, action: #selector(coverPressed), for: .touchUpInside)
        
        if let contentView = contentView {
            view.addSubview(contentView)
            contentView.alpha = 0
            contentView.snp.makeConstraints { (make) in
                make.center.equalToSuperview()
            }
        }
        
        UIView.animate(withDuration: 0.05,
                       delay: 0,
                       options: .curveEaseIn,
                       animations: {
                        cover.alpha = 1
                        self.contentView.alpha = 1
                        self.contentView.transform = CGAffineTransform.identity})
    }
    
    override func hiddenNavigationBarIfNeeded() -> Bool {
        return true
    }
    
    
    @objc func coverPressed() {
        self.dismiss(animated: false, completion: nil)
    }
}
