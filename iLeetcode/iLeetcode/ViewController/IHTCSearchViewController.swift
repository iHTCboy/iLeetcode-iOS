//
//  iHTCSearchViewController.swift
//  iWuBi
//
//  Created by HTC on 2019/4/12.
//  Copyright © 2019 HTC. All rights reserved.
//

import UIKit

class IHTCSearchViewController: UIViewController {

    @IBOutlet weak var naviBar: UINavigationBar!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var optionItem: UIBarButtonItem!
    

    @IBAction func clickedCancelItem(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func clickedOptionItem(_ item: UIBarButtonItem) {
        if item.title == "All" {
            item.title = "ID"
        } else if item.title == "ID"  {
            item.title = "Title"
        } else if item.title == "Title"  {
            item.title = "Content"
        } else if item.title == "Content"  {
            item.title = "All"
        }
        
        searchWordList(words: searchBar.text ?? "")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
    }

    var selectedCell: ITQuestionListViewCell!
    var isShowZH: Bool = false
    private var searchArray: Array<ITQuestionModel> = []
}


extension IHTCSearchViewController {
    func setupUI() {
        
        // language
        switch IHTCUserDefaults.shared.getUDLanguage() {
            case "zh_CN":
                isShowZH = true
                break
            case "en_US":
                isShowZH = false
                break
            default: break
        }
        
        self.searchBar.tintColor = kColorAppOrange
        self.searchBar.becomeFirstResponder()
        self.searchBar.delegate = self
        
        tableView.contentInset = UIEdgeInsets.init(top: 0, left: 0, bottom: 40, right: 0)
        tableView.separatorStyle = UITableViewCell.SeparatorStyle.none
        tableView.estimatedRowHeight = 80
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib.init(nibName: "ITQuestionListViewCell", bundle: Bundle.main), forCellReuseIdentifier: "ITQuestionListViewCell")
        
        // 判断系统版本，必须iOS 9及以上，同时检测是否支持触摸力度识别
        if #available(iOS 9.0, *), traitCollection.forceTouchCapability == .available {
            // 注册预览代理，self监听，tableview执行Peek
            registerForPreviewing(with: self, sourceView: tableView)
        }
        
    }
    
    func searchWordList(words: String) {
        if words.count == 0 {
            naviBar.topItem?.title = "Search"
            self.searchArray.removeAll()
            self.tableView.reloadData()
            return
        }
        
        searchLeetCoder(words: words)
    }
    
    func searchLeetCoder(words: String) {
        // remove all data
        naviBar.topItem?.title = "Search"
        self.searchArray.removeAll()
        
        var filterArray = Array<String>()
        if optionItem.title == "All" {
            filterArray = ["leetId", "title", "titleZh", "difficulty", "questionDescription", "questionDescriptionZh", "is_locked", "frequency", "tags", "companies"]
        } else if optionItem.title == "ID"  {
            filterArray = ["leetId"]
        } else if optionItem.title == "Title"  {
            filterArray = ["title", "titleZh"]
        } else if optionItem.title == "Content"  {
            filterArray = ["questionDescription", "questionDescriptionZh"]
        }
        
        // Update the filtered array based on the search text.
        let searchResults = ILeetCoderModel.shared.leetsArray
        
        // Strip out all the leading and trailing spaces.
        let whitespaceCharacterSet = CharacterSet.whitespaces
        let strippedString = words.trimmingCharacters(in: whitespaceCharacterSet)
        let searchItems = strippedString.components(separatedBy: " ") as [String]
        
        // Build all the "AND" expressions for each value in the searchString.
        let andMatchPredicates: [NSPredicate] = searchItems.map { searchString in
            // Each searchString creates an OR predicate for: name, yearIntroduced, introPrice.
            var searchItemsPredicate = [NSPredicate]()
            
            // Below we use NSExpression represent expressions in our predicates.
            // NSPredicate is made up of smaller, atomic parts: two NSExpressions (a left-hand value and a right-hand value).
            
            let searchStringExpression = NSExpression(forConstantValue: searchString)
            
            // Name field matching.
            for key in filterArray {
                let keyExpression = NSExpression(forKeyPath: key)
                let keySearchComparisonPredicate = NSComparisonPredicate(leftExpression: keyExpression, rightExpression: searchStringExpression, modifier: .direct, type: .contains, options: .caseInsensitive)
                searchItemsPredicate.append(keySearchComparisonPredicate)
            }
            
            // Add this OR predicate to our master AND predicate.
            let orMatchPredicate = NSCompoundPredicate(orPredicateWithSubpredicates:searchItemsPredicate)
            
            return orMatchPredicate
        }
        
        // Match up the fields of the Product object.
        let finalCompoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: andMatchPredicates)
        
        let filteredResults = searchResults.filter { finalCompoundPredicate.evaluate(with: $0) }
        
        // 转成模型
        for dict in filteredResults {
            let leetId = dict["leetId"] as! String
            let model = ILeetCoderModel.shared.leetData(id: leetId)
            self.searchArray.append(model)
        }
        
        naviBar.topItem?.title = "Search(\(self.searchArray.count))"
        self.tableView.reloadData()
    }
    
}

