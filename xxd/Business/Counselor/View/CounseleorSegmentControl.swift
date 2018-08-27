//
//  CounseleorSegmentControl.swift
//  xxd
//
//  Created by chenyusen on 2018/3/2.
//  Copyright © 2018年 com.smartstudy. All rights reserved.
//

import UIKit

private let itemHeight: CGFloat = 30
private let singleItemWidth: CGFloat = 90

protocol CounseleorSegmentControlDelegate: class {
    func segmentControl(_ segmentControl: CounseleorSegmentControl, didPressed index: Int, title: String)
}

class CounseleorSegmentControl: UIView {
    var titles: [String] = []
    private var blockView: UIView!
    private var selectedButton: UIButton!
    private var buttons: [UIButton] = []
    public weak var delegate: CounseleorSegmentControlDelegate?
    
    public var selectedIndex: Int = 0 {
        didSet {
            guard oldValue != selectedIndex else { return }
            let button = buttons.first { $0.tag == selectedIndex }!
            button.sendActions(for: .touchUpInside)
        }
    }

    convenience init(titles: [String]) {
        self.init(frame: .zero)
        self.titles = titles
        
        layer.cornerRadius = itemHeight / 2
        layer.masksToBounds = true
        self.backgroundColor = UIColor(0xE4E5E6)
        
        blockView = UIView(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: singleItemWidth, height: itemHeight)),
                           color: UIColor(0x078cf1))
        blockView.layer.cornerRadius = itemHeight / 2
        blockView.layer.masksToBounds = true
        addSubview(blockView)
        
        
        for (index, title) in titles.enumerated() {
            let button = UIButton(frame: CGRect(x: (CGFloat(index) * singleItemWidth), y: 0, width: singleItemWidth, height: itemHeight))
            button.setTitle(title, for: .normal)
            button.tag = index
            button.titleLabel?.font = UIFont.systemFont(ofSize: 13)
            button.setTitleColor(UIColor(0x58646E), for: .normal)
            button.setTitleColor(.white, for: .selected)
            button.setTitleColor(.white, for: [.selected, .highlighted])
            button.addTarget(self, action: #selector(buttonPressed(_:)), for: .touchUpInside)
            buttons.append(button)
            addSubview(button)
            if index == 0 {
                button.isSelected = true
                selectedButton = button
            }
            
            if index == titles.count - 1 {
                self.size = CGSize(width: singleItemWidth * CGFloat(titles.count), height: itemHeight)
            }
        }
    }
    
    @objc func buttonPressed(_ sender: UIButton) {
        guard sender != selectedButton else { return }
        selectedButton.isSelected = false
        sender.isSelected = true
        selectedButton = sender
        UIView.animate(withDuration: 0.25) {
            self.blockView.left = CGFloat(sender.tag) * singleItemWidth
        }
        delegate?.segmentControl(self, didPressed: sender.tag, title: sender.currentTitle!)
    }
}
