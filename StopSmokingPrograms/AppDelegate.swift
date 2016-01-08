//
//  AppDelegate.swift
//  StopSmokingPrograms
//
//  Created by Fran on 15/10/6.
//  Copyright © 2015年 kimree. All rights reserved.
//

import UIKit
import Fabric
import Crashlytics


// 如果将下面 @UIApplicationMain 的注释去掉, 需要删除 main.swift 文件
//@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, CLLocationManagerDelegate {
    
    var window: UIWindow?
    var parallaxView: ACParallaxView?
    
    var loginUser: KMUser?
    
    // MARK: - 用户抽烟习惯， readonly属性
    private var loginUserHabits: KMUserHabits?
    var userHabits: KMUserHabits{
        get{
            if loginUserHabits == nil{
                loginUserHabits = KMUserHabitsHelper.getUserHabits(loginUser!)
            }
            return loginUserHabits!
        }
    }
    
    // MARK: - 在其他对象里面获取时，不能直接获取，需要通过提供的 get 方法
    private var userActionRecotd: KMUserActionRecord?
    var todayActionRecord: KMUserActionRecord{
        get{
            if userActionRecotd == nil{
                userActionRecotd = KMUserActionRecordHelper.getUserActionRecord(loginUser!, habits: userHabits)
            }else{
                let todayDate = KimreeDateTool.dateFromString(KimreeDateTool.currentDateString())
                if !todayDate.isEqualToDate(userActionRecotd!.historyDate!){
                    userActionRecotd = KMUserActionRecordHelper.getUserActionRecord(loginUser!, habits: userHabits)
                }
            }
            
            return userActionRecotd!
        }
    }
    
    // MARK: - 定位
    var locationManager: CLLocationManager!
    private var locationUpdateBlock: ((location: CLLocation) -> Void)?
    
    // MARK: - appdelegate
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        
        // 启动崩溃监测
        Fabric.with([Crashlytics.self])
        
        // LeanCloud, first of all
        // 自定义的model必须写在 setApplicationId 前面
        KMUser.registerSubclass()
        KMUserFeedback.registerSubclass()
        KMUserHabits.registerSubclass()
        KMUserActionRecord.registerSubclass()
        KMUserActionRecordInfo.registerSubclass()
        AVOSCloud.setApplicationId(KM_LEAN_CLOUD_APP_ID, clientKey: KM_LEAN_CLOUD_APP_KEY)
        AVCloud.setProductionMode(true)
        
        // 开启定位服务， 要在进入任何viewcontroller之前只需
        setUpLocation()
        
        self.window = UIWindow(frame: KM_FRAME)
        self.window?.backgroundColor = UIColor.whiteColor()
        self.window?.makeKeyAndVisible()
        
        // 自动登录需要最先处理，登录情况决定了 self.window?.rootViewController 显示哪一个
        autoLogin()
        
        // 视差特效, 加在 appdelegate 的 window下面， 其他所有界面只要view设置透明度之后，都可以看到
        parallaxView = ACParallaxView(frame: KM_FRAME)
        let imageView = UIImageView(frame: KM_FRAME)
        imageView.image = UIImage(named: "background")
        parallaxView!.addSubview(imageView)
        parallaxView!.parallax = true
        parallaxView!.refocusParallax = true
        self.window?.insertSubview(parallaxView!, atIndex: 0)
        
        // SVProgressHUD 样式设置
        SVProgressHUD.setDefaultStyle(SVProgressHUDStyle.Light)
        SVProgressHUD.setDefaultMaskType(SVProgressHUDMaskType.Black)
        SVProgressHUD.setMinimumDismissTimeInterval(3)
        
        //设置状态栏通知样式
        JDStatusBarNotification.setDefaultStyle { (style: JDStatusBarStyle!) -> JDStatusBarStyle! in
            style.barColor = UIColor.blackColor()
            style.textColor = UIColor.whiteColor()
            style.animationType = JDStatusBarAnimationType.Move
            style.font = UIFont.systemFontOfSize(12.0)
            return style
        }
        
        // 影响不大的功能可以异步处理, 加快界面显示速度
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) { [weak self]() -> Void in
            
            // 启动网络监控
            self?.networkMonitoring()
            
            // 检查更新
            self?.checkForUpdate()
                        
        }
        
        return true
    }
    
    
    // MARK: - 开启定位服务
    func setUpLocation(){
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 10.0
        
        if CLLocationManager.locationServicesEnabled() && CLLocationManager.authorizationStatus() != CLAuthorizationStatus.Denied && CLLocationManager.authorizationStatus() != CLAuthorizationStatus.Restricted{
            if #available(iOS 8.0, *) {
                locationManager.requestWhenInUseAuthorization()
                locationManager.requestAlwaysAuthorization()
            }
        }else{
            let alert = UIAlertView(title: "请开启定位服务", message: "点击 \"设置\"→\"隐私\"→\"定位服务\" 开启定位服务", delegate: nil, cancelButtonTitle: "确定", otherButtonTitles: "知道了")
            alert.showAlertViewWithCompleteBlock({ (buttonIndex) -> Void in
                if buttonIndex == 0{
                    UIApplication.sharedApplication().openURL(NSURL(string: UIApplicationOpenSettingsURLString)!)
                }
            })
        }
        
    }
    
    func recordLocation(userActionRecord: KMUserActionRecord){
        locationUpdateBlock = {(location: CLLocation) in
            let hour = (KimreeDateTool.dateStringWithDate(NSDate(), dateFormatString: "HH") as NSString).integerValue
            let latitude = location.coordinate.latitude
            let longitude = location.coordinate.longitude
            
            let recordInfo = KMUserActionRecordInfo()
            recordInfo.user = userActionRecord.user
            recordInfo.record = userActionRecord
            recordInfo.hour = hour
            recordInfo.latitude = latitude
            recordInfo.longitude = longitude
            KMUserActionRecordInfoHelper.updateRecordInfo(recordInfo)
        }
        locationManager.startUpdatingLocation()
    }
    
    // MARK: - CLLocationManagerDelegate
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        KMLog("didUpdateLocations")
        manager.stopUpdatingLocation()
        locationUpdateBlock?(location: locations.first!)
        locationUpdateBlock = nil
    }
    
    // MARK: - 自动登录(登录和注销都要在appdelegate内处理)
    // 自动登录需要最先处理，登录情况决定了 self.window?.rootViewController 显示哪一个
    func autoLogin(){
        let loginProof = LocalStorage.shareLocalStorage().getObject(KM_STORAGE_USER_LOGIN_PROOF, searchPathDirectory: NSSearchPathDirectory.DocumentDirectory) as? NSDictionary
        if loginProof == nil{
            changeRootViewControllerWithLoginStatus(false)
        }else{
            let userName = loginProof!["userName"] as! String
            let password = loginProof!["password"] as! String
            loginWithUserName(userName, password: password)
        }
        
    }
    
    // 根据给定的用户名和密码登陆
    // changeRootVCWhenLoginFail, 登录失败后是否需要切换rootVC， 自动登录时需要切换， 如果在登录界面登录，点击登录按钮后登录失败则不需要切换
    // 登录成功后是一定会切换rootVC的
    func loginWithUserName(userName: String, password: String, changeRootVCWhenLoginFail: Bool = true){
        let user = KMUserHelper.loginWithUserName(userName, password: password)
        if user != nil{
            // 要立刻设置 loginUser, 后续步骤可能需要使用到
            self.loginUser = user
            
            // 登陆成功后保存登陆凭据
            let loginProof = NSMutableDictionary()
            loginProof.setObject(userName, forKey: "userName")
            loginProof.setObject(password, forKey: "password")
            LocalStorage.shareLocalStorage().addObject(loginProof, fileName: KM_STORAGE_USER_LOGIN_PROOF, searchPathDirectory: NSSearchPathDirectory.DocumentDirectory)
            
            changeRootViewControllerWithLoginStatus(true)
            
        }else{
            if changeRootVCWhenLoginFail{
                changeRootViewControllerWithLoginStatus(false)
            }
        }
    }
    
    // 修改 rootViewController( 登录 注销)
    // 根据登录情况设置 appdelegate.window 的 rootViewController, 这样可以避免 pop 或者 dismiss 返回跳转前的vc
    func changeRootViewControllerWithLoginStatus(isLogin: Bool){
        let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let loginSBName = isLogin ? "main" : "login"
        let rootVC = mainStoryboard.instantiateViewControllerWithIdentifier(loginSBName)
        self.window?.rootViewController = rootVC
        
        // 注销登录时,需要清清除之前的登录信息
        if !isLogin{
            self.loginUser = nil
            self.loginUserHabits = nil
            self.userActionRecotd = nil
        }
    }
    
    // MARK: - 网络监控
    func networkMonitoring(){
        let manager = KM_NET_MANAGER
        manager.reachabilityManager.setReachabilityStatusChangeBlock { (status: AFNetworkReachabilityStatus) -> Void in
            switch status{
            case .NotReachable:
                JDStatusBarNotification.showWithStatus("Network NotReachable", dismissAfter: KM_JD_VIEW_SHOW_TIME)
            case .ReachableViaWiFi:
                //                JDStatusBarNotification.showWithStatus("Network ReachableViaWiFi", dismissAfter: KM_JD_VIEW_SHOW_TIME)
                KMLog("Network ReachableViaWiFi")
            case .ReachableViaWWAN:
                //                JDStatusBarNotification.showWithStatus("Network ReachableViaWWAN", dismissAfter: KM_JD_VIEW_SHOW_TIME)
                KMLog("Network ReachableViaWWAN")
            case .Unknown:
                JDStatusBarNotification.showWithStatus("Network Unknown", dismissAfter: KM_JD_VIEW_SHOW_TIME)
            }
        }
        manager.reachabilityManager.startMonitoring()
    }
    
    // MARK: - 检查更新
    /**
    判断版本是否需要跟新
    
    版本号为 xx.xx.xx格式，需要分段进行比较
    */
    func checkForUpdate(){
        if KM_VERSION_NEED_UPDATE{
            
            // 界面显示要回到主线程处理
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                let alert = UIAlertView(title: "版本更新", message: "您可以更新到最新的版本!", delegate: nil, cancelButtonTitle: "取消", otherButtonTitles: "确定")
                alert.showAlertViewWithCompleteBlock({ (buttonIndex) -> Void in
                    if buttonIndex == 1{
                        UIApplication.sharedApplication().openURL(NSURL(string: KM_API_APP_STORE_UPDATE)!)
                    }
                })
            })
        }
    }
    
    // MARK: - app delegate
    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
}