extension String {
    func subString(from: Int, to: Int) -> String {
        let startIndex = self.index(self.startIndex, offsetBy: from)
        let endIndex = self.index(self.startIndex, offsetBy: to)
        return String(self[startIndex..<endIndex])
    }
}

extension IHTCSearchViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchWordList(words: searchBar.text ?? "")
        searchBar.resignFirstResponder()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchWordList(words: searchBar.text ?? "")
    }
}


extension IHTCSearchViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        searchBar.resignFirstResponder()
    }
}


// MARK: Tableview Delegate
extension IHTCSearchViewController : UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.searchArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: ITQuestionListViewCell = tableView.dequeueReusableCell(withIdentifier: "ITQuestionListViewCell") as! ITQuestionListViewCell
        cell.accessoryType = .disclosureIndicator
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
        
        let question = self.searchArray[indexPath.row]
        cell.numLbl.text =  " #" + question.leetId + " "
        let difZh = (question.difficulty == "Easy" ? "容易" : (question.difficulty == "Medium" ? "中等" : "困难" ))
        cell.tagLbl.text =  " " + (isShowZH ? difZh : question.difficulty) + " "
        cell.tagLbl.backgroundColor = ILeetCoderModel.shared.colorForKey(level: question.difficulty)
        cell.frequencyLbl.text = " " + (question.frequency.count < 3 ? (question.frequency + ".0%") : question.frequency) + " "
        
        
        if question.tagString.count > 0 {
            cell.langugeLbl.text =  " " + (isShowZH ? question.tagStringZh : question.tagString).componentsJoined(by: " · ") + " "
            cell.langugeLbl.backgroundColor = kColorAppGray
            cell.langugeLbl.isHidden = false
        }
        else {
            cell.langugeLbl.text = ""
            cell.langugeLbl.isHidden = true
        }
        
        switch IHTCUserDefaults.shared.getUDLanguage() {
            case "zh_CN":
                cell.questionLbl.text = question.titleZh.count > 0 ? question.titleZh : question.title
                break
            case "en_US":
                cell.questionLbl.text = question.title
                break
            default: break
        }
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let question = self.searchArray[indexPath.row]
        let questionVC = IHTCSearchDetailVC()
        questionVC.title = question.language
        questionVC.currentIndex = indexPath.row
        questionVC.questionsArray = self.searchArray
        questionVC.questionModle = question
        questionVC.hidesBottomBarWhenPushed = true
        self.navigationController?.navigationBar.isHidden = false
        self.navigationController?.pushViewController(questionVC, animated: true)
    }
}



// MARK: - UIViewControllerPreviewingDelegate
@available(iOS 9.0, *)
extension IHTCSearchViewController: UIViewControllerPreviewingDelegate {
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        searchBar.resignFirstResponder()
        // 模态弹出需要展现的控制器
        //        showDetailViewController(viewControllerToCommit, sender: nil)
        // 通过导航栏push需要展现的控制器
        show(viewControllerToCommit, sender: nil)
    }
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        // 获取indexPath和cell
        guard let indexPath = tableView.indexPathForRow(at: location), let cell = tableView.cellForRow(at: indexPath) else { return nil }
        // 设置Peek视图突出显示的frame
        previewingContext.sourceRect = cell.frame
        
        let question = self.searchArray[indexPath.row]
        let questionVC = IHTCSearchDetailVC()
        questionVC.title = question.language
        questionVC.currentIndex = indexPath.row
        questionVC.questionsArray = self.searchArray
        questionVC.questionModle = question
        questionVC.hidesBottomBarWhenPushed = true
        
        // 返回需要弹出的控制权
        return questionVC
    }
}
