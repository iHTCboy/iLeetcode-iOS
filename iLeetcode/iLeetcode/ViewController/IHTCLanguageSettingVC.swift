//
//  IHTCLanguageSettingViewController.swift
//  iLeetcode
//
//  Created by HTC on 2019/4/22.
//  Copyright © 2019 HTC. All rights reserved.
//

import UIKit

class IHTCLanguageSettingVC: UITableViewController {

    let language = ["简体中文", "English"]
    
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
        switch IHTCUserDefaults.shared.getUDLanguage() {
        case "zh_CN":
            isShowZH = "确定"
            break
        case "en_US":
            isShowZH = "OK"
            break
        default: break
        }
        
        // UIBarButtonItem
        let resetItem = UIBarButtonItem(title: isShowZH, style: .plain, target: self, action: #selector(resetLanguage))
        navigationItem.rightBarButtonItems = [resetItem]
        
    }
    
    @objc func resetLanguage(item: UIBarButtonItem) {
        print(item)
        if item.title == "OK" {
            IHTCLocalizedManger.shared.setUserLanguage(language: "en")
        } else {
            IHTCLocalizedManger.shared.setUserLanguage(language: "zh-Hans")
        }
        
        ILeetCoderModel.shared.resetData()
        let vc = UIStoryboard.init(name: "Main", bundle: nil);
        let tabbarVC = vc.instantiateInitialViewController()!
        view.window?.rootViewController = tabbarVC
        
        resetTabBarControllerTitle(tabbarVC)
    }
    
    func resetTabBarControllerTitle(_ vc: UIViewController) {
        if let tabbarVC = vc as? UITabBarController {
            guard let items = tabbarVC.tabBar.items else { return }
            items[0].title = HTCLocalized("iCoder")
            items[1].title = HTCLocalized("Tags")
            items[2].title = HTCLocalized("Companies")
            items[3].title = HTCLocalized("Me")
        }
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
        }
        
        cell?.accessoryType = .none
        switch IHTCUserDefaults.shared.getUDLanguage() {
        case "zh_CN":
            if indexPath.row == 0 {
                cell?.accessoryType = .checkmark
            }
            break
        case "en_US":
            if indexPath.row == 1 {
                cell?.accessoryType = .checkmark
            }
            break
        default: break
            
        }
        
        cell?.textLabel?.text = language[indexPath.row]
        // Configure the cell...
        
        return cell!
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        switch indexPath.row {
        case 0:
            IHTCUserDefaults.shared.setUDlanguage(value: "zh_CN")
            break
        case 1:
            IHTCUserDefaults.shared.setUDlanguage(value: "en_US")
            break
        default:break
            
        }
        updateItem()
        tableView.reloadData()
    }
}
