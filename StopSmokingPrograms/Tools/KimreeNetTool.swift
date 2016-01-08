//
//  KimreeNetTool.swift
//  StopSmokingPrograms
//
//  Created by Fran on 15/10/7.
//  Copyright © 2015年 kimree. All rights reserved.
//

import UIKit

// MARK: - network manager
var KM_NET_MANAGER: AFHTTPRequestOperationManager{
    get{
        let manager = AFHTTPRequestOperationManager()
        manager.requestSerializer = AFJSONRequestSerializer()
        manager.responseSerializer = AFJSONResponseSerializer()
        let contentTypes: Set = ["application/json", "text/json", "text/javascript","text/html", "application/x-javascript"]
        manager.responseSerializer.acceptableContentTypes = contentTypes
        manager.requestSerializer.timeoutInterval = 10
        return manager
    }
}
