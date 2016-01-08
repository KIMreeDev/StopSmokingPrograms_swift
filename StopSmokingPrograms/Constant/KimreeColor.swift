//
//  KimreeColor.swift
//  StopSmokingPrograms
//
//  Created by Fran on 15/10/7.
//  Copyright © 2015年 kimree. All rights reserved.
//

import UIKit


func RGBA(red: CGFloat, _ green: CGFloat, _ blue: CGFloat, _ alpha: CGFloat) -> UIColor{
    return UIColor(red: red / 255, green: green / 255, blue: blue / 255, alpha: alpha)
}

func RGB(red: CGFloat, _ green: CGFloat, _ blue: CGFloat) -> UIColor{
    return RGBA(red, green, blue, 1.0)
}

let KM_COLOR_NAVIGATION_TITLE = RGB(72, 201, 223)
let KM_COLOR_NAVIGATION_BAR_BUTTON_ITEM = RGB(255, 176, 0)

let KM_COLOR_BLACK_ALPHA = RGBA(0, 0, 0, 0.3)