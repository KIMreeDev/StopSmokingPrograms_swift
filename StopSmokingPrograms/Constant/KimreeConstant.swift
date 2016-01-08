//
//  KimreeConstant.swift
//  StopSmokingPrograms
//
//  Created by Fran on 15/10/7.
//  Copyright © 2015年 kimree. All rights reserved.
//

import UIKit

// MARK: - bundle infoDictionary
var KM_BUNDLE_INFO_DICTIONARY: [String : AnyObject]?{
    get{
        let infoDictionary = NSBundle.mainBundle().infoDictionary
        return infoDictionary
    }
}

// MARK: - local version 本地版本号
let KM_LOCAL_VERSION: String = {
    var version = "1.0"
    let dic = KM_BUNDLE_INFO_DICTIONARY
    let localVersionString = dic?["CFBundleShortVersionString"] as? String
    if localVersionString != nil{
        version = localVersionString!
    }
    return version
}()

// MARK: - remote version, need AFNetworking  appstore版本号
let KM_REMOTE_VERSION: String = {
    // 远程版本信息只需要获取一次,如果获取失败，则使用本地版本
    var version = KM_LOCAL_VERSION
    let manager = KM_NET_MANAGER
    manager.completionQueue = dispatch_queue_create("afnetworking-getRemoteVersion", nil)
    
    // 同步
    let semaphore = dispatch_semaphore_create(0)
    manager.GET(KM_API_APP_REMOTE_INFO, parameters: nil, success: { (operation: AFHTTPRequestOperation!, responseObj: AnyObject!) -> Void in
        let dic = responseObj as? NSDictionary
        let results = dic?["results"] as? NSArray
        if results != nil && results!.count > 0{
            let result = results![0] as! NSDictionary
            version = result["version"] as! String
        }
        
        dispatch_semaphore_signal(semaphore)
        }) { (operation: AFHTTPRequestOperation!, error: NSError!) -> Void in
            KMLog("KM_REMOTE_VERSION : \(error.localizedDescription)")
            dispatch_semaphore_signal(semaphore)
    }
    
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
    
    return version
}()

// MARK: - need update  是否需要更新。 由于只会取一次远程版本，所以这里只需要判断一次就可以了
let KM_VERSION_NEED_UPDATE: Bool = {
    let localVersion = KM_LOCAL_VERSION
    let remoteVersion = KM_REMOTE_VERSION
    var update = false
    
    if localVersion.compare(remoteVersion, options: NSStringCompareOptions.NumericSearch) == NSComparisonResult.OrderedAscending{
        update = true
    }
    
//    let local = localVersion.componentsSeparatedByString(".")
//    let remote = remoteVersion.componentsSeparatedByString(".")
//    
//    let length = min(local.count, remote.count)
//    for i in 0..<length{
//        let localV = (local[i] as NSString).doubleValue
//        let remoteV = (remote[i] as NSString).doubleValue
//        if remoteV > localV{
//            verEqual = false
//            update = true
//            break
//        }else if remoteV == localV{
//            verEqual = true
//            continue
//        }else{
//            verEqual = false
//            update = false
//            break
//        }
//    }
//    if verEqual{
//        if remote.count > local.count{
//            update = true
//        }
//    }
    
    return update
}()

// MARK: - 自定义log。 
// 在 Swift 项目里也和 Objective-C 一样使用 DEBUG 来区分 Debug 和 Release，我们只需要到 Target 的 Build Settings 里面，找到 Swift Compiler Custom Flags，在 Debug 处传入一个 -D DEBUG 即可。
func KMLog(format: String, args: CVarArgType...){
    #if DEBUG
        NSLogv(format, getVaList(args))
        #else
        // NO LOG
    #endif
}

func KMLog(format: String){
    KMLog(format, args: [])
}

// MARK: - appDelagate
var KM_APP_DELEGATE: AppDelegate{
    get{
        return UIApplication.sharedApplication().delegate as! AppDelegate
    }
}

// MARK: - user defaults
var KM_USER_DEFAULTS: NSUserDefaults{
    get{
        return NSUserDefaults.standardUserDefaults()
    }
}

// MARK: - base frame
let KM_FRAME = UIScreen.mainScreen().bounds
let KM_FRAME_WIDTH = KM_FRAME.size.width
let KM_FRAME_HEIGHT = KM_FRAME.size.height


// MARK: - progressHUD
let KM_JD_VIEW_SHOW_TIME: NSTimeInterval = 2

// MARK: - email
let KM_EMAIL_ADDRESS = "fran.zhou@kimree.net"
let KM_EMAIL_PASSWORD = "zhoufan322"
let KM_EMAIL_SMTP = "smtp.exmail.qq.com"

// MARK: - history record limit
let KM_HISTORY_RECORD_LIMIT_MAX_DAYS = 30

