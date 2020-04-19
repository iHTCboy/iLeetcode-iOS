//
//  ITQuestionDetailViewController.swift
//  iTalker
//
//  Created by HTC on 2017/4/9.
//  Copyright © 2017年 ihtc.cc @iHTCboy. All rights reserved.
//

import UIKit
import WebKit
import SafariServices
//import SwiftyMarkdown


class ITQuestionDetailViewController: ITBasePopTransitionVC {
 
    // MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        // trait发生了改变
        if #available(iOS 13.0, *) {
            if (self.traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection)) {
                // 执行操作
                reloadWebView()
            }
        }
    }
    
    
    var selectedCell: ITQuestionListViewCell!
    var questionModle : ITQuestionModel?
    var questionsArray: Array<ITQuestionModel> = []
    var currentIndex: Int = 0
    var isShowZH : Bool = false
    var languageItem : UIBarButtonItem?
    
    lazy var tableView: UITableView = {
        var tableView = UITableView.init(frame: CGRect.zero, style: .plain)
        if #available(iOS 13.0, *) {
            tableView.backgroundColor = .secondarySystemGroupedBackground
        }
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.separatorStyle = UITableViewCell.SeparatorStyle.none
        tableView.estimatedRowHeight = 80
        tableView.estimatedSectionHeaderHeight = 80
        tableView.delegate = self;
        tableView.dataSource = self;
        tableView.register(UINib.init(nibName: "ITQuestionListViewCell", bundle: Bundle.main), forCellReuseIdentifier: "ITQuestionListViewCell")
        tableView.register(UINib.init(nibName: "ITQuestionDetailViewCell", bundle: Bundle.main), forCellReuseIdentifier: "ITQuestionDetailViewCell")
        return tableView
    }()
    
    lazy var webView: WKWebView = {
        let preferences = WKPreferences()
        preferences.javaScriptEnabled = true
        let configuration = WKWebViewConfiguration()
        configuration.preferences = preferences
        var webView = WKWebView.init(frame: CGRect.zero, configuration: configuration)
        webView.allowsBackForwardNavigationGestures = true;
        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.scrollView.contentInset = UIEdgeInsets.init(top: 0, left: 0, bottom: 0, right: 0)
        webView.isOpaque = false;
        if #available(iOS 13.0, *) {
            webView.backgroundColor = .systemBackground
        } else {
            webView.backgroundColor = .groupTableViewBackground
        }
        return webView
    }()
    
    lazy var infoItem :UIBarButtonItem = {
        let infoBtn = UIButton.init(type: UIButton.ButtonType.detailDisclosure)
        infoBtn.addTarget(self, action: #selector(showAnswer), for: .touchUpInside)
        let item = UIBarButtonItem.init(customView: infoBtn)
        return item
    }()
    
    @available(iOS 9.0, *)
    lazy var previewActions: [UIPreviewActionItem] = {
        let a = UIPreviewAction(title: HTCLocalized("Problem-solving"), style: .default, handler: { (action, vc) in
            self.showAnswer(item: action)
        })
        let b = UIPreviewAction(title: HTCLocalized("Share"), style: .default, handler: { (action, vc) in
            self.sharedPageView(item: action)
        })
        return [a, b]
    }()
    
    @available(iOS 9.0, *)
    override var previewActionItems: [UIPreviewActionItem] {
        return previewActions
    }
}


extension ITQuestionDetailViewController {
    fileprivate func setUpUI() {
        switch IHTCUserDefaults.shared.getUDLanguage() {
            case "zh_CN":
                isShowZH = true
                break
            case "en_US":
                isShowZH = false
                break
            default: break
        }
        
        if #available(iOS 13.0, *) {
            view.backgroundColor = .secondarySystemGroupedBackground
        }
        
        //tableView
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
        
