//
//  ValidateTool.swift
//  StopSmokingPrograms
//
//  Created by Fran on 15/10/12.
//  Copyright © 2015年 kimree. All rights reserved.
//

import UIKit

class ValidateTool: NSObject{
    // 用户名验证
    class func isUserName(userName: String) -> Bool{
        let str = userName.stringByReplacingOccurrencesOfString(" ", withString: "")
        let pattern = "\\w+"
        return matchPattern(pattern, str: str)
    }
    
    // 密码验证
    class func isPassword(password: String) -> Bool{
        let str = password.stringByReplacingOccurrencesOfString(" ", withString: "")
        let pattern = "\\w+"
        return matchPattern(pattern, str: str)
    }
    
    // 邮箱验证
    class func isEmail(email: String) -> Bool{
        let str = email.stringByReplacingOccurrencesOfString(" ", withString: "")
        let pattern = "\\w+(.\\w+)*@\\w+.\\w+"
        return matchPattern(pattern, str: str)
    }
    
    class func matchPattern(pattern: String, str: String) -> Bool{
        var isMatch = false
        let regex = try? NSRegularExpression(pattern: pattern, options: NSRegularExpressionOptions.AnchorsMatchLines)
        let matches = regex?.matchesInString(str, options: NSMatchingOptions.Anchored, range: NSMakeRange(0, str.characters.count))
        if matches != nil{
            for match in matches!{
                let range = match.range
                
                // 如果匹配结果能包含整个字符串，则认为匹配成功
                if range.location == 0 && range.length == str.characters.count{
                    isMatch = true
                }
            }
        }
        return isMatch
    }
}