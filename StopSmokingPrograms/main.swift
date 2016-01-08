//
//  main.swift
//  StopSmokingPrograms
//
//  Created by Fran on 15/11/30.
//  Copyright © 2015年 kimree. All rights reserved.
//

import Foundation

KMLog("main.swift")


//这里把 UIApplication 换成你自定义的 Application，Process 枚举在Xcode6.3以上才定义。
//如果你正在使用Xcode6.2以下的版本，稍微替换一下UIApplicationMain函数中代码
//UIApplicationMain(C_ARGC, C_ARGV, NSStringFromClass(UIApplication), NSStringFromClass(AppDelegate))

UIApplicationMain(Process.argc, Process.unsafeArgv, NSStringFromClass(UIApplication), NSStringFromClass(AppDelegate))


