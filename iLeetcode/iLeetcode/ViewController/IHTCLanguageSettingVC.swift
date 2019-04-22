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
        
        title = "Language"
        if #available(iOS 11.0, *) {
            self.navigationItem.largeTitleDisplayMode = .never
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
        
        tableView.reloadData()
    }
}
