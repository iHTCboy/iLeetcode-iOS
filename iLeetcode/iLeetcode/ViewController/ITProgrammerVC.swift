//
//  ITProgrammerVC.swift
//  iTalker
//
//  Created by HTC on 2017/4/22.
//  Copyright © 2017年 ihtc.cc @iHTCboy. All rights reserved.
//

import UIKit
import StoreKit
import SafariServices

class ITProgrammerVC: UIViewController {

    // MARK:- Lify Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    var isNewVersion = false
    
    // MARK:- 懒加载
    lazy var tableView: UITableView = {
        var tableView = UITableView.init(frame: CGRect.zero, style: .grouped)
        tableView.contentInset = UIEdgeInsets.init(top: 0, left: 0, bottom: 20, right: 0)
        tableView.sectionFooterHeight = 0.1;
        tableView.estimatedRowHeight = 55
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        tableView.dataSource = self
        return tableView
    }()
    
    fileprivate var titles = ["0": "\(HTCLocalized("Display Language")):设置题目显示的默认语言,\(HTCLocalized("Display Appearance")):暗黑or浅色",
        
        "1": "\(HTCLocalized("In App Rating")):\(HTCLocalized("Welcome to iCoder app review!")),\(HTCLocalized("AppStore Evaluation")):\(HTCLocalized("Welcome to write a review"))!,\(HTCLocalized("Send to a friend")):\(HTCLocalized("Study together with friends around!"))",
        
        "2":"\(HTCLocalized("Feedback")):\(HTCLocalized("Welcome to AppStore for requests or bugs")),\(HTCLocalized("E-mail Contact")):\(HTCLocalized("If you have questions please email")),\(HTCLocalized("Privacy Policy")):\(HTCLocalized("User Services Agreement")),\(HTCLocalized("Open Source")):\(HTCLocalized("It is now open source code")),\(HTCLocalized("Attention More")):\(HTCLocalized("Welcome to the author's blog")),\(HTCLocalized("Learn More")):\(HTCLocalized("More Developer Content recommendation")),\(HTCLocalized("About Application")):\(kiTalker)"] as [String : String]

}


extension ITProgrammerVC
{
    func setupUI() {
        view.addSubview(tableView)
        let constraintViews = [
            "tableView": tableView
        ]
        let vFormat = "V:|-0-[tableView]-0-|"
        let hFormat = "H:|-0-[tableView]-0-|"
        let vConstraints = NSLayoutConstraint.constraints(withVisualFormat: vFormat, options: [], metrics: [:], views: constraintViews)
        let hConstraints = NSLayoutConstraint.constraints(withVisualFormat: hFormat, options: [], metrics: [:], views: constraintViews)
        view.addConstraints(vConstraints)
        view.addConstraints(hConstraints)
        view.layoutIfNeeded()
    }
    
    override var prefersStatusBarHidden: Bool {
        return false
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

}

// MARK: Tableview Delegate
extension ITProgrammerVC : UITableViewDelegate, UITableViewDataSource
{
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 25
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.titles.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let string = self.titles["\(section)"]
        let titleArray = string?.components(separatedBy: ",")
        return (titleArray?.count)!
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell = tableView.dequeueReusableCell(withIdentifier: "ITProgrammerVCViewCell")
        if (cell  == nil) {
            cell = UITableViewCell.init(style: .value1, reuseIdentifier: "ITProgrammerVCViewCell")
            cell!.accessoryType = .disclosureIndicator
            cell!.selectedBackgroundView = UIView.init(frame: cell!.frame)
            cell!.selectedBackgroundView?.backgroundColor = kColorAppOrange.withAlphaComponent(0.7)
            cell?.textLabel?.font = UIFont.systemFont(ofSize: DeviceType.IS_IPAD ? 20:16.5)
            cell?.detailTextLabel?.font = UIFont.systemFont(ofSize: DeviceType.IS_IPAD ? 16:12.5)
            cell?.detailTextLabel?.sizeToFit()
        }
        
        let string = self.titles["\(indexPath.section)"]
        let titleArray = string?.components(separatedBy: ",")
        let titles = titleArray?[indexPath.row]
        let titleA = titles?.components(separatedBy: ":")
        cell!.textLabel?.text = titleA?[0]
        if indexPath.section == 0 && indexPath.row == 0 {
            var currentLanguage = ""
            switch IHTCLocalizedManger.shared.currentLanguage() {
            case "zh-Hans":
                currentLanguage = "简体中文"
                break
            case "zh-Hant":
                currentLanguage = "繁体中文"
                break
            default:
                currentLanguage = "English"
                break
            }
            cell?.detailTextLabel?.text = currentLanguage
        }
        else if indexPath.section == 0 && indexPath.row == 1 {
            cell?.detailTextLabel?.text = HTCLocalized(IHTCUserDefaults.shared.getAppAppearance().rawValue)
        }
        else {
            cell?.detailTextLabel?.text = titleA?[1]
        }
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let section = indexPath.section;
        let row = indexPath.row;
        
        switch section {
        case 0:
            if row == 0 {
                let vc = IHTCLanguageSettingVC()
                vc.hidesBottomBarWhenPushed = true
                navigationController?.pushViewController(vc, animated: true)
            }
            if row == 1 {
                let vc = IHTCAppearanceVC()
                vc.hidesBottomBarWhenPushed = true
                navigationController?.pushViewController(vc, animated: true)
            }
            break
        case 1:
            if row == 0 {
                if #available(iOS 10.3, *) {
                    SKStoreReviewController.requestReview()
                } else {
                    IAppleServiceUtil.openAppstore(url: kAppDownloadURl, isAssessment: true)
                }
            }
            if row == 1 {
                IAppleServiceUtil.openAppstore(url: kAppDownloadURl, isAssessment: false)
            }
            if row == 2 {
                IAppleServiceUtil.shareWithImage(image: UIImage(named: "App-share-Icon")!, text: kAppShare, url: kAppDownloadURl, vc: self)
            }
            
            break
        case 2:
            if row == 0 {
                IAppleServiceUtil.openAppstore(url: kAppDownloadURl, isAssessment: true)
            }
            if row == 1 {
                let message = HTCLocalized("Welcome to the mail. Write down your questions.") + "\n\n\n\n" + kMarginLine + "\n \(HTCLocalized("The current "))\(kiTalker)\(HTCLocalized(" version"))：" + KAppVersion + "， \(HTCLocalized("System version"))：" + String(Version.SYS_VERSION_FLOAT) + "， \(HTCLocalized("Device Information"))：" + UIDevice.init().modelName
                
                ITCommonAPI.shared.sendEmail(recipients: [kEmail], messae: message, vc: self)
            }
            if row == 2 {
                IAppleServiceUtil.openWebView(url: kLicenseURL, tintColor: kColorAppOrange, vc: self)
            }
            if row == 3 {
                IAppleServiceUtil.openWebView(url: kGithubURL, tintColor: kColorAppOrange, vc: self)
            }
            if row == 4 {
                IAppleServiceUtil.openWebView(url: kiHTCboyURL, tintColor: kColorAppOrange, vc: self)
            }
            if row == 5 {
                let vc = ITAdvancelDetailViewController()
                vc.title = HTCLocalized("Learn More")
                vc.advancelType = .iHTCboyApp
                vc.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(vc, animated: true)
            }
            if row == 6 {
                let vc = ITAboutAppVC()
                vc.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(vc, animated: true)
            }
            break
            
        default: break
            
        }
    }
}

