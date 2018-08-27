//
//  APISelectorViewController.swift
//  xxd
//
//  Created by remy on 2017/12/21.
//  Copyright © 2017年 com.smartstudy. All rights reserved.
//

class APISelectorViewController: SSTableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "环境选择"
        
        tableView.separatorStyle = .singleLine
        tableView.tableFooterView = UIView()
        tableView.rowHeight = 80
        
        var items:[Any] = []
        for dict in XDEnvConfig.envHosts {
            items.append(tableViewActions.attach(to: EnvItem(attributes: dict), tap: {
                [unowned self] (object, target, indexPath) -> Bool in
                if let object = object as? EnvItem {
                    if object.isCurrentEnv {
                        self.showMMPHUD()
                    } else if object.envType == .custom {
                        self.showCustomAlert(item: object)
                    } else {
                        Preference.CURRENT_ENVIRONMENT_TYPE.set(object.envType.rawValue)
                        Preference.synchronize()
                        self.logout()
                    }
                }
                return true
            }))
        }
        tableViewModel.addObjects(from: items)
    }
    
    func showCustomAlert(item: EnvItem) {
        let alert = UIAlertController(title: "自定义环境", message: nil, preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.placeholder = "输入APIHost"
            textField.text = item.apiHost
        }
        alert.addTextField { (textField) in
            textField.placeholder = "输入WebHost"
            textField.text = item.webHost
        }
        let cancel = UIAlertAction(title: "取消", style: .cancel) {
            [unowned alert] (action) in
            alert.dismiss(animated: true, completion: nil)
        }
        alert.addAction(cancel)
        let confirm = UIAlertAction(title: "确认", style: .default) {
            [unowned alert] (action) in
            action.isEnabled = true
            guard let t1 = alert.textFields?.first?.text, let t2 = alert.textFields?.last?.text, !t1.isEmpty, !t2.isEmpty else {
                action.isEnabled = false
                return
            }
            self.logout()
            let dict = [
                XDEnvTypeKey: EnvType.custom.rawValue,
                XDEnvAPIHostKey: t1,
                XDEnvWebHostKey: t2
            ]
            Preference.CUSTOM_ENVIRONMENT.set(dict)
            Preference.CURRENT_ENVIRONMENT_TYPE.set(EnvType.custom.rawValue)
            Preference.synchronize()
        }
        alert.addAction(confirm)
        self.present(alert, animated: true, completion: nil)
    }
    
    func logout() {
        SSNetworkManager.shared().get(XD_API_USER_LOGOUT, parameters: nil, success: { (task, responseObject) in
            XDUser.shared.logout()
        }) { (task, error) in
        }
        showRebootHUD()
    }
    
    func showRebootHUD() {
        let hud = MBProgressHUD.showAdded(to: UIApplication.shared.keyWindow!, animated: true)
        hud.mode = .indeterminate
        let msg: NSString = "🙂请双击Home键,关闭应用后重新打开"
        let attrMsg = NSMutableAttributedString(string: msg as String)
        let range = msg.range(of: "关闭应用")
        attrMsg.setAttributes([
            .font: UIFont.systemFont(ofSize: 20),
            .foregroundColor: UIColor.red
            ], range: range)
        hud.label.attributedText = attrMsg
    }
    
    func showMMPHUD() {
        let hud = MBProgressHUD.showAdded(to: UIApplication.shared.keyWindow!, animated: true)
        hud.mode = .text
        let msg: NSString = "🙄MMP,你已经在当前环境!"
        let attrMsg = NSMutableAttributedString(string: msg as String)
        let range = msg.range(of: "MMP")
        attrMsg.setAttributes([
            .font: UIFont.systemFont(ofSize: 20),
            .foregroundColor: UIColor.red
            ], range: range)
        hud.label.attributedText = attrMsg
        hud.hide(animated: true, afterDelay: 3)
    }
}
