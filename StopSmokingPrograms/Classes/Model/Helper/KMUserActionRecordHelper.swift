//
//  KMUserActionRecordHelper.swift
//  StopSmokingPrograms
//
//  Created by Fran on 15/11/2.
//  Copyright © 2015年 kimree. All rights reserved.
//

import UIKit

class KMUserActionRecordHelper: NSObject {
    
    class func getUserActionRecord(user: KMUser, habits: KMUserHabits) -> KMUserActionRecord{
        let query = KMUserActionRecord.query()
        query.whereKey("historyDate", equalTo: KimreeDateTool.dateFromString(KimreeDateTool.currentDateString()))
        query.whereKey("user", equalTo: user)
        
        var error: NSError?
        var record = query.getFirstObject(&error) as! KMUserActionRecord!
        
        if record == nil{
            record = saveDefaultActionRecord(user, habits: habits)
            if error == nil || (error != nil && error!.code == kAVErrorObjectNotFound){
                record.saveEventually()
            }
        }
        
        return record
    }
    
    class func saveDefaultActionRecord(user: KMUser, habits: KMUserHabits) -> KMUserActionRecord{
        let record = KMUserActionRecord()
        record.user = user
        record.historyDate = KimreeDateTool.dateFromString(KimreeDateTool.currentDateString())
        record.habitsNum = KMUserHabitsHelper.canSmokingToday(habits) ? habits.smokedPerDay : 0
        record.smokedNum = 0
        record.priceForOnePackage = habits.priceForOnePackage
        
        return record
    }
    
    class func updateUserActionRecord(record: KMUserActionRecord){
        
        func saveCache(_record: KMUserActionRecord){
            var cache = LocalStorage.shareLocalStorage().getObject(KM_STORAGE_USER_ACTION_RECORD, searchPathDirectory: NSSearchPathDirectory.CachesDirectory) as? NSMutableDictionary
            if cache == nil{
                cache = NSMutableDictionary()
            }
            
            var rootDic = cache!.objectForKey(_record.user!.objectId) as? NSMutableDictionary
            if rootDic == nil{
                rootDic = NSMutableDictionary()
                cache?.setObject(rootDic!, forKey: _record.user!.objectId)
            }
            
            let data = NSMutableDictionary()
            data.setObject(_record.objectId, forKey: "objectId")
            data.setObject(_record.smokedNum, forKey: "smokedNum")
            data.setObject(_record.habitsNum, forKey: "habitsNum")
            data.setObject(_record.priceForOnePackage, forKey: "priceForOnePackage")
            rootDic?.setObject(data, forKey: _record.historyDate!)
            
            LocalStorage.shareLocalStorage().addObject(cache!, fileName: KM_STORAGE_USER_ACTION_RECORD, searchPathDirectory: NSSearchPathDirectory.CachesDirectory)
        }
        
        let query = KMUserActionRecord.query()
        query.whereKey("historyDate", equalTo: KimreeDateTool.dateFromString(KimreeDateTool.currentDateString()))
        query.whereKey("user", equalTo: record.user)
        
        var error: NSError?
        let find = query.getFirstObject(&error) as! KMUserActionRecord!
        
        if find == nil && (error == nil || (error != nil && error!.code == kAVErrorObjectNotFound)){
            record.saveEventually()
        }else if find != nil && error == nil{
            if find.objectId == record.objectId{
                record.saveEventually({ (success: Bool, error: NSError!) -> Void in
                    if success{
                        saveCache(record)
                    }
                })
            }else{
                find.habitsNum = record.habitsNum
                find.smokedNum = record.smokedNum
                find.priceForOnePackage = record.priceForOnePackage
                
                find.saveEventually({ (success: Bool, error: NSError!) -> Void in
                    if success{
                        saveCache(find)
                    }
                })
            }
        }else if error != nil{
            JDStatusBarNotification.showWithStatus("同步今日动态失败", dismissAfter: KM_JD_VIEW_SHOW_TIME)
            SVProgressHUD.showErrorWithStatus("同步今日动态失败:\(error!.localizedDescription)")
        }
    
    }
    
    // 获取用户每天的吸烟记录， 默认获取30天之内的
    // 注意缓存处理
    class func getAllRecord(user: KMUser, limitDays: Int = 30) -> NSMutableDictionary{
        
