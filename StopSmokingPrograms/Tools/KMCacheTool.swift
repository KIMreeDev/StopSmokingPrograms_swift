//
//  KMCacheTool.swift
//  StopSmokingPrograms
//
//  Created by Fran on 15/10/15.
//  Copyright © 2015年 kimree. All rights reserved.
//

import UIKit

class KMCacheTool: NSObject {
    // 计算缓存大小
    static var cacheSize: String{
        get{
            let basePath = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.CachesDirectory, NSSearchPathDomainMask.UserDomainMask, true).first
            let fileManager = NSFileManager.defaultManager()
            
            func caculateCache() -> Float{
                var total: Float = 0
                if fileManager.fileExistsAtPath(basePath!){
                    let childrenPath = fileManager.subpathsAtPath(basePath!)
                    if childrenPath != nil{
                        for path in childrenPath!{
                            let childPath = basePath!.stringByAppendingString("/").stringByAppendingString(path)
                            do{
                                let attr = try fileManager.attributesOfItemAtPath(childPath)
                                let fileSize = attr["NSFileSize"] as! Float
                                total += fileSize
                                
                            }catch _{
                                
                            }
                        }
                    }
                }
                
                return total
            }
            
            
            let totalCache = caculateCache()
            return NSString(format: "%.2f MB", totalCache / 1024.0 / 1024.0 ) as String
        }
    }
    
    // 清除缓存
    class func clearCache() -> Bool{
        var result = true
        let basePath = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.CachesDirectory, NSSearchPathDomainMask.UserDomainMask, true).first
        let fileManager = NSFileManager.defaultManager()
        if fileManager.fileExistsAtPath(basePath!){
            let childrenPath = fileManager.subpathsAtPath(basePath!)
            for childPath in childrenPath!{
                let cachePath = basePath?.stringByAppendingString("/").stringByAppendingString(childPath)
                do{
                    try fileManager.removeItemAtPath(cachePath!)
                }catch _{
                    result = false
                }
            }
        }
        
        return result
    }
}
