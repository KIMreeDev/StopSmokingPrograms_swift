//
//  KMUser.swift
//  StopSmokingPrograms
//
//  Created by Fran on 15/10/8.
//  Copyright © 2015年 kimree. All rights reserved.
//

import UIKit

class KMUser: AVObject, AVSubclassing {
    
    @NSManaged var userName: String?
    @NSManaged var password: String?
    @NSManaged var email: String?
    
    static func parseClassName() -> String! {
        return "kimree_user"
    }
    
}
