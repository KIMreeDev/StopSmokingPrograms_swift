//
//  KMUserActionRecordInfo.swift
//  StopSmokingPrograms
//
//  Created by Fran on 15/11/5.
//  Copyright © 2015年 kimree. All rights reserved.
//

import UIKit

class KMUserActionRecordInfo: AVObject, AVSubclassing {

    @NSManaged var user: KMUser?
    @NSManaged var record: KMUserActionRecord?
    
    // 抽烟时间， 小时
    @NSManaged var hour: Int
    
    // 经度纬度, 参照高德地图坐标系
    @NSManaged var latitude: Double
    @NSManaged var longitude: Double
    
    static func parseClassName() -> String! {
        return "kimree_user_action_record_info"
    }
}
