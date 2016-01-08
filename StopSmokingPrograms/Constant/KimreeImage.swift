//
//  KimreeImage.swift
//  StopSmokingPrograms
//
//  Created by Fran on 15/10/15.
//  Copyright © 2015年 kimree. All rights reserved.
//

import Foundation

//MARK: - 生成指定尺寸的纯色图片
func imageWithColor(color: UIColor!, size: CGSize) -> UIImage{
    var size = size
    if CGSizeEqualToSize(size, CGSizeZero){
        size = CGSizeMake(1, 1)
    }
    let rect = CGRectMake(0, 0, size.width, size.height)
    UIGraphicsBeginImageContext(rect.size)
    let context = UIGraphicsGetCurrentContext()
    CGContextSetFillColorWithColor(context, color.CGColor)
    CGContextFillRect(context, rect)
    
    let image = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    return image
}

//MARK: - 修改图片尺寸
func imageScaleToSize(image: UIImage, size: CGSize) -> UIImage{
    // 创建一个bitmap的context
    // 并把它设置成为当前正在使用的context
    // Determine whether the screen is retina
    if UIScreen.mainScreen().scale == 2.0{
        UIGraphicsBeginImageContextWithOptions(size, false, 2.0)
    }else{
        UIGraphicsBeginImageContext(size)
    }
    
    // 绘制改变大小的图片
    image.drawInRect(CGRectMake(0, 0, size.width, size.height))
    
    // 从当前context中创建一个改变大小后的图片
    let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
    
    // 使当前的context出堆栈
    UIGraphicsEndImageContext()
    
    // 返回新的改变大小后的图片
    return scaledImage
}

//MARK: - 压缩图片大小
func imageCompress(originalImage: UIImage) -> UIImage{
    guard let imageData = UIImageJPEGRepresentation(originalImage, 0.5) else{
        return originalImage
    }
    
    let compressImage = UIImage(data: imageData)!
    return compressImage
}