        // webview
        tableView.reloadData()
        var webHeight = selectedCell.frame.size.height + (navigationController?.navigationBar.frame.size.height ?? 0) + (UIApplication.shared.statusBarFrame.size.height ?? 0)
        #if targetEnvironment(macCatalyst)
//        webHeight += UIViewController.keyWindowHTC()?.windowScene?.statusBarManager?.statusBarFrame.size.height ?? 0
        webHeight += 22
        #endif
        let webView = self.webView
        view.addSubview(webView)
        webView.uiDelegate = self
        webView.navigationDelegate = self
        let webViewConstraintViews = [
            "webView": webView
        ]
        let vFormatWeb = "V:|-\(webHeight)-[webView]-0-|"
        let hFormatWeb = "H:|-0-[webView]-0-|"
        let vConstraintsWeb = NSLayoutConstraint.constraints(withVisualFormat: vFormatWeb, options: [], metrics: [:], views: webViewConstraintViews)
        let hConstraintsWeb = NSLayoutConstraint.constraints(withVisualFormat: hFormatWeb, options: [], metrics: [:], views: webViewConstraintViews)
        view.addConstraints(vConstraintsWeb)
        view.addConstraints(hConstraintsWeb)
        view.layoutIfNeeded()
        reloadWebView()
        
