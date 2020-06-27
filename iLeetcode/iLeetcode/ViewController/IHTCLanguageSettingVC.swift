//
//  IHTCLanguageSettingViewController.swift
//  iLeetcode
//
//  Created by HTC on 2019/4/22.
//  Copyright © 2019 HTC. All rights reserved.
//

import UIKit

class IHTCLanguageSettingVC: UITableViewController {

    let language = [HTCLocalized("Follow System"), "English", "简体中文", "繁体中文"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }
    
    func setupUI() {
        title = "Language"
        if #available(iOS 11.0, *) {
            self.navigationItem.largeTitleDisplayMode = .never
        }
        
        updateItem()
    }
    
    func updateItem() {
        var isShowZH = ""
        switch IHTCLocalizedManger.shared.currentLanguage() {
        case "zh-Hans":
            isShowZH = "确定"
            break
        case "zh-Hant":
            isShowZH = "確定"
            break
        default:
            isShowZH = "OK"
            break
        }
        
        // UIBarButtonItem
        let resetItem = UIBarButtonItem(title: isShowZH, style: .plain, target: self, action: #selector(resetLanguage))
        navigationItem.rightBarButtonItems = [resetItem]
    }
    
    @objc func resetLanguage(item: UIBarButtonItem) {
        ILeetCoderModel.shared.resetData()
        let vc = UIStoryboard.init(name: "Main", bundle: nil)
        let tabbarVC = vc.instantiateInitialViewController()!
        view.window?.rootViewController = tabbarVC
        
        tabbarVC.resetTabBarControllerTitle(tabbarVC)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return language.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "IELanguageTableViewCell")
        if (cell  == nil) {
            cell = UITableViewCell.init(style: .value1, reuseIdentifier: "IELanguageTableViewCell")
            #if targetEnvironment(macCatalyst)
            cell?.textLabel?.font = UIFont.systemFont(ofSize: 20)
            #endif
        }
        
        cell?.accessoryType = .none
        switch IHTCLocalizedManger.shared.currentLanguage() {
//        case "":
//            if indexPath.row == 0 {
//                cell?.accessoryType = .checkmark
//            }
//            break
        case "en":
            if indexPath.row == 1 {
                cell?.accessoryType = .checkmark
            }
            break
        case "zh-Hans":
            if indexPath.row == 2 {
                cell?.accessoryType = .checkmark
            }
            break
        case "zh-Hant":
            if indexPath.row == 3 {
                cell?.accessoryType = .checkmark
            }
            break
        default:
            break
        }
        
        cell?.textLabel?.text = language[indexPath.row]
        
        return cell!
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        switch indexPath.row {
        case 0:
            IHTCLocalizedManger.shared.flowSystemLanguage()
            if IHTCLocalizedManger.shared.currentLanguage() == "en" {
                IHTCUserDefaults.shared.setUDlanguage(value: "en_US")
            } else {
                IHTCUserDefaults.shared.setUDlanguage(value: "zh_CN")
            }
            break
        case 1:
            IHTCUserDefaults.shared.setUDlanguage(value: "en_US")
            IHTCLocalizedManger.shared.setUserLanguage(language: "en")
            break
        case 2:
            IHTCUserDefaults.shared.setUDlanguage(value: "zh_CN")
            IHTCLocalizedManger.shared.setUserLanguage(language: "zh-Hans")
            break
        case 3:
            IHTCUserDefaults.shared.setUDlanguage(value: "zh_CN")
            IHTCLocalizedManger.shared.setUserLanguage(language: "zh-Hant")
            break
        default:break
            
        }
        updateItem()
        tableView.reloadData()
    }
}