        let fromDate = KimreeDateTool.dateFromString(KimreeDateTool.dateStringWithDate(NSDate(timeIntervalSinceNow: -Double(limitDays - 1) * 24 * 60 * 60)))
        
        func getAllUserRecordWithIdNotIn( _dic: NSMutableDictionary, minDate: NSDate) -> NSMutableDictionary{
            let result = NSMutableDictionary()
            
            let objectIdArray = NSMutableArray()
            for _key in _dic.allKeys{
                let _valDic = _dic.objectForKey(_key) as! NSMutableDictionary
                objectIdArray.addObject(_valDic.objectForKey("objectId") as? String ?? "")
            }
            
            let query = KMUserActionRecord.query()
            query.whereKey("user", equalTo: user)
            query.whereKey("historyDate", greaterThanOrEqualTo: minDate)
            query.whereKey("objectId", notContainedIn: objectIdArray as [AnyObject])
            
            let queryRes = query.findObjects() as! [KMUserActionRecord]
            for _record in queryRes{
                let data = NSMutableDictionary()
                data.setObject(_record.objectId, forKey: "objectId")
                data.setObject(_record.smokedNum, forKey: "smokedNum")
                data.setObject(_record.habitsNum, forKey: "habitsNum")
                data.setObject(_record.priceForOnePackage, forKey: "priceForOnePackage")
                result.setObject(data, forKey: _record.historyDate!)
            }
            
            return result
        }
        
        var caches = LocalStorage.shareLocalStorage().getObject(KM_STORAGE_USER_ACTION_RECORD, searchPathDirectory: NSSearchPathDirectory.CachesDirectory) as? NSMutableDictionary
        if caches == nil{
            caches = NSMutableDictionary()
        }
        var dataDic = caches!.objectForKey(user.objectId) as? NSMutableDictionary
        if dataDic == nil{
            dataDic = NSMutableDictionary()
            caches!.setObject(dataDic!, forKey: user.objectId)
        }
        
        let nearDic = NSMutableDictionary()
        for ele in dataDic!{
            let _keyDate = ele.key as! NSDate
            if _keyDate.compare(fromDate) != NSComparisonResult.OrderedAscending{
                nearDic.setObject(ele.value, forKey: _keyDate)
            }
        }
        
        let query = KMUserActionRecord.query()
        query.whereKey("user", equalTo: user)
        query.whereKey("historyDate", greaterThanOrEqualTo: fromDate)
        let count = query.countObjects()
        if count > nearDic.count{
            let remoteDic = getAllUserRecordWithIdNotIn(nearDic, minDate: fromDate)
            nearDic.addEntriesFromDictionary(remoteDic as [NSObject : AnyObject])
            dataDic?.addEntriesFromDictionary(nearDic as [NSObject : AnyObject])
            
            LocalStorage.shareLocalStorage().addObject(caches!, fileName: KM_STORAGE_USER_ACTION_RECORD, searchPathDirectory: NSSearchPathDirectory.CachesDirectory)
        }
        
        return nearDic
    }
    
    
    // 获取最后一次有抽烟记录的日期， 往后推迟一天就算作是戒烟看是日期
    class func getLastSmokedDate(user: KMUser, habits: KMUserHabits) -> NSDate{
        var date = NSDate()
        
        let query = KMUserActionRecord.query()
        query.whereKey("user", equalTo: user)
        query.whereKey("smokedNum", notEqualTo: 0)
        query.orderByDescending("historyDate")
        
        let res = query.getFirstObject() as? KMUserActionRecord
        if res != nil{
            date = NSDate(timeInterval: 24 * 60 * 60, sinceDate: res!.historyDate!)
        }else{
            let queryElse = KMUserActionRecord.query()
            queryElse.whereKey("user", equalTo: user)
            queryElse.whereKey("smokedNum", equalTo: 0)
            queryElse.orderByAscending("historyDate")
            
            let resElse = queryElse.getFirstObject() as? KMUserActionRecord
            if resElse != nil{
                if habits.stillSmoking{
                    date = resElse!.historyDate!
                }else{
                    date = KimreeDateTool.dateFromString(habits.nonSmokeSince!)
                }
                
            }else{
                date = KimreeDateTool.dateFromString(KimreeDateTool.currentDateString())
            }
        }
        
        
        return date
    }
    
}