        // UIBarButtonItem
        let shareItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(sharedPageView))
        let language = UIBarButtonItem(title: isShowZH ? "En" : "中", style: .plain, target: self, action: #selector(switchLanguage))
        languageItem = language
        var font = UIBarButtonItem()
        #if !targetEnvironment(macCatalyst)
            font = UIBarButtonItem(title: "a", style: .plain, target: self, action: #selector(fontSize))
        #endif
        let fixedSpace = UIBarButtonItem.init(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        fixedSpace.width = 15
        navigationItem.rightBarButtonItems = [shareItem, infoItem, fixedSpace, language, fixedSpace, font]

    }
    
    @objc func showAnswer(item: Any) {
        let alert = UIAlertController(title: HTCLocalized("Tips"),
                                      message: HTCLocalized("Select the language of the answer for the solution."),
                                      preferredStyle: UIAlertController.Style.alert)
        
        let enProblemsAction = UIAlertAction.init(title: HTCLocalized("Subject(English)"), style: .default) { (action: UIAlertAction) in
            let url = "https://leetcode.com/problems/" + self.questionModle!.link + "/"
            self.showWebView(url: url)
        }
        alert.addAction(enProblemsAction)
        
        // https://leetcode.com/problems/two-sum/solution/
        let enAction = UIAlertAction.init(title: HTCLocalized("Solution(English)"), style: .default) { (action: UIAlertAction) in
            let url = "https://leetcode.com/problems/" + self.questionModle!.link + "/solution/"
            self.showWebView(url: url)
        }
        alert.addAction(enAction)
        
        let zhProblemsAction = UIAlertAction.init(title: HTCLocalized("Subject(Chinese)"), style: .default) { (action: UIAlertAction) in
            let url = "https://leetcode-cn.com/problems/" + self.questionModle!.link + "/"
            self.showWebView(url: url)
        }
        alert.addAction(zhProblemsAction)
        
        // https://leetcode-cn.com/problems/two-sum/solution/
        let zhAction = UIAlertAction.init(title: HTCLocalized("Solution(Chinese)"), style: .default) { (action: UIAlertAction) in
            let url = "https://leetcode-cn.com/problems/" + self.questionModle!.link + "/solution/"
            self.showWebView(url: url)
        }
        alert.addAction(zhAction)
        
        let cancelAction = UIAlertAction.init(title: HTCLocalized("Cancel"), style: .destructive) { (action: UIAlertAction) in
            
        }
        alert.addAction(cancelAction)
        view.window!.rootViewController!.present(alert, animated: true, completion: {
            //print("UIAlertController present");
        })
    }
    
    @objc func switchLanguage(item: UIBarButtonItem) {
        if item.title == "中" {
            isShowZH = true
            item.title = "En"
        }
        else {
            isShowZH = false
            item.title = "中"
        }
        
        // titile localization
        let old_title = self.navigationItem.title ?? ""
        if let value = ILeetCoderModel.shared.titleLocaliDict[old_title] {
            self.navigationItem.title = value
        }
        
        self.tableView.reloadData()
        reloadWebView()
    }
    
    @objc func fontSize(item: UIBarButtonItem) {
        if item.title == "a" {
            item.title = "A"
            setCssFont(percentFont: 120, rowSpace: 26)
        }
        else if item.title == "A"  {
            item.title = "aA"
            setCssFont(percentFont: 150, rowSpace: 28)
        } else if item.title == "aA"  {
            item.title = "AA"
            setCssFont(percentFont: 200, rowSpace: 30)
        } else if item.title == "AA"  {
            item.title = "a"
            setCssFont(percentFont: 100, rowSpace: 24)
        }
    }
    
    func setCssFont(percentFont: NSInteger, rowSpace: NSInteger) {
        let css = "document.getElementsByClassName('markdown-body')[0].style.webkitTextSizeAdjust= '\(percentFont)%'; document.getElementsByClassName('markdown-body')[0].style.lineHeight= '\(rowSpace)px;'"
        webView.evaluateJavaScript(css, completionHandler: nil)
    }
    
    @objc func sharedPageView(item: Any) {
        // 页面高度
        webView.evaluateJavaScript("document.body.scrollHeight") { (height, error) in
            let height = height as! CGFloat + 15 //spacing 20
            let headerImage = self.selectedCell.screenshot ?? UIImage.init(named: "App-share-Icon")
            self.webView.scrollView.takeScreenshotOfFullContent { (masterImage: UIImage!) in
                DispatchQueue.main.async {
                    if masterImage == nil {
                        return
                    }
                    let mainImage = masterImage.imageCroppingRect(croppingRect: CGRect.init(x: 0, y: 0, width: Int(masterImage.size.width), height: Int(height))) ?? UIImage.init(named: "App-share-Icon")!
                    let footerImage = IHTCShareFooterView.footerView(image: UIImage.init(named: "iLeetCoder-qrcode")!, title: kShareTitle, subTitle: kShareSubTitle).screenshot
                    let image = ImageHandle.slaveImageWithMaster(masterImage: mainImage, headerImage: headerImage!, footerImage: footerImage!)
                    IAppleServiceUtil.shareImage(image: image!, vc: self.view.window!.rootViewController!)
                }
            }
        }
    }
    
    func showWebView(url: String) {
        var vc: SFSafariViewController
        if #available(iOS 13.0, *) {
            let config = SFSafariViewController.Configuration()
            config.entersReaderIfAvailable = true
            vc = SFSafariViewController.init(url: URL(string: url)!, configuration: config)
        } else {
            vc = SFSafariViewController(url: URL(string: url)!, entersReaderIfAvailable: true)
        }
        if #available(iOS 10.0, *) {
            vc.preferredBarTintColor = kColorAppOrange
            vc.preferredControlTintColor = UIColor.white
        }
        if #available(iOS 11.0, *) {
            vc.dismissButtonStyle = .close
        }
        view.window!.rootViewController!.present(vc, animated: true)
    }
    
    fileprivate func headerView() -> UIView {
        let cell = UINib(nibName: "ITQuestionListViewCell", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! ITQuestionListViewCell
        cell.accessoryType = .none
        cell.selectionStyle = .none
        cell.numLbl.layer.cornerRadius = 3
        cell.numLbl.layer.masksToBounds = true
        cell.numLbl.adjustsFontSizeToFitWidth = true
        cell.numLbl.baselineAdjustment = .alignCenters
        cell.tagLbl.layer.cornerRadius = 3
        cell.tagLbl.layer.masksToBounds = true
        cell.tagLbl.adjustsFontSizeToFitWidth = true
        cell.tagLbl.baselineAdjustment = .alignCenters
        cell.langugeLbl.layer.cornerRadius = 3
        cell.langugeLbl.layer.masksToBounds = true
        cell.langugeLbl.adjustsFontSizeToFitWidth = true
        cell.langugeLbl.baselineAdjustment = .alignCenters
        cell.frequencyLbl.layer.cornerRadius = 3
        cell.frequencyLbl.layer.masksToBounds = true
        cell.frequencyLbl.adjustsFontSizeToFitWidth = true
        cell.frequencyLbl.baselineAdjustment = .alignCenters
        #if targetEnvironment(macCatalyst)
           cell.questionLbl.font = UIFont.systemFont(ofSize: 20)
        #endif
        
        let question = questionModle!
        cell.numLbl.text =  " #" + question.leetId + " "
        cell.tagLbl.text =  " " + question.difficulty + " "
        cell.tagLbl.backgroundColor = ILeetCoderModel.shared.colorForKey(level: question.difficulty)
        cell.frequencyLbl.text = " " + (question.frequency.count < 3 ? (question.frequency + ".0%") : question.frequency) + " "
        cell.langugeLbl.backgroundColor = kColorAppGray
        
        cell.langugeLbl.isHidden = question.tagString.count == 0 ? true : false
        
        if isShowZH {
            cell.tagLbl.text =  " " + (question.difficulty == "Easy" ? "容易" : (question.difficulty == "Medium" ? "中等" : "困难" )) + " "
            cell.langugeLbl.text = cell.langugeLbl.isHidden ? "" : (" " + question.tagStringZh.componentsJoined(by: " · ") + " ")
            cell.questionLbl.text = question.titleZh.count > 0 ? question.titleZh : question.title
        }else{
            cell.tagLbl.text = " " + question.difficulty + " "
            cell.langugeLbl.text = cell.langugeLbl.isHidden ? "" : (" " + question.tagString.componentsJoined(by: " · ") + " ")
            cell.questionLbl.text = question.title
        }
        
        let previousTap = UITapGestureRecognizer.init(target: self, action: #selector(showPreviousQuestion));
        previousTap.numberOfTapsRequired = 2
        cell.PreviousQuestionView.addGestureRecognizer(previousTap)
        
        let nextTap = UITapGestureRecognizer.init(target: self, action: #selector(showNexQuestion));
        nextTap.numberOfTapsRequired = 2
        cell.NextQuestionView.addGestureRecognizer(nextTap)
        
        return cell
    }
    
    @objc func showPreviousQuestion() {
        
        let previousIndex = currentIndex - 1
        if previousIndex < 0 {
            #if !targetEnvironment(macCatalyst)
            let alert = UIAlertController.init(title: HTCLocalized("Tips"), message: HTCLocalized("No more previous questions"), preferredStyle: .alert)
            let cancelAction = UIAlertAction.init(title: HTCLocalized("OK"), style: .destructive) { (action: UIAlertAction) in
                
            }
            alert.addAction(cancelAction)
            view.window!.rootViewController!.present(alert, animated: true, completion: {
                //print("UIAlertController present");
            })
            #endif
            return
        }
        
        currentIndex = previousIndex
        let question = questionsArray[previousIndex]
        questionModle = question
        self.tableView.reloadData()
        reloadWebView()
    }
    
    @objc func showNexQuestion() {
        let previousIndex = currentIndex + 1
        if previousIndex > questionsArray.count {
            #if !targetEnvironment(macCatalyst)
            let alert = UIAlertController.init(title: HTCLocalized("Tips"), message: HTCLocalized("No more next questions"), preferredStyle: .alert)
            let cancelAction = UIAlertAction.init(title: HTCLocalized("OK"), style: .destructive) { (action: UIAlertAction) in
                
            }
            alert.addAction(cancelAction)
            view.window!.rootViewController!.present(alert, animated: true, completion: {
                //print("UIAlertController present");
            })
            #endif
            return
        }
        
        currentIndex = previousIndex
        let question = questionsArray[previousIndex]
        questionModle = question
        self.tableView.reloadData()
        reloadWebView()
    }
    
    fileprivate func reloadWebView() {
        var contents = ""
        if isShowZH {
            contents = questionModle!.questionDescriptionZh.count > 0 ? questionModle!.questionDescriptionZh : questionModle!.questionDescription;
        }
        else {
            contents =  questionModle!.questionDescription
        }
        
        let path = Bundle.main.path(forResource: "iLeetCoder", ofType: "html")!
        //reading
        var text = try! String.init(contentsOfFile: path, encoding: String.Encoding.utf8)
        if #available(iOS 13.0, *) {
            if (UITraitCollection.current.userInterfaceStyle == .dark) {
                text = text.replacingOccurrences(of: "${css}", with: "iLeetCoder-dark.css")
            } else {
                text = text.replacingOccurrences(of: "${css}", with: "iLeetCoder.css")
            }
        } else {
            text = text.replacingOccurrences(of: "${css}", with: "iLeetCoder.css")
        }
        text = text.replacingOccurrences(of: "${contents}", with: contents)
        // load string
        let bundleURL = URL.init(string: path)
        if bundleURL != nil {
            webView.loadHTMLString(text, baseURL: Bundle.main.resourceURL)
        }
    }
    
    override var prefersStatusBarHidden: Bool {
        return false
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

}


extension ITQuestionDetailViewController : UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return tableView.frame.size.height - tableView.sectionHeaderHeight
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let cell = headerView()
        self.selectedCell = (cell as! ITQuestionListViewCell)
        return cell
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
      
        let cell: ITQuestionDetailViewCell = tableView.dequeueReusableCell(withIdentifier: "ITQuestionDetailViewCell") as! ITQuestionDetailViewCell
        cell.accessoryType = .none
        cell.selectionStyle = .none
        cell.textLabel!.text = ""
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
}


extension ITQuestionDetailViewController: WKNavigationDelegate, WKUIDelegate {
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        
        if navigationAction.targetFrame == nil {
            webView.load(navigationAction.request)
        }
        decisionHandler(.allow)
    }
    
//    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
//
//    }
}


