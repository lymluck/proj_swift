//
//  MasterHottestMajorListViewController.swift
//  xxd
//
//  Created by Lisen on 2018/7/11.
//  Copyright © 2018年 com.smartstudy. All rights reserved.
//

import UIKit

/// 研究生热门专业列表
class MasterHottestMajorListViewController: SSViewController {
    var majorModels: [MasterHottestMajorModel] = [] {
        didSet {
            majorCollectionView.reloadData()
        }
    }
    private let kCellWidth: CGFloat = (XDSize.screenWidth-50.0)/3.0
    private let kHeaderReuseIdentifier: String = "MajorListHeaderView"
    private let kFooterReuseIdentifier: String = "MajorListFooterView"
    private let kMajorCellReuseIdentifier: String = "MajorListCell"
    
    private lazy var majorCollectionView: UICollectionView = {
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: kCellWidth, height: 34.0)
        layout.headerReferenceSize = CGSize(width: XDSize.screenWidth, height: 64.0)
        layout.footerReferenceSize = CGSize(width: XDSize.screenWidth-32.0, height: 20.0)
        layout.minimumInteritemSpacing = 9.0
        layout.minimumLineSpacing = 16.0
        let collectionView: UICollectionView = UICollectionView(frame: CGRect(x: 16.0, y: 0.0, width: XDSize.screenWidth-32.0, height: XDSize.screenHeight-XDSize.topHeight-40.0), collectionViewLayout: layout)
        collectionView.backgroundColor = UIColor.white
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.showsVerticalScrollIndicator = false
        collectionView.register(MajorListHeaderView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: kHeaderReuseIdentifier)
        collectionView.register(MajorListFooterView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionFooter, withReuseIdentifier: kFooterReuseIdentifier)
        collectionView.register(MajorListCell.self, forCellWithReuseIdentifier: kMajorCellReuseIdentifier)
        return collectionView
    }()
    
    override func needNavigationBar() -> Bool {
        return false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initContentViews()
    }
    
    private func initContentViews() {
        view.backgroundColor = UIColor.white
        view.addSubview(majorCollectionView)
    }
    
}

// MARK: UICollectionViewDataSource
extension MasterHottestMajorListViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return majorModels.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return majorModels[section].subMajors.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: MajorListCell = collectionView.dequeueReusableCell(withReuseIdentifier: kMajorCellReuseIdentifier, for: indexPath) as! MajorListCell
        cell.majorName = majorModels[indexPath.section].subMajors[indexPath.row].chineseName
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionElementKindSectionHeader {
            let header: MajorListHeaderView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: kHeaderReuseIdentifier, for: indexPath) as! MajorListHeaderView
            header.isMoreBtnHidden = true
            header.categoryName = majorModels[indexPath.section].categoryName
            return header
        } else {
            let footerView: MajorListFooterView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionFooter, withReuseIdentifier: kFooterReuseIdentifier, for: indexPath) as! MajorListFooterView
            if indexPath.section == (majorModels.count-1) {
                footerView.separatorView.isHidden = true
            } else {
                footerView.separatorView.isHidden = false
            }
            return footerView
        }
    }
}

// MARK: UICollectionViewDelegate
extension MasterHottestMajorListViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let majorVC: MasterMajorDetailViewController = MasterMajorDetailViewController()
        majorVC.majorName = majorModels[indexPath.section].subMajors[indexPath.row].chineseName
        majorVC.majorId = majorModels[indexPath.section].subMajors[indexPath.row].majorId
        navigationController?.pushViewController(majorVC, animated: true)
    }
}
