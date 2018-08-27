//
//  MajorLibraryViewController.swift
//  xxd
//
//  Created by Lisen on 2018/7/2.
//  Copyright © 2018年 com.smartstudy. All rights reserved.
//

import UIKit


private let kRankCategoryMeanSpace: CGFloat = (XDSize.screenWidth-192.0)/8.0
private let kRankCategoryWidth: CGFloat = kRankCategoryMeanSpace*2.0+48.0
private let kCellWidth: CGFloat = (XDSize.screenWidth-50.0)/3.0
private let kHeaderReuseIdentifier: String = "MajorListHeaderView"
private let kFooterReuseIdentifier: String = "MajorListFooterView"
private let kMajorCellReuseIdentifier: String = "MajorListCell"

/// 新版专业库
class MajorLibraryViewController: SSViewController {
    
    private var rankCategoryTitles = [(" 全球专业排名 ", "global"), (" 美国专业排名 ", "USA"), ("美国研究生专业排名", "USA"), (" 艺术专业排名 ", "art")]
    private lazy var majorDatas: [HottestMajorModel] = []
    private lazy var tableHeaderView: UIView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: XDSize.screenWidth, height: 0.0), color: UIColor.white)
    private lazy var majorCollectionView: UICollectionView = {
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: kCellWidth, height: 34.0)
        layout.headerReferenceSize = CGSize(width: XDSize.screenWidth, height: 64.0)
        layout.footerReferenceSize = CGSize(width: XDSize.screenWidth-32.0, height: 20.0)
        layout.minimumInteritemSpacing = 9.0
        layout.minimumLineSpacing = 16.0
        let collectionView: UICollectionView = UICollectionView(frame: CGRect(x: 16.0, y: XDSize.topHeight, width: XDSize.screenWidth-32.0, height: XDSize.screenHeight-XDSize.topHeight), collectionViewLayout: layout)
        collectionView.backgroundColor = UIColor.white
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.showsVerticalScrollIndicator = false
        collectionView.register(MajorListHeaderView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: kHeaderReuseIdentifier)
        collectionView.register(MajorListFooterView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionFooter, withReuseIdentifier: kFooterReuseIdentifier)
        collectionView.register(MajorListCell.self, forCellWithReuseIdentifier: kMajorCellReuseIdentifier)
        return collectionView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "找专业"
        initHeaderView()
        requestMajorInfos()
    }
    
    // MARK: private methods
    private func initHeaderView() {
        initRankCategoryView()
        initSmartMajorView()
    }
    
    private func initRankCategoryView() {
        for (index, value) in rankCategoryTitles.enumerated() {
            var topSpace: CGFloat = 10.0
            var imageHeight: CGFloat = 48.0
            if index == rankCategoryTitles.count-1 {
                topSpace = 5.0
                imageHeight = 53.0
            }
            let sectionBackgroundView: UIView = UIView(frame: CGRect(x: CGFloat(index)*kRankCategoryWidth-16.0, y: 16.0, width: kRankCategoryWidth, height: 118.0), color: UIColor.white)
            let rankLogoView: UIImageView = UIImageView(frame: CGRect(x: kRankCategoryMeanSpace, y: topSpace, width: 48.0, height: imageHeight), imageName: value.1)
            let rankTitleLabel: UILabel = UILabel(frame: CGRect(x: rankLogoView.left-8.0, y: rankLogoView.bottom+10.0, width: 64.0, height: 30.0), text: value.0, textColor: UIColor(0x58646E), fontSize: 12.0)
            rankTitleLabel.textAlignment = .center
            rankTitleLabel.numberOfLines = 2
            let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(eventBackgroundViewTapResponse(_:)))
            sectionBackgroundView.addGestureRecognizer(tapGesture)
            sectionBackgroundView.tag = index
            sectionBackgroundView.addSubview(rankLogoView)
            sectionBackgroundView.addSubview(rankTitleLabel)
            tableHeaderView.addSubview(sectionBackgroundView)
        }
        let topSeparatorView: UIView = UIView(frame: CGRect(x: 0.0, y: 130.0, width: XDSize.screenWidth-32.0, height: 0.5), color: XDColor.itemLine)
        tableHeaderView.addSubview(topSeparatorView)
    }
    
    private func initSmartMajorView() {
        let smartBgView: UIView = UIView(frame: CGRect(x: 0.0, y: 150.0, width: XDSize.screenWidth-32.0, height: 68.0), color: .clear)
        smartBgView.layer.cornerRadius = 6.0
        smartBgView.layer.masksToBounds = true
        let smartMajorView: UIImageView = UIImageView(frame: CGRect(x: 0.0, y: 0.0, width: 382.0, height: 76), imageName: "smartMajor_bg")
        let smartLabel: UILabel = UILabel(frame: CGRect(x: 12.0, y: 15.0, width: 100.0, height: 24.0), text: "智能选专业", textColor: UIColor(0x0FFAFF), fontSize: 17.0, bold: true)
        let smartIntroLabel: UILabel = UILabel(frame: CGRect(x: 12.0, y: smartLabel.bottom, width: 200.0, height: 18.0), text: "霍兰德性格测试&大数据为你测算", textColor: UIColor(white: 1.0, alpha: 0.6), fontSize: 13.0)
        let smartMoreImage: UIImageView = UIImageView(frame: CGRect.zero, imageName: "college_more_icon")
        let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(eventBackgroundViewTapResponse(_:)))
        smartMajorView.isUserInteractionEnabled = true
        smartMajorView.tag = 4
        smartMajorView.addGestureRecognizer(tapGesture)
        smartBgView.addSubview(smartMajorView)
        smartBgView.addSubview(smartLabel)
        smartBgView.addSubview(smartIntroLabel)
        smartBgView.addSubview(smartMoreImage)
        smartMoreImage.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.right.equalTo(-16.0)
            make.width.equalTo(9.0)
            make.height.equalTo(16.0)
        }
        tableHeaderView.addSubview(smartBgView)
        tableHeaderView.height = smartBgView.bottom+16.0
        tableHeaderView.top = -smartBgView.bottom-16.0
        majorCollectionView.contentInset = UIEdgeInsets(top: smartBgView.bottom+16.0, left: 0.0, bottom: 0.0, right: 0.0)
        majorCollectionView.addSubview(tableHeaderView)
        view.backgroundColor = UIColor.white
        view.addSubview(majorCollectionView)
    }
    
    @objc private func eventBackgroundViewTapResponse(_ gesture: UITapGestureRecognizer) {
        if let tapView = gesture.view {
            if tapView.tag >= 0 && tapView.tag <= 3 {
                let rankVC: MajorCountryRankViewController = MajorCountryRankViewController()
                if tapView.tag == 3 {
                    rankVC.name = "艺术专业"
                } else {
                    rankVC.name = rankCategoryTitles[tapView.tag].0
                }
                rankVC.rankType = MajorTotalRankType(rawValue: tapView.tag)!
                navigationController?.pushViewController(rankVC, animated: true)
            } else if tapView.tag == 4 {
                let smartMajorVC: SmartMajorViewController = SmartMajorViewController()
                navigationController?.pushViewController(smartMajorVC, animated: true)
            }
        }
    }
    
    override func routerEvent(name: String, data: Dictionary<String, Any>) {
        if name == "MajorHeaderViewTap" {
            let majorVC: MajorViewController = MajorViewController()
            majorVC.selectedCategoryId = data["categoryId"] as? String
            navigationController?.pushViewController(majorVC, animated: true)
        }
    }
    
    private func requestMajorInfos() {
        SSNetworkManager.shared().get(XD_API_HOT_MAJOR_BYC, parameters: nil, success: { (dataTask, responseObject) in
            if let responseData = responseObject as? [String: Any], let serverData = responseData["data"] as? [[String: Any]] {
                for dic in serverData {
                    let major: HottestMajorModel = HottestMajorModel.yy_model(with: dic)!
                    self.majorDatas.append(major)
                }
                self.majorCollectionView.reloadData()
            }
        }) { (dataTask, error) in
            XDPopView.toast(error.localizedDescription)
        }
    }
}

