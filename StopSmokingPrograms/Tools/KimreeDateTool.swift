//
//  KimreeDateTool.swift
//  StopSmokingPrograms
//
//  Created by Fran on 15/10/23.
//  Copyright © 2015年 kimree. All rights reserved.
//

import UIKit

class KimreeDateTool: NSObject {
    
    static var dateFormatString = "yyyy-MM-dd"
    
    class func currentDateString(dateFormatString: String = KimreeDateTool.dateFormatString) -> String{
        return dateStringWithDate(NSDate())
    }
    
    class func dateStringWithDate(date: NSDate, dateFormatString: String = KimreeDateTool.dateFormatString) -> String{
        let dateFormat = NSDateFormatter()
        dateFormat.dateFormat = dateFormatString
        
        return dateFormat.stringFromDate(date)
    }
    
    class func dateFromString(dateString: String, dateFormatString: String = KimreeDateTool.dateFormatString) -> NSDate{
        let dateFormat = NSDateFormatter()
        dateFormat.dateFormat = dateFormatString
        
        return dateFormat.dateFromString(dateString) ?? NSDate()
    }
    
}

var KM_DATE_CURRENT_YEAR: Int{
    get{
        let calendar = NSCalendar.currentCalendar()
        let components = calendar.components(NSCalendarUnit.Year, fromDate: NSDate())
        return components.year
    }
}


var KM_DATE_CURRENT_MONTH: Int{
    get{
        let calendar = NSCalendar.currentCalendar()
        let components = calendar.components(NSCalendarUnit.Month, fromDate: NSDate())
        return components.month
    }
}


var KM_DATE_CURRENT_DAY: Int{
    get{
        let calendar = NSCalendar.currentCalendar()
        let components = calendar.components(NSCalendarUnit.Day, fromDate: NSDate())
        return components.day
    }
}
