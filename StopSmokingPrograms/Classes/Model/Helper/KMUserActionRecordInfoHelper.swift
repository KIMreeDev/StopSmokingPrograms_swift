//
//  KMUserActionRecordInfoHelper.swift
//  StopSmokingPrograms
//
//  Created by Fran on 15/11/5.
//  Copyright © 2015年 kimree. All rights reserved.
//

import UIKit

class KMUserActionRecordInfoHelper: NSObject {
    
    class func updateRecordInfo(info: KMUserActionRecordInfo){
        info.saveEventually { (success: Bool, error: NSError!) -> Void in
            if success{
                var caches = LocalStorage.shareLocalStorage().getObject(KM_STORAGE_USER_ACTION_RECORD_INFO, searchPathDirectory: NSSearchPathDirectory.CachesDirectory) as? NSMutableDictionary
                if caches == nil{
                    caches = NSMutableDictionary()
                }
                
                var rootDic = caches?.objectForKey(info.user!.objectId) as? NSMutableDictionary
                if rootDic == nil{
                    rootDic = NSMutableDictionary()
                    caches?.setObject(rootDic!, forKey: info.user!.objectId)
                }
                
                var saveData = rootDic?.objectForKey(info.record!.historyDate!) as? NSMutableDictionary
                if saveData == nil{
                    saveData = NSMutableDictionary()
                    rootDic?.setObject(saveData!, forKey: info.record!.historyDate!)
                }
                
                let dic = NSMutableDictionary()
                dic.setObject(info.objectId, forKey: "objectId")
                dic.setObject(info.updatedAt, forKey: "updatedAt")
                dic.setObject(info.record!.historyDate!, forKey: "historyDate")
                dic.setObject(info.user!.objectId, forKey: "userId")
                dic.setObject(info.record!.objectId, forKey: "recordId")
                dic.setObject(info.hour, forKey: "hour")
                dic.setObject(info.latitude, forKey: "latitude")
                dic.setObject(info.longitude, forKey: "longitude")
                
                saveData?.setObject(dic, forKey: info.objectId)
                LocalStorage.shareLocalStorage().addObject(caches!, fileName: KM_STORAGE_USER_ACTION_RECORD_INFO, searchPathDirectory: NSSearchPathDirectory.CachesDirectory)
            }
        }
    }
    
    // 获取吸烟记录信息详情， 默认获取30天之内的
    class func getAllRecordInfo(user: KMUser, limitDays: Int = 30) -> NSMutableDictionary{
        let fromDate = KimreeDateTool.dateFromString(KimreeDateTool.dateStringWithDate(NSDate(timeIntervalSinceNow: -Double(limitDays - 1) * 24 * 60 * 60)))
        
        func getRecordInfoWithIdNotIn( _dic: NSMutableDictionary, minDate: NSDate) -> NSMutableDictionary{
            let result = NSMutableDictionary()
            
            let objectIdArray = NSMutableArray()
            for _key in _dic.allKeys{
                let _valDic = _dic.objectForKey(_key) as! NSMutableDictionary
                for _idKey in _valDic.allKeys{
                    objectIdArray.addObject(_idKey as? String ?? "")
                }
            }
            
            let query = KMUserActionRecordInfo.query()
            query.whereKey("user", equalTo: user)
            query.whereKey("createdAt", greaterThanOrEqualTo: minDate)
            query.whereKey("objectId", notContainedIn: objectIdArray as [AnyObject])
            
            let queryRes = query.findObjects() as! [KMUserActionRecordInfo]
            for info in queryRes{
                info.record?.refresh()
                var infoDic = result.objectForKey(info.record!.historyDate!) as? NSMutableDictionary
                if infoDic == nil{
                    infoDic = NSMutableDictionary()
                    result.setObject(infoDic!, forKey: info.record!.historyDate!)
                }
                
                let dic = NSMutableDictionary()
                dic.setObject(info.objectId, forKey: "objectId")
                dic.setObject(info.updatedAt, forKey: "updatedAt")
                dic.setObject(info.record!.historyDate!, forKey: "historyDate")
                dic.setObject(user.objectId, forKey: "userId")
                dic.setObject(info.record!.objectId, forKey: "recordId")
                dic.setObject(info.hour, forKey: "hour")
                dic.setObject(info.latitude, forKey: "latitude")
                dic.setObject(info.longitude, forKey: "longitude")
                
                infoDic?.setObject(dic, forKey: info.objectId)
            }
            
            return result
        }
        
        
        var caches = LocalStorage.shareLocalStorage().getObject(KM_STORAGE_USER_ACTION_RECORD_INFO, searchPathDirectory: NSSearchPathDirectory.CachesDirectory) as? NSMutableDictionary
        if caches == nil{
            caches = NSMutableDictionary()
        }
        var dataDic = caches?.objectForKey(user.objectId) as? NSMutableDictionary
        if dataDic == nil{
            dataDic = NSMutableDictionary()
            caches?.setObject(dataDic!, forKey: user.objectId)
        }
        
        let nearDic = NSMutableDictionary()
        for ele in dataDic!{
            let _keyDate = ele.key as! NSDate
            if _keyDate.compare(fromDate) != NSComparisonResult.OrderedAscending{
                nearDic.setObject(ele.value, forKey: _keyDate)
            }
        }
        
        var localCount = 0
        for ele in nearDic{
            let valDic = ele.value as? NSMutableDictionary
            localCount += valDic?.count ?? 0
        }
        
        let query = KMUserActionRecordInfo.query()
        query.whereKey("user", equalTo: user)
        query.whereKey("createdAt", greaterThanOrEqualTo: fromDate)
        let count = query.countObjects()
        if count > localCount {
            let remoteDic = getRecordInfoWithIdNotIn(nearDic, minDate: fromDate)
            
            for _ele in remoteDic{
                if nearDic.objectForKey(_ele.key) == nil{
                    nearDic.setObject(_ele.value, forKey: _ele.key as! NSDate)
                }else{
                    let infoDic = nearDic.objectForKey(_ele.key) as? NSMutableDictionary
                    infoDic?.addEntriesFromDictionary(_ele.value as! [NSObject : AnyObject])
                }
            }
            
            dataDic?.addEntriesFromDictionary(nearDic as [NSObject : AnyObject])
            
            LocalStorage.shareLocalStorage().addObject(caches!, fileName: KM_STORAGE_USER_ACTION_RECORD_INFO, searchPathDirectory: NSSearchPathDirectory.CachesDirectory)
        }
        
        return nearDic
    }
    
}