// MARK: UICollectionViewDataSource
extension MajorLibraryViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return majorDatas.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return majorDatas[section].majors.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: MajorListCell = collectionView.dequeueReusableCell(withReuseIdentifier: kMajorCellReuseIdentifier, for: indexPath) as! MajorListCell
        if let majorModel = majorDatas[indexPath.section].subMajors.item(at: indexPath.row) {
            cell.majorName = majorModel.categoryName
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionElementKindSectionHeader {
            let header: MajorListHeaderView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: kHeaderReuseIdentifier, for: indexPath) as! MajorListHeaderView
            header.categoryName = majorDatas[indexPath.section].categoryName
            header.categoryId = majorDatas[indexPath.section].categoryId
            return header
        } else {
            let footerView: MajorListFooterView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionFooter, withReuseIdentifier: kFooterReuseIdentifier, for: indexPath) as! MajorListFooterView
            if indexPath.section == majorDatas.count-1 {
                footerView.separatorView.isHidden = true
            } else {
                footerView.separatorView.isHidden = false
            }
            return footerView
        }
    }
}

// MARK: UICollectionViewDelegate
extension MajorLibraryViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let majorModel = majorDatas[indexPath.section].subMajors.item(at: indexPath.row) {
            XDRoute.pushWebVC([QueryKey.URLPath: majorModel.majorURLPath, QueryKey.TitleName: majorModel.categoryName])
        }
    }
}
