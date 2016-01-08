//
//  KMTodayCircleView.swift
//  StopSmokingPrograms
//
//  Created by Fran on 15/10/28.
//  Copyright © 2015年 kimree. All rights reserved.
//

import UIKit

class KMTodayCircleView: UIView {

    var circleEndAngleRatio: CGFloat = 1
    var circleBackgroundColor = UIColor.whiteColor()
    var circleChnagedColor = UIColor.greenColor()
    
    var circleWidth: CGFloat = 10
    var circleR: CGFloat = 0
    
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        let startAngle: CGFloat = -90
        
        let centerX = rect.size.width / 2.0
        let centerY = rect.size.height / 2.0
        
        //获取画笔上下文
        let context = UIGraphicsGetCurrentContext()
        
        //抗锯齿设置
        CGContextSetAllowsAntialiasing(context, true)
        
        CGContextSetLineWidth(context, circleWidth)
        

        CGContextSetStrokeColorWithColor(context, circleBackgroundColor.CGColor)
        CGContextAddArc(context, centerX, centerY, circleR, startAngle * CGFloat(M_PI / 180), (360 + startAngle) * CGFloat(M_PI / 180), 0)
        CGContextStrokePath(context)
        
        CGContextSetStrokeColorWithColor(context, circleChnagedColor.CGColor)
        CGContextAddArc(context, centerX, centerY, circleR, startAngle * CGFloat(M_PI / 180), (startAngle + circleEndAngleRatio * 360) * CGFloat(M_PI / 180), 0)
        CGContextStrokePath(context)
    }

}
