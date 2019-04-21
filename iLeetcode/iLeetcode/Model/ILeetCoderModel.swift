//
//  ILeetCoderModel.swift
//  iLeetcode
//
//  Created by HTC on 2019/3/31.
//  Copyright © 2019 HTC. All rights reserved.
//

import UIKit

class ILeetCoderModel: NSObject {
    static let shared = ILeetCoderModel()
    private override init() {
        //This prevents others from using the default '()' initializer for this class.
        super.init()
        initModel()
    }
    public var defaultArray = ["All",
                                "Easy",
                                "Medium",
                                "Hard",
                                "Public",
                                "Private"]
    public var tagsArray = Array<String>() //[]
    public var enterpriseArray = Array<String>() //[]
    

    fileprivate var defaultDict  = Dictionary<String, ITModel>()
    fileprivate var tagsDict = Dictionary<String, ITModel>()
    fileprivate var enterpriseDict = Dictionary<String, ITModel>()
    fileprivate var leetIdsDict = Dictionary<String, ITQuestionModel>()
}


extension ILeetCoderModel
{
    func defaultData() -> Dictionary<String, ITModel> {
        return self.defaultDict
    }
    
    func tagsData() -> Dictionary<String, ITModel> {
        return self.tagsDict
    }
    
    func enterpriseData() -> Dictionary<String, ITModel> {
        return self.enterpriseDict
    }
    
    func leetData(id: String) -> ITQuestionModel {
        return self.leetIdsDict[id] ?? ITQuestionModel(dictionary: [:])
    }
    
    func colorForKey(level: String) -> UIColor {
        switch level {
        case "All":
            return KColorAppRed
        case "Easy":
            return kColorAppGreen
        case "Medium":
            return kColorAppOrange
        case "Hard":
            return KColorAppRed
        default:
            return kColorAppBlue
        }
    }
    
    private func initModel() {
        let fileName = "iLeetCoder-Question"
        if let file = Bundle.main.url(forResource: fileName, withExtension: "json") {
            do {
                let data = try Data(contentsOf: file)
                let json = try JSONSerialization.jsonObject(with: data, options: [])
                if let objects = json as? [Dictionary<String, Any>] {
                    // json is a dictionary
                    var dfDict = Dictionary<String, NSMutableArray>()
                    for df in self.defaultArray {
                        dfDict[df] = NSMutableArray.init();
                    }
                    
                    var tagDict = Dictionary<String, NSMutableArray>()
                    var enterDict = Dictionary<String, NSMutableArray>()
                    var idsDict = Dictionary<String, Dictionary<String, Any>>()
                    
                    // 分类保存
                    for question in objects {
                        // default
                        let allDict = dfDict["All"]
                        allDict?.add(question)
                        
                        let leetId = question["leetId"] as! String
                        idsDict[leetId] = question
                        
                        let difficulty = question["difficulty"] as! String
                        let difDict = dfDict[difficulty]
                        difDict?.add(question)
                        
                        let is_locked = question["is_locked"] as! String
                        let is_lockedDict = dfDict[is_locked == "Normal" ? "Public" : "Private"]
                        is_lockedDict?.add(question)
                        
                        // tags
                        if let tags = question["tags"] as? [Dictionary<String, String>] {
                            if tags.count > 0 {
                                for tag in tags {
                                    let tg = tag["tag"]
                                    if let tagArray = tagDict[tg!] {
                                        tagArray.add(question)
                                    }
                                    else {
                                        let newTagArray = NSMutableArray.init();
                                        newTagArray.add(question)
                                        tagDict[tg!] = newTagArray
                                    }
                                }
                            }
                        }
                        
                        //ids
                        if let companies = question["companies"] as? Array<String> {
                            if companies.count > 0 {
                                for company in companies {
                                    if let cpArray = enterDict[company] {
                                        cpArray.add(question)
                                    }
                                    else {
                                        let newCpArray = NSMutableArray.init();
                                        newCpArray.add(question)
                                        enterDict[company] = newCpArray
                                    }
                                }
                            }
                        }
                    }
                    
                    // 转成模型
                    for dfKey in dfDict.keys {
                        let model = ITModel.init(array: dfDict[dfKey] as! Array<Dictionary<String, Any>>, language: dfKey)
                        self.defaultDict[dfKey] = model
                    }
                    
                    let tagArray = tagDict.keys.sorted(){$0 < $1} //排序
                    for tagKey in tagArray {
                        let model = ITModel.init(array: tagDict[tagKey] as! Array<Dictionary<String, Any>>, language: tagKey)
                        self.tagsDict[tagKey] = model
                        self.tagsArray.append(tagKey)
                    }
                    
                    let cpsArray = enterDict.keys.sorted(){$0 < $1} //排序
                    for cpKey in cpsArray {
                        let model = ITModel.init(array: enterDict[cpKey] as! Array<Dictionary<String, Any>>, language: cpKey)
                        self.enterpriseDict[cpKey] = model
                        self.enterpriseArray.append(cpKey)
                    }
                    
                    // ids
                    for idKey in idsDict.keys {
                        let questionModel = ITQuestionModel.init(dictionary: idsDict[idKey]!);
                        leetIdsDict[idKey] = questionModel
                    }
                    
                } else {
                    print("JSON is invalid")
                }
            } catch {
                print(error.localizedDescription)
            }
        } else {
            print("no find json file")
        }
    }
}
