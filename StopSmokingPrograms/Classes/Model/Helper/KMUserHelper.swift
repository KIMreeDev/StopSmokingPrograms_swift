//
//  KMUserHelper.swift
//  StopSmokingPrograms
//
//  Created by Fran on 15/10/8.
//  Copyright © 2015年 kimree. All rights reserved.
//

import UIKit

class KMUserHelper: NSObject {
    
    // 登录
    class func loginWithUserName(userName: String, password: String) -> KMUser?{
        let query = KMUser.query()
        query.whereKey("userName", equalTo: userName)
        query.whereKey("password", equalTo: password)
        
        var user: KMUser? = nil
        var error: NSError?
        let array = query.findObjects(&error) as? [KMUser]
        if error != nil && error!.code != kAVErrorObjectNotFound{
            JDStatusBarNotification.showWithStatus("\(error!.localizedDescription)", dismissAfter: KM_JD_VIEW_SHOW_TIME)
            SVProgressHUD.showErrorWithStatus("\(error!.localizedDescription)")
            user = nil
        }else if array!.count != 1{
            JDStatusBarNotification.showWithStatus("用户名或密码错误", dismissAfter: KM_JD_VIEW_SHOW_TIME)
            SVProgressHUD.showErrorWithStatus("用户名或密码错误")
            user = nil
        }else{
            user = array!.first
        }
        
        return user
    }
    
    // 验证用户名是否使用
    class func validateUserName(userName: String) -> Bool{
        let query = KMUser.query()
        query.whereKey("userName", equalTo: userName)
        
        var canUse = true
        var error: NSError?
        let array = query.findObjects(&error)
        if error != nil && error!.code != kAVErrorObjectNotFound{
            JDStatusBarNotification.showWithStatus("\(error!.localizedDescription)", dismissAfter: KM_JD_VIEW_SHOW_TIME)
            SVProgressHUD.showErrorWithStatus("\(error!.localizedDescription)")
            canUse = false
        }else if array.count != 0{
            JDStatusBarNotification.showWithStatus("用户名已被使用,请使用其他用户名!", dismissAfter: KM_JD_VIEW_SHOW_TIME)
            SVProgressHUD.showErrorWithStatus("用户名已被使用,请使用其他用户名!")
            canUse = false
        }
        
        return canUse
    }
    
    // 用户名是唯一的, email 和 userName可以组合起来找回对应userName账户的密码
    class func registerWithUserName(userName: String, password: String, email: String) -> Bool{
        let user = KMUser()
        user.userName = userName
        user.password = password
        user.email = email
        
        var registerOK = true
        var error: NSError?
        
        // 还是要先判断一下用户名被占用没
        if validateUserName(userName){
            user.save(&error)
            if error != nil && error!.code != kAVErrorObjectNotFound{
                JDStatusBarNotification.showWithStatus("\(error!.localizedDescription)", dismissAfter: KM_JD_VIEW_SHOW_TIME)
                SVProgressHUD.showErrorWithStatus("\(error!.localizedDescription)")
                registerOK = false
            }else{
                JDStatusBarNotification.showWithStatus("注册成功!", dismissAfter: KM_JD_VIEW_SHOW_TIME)
                SVProgressHUD.showErrorWithStatus("注册成功!")
                registerOK = true
            }
        }else{
            registerOK = false
        }
        
        return registerOK
    }
    
    // 根据用户名和注册邮箱找回密码
    class func findUserWithUserName(userName: String, email: String) -> KMUser?{
        let query = KMUser.query()
        query.whereKey("userName", equalTo: userName)
        query.whereKey("email", equalTo: email)
        
        var user: KMUser? = nil
        var error: NSError?
        let array = query.findObjects(&error) as! [KMUser]
        if error != nil && error!.code != kAVErrorObjectNotFound{
            JDStatusBarNotification.showWithStatus("\(error!.localizedDescription)", dismissAfter: KM_JD_VIEW_SHOW_TIME)
            SVProgressHUD.showErrorWithStatus("\(error!.localizedDescription)")
            user = nil
        }else if array.count != 1{
            JDStatusBarNotification.showWithStatus("用户名或邮箱错误", dismissAfter: KM_JD_VIEW_SHOW_TIME)
            SVProgressHUD.showErrorWithStatus("用户名或邮箱错误")
            user = nil
        }else{
            user = array.first
        }
        
        return user
    }
    
}
