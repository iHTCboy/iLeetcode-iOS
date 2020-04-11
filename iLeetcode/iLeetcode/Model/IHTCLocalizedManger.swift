//
//  IHTCLocalizedManger.swift
//  iCoder
//
//  Created by HTC on 2020/4/11.
//  Copyright © 2020 HTC. All rights reserved.
//

import UIKit


// 多语言
func HTCLocalized(_ key: String) -> String {
//    return NSLocalizedString(key, tableName: nil, comment: "")
    return IHTCLocalizedManger.shared.localizedString(key)
}

class IHTCLocalizedManger: NSObject {
    
    static let languagesKey = "AppleLanguages"
    var bundle:Bundle?
    
    static let shared : IHTCLocalizedManger = {
        let instance = IHTCLocalizedManger()
        return instance
    }()
    
    override init() {
        super.init()
        initLangage()
    }
    
    func setUserLanguage(language:String) {
        IHTCUserDefaults.shared.setUDValue(value: language, forKey: "UserLanguage")
        
        let bundlePath = Bundle.main.path(forResource: language, ofType: "lproj")
        bundle = Bundle.init(path: bundlePath!)
    }
    
    func currentLanguage() -> String {
        if let userLanguage = IHTCUserDefaults.shared.getUDValue(key: "UserLanguage") as? String   {
            return userLanguage
        }
        return NSLocale.preferredLanguages.first ?? "en"
    }
    
    func isChineseLanguage() -> Bool {
        if currentLanguage().hasPrefix("zh-Hans") {
            return true
        }
        return false
    }
    
    func flowSystemLanguage() {
        IHTCUserDefaults.shared.setUDValue(value: nil, forKey: "UserLanguage")
        initLangage()
    }
    
    func initLangage() {
        var language = currentLanguage()
        
        if language == "zh-Hans-CN" || language == "zh-Hans" || language == "zh-Hans-HK" || language == "zh-Hans-US" {
            language = "zh-Hans"
        }
        else if language == "zh-Hant-CN" || language == "zh-Hant" || language == "zh-HK" {
            language = "zh-Hant"
        }
//        else if language.hasPrefix("pt") {
//            language = "pt";//葡萄牙语
//        }
//        else if language.hasPrefix("es") {
//            language = "es";//西班牙语
//        }
//        else if language.hasPrefix("th") {
//            language = "th";//泰语
//        }
//        else if language.hasPrefix("hi") {
//            language = "hi";//印地语
//        }
        else {
            language = "en"
        }
        
        IHTCUserDefaults.shared.setUDValue(value:language, forKey: "UserLanguage")
        
        let bundlePath = Bundle.main.path(forResource: language, ofType: "lproj")
        bundle = Bundle.init(path: bundlePath!)
    }
    
    fileprivate func localizedString(_ key: String) -> String {
        return NSLocalizedString(key, tableName: "", bundle: bundle!, value: "", comment: "")
    }
}
