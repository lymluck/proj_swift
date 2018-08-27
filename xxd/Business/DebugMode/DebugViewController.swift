//
//  DebugViewController.swift
//  xxd
//
//  Created by remy on 2017/12/21.
//  Copyright © 2017年 com.smartstudy. All rights reserved.
//

import LHPerformanceStatusBar

class DebugViewController: SSTableViewController {
    
    private var kDebugNeedFPSDisplay = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Debug Mode"
        
        tableView.separatorStyle = .singleLine
        tableView.tableFooterView = UIView()
        tableView.rowHeight = 60
        
        var items:[Any] = []
        items.append(tableViewActions.attach(to: NISubtitleCellObject(title: "修改服务器", subtitle: "当前服务器环境:\(XDEnvConfig.envName)"), tap: {
            [unowned self] (object, target, indexPath) -> Bool in
            self.navigationController?.pushViewController(APISelectorViewController(), animated: true)
            return true
        }))
        items.append(tableViewActions.attach(to: NISubtitleCellObject(title: "用户及设备信息"), tap: {
            [unowned self] (object, target, indexPath) -> Bool in
            self.showDeviceInfo()
            return true
        }))
        items.append(tableViewActions.attach(to: NISwitchFormElement.switch(withID: 0, labelText: "打开设备资源监控", value: kDebugNeedFPSDisplay, didChangeTarget: self, didChange: #selector(didChangeFPSSuperVision(_:))) as! NISwitchFormElement, tap: { (object, target, indexPath) -> Bool in
            return true
        }))
        items.append(tableViewActions.attach(to: NISwitchFormElement.switch(withID: 0, labelText: "开启无限评价课程", value: UserDefaults.standard.bool(forKey: "kUnlimitedEvaluateCourseKey"), didChangeTarget: self, didChange: #selector(didChangeUnlimitedEvaluateCourse(_:))) as! NISwitchFormElement, tap: { (object, target, indexPath) -> Bool in
            return true
        }))
        items.append(tableViewActions.attach(to: NISwitchFormElement.switch(withID: 0, labelText: "开始看完视频后弹窗评价", value: UserDefaults.standard.bool(forKey: "kEvaluateAfterWatchingKey"), didChangeTarget: self, didChange: #selector(didChangekEvaluateAfterWatching(_:))) as! NISwitchFormElement, tap: { (object, target, indexPath) -> Bool in
            return true
        }))
        items.append(tableViewActions.attach(to: NISwitchFormElement.switch(withID: 0, labelText: "开启无限完善信息", value: UserDefaults.standard.bool(forKey: "kUnlimitedCompletionKey"), didChangeTarget: self, didChange: #selector(didChangeUnlimitedCompletion(_:))) as! NISwitchFormElement, tap: { (object, target, indexPath) -> Bool in
            return true
        }))
        items.append(tableViewActions.attach(to: NISwitchFormElement.switch(withID: 0, labelText: "开启无限引导页", value: UserDefaults.standard.bool(forKey: "kUnlimitedGuideKey"), didChangeTarget: self, didChange: #selector(didChangeUnlimitedGuide(_:))) as! NISwitchFormElement, tap: { (object, target, indexPath) -> Bool in
            return true
        }))
        items.append(tableViewActions.attach(to: NISwitchFormElement.switch(withID: 0, labelText: "开启无限未登录状态", value: UserDefaults.standard.bool(forKey: "kUnlimitedUnSignIn"), didChangeTarget: self, didChange: #selector(didChangeUnlimitedUnSignIn(_:))) as! NISwitchFormElement, tap: { (object, target, indexPath) -> Bool in
            return true
        }))
        items.append(tableViewActions.attach(to: NISwitchFormElement.switch(withID: 0, labelText: "开启无限留学规划", value: UserDefaults.standard.bool(forKey: "kUnlimitedStudyPlan"), didChangeTarget: self, didChange: #selector(didChangeUnlimitedStudyPlan(_:))) as! NISwitchFormElement, tap: { (object, target, indexPath) -> Bool in
            return true
        }))
        items.append(tableViewActions.attach(to: NISwitchFormElement.switch(withID: 0, labelText: "开启无限开机广告页(有图才显示)", value: UserDefaults.standard.bool(forKey: "kUnlimitedAD"), didChangeTarget: self, didChange: #selector(didChangeUnlimitedAD(_:))) as! NISwitchFormElement, tap: { (object, target, indexPath) -> Bool in
            return true
        }))
        items.append(tableViewActions.attach(to: NISwitchFormElement.switch(withID: 0, labelText: "开启无限引导评分", value: UserDefaults.standard.bool(forKey: "kUnlimitedGrade"), didChangeTarget: self, didChange: #selector(didChangeUnlimitedGrade(_:))) as! NISwitchFormElement, tap: { (object, target, indexPath) -> Bool in
            return true
        }))
        tableViewModel.addObjects(from: items)
    }
    
    func showDeviceInfo() {
        let model = XDUser.shared.model
        let info = "\nID:\(model.ID)\n\nJPUSHID:\(XDEnvConfig.jpushRegistrationID)\n\nUDID:\(UIDevice.UDID)\n\nTOKEN:\(model.token)\n\nTICKET:\(model.ticket)\n\nSSOPENID:\(SSOpenID.id() ?? "")\n\nssUser:\(model.ssUser)"
        let alert = UIAlertController(title: "用户及设备信息", message: info, preferredStyle: .alert)
        let cancel = UIAlertAction(title: "取消", style: .cancel) {
            [unowned alert] (action) in
            alert.dismiss(animated: true, completion: nil)
        }
        alert.addAction(cancel)
        self.present(alert, animated: true, completion: nil)
    }
    
    @objc private func didChangeFPSSuperVision(_ sender: UISwitch) {
        kDebugNeedFPSDisplay = sender.isOn
        if sender.isOn {
            LHPerformanceMonitorService.run()
        } else {
            LHPerformanceMonitorService.stop()
        }
    }
    
    @objc private func didChangeUnlimitedEvaluateCourse(_ sender: UISwitch) {
        UserDefaults.standard.set(sender.isOn, forKey: "kUnlimitedEvaluateCourseKey")
        UserDefaults.standard.synchronize()
    }
    
    @objc private func didChangeUnlimitedCompletion(_ sender: UISwitch) {
        UserDefaults.standard.set(sender.isOn, forKey: "kUnlimitedCompletionKey")
        UserDefaults.standard.synchronize()
    }
    
    @objc private func didChangeUnlimitedGuide(_ sender: UISwitch) {
        UserDefaults.standard.set(sender.isOn, forKey: "kUnlimitedGuideKey")
        UserDefaults.standard.synchronize()
    }
    
    @objc private func didChangeUnlimitedUnSignIn(_ sender: UISwitch) {
        UserDefaults.standard.set(sender.isOn, forKey: "kUnlimitedUnSignIn")
        UserDefaults.standard.synchronize()
    }
    
    @objc private func didChangeUnlimitedStudyPlan(_ sender: UISwitch) {
        UserDefaults.standard.set(sender.isOn, forKey: "kUnlimitedStudyPlan")
        UserDefaults.standard.synchronize()
    }
    
    @objc private func didChangeUnlimitedAD(_ sender: UISwitch) {
        UserDefaults.standard.set(sender.isOn, forKey: "kUnlimitedAD")
        UserDefaults.standard.synchronize()
    }
    
    @objc private func didChangeUnlimitedGrade(_ sender: UISwitch) {
        UserDefaults.standard.set(sender.isOn, forKey: "kUnlimitedGrade")
        UserDefaults.standard.synchronize()
    }
    
    @objc private func didChangekEvaluateAfterWatching(_ sender: UISwitch) {
        UserDefaults.standard.set(sender.isOn, forKey: "kEvaluateAfterWatchingKey")
        UserDefaults.standard.synchronize()
    }
}
