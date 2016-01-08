//
//  KMUserHabitsHelper.swift
//  StopSmokingPrograms
//
//  Created by Fran on 15/10/21.
//  Copyright © 2015年 kimree. All rights reserved.
//

import UIKit

class KMUserHabitsHelper: NSObject {

    class func getUserHabits(user: KMUser) ->KMUserHabits!{
        let query = KMUserHabits.query()
        query.whereKey("user", equalTo: user)
        
        var error: NSError?
        var habits = query.getFirstObject(&error) as! KMUserHabits!
        
        // 如果无法查到 habits, 创建一个默认的。 如果 error 为 nil, 说明不存在其他情况，可以将创建的默认的 habits 同步到LeanCloud
        // 如果 error 不为 nil, 说明可能是其他原因导致查询失败， 这里创建的默认的 habits 不能同步
        // 提交修改的 habits  请使用  updateUserHabits 方法
        if habits == nil{
            habits = saveDefaultHabits(user)
            
            if error == nil || (error != nil && error!.code == kAVErrorObjectNotFound){
                habits.saveEventually()
            }
        }
        
        return habits
    }
    
    class func saveDefaultHabits(user: KMUser) -> KMUserHabits!{
        let userHabits = KMUserHabits()
        userHabits.user = user
        userHabits.stillSmoking = true
        userHabits.smokedPerDay = 20
        userHabits.smokingYears = KM_DATE_CURRENT_YEAR
        userHabits.priceForOnePackage = 20.0
        userHabits.nicotineLevel = NicotineLevel_Ultra_Light
        userHabits.birthYear = KM_DATE_CURRENT_YEAR - 18
        
        return userHabits
    }
    
    class func updateUserHabits(habits: KMUserHabits){
        let query = KMUserHabits.query()
        query.whereKey("user", equalTo: habits.user)

        var error: NSError?
        let remoteHabits = query.getFirstObject(&error) as! KMUserHabits!
        
        if remoteHabits == nil && (error == nil || (error != nil && error!.code == kAVErrorObjectNotFound)){
            habits.saveEventually()
        }else if remoteHabits != nil && error == nil{
            if remoteHabits.objectId == habits.objectId{
                habits.saveEventually()
            }else{
                remoteHabits.stillSmoking = habits.stillSmoking
                remoteHabits.smokedPerDay = habits.smokedPerDay
                remoteHabits.smokingYears = habits.smokingYears
                remoteHabits.priceForOnePackage = habits.priceForOnePackage
                remoteHabits.nicotineLevel = habits.nicotineLevel
                remoteHabits.birthYear = habits.birthYear
                
                remoteHabits.saveEventually()
            }
        }else if error == nil{
            JDStatusBarNotification.showWithStatus("同步用户吸烟习惯失败", dismissAfter: KM_JD_VIEW_SHOW_TIME)
            SVProgressHUD.showErrorWithStatus("同步用户吸烟习惯失败:\(error!.localizedDescription)")
        }
    }
    
    // 判断今天是否能吸烟
    class func canSmokingToday(habits: KMUserHabits) -> Bool{
        var result = true
        
        let todayStr = KimreeDateTool.currentDateString()
        
        let stillSmoking = habits.stillSmoking
        let nonSmokeSince = habits.nonSmokeSince
        
        if stillSmoking == false{
            let todayDate = KimreeDateTool.dateFromString(todayStr)
            let nonSmokeDate = KimreeDateTool.dateFromString(nonSmokeSince!)
            
            if todayDate.compare(nonSmokeDate) != NSComparisonResult.OrderedAscending{
                result = false
            }
        }
                
        return result
    }
    
}
