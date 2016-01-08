//
//  KMUserHabits.swift
//  StopSmokingPrograms
//
//  Created by Fran on 15/10/19.
//  Copyright © 2015年 kimree. All rights reserved.
//

import UIKit

let NicotineLevel_Ultra_Light = "<0.5"
let NicotineLevel_Light = "0.5-0.7"
let NicotineLevel_Regular = "0.7-1.0"
let NicotineLevel_Strong = ">1.0"

class KMUserHabits: AVObject, AVSubclassing {
    
    @NSManaged var user: KMUser?
    @NSManaged var stillSmoking: Bool
    @NSManaged var smokedPerDay: Int
    
    // 实际记录的是用户从哪一年开始吸烟， 根据当前年限和用户设置年份，计算实际烟龄
    @NSManaged var smokingYears: Int
    
    @NSManaged var priceForOnePackage: Float
    @NSManaged var nicotineLevel: String?
    
    // 同 smokingYears 一样
    @NSManaged var birthYear: Int
    
    @NSManaged var nonSmokeSince: String?
    
    static func parseClassName() -> String! {
        return "kimree_user_habits"
    }

}