extension ITQuestionDetailViewController {
    override public var keyCommands: [UIKeyCommand]? {
        let leftKeyCommand = UIKeyCommand.init(input: UIKeyCommand.inputLeftArrow, modifierFlags: [], action: #selector(leftCommand))
        leftKeyCommand.discoverabilityTitle = HTCLocalized("Previous Question")
        let rightKeyCommand = UIKeyCommand.init(input: UIKeyCommand.inputRightArrow, modifierFlags: [], action: #selector(rightCommand))
        rightKeyCommand.discoverabilityTitle = HTCLocalized("Next Question")
        let langugeKeyCommand = UIKeyCommand.init(input: "T", modifierFlags: [.command], action: #selector(langugeCommand))
        langugeKeyCommand.discoverabilityTitle = HTCLocalized("Display Language")
//        let infoKeyCommand = UIKeyCommand.init(input: "I", modifierFlags: [.command], action: #selector(InfoCommand))
//        infoKeyCommand.discoverabilityTitle = HTCLocalized("Tips")
        
        return [leftKeyCommand, rightKeyCommand, langugeKeyCommand] //, infoKeyCommand]
    }

    @objc private func leftCommand(sender: UIKeyCommand) {
        showPreviousQuestion()
    }
    
    @objc private func rightCommand(sender: UIKeyCommand) {
        showNexQuestion()
    }
    
    @objc private func langugeCommand(sender: UIKeyCommand) {
        switchLanguage(item: languageItem!)
    }
    
//    @objc private func InfoCommand(sender: UIKeyCommand) {
//        showAnswer(item: infoItem)
//    }
    
    open override var canBecomeFirstResponder: Bool {
        return true
    }
}
