//
//  HistoryTabBarViewController.swift
//  StopSmokingPrograms
//
//  Created by Fran on 15/11/6.
//  Copyright © 2015年 kimree. All rights reserved.
//

import UIKit

class HistoryTabBarViewController: BasicTabBarViewController, UITabBarControllerDelegate {
    
    private struct RecordEntryDataStruct{
        static var data: [(key: AnyObject, value: AnyObject)]?
        static var token: dispatch_once_t = 0
    }
    
    private struct RecordInfoEntryDataStruct{
        static var data: [(key: AnyObject, value: AnyObject)]?
        static var token: dispatch_once_t = 0
    }
    
    // import 在deinit中需要将 struct 的token清零， 否则下次进入时, dispatch_once 不会执行
    deinit{
        RecordEntryDataStruct.token = 0
        RecordInfoEntryDataStruct.token = 0
        
        KMLog("HistoryTabBarViewController deinit")
    }
    
    private var lastThirtyDaysRecord = KMUserActionRecordHelper.getAllRecord(KM_APP_DELEGATE.loginUser!, limitDays: KM_HISTORY_RECORD_LIMIT_MAX_DAYS)
    var getLastThirtyDaysRecordSortedEntryArray: [(key: AnyObject, value: AnyObject)]{
        get{
            
            dispatch_once(&RecordEntryDataStruct.token) { () -> Void in
                RecordEntryDataStruct.data = self.sortDatas(self.lastThirtyDaysRecord)
            }
            
            return RecordEntryDataStruct.data!
        }
    }
    
    private var lastThirtyDaysRecordInfo = KMUserActionRecordInfoHelper.getAllRecordInfo(KM_APP_DELEGATE.loginUser!, limitDays: KM_HISTORY_RECORD_LIMIT_MAX_DAYS)
    var getLastThirtyDaysRecordInfoSortedEntryArray: [(key: AnyObject, value: AnyObject)]{
        get{
            
            dispatch_once(&RecordInfoEntryDataStruct.token) { () -> Void in
                RecordInfoEntryDataStruct.data = self.sortDatas(self.lastThirtyDaysRecordInfo)
            }
            
            return RecordInfoEntryDataStruct.data!
        }
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.delegate = self
                
        self.navigationController?.navigationBar.hidden = true
        
        self.tabBar.backgroundImage = imageWithColor(UIColor.whiteColor(), size: self.tabBar.bounds.size)
        self.tabBar.shadowImage = imageWithColor(KM_COLOR_BLACK_ALPHA, size: CGSizeMake(KM_FRAME_WIDTH, 1))
        self.tabBar.tintColor = KM_COLOR_NAVIGATION_BAR_BUTTON_ITEM
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - UITabBarControllerDelegate
    func tabBarController(tabBarController: UITabBarController, shouldSelectViewController viewController: UIViewController) -> Bool {
        var canSelect = true
        
        let allVC = tabBarController.viewControllers
        let selectVCIndex = tabBarController.selectedIndex
        let nextVCIndex = (allVC as NSArray?)?.indexOfObject(viewController) ?? 0
        
        if selectVCIndex == nextVCIndex{
            canSelect = false
        }
        
        if nextVCIndex == (allVC?.count ?? 0) - 1{
            canSelect = false
            self.dismissViewControllerAnimated(true, completion: nil)
        }
        
        return canSelect
    }
    
    // MARK: - record & recordInfo 数据获取方法
    func getLastRecordWithLimitDays(limitDays: Int) -> [(key: AnyObject, value: AnyObject)]{
        var sortedRecordEntryArray = [(key: AnyObject, value: AnyObject)]()
        if limitDays <= KM_HISTORY_RECORD_LIMIT_MAX_DAYS{
            sortedRecordEntryArray.appendContentsOf(getLastThirtyDaysRecordSortedEntryArray)
        }else{
            let allRecord = KMUserActionRecordHelper.getAllRecord(KM_APP_DELEGATE.loginUser!, limitDays: limitDays)
            sortedRecordEntryArray.appendContentsOf(sortDatas(allRecord))
        }
        
        var result = [(key: AnyObject, value: AnyObject)]()
        let minDate = KimreeDateTool.dateFromString(KimreeDateTool.dateStringWithDate(NSDate(timeIntervalSinceNow: -Double(limitDays - 1) * 24 * 60 * 60)))
        for entry in sortedRecordEntryArray{
            let date = entry.key as? NSDate
            if date?.compare(minDate) != NSComparisonResult.OrderedAscending{
                result.append(entry)
            }
        }
        
        return result
    }
    
    func getLastRecordInfoWithLimitDays(limitDays: Int) -> [(key: AnyObject, value: AnyObject)]{
        var sortedRecordInfoEntryArray = [(key: AnyObject, value: AnyObject)]()
        if limitDays <= KM_HISTORY_RECORD_LIMIT_MAX_DAYS{
            sortedRecordInfoEntryArray.appendContentsOf(getLastThirtyDaysRecordInfoSortedEntryArray)
        }else{
            let allRecordInfo = KMUserActionRecordInfoHelper.getAllRecordInfo(KM_APP_DELEGATE.loginUser!, limitDays: limitDays)
            sortedRecordInfoEntryArray.appendContentsOf(sortDatas(allRecordInfo))
        }
        
        var result = [(key: AnyObject, value: AnyObject)]()
        let minDate = KimreeDateTool.dateFromString(KimreeDateTool.dateStringWithDate(NSDate(timeIntervalSinceNow: -Double(limitDays - 1) * 24 * 60 * 60)))
        for entry in sortedRecordInfoEntryArray{
            let date = entry.key as? NSDate
            if date?.compare(minDate) != NSComparisonResult.OrderedAscending{
                result.append(entry)
            }
        }
        
        return result
    }
    
    private func sortDatas(recordOrRecordInfoDictionary: NSMutableDictionary) -> [(key: AnyObject, value: AnyObject)]{
        
        let elementArray = recordOrRecordInfoDictionary.sort { (element1: (key: AnyObject, value: AnyObject), element2: (key: AnyObject, value: AnyObject)) -> Bool in
            var sortResult = true
            let data1 = element1.key as? NSDate
            let data2 = element2.key as? NSDate
            
            if data1 != nil && data2 != nil{
                if data1?.compare(data2!) != NSComparisonResult.OrderedAscending{
                    sortResult = true
                }else{
                    sortResult = false
                }
            }
            
            return sortResult
        }
        
        return elementArray
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
