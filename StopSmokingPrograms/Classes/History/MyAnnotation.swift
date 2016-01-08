//
//  MyAnnotation.swift
//  StopSmokingPrograms
//
//  Created by Fran on 15/11/12.
//  Copyright © 2015年 kimree. All rights reserved.
//

import UIKit

class MyAnnotation: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var subtitle: String?
    
    init(coordinate: CLLocationCoordinate2D, title: String?, subtitle: String?) {
        self.coordinate = coordinate
        self.title = title
        self.subtitle = subtitle
    }
}
