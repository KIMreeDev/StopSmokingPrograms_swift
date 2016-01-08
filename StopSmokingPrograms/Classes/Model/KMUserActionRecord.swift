//
//  KMUserActionRecord.swift
//  StopSmokingPrograms
//
//  Created by Fran on 15/10/27.
//  Copyright © 2015年 kimree. All rights reserved.
//

import UIKit

class KMUserActionRecord: AVObject, AVSubclassing {
    
    @NSManaged var user: KMUser?
    
    // 当前记录是哪一天的
    @NSManaged var historyDate: NSDate?
    
    @NSManaged var habitsNum: Int
    @NSManaged var smokedNum: Int
    
    // 当前习惯下，每包烟的价格
    @NSManaged var priceForOnePackage: Float
    
    static func parseClassName() -> String! {
        return "kimree_user_action_record"
    }
}
