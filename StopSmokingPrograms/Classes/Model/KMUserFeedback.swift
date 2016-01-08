//
//  KMUserFeedback.swift
//  StopSmokingPrograms
//
//  Created by Fran on 15/10/14.
//  Copyright © 2015年 kimree. All rights reserved.
//

import UIKit

class KMUserFeedback: AVObject, AVSubclassing {
    
    @NSManaged var user: KMUser?
    @NSManaged var content: String?
    
    static func parseClassName() -> String! {
        return "kimree_user_feedback"
    }
}
