//
//  IHTCUserDefaults.swift
//  iLeetcode
//
//  Created by HTC on 2019/4/22.
//  Copyright © 2019 HTC. All rights reserved.
//

import UIKit

class IHTCUserDefaults: NSObject {
    
    static let shared = IHTCUserDefaults()
    let df = UserDefaults.standard
}

extension IHTCUserDefaults
{
    func setUDValue(value: Any?, forKey key: String){
        df.set(value, forKey: key)
        df.synchronize()
    }
    
    func getUDValue(key: String) -> Any? {
        return df.value(forKey: key)
    }
}

// MARK: 语言设置
extension IHTCUserDefaults
{
    func getUDLanguage() -> String {
        if let language = getUDValue(key: "IHTCLanguageKey") as? String {
            return language
        }
        return  "en_US"
    }
    
    func setUDlanguage(value: String) {
        setUDValue(value: value, forKey: "IHTCLanguageKey")
    }
}
