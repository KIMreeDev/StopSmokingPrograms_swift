//
//  MainViewController.swift
//  StopSmokingPrograms
//
//  Created by Fran on 15/10/8.
//  Copyright © 2015年 kimree. All rights reserved.
//

import UIKit

// 功能命名, 方便判断
let FeatureTitle_Today = "今日动态"
let FeatureTitle_Habits = "吸烟习惯"
let FeatureTitle_History = "历史记录"
let FeatureTitle_Health = "健康状况"
let FeatureTitle_Setting = "设置"

// 界面设置默认值
let Radius_Limit: CGFloat = 1000
let AngularSpacing_Limit: CGFloat = 20
let XOffset_Limite: CGFloat = 320
let Width_Limit: CGFloat = 320
let Height_Limit: CGFloat = 120

class MainViewController: BasicViewController, UITableViewDataSource, UITableViewDelegate, UIGestureRecognizerDelegate, UICollectionViewDataSource, UICollectionViewDelegate{
    
    // Important, 记录当前显示在最前端的cellItem下标
    private var currentSelectIndex: Int = 0
    
    @IBOutlet weak var version: UILabel!
    
    @IBOutlet weak var collectionMenu: UICollectionView!
    private var collectionMenuLayout: AWCollectionViewDialLayout!
    
    @IBOutlet weak var rightButton: UIButton!
    private var menuSetting: MainMenuSetting?
    
    private let circleData:[(title: String, imageName: String, color: UIColor)] = [
        (FeatureTitle_Today, "FeatureTitle_Today", RGB(116, 114, 119)),
        (FeatureTitle_Habits, "FeatureTitle_Habits", RGB(112, 83, 143)),
        (FeatureTitle_History, "FeatureTitle_History", RGB(153, 170, 84)),
        (FeatureTitle_Health, "FeatureTitle_Health", RGB(225, 99, 71)),
        (FeatureTitle_Setting, "FeatureTitle_Setting", RGB(64, 99, 173))
    ]
    
    private var slideView: UIView?
    private var slideIndexTableView: UITableView?
    private var slideDistance = KM_FRAME_WIDTH - 100
    private var normalTransform = CGAffineTransformMakeScale(1.0, 1.0)
    private var scaleTransform = CGAffineTransformMakeScale(0.8, 0.8)
    
    private var userMainMenuDefaultSetting: NSMutableDictionary = NSMutableDictionary()
    
    // 加载其他Storyboard时候，第一次会比较慢
    // lazy 必须配合 var 使用, 没有 lazy let
    private lazy var todayStoryboard = UIStoryboard(name: "Today", bundle: nil)
    private lazy var habitsStoryboard = UIStoryboard(name: "Habits", bundle: nil)
    private lazy var historyStoryboard = UIStoryboard(name: "History", bundle: nil)
    private lazy var healthStoryboard = UIStoryboard(name: "Health", bundle: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        
        KMLog("MainViewController")
        
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            // 调用一次数据信息，加载必要数据
            KM_APP_DELEGATE.userHabits
            KM_APP_DELEGATE.todayActionRecord
        }
        
        loadDefaultSetting()
        buildMainView()
    }
    
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        setUpSlideView()
        
        collectionMenu.userInteractionEnabled = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Main界面默认设置
    func loadDefaultSetting(){
        let defaultSetting = LocalStorage.shareLocalStorage().getObject(KM_STORAGE_USER_MAIN_MENU_SETTING, searchPathDirectory: NSSearchPathDirectory.DocumentDirectory)
        if defaultSetting != nil{
            userMainMenuDefaultSetting = defaultSetting as? NSMutableDictionary ?? NSMutableDictionary()
        }
        if userMainMenuDefaultSetting.objectForKey("radius") == nil{
            userMainMenuDefaultSetting.setObject(CGFloat(500), forKey: "radius")
        }
        if userMainMenuDefaultSetting.objectForKey("angularSpacing") == nil{
            userMainMenuDefaultSetting.setObject(CGFloat(10), forKey: "angularSpacing")
        }
        if userMainMenuDefaultSetting.objectForKey("xOffset") == nil{
            userMainMenuDefaultSetting.setObject(CGFloat(160), forKey: "xOffset")
        }
        if userMainMenuDefaultSetting.objectForKey("height") == nil{
            userMainMenuDefaultSetting.setObject(CGFloat(80), forKey: "height")
        }
        if userMainMenuDefaultSetting.objectForKey("width") == nil{
            userMainMenuDefaultSetting.setObject(CGFloat(230), forKey: "width")
        }
    }
    
    func buildMainView(){
        version.text = "版本信息 : " + KM_LOCAL_VERSION
        
        collectionMenu.registerNib(UINib(nibName: "MainMenuCell", bundle: nil), forCellWithReuseIdentifier: "MainMenuCell")
        
        let radius: CGFloat = userMainMenuDefaultSetting.objectForKey("radius") as! CGFloat
        let angularSpacing: CGFloat = userMainMenuDefaultSetting.objectForKey("angularSpacing") as! CGFloat
        let xOffset: CGFloat = userMainMenuDefaultSetting.objectForKey("xOffset") as! CGFloat
        let cellHeight: CGFloat = userMainMenuDefaultSetting.objectForKey("height") as! CGFloat
        let cellWidth: CGFloat = userMainMenuDefaultSetting.objectForKey("width") as! CGFloat
        
        collectionMenuLayout = AWCollectionViewDialLayout(radius: radius, andAngularSpacing: angularSpacing, andCellSize: CGSizeMake(cellWidth, cellHeight), andAlignment: WHEELALIGNMENTCENTER, andItemHeight: cellHeight, andXOffset: xOffset)
        collectionMenu.collectionViewLayout = collectionMenuLayout
        
        // 编辑状态时, tag 为11;  非编辑状态， tag 为10
        // 进入界面后, tag 默认为 10
        rightButton.tag = 10
        rightButton.setTitle("编辑", forState: UIControlState.Normal)
        rightButton.setTitleColor(KM_COLOR_NAVIGATION_BAR_BUTTON_ITEM, forState: UIControlState.Normal)
    }
    
    // MARK: - MainMenuSetting
    @IBAction func mainMenuSettingClick(sender: UIButton){
        slideBack()
        let tag = sender.tag
        if tag == 10{
            showMainMenuSetting()
            sender.tag = 11
            rightButton.setTitle("关闭", forState: UIControlState.Normal)
        }else if tag == 11{
            closeMainMenuSetting()
            rightButton.tag = 10
            rightButton.setTitle("编辑", forState: UIControlState.Normal)
        }
    }
    
    // 隐藏菜单设置界面
    func closeMainMenuSetting(){
        UIView.beginAnimations("closeMainMenuSetting", context: nil)
        UIView.setAnimationDelay(0.3)
        
        menuSetting?.frame = CGRectMake(0, KM_FRAME_HEIGHT, KM_FRAME_WIDTH, KM_FRAME_HEIGHT)
        
        UIView.commitAnimations()
    }
    
    // 显示菜单设置界面
    func showMainMenuSetting(){
        if menuSetting == nil{
            setUpMainMenuSetting()
        }
        
        UIView.beginAnimations("showMainMenuSetting", context: nil)
        UIView.setAnimationDelay(0.3)
        
        menuSetting?.frame = CGRectMake(0, 0, KM_FRAME_WIDTH, KM_FRAME_HEIGHT)
        
        UIView.commitAnimations()
        
    }
    
    // 初始化菜单设置界面
    func setUpMainMenuSetting(){
        menuSetting = MainMenuSetting.instanceFromNib()
        menuSetting?.frame = CGRectMake(0, KM_FRAME_HEIGHT, KM_FRAME_WIDTH, KM_FRAME_HEIGHT)
        self.view.addSubview(menuSetting!)
        self.view.bringSubviewToFront(menuSetting!)
        self.view.bringSubviewToFront(rightButton)
        
        let radius = collectionMenuLayout.dialRadius
        let angularSpacing = collectionMenuLayout.AngularSpacing
        let xOffset = collectionMenuLayout.xOffset
        let width = collectionMenuLayout.cellSize.width
        let height = collectionMenuLayout.itemHeight
        
        changeMenuSettingLabelAndSliderWithRadius(radius, angularSpacing: angularSpacing, xOffset: xOffset, width: width, height: height)
        
        menuSetting?.radiusSlider.addTarget(self, action: "updateMenuSetting", forControlEvents: UIControlEvents.ValueChanged)
        menuSetting?.angularSpacingSlider.addTarget(self, action: "updateMenuSetting", forControlEvents: UIControlEvents.ValueChanged)
        menuSetting?.xOffsetSlider.addTarget(self, action: "updateMenuSetting", forControlEvents: UIControlEvents.ValueChanged)
        menuSetting?.widthSlider.addTarget(self, action: "updateMenuSetting", forControlEvents: UIControlEvents.ValueChanged)
        menuSetting?.heightSlider.addTarget(self, action: "updateMenuSetting", forControlEvents: UIControlEvents.ValueChanged)
    }
    
    // 滑动 slider 触发的事件
    func updateMenuSetting(){
        let radius: CGFloat = CGFloat(menuSetting!.radiusSlider.value) * Radius_Limit
        let angularSpacing: CGFloat = CGFloat(menuSetting!.angularSpacingSlider.value) * AngularSpacing_Limit
        let xOffset: CGFloat = CGFloat(menuSetting!.xOffsetSlider.value) * XOffset_Limite
        let width: CGFloat = CGFloat(menuSetting!.widthSlider.value) * Width_Limit
        let height: CGFloat = CGFloat(menuSetting!.heightSlider.value) * Height_Limit
        
        changeMenuSettingLabelAndSliderWithRadius(radius, angularSpacing: angularSpacing, xOffset: xOffset, width: width, height: height)
        
        collectionMenuLayout.dialRadius = radius
        collectionMenuLayout.AngularSpacing = angularSpacing
        collectionMenuLayout.xOffset = xOffset
        collectionMenuLayout.cellSize = CGSizeMake(width, height)
        collectionMenuLayout.itemHeight = height
        collectionMenuLayout.invalidateLayout()
        
        self.collectionMenu.reloadData()
        
        // 保证当前选中的cell还是显示在最前
        // 在layout数据变化过程中, index动态计算不准确, 只能采取这种全局变量记录的方式
        self.viewDidScrollToCellIndex(collectionMenu, index: currentSelectIndex)
        self.collectionMenu.userInteractionEnabled = true
    }
    
    // 修改界面设置的数据
    func changeMenuSettingLabelAndSliderWithRadius(radius: CGFloat, angularSpacing: CGFloat, xOffset: CGFloat, width: CGFloat, height: CGFloat){
        let radius = CGFloat(NSString(format: "%.0f", radius).floatValue)
        menuSetting?.radiusLabel.text = "Radius：\(radius)"
        menuSetting?.radiusSlider.value = Float(radius / Radius_Limit)
        
        let angularSpacing = CGFloat(NSString(format: "%.0f", angularSpacing).floatValue)
        menuSetting?.angularSpacingLabel.text = "Angular spacing：\(angularSpacing)"
        menuSetting?.angularSpacingSlider.value = Float(angularSpacing / AngularSpacing_Limit)
        
        let xOffset = CGFloat(NSString(format: "%.0f", xOffset).floatValue)
        menuSetting?.xOffsetLabel.text = "X offset：\(xOffset)"
        menuSetting?.xOffsetSlider.value = Float(xOffset / XOffset_Limite)
        
        let width = CGFloat(NSString(format: "%.0f", width).floatValue)
        menuSetting?.widthLabel.text = "Width：\(width)"
        menuSetting?.widthSlider.value = Float(width / Width_Limit)
        menuSetting?.widthSlider.minimumValue = Float(height * 2 / Width_Limit)
        
        let height = CGFloat(NSString(format: "%.0f", height).floatValue)
        menuSetting?.heightLabel.text = "Height：\(height)"
        menuSetting?.heightSlider.value = Float(height / Height_Limit)
        menuSetting?.heightSlider.minimumValue = Float(50 / Height_Limit)
        
        // 本地持久化
        userMainMenuDefaultSetting.setObject(radius, forKey: "radius")
        userMainMenuDefaultSetting.setObject(angularSpacing, forKey: "angularSpacing")
        userMainMenuDefaultSetting.setObject(xOffset, forKey: "xOffset")
        userMainMenuDefaultSetting.setObject(width, forKey: "width")
        userMainMenuDefaultSetting.setObject(height, forKey: "height")
        LocalStorage.shareLocalStorage().addObject(userMainMenuDefaultSetting, fileName: KM_STORAGE_USER_MAIN_MENU_SETTING, searchPathDirectory: NSSearchPathDirectory.DocumentDirectory)
        
    }
    
    // MARK: - UICollectionViewDataSource
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return circleData.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("MainMenuCell", forIndexPath: indexPath) as! MainMenuCell
        
        cell.backgroundColor = UIColor.clearColor()
        
        cell.imageView.layer.masksToBounds = true
        cell.imageView.layer.cornerRadius = collectionMenuLayout.itemHeight / 2.0
        
        cell.titleLabel.font = UIFont.systemFontOfSize(20)
        cell.titleLabel.backgroundColor = RGBA(0, 0, 0, 0.5)
        cell.titleLabel.textColor = UIColor.whiteColor()
        
        let data = circleData[indexPath.row]
        let title = data.title
        let imageName = data.imageName
        let color = data.color
        
        cell.titleLabel.text = title
        cell.imageView.image = UIImage(named: imageName)
        cell.imageView.backgroundColor = color
        
        return cell
    }
    
    // MARK: - UICollectionViewDelegate
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        KMLog("didSelectItemAtIndexPath : \(indexPath)")
        
        if indexPath.row == currentSelectIndex{
            if collectionView.frame.origin.x >= 0{
                let index = indexPath.row
                let data = circleData[index]
                let title = data.title
                
                // 避免双击， 在 prepareForSegue 打开界面之后，重新设置为true
                collectionView.userInteractionEnabled = false
                
                // 自定义一个 UIStoryboardSegue, 使界面跳转走 prepareForSegue 流程, 在 prepareForSegue 进行统一管理
                if title == FeatureTitle_Today{
                    let toVC = todayStoryboard.instantiateInitialViewController()
                    let segue = UIStoryboardSegue(identifier: FeatureTitle_Today, source: self, destination: toVC!)
                    self.prepareForSegue(segue, sender: self)
                    
                }else if title == FeatureTitle_Habits{
                    let toVC = habitsStoryboard.instantiateInitialViewController()
                    let segue = UIStoryboardSegue(identifier: FeatureTitle_Habits, source: self, destination: toVC!)
                    self.prepareForSegue(segue, sender: self)
                    
                }else if title == FeatureTitle_History{
                    let toVC = historyStoryboard.instantiateInitialViewController()
                    let segue = UIStoryboardSegue(identifier: FeatureTitle_History, source: self, destination: toVC!)
                    self.prepareForSegue(segue, sender: self)
                    
                }else if title == FeatureTitle_Health{
                    let toVC = healthStoryboard.instantiateInitialViewController()
                    let segue = UIStoryboardSegue(identifier: FeatureTitle_Health, source: self, destination: toVC!)
                    self.prepareForSegue(segue, sender: self)
                    
                }else if title == FeatureTitle_Setting{
                    collectionView.userInteractionEnabled = true
                    showSettingView()
                }
            }else{
                slideBack()
            }
            
        }else{
            viewDidScrollToCellIndex(collectionView, index: indexPath.row)
        }
    }
    
    
    // MARK: - collectionView 滑动代理
    // 注意 MainViewController 中的 UICollectionView 和 UITableView 都会走这个代理, 需要进行区分
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        // 在滑动结束前， 不允许第二次点击cell
        if scrollView is UICollectionView{
            scrollView.userInteractionEnabled = false
        }
    }
    
    // 滑动动画结束， 此时才可以进行点击操作
    func scrollViewDidEndScrollingAnimation(scrollView: UIScrollView) {
        // 滑动结束后才可以再次点击cell
        if scrollView is UICollectionView{
            KMLog("scrollViewDidEndScrollingAnimation")
            scrollView.userInteractionEnabled = true
        }
        
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if scrollView is UICollectionView{
            scrollView.userInteractionEnabled = false
        }
    }
    
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        if scrollView is UICollectionView{
            viewDidEndScroll(scrollView)
        }
    }
    
    func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if scrollView is UICollectionView{
            viewDidEndScroll(scrollView)
        }
    }
    
    // MARK: - 将点击的 cell 在最前面显示
    func viewDidEndScroll(scrollView: UIScrollView){
        let y = scrollView.contentOffset.y
        let cellHeight = collectionMenuLayout.itemHeight
        var index: Int = Int(y / cellHeight)
        let indexLeft = y % cellHeight
        
        if indexLeft >= cellHeight / 2.0{
            index++
        }
        viewDidScrollToCellIndex(scrollView, index: index)
        
        scrollView.userInteractionEnabled = true
    }
    
    func viewDidScrollToCellIndex(scrollView: UIScrollView, index: Int){
        // 在滑动结束前， 不允许第二次点击cell
        scrollView.userInteractionEnabled = false
        
        let cellHeight = collectionMenuLayout.itemHeight
        let offsetY = cellHeight * CGFloat(index)
        var newOffset = scrollView.contentOffset
        newOffset.y = offsetY
        scrollView.setContentOffset(newOffset, animated: true)
        
        self.currentSelectIndex = index
    }
    
    // MARK: - 显示侧滑界面
    func showSettingView(){
        if slideView == nil{
            setUpSlideView()
        }
        
        resetSlideView()
        slideLeft()
    }
    
    func resetSlideView(){
        slideView?.frame = CGRectMake(KM_FRAME_WIDTH, 0, slideDistance, KM_FRAME_HEIGHT)
        slideView?.transform = normalTransform
    }
    
    func slideLeft(){
        if  self.collectionMenu.frame.origin.x >= 0{
            
            UIView.beginAnimations("slideLeft", context: nil)
            UIView.setAnimationDuration(0.2)
            
            
            slideView?.frame = CGRectMake(KM_FRAME_WIDTH - slideDistance, 0, slideView!.frame.size.width, KM_FRAME_HEIGHT)
            slideView?.transform = scaleTransform
            
            self.collectionMenu.frame = CGRectMake(-slideDistance, 0, KM_FRAME_WIDTH, KM_FRAME_HEIGHT)
            self.collectionMenu.transform = scaleTransform
            
            UIView.commitAnimations()
        }
    }
    
    func slideBack(){
        if  self.collectionMenu.frame.origin.x < 0{
            
            UIView.beginAnimations("slideBack", context: nil)
            UIView.setAnimationDuration(0.2)
            
            slideView?.transform = normalTransform
            slideView?.frame = CGRectMake(KM_FRAME_WIDTH, 0, slideView!.frame.size.width, KM_FRAME_HEIGHT)
            
            
            self.collectionMenu.transform = normalTransform
            self.collectionMenu.frame = KM_FRAME
            
            UIView.commitAnimations()
        }
        
    }
    
    // MARK: - 搭建侧滑界面
    func setUpSlideView(){
        if slideView == nil{
            slideView = UIView(frame: CGRectMake(KM_FRAME_WIDTH, 0, slideDistance, KM_FRAME_HEIGHT))
            slideView?.backgroundColor = RGBA(0, 0, 0, 0.5)
            
            // navigation
            let navigationItem = UINavigationItem(title: "设置")
            navigationItem.leftBarButtonItem = UIBarButtonItem(title: "注销", style: UIBarButtonItemStyle.Plain, target: self, action: "logout")
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: "返回", style: UIBarButtonItemStyle.Plain, target: self, action: "slideBack")
            
            let navigationBarHeight: CGFloat = 64
            let navigationBar = UINavigationBar(frame: CGRectMake(0, 0, slideView!.frame.size.width, navigationBarHeight))
            navigationBar.setBackgroundImage(UIImage(), forBarMetrics: UIBarMetrics.Default)
            navigationBar.shadowImage = UIImage()
            navigationBar.tintColor = UIColor.whiteColor()
            navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
            
            navigationBar.shadowImage = imageWithColor(UIColor.whiteColor(), size: CGSizeMake(1, 1))
            navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: KM_COLOR_NAVIGATION_TITLE]
            navigationBar.tintColor = KM_COLOR_NAVIGATION_BAR_BUTTON_ITEM
            
            navigationBar.pushNavigationItem(navigationItem, animated: true)
            slideView?.addSubview(navigationBar)
            
            // tableView
            let tableView = UITableView(frame: CGRectMake(0, navigationBarHeight, slideView!.frame.size.width, slideView!.frame.size.height - navigationBarHeight), style: UITableViewStyle.Grouped)
            tableView.dataSource = self
            tableView.delegate = self
            tableView.tableHeaderView = UIView(frame: CGRectMake(0, 0, 0, CGFloat.min))
            tableView.backgroundColor = UIColor.clearColor()
            if #available(iOS 8.0, *){
                tableView.layoutMargins = UIEdgeInsetsZero
            }
            tableView.separatorInset = UIEdgeInsetsZero
            
            slideView?.addSubview(tableView)
            slideIndexTableView = tableView
            
            self.view.addSubview(slideView!)
            self.view.bringSubviewToFront(slideView!)
        }
    }
    
    // MARK: - 注销登录
    // 登录登出统一到 appDelegate 中进行处理
    func logout(){
        let alert = UIAlertView(title: "注销登录", message: "确定退出当前登录用户?", delegate: nil, cancelButtonTitle: "确定", otherButtonTitles: "取消")
        alert.showAlertViewWithCompleteBlock { [weak self](buttonIndex) -> Void in
            if buttonIndex == 0{
                self?.slideBack()
                KM_APP_DELEGATE.changeRootViewControllerWithLoginStatus(false)
            }
        }
    }
    
    // MARK: - UITableViewDataSource
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 6
    }
    
    // MARK: - UITableViewDelegate
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let identifier = "SlideViewCell"
        var cell = tableView.dequeueReusableCellWithIdentifier(identifier)
        if cell == nil{
            cell = UITableViewCell(style: UITableViewCellStyle.Value1, reuseIdentifier: identifier)
            
            cell?.imageView?.image = nil
            
            cell?.textLabel?.textAlignment = NSTextAlignment.Left
            cell?.textLabel?.textColor = UIColor.whiteColor()
            cell?.textLabel?.font = UIFont.systemFontOfSize(18)
            
            cell?.detailTextLabel?.textAlignment = NSTextAlignment.Right
            cell?.detailTextLabel?.textColor = UIColor.whiteColor()
            cell?.detailTextLabel?.font = UIFont.systemFontOfSize(14)
            
            cell?.selectionStyle = .None
            cell?.backgroundColor = UIColor.clearColor()
            
            if #available(iOS 8.0, *){
                cell!.layoutMargins = UIEdgeInsetsZero
            }
            cell!.separatorInset = UIEdgeInsetsZero
        }
        cell?.accessoryType = .DisclosureIndicator
        
        let row = indexPath.row
        switch row{
        case 0:
            cell?.textLabel?.text = "关于"
        case 1:
            cell?.textLabel?.text = "问题反馈"
        case 2:
            cell?.textLabel?.text = "清理缓存"
            cell?.detailTextLabel?.text = KMCacheTool.cacheSize
            cell?.accessoryType = .None
        case 3:
            cell?.textLabel?.text = "评论"
        case 4:
            cell?.textLabel?.text = "当前版本"
            cell?.detailTextLabel?.text = KM_LOCAL_VERSION
            cell?.accessoryType = .None
        case 5:
            cell?.textLabel?.text = "修改密码"
        default:
            KMLog("default")
        }
        
        return cell!
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let row = indexPath.row
        switch row{
        case 0:
            self.performSegueWithIdentifier("about", sender: self)
        case 1:
            self.performSegueWithIdentifier("feedback", sender: self)
        case 2:
            self.clearCache()
        case 3:
            self.comment()
        case 4:
            checkUpdate()
        case 5:
            self.performSegueWithIdentifier("changePassword", sender: self)
        default:
            KMLog("\(row)")
        }
    }
    
    // 清楚缓存
    func clearCache(){
        let alert = UIAlertView(title: "清除缓存", message: "确定清除缓存", delegate: nil, cancelButtonTitle: "取消", otherButtonTitles: "确定")
        alert.showAlertViewWithCompleteBlock { (buttonIndex) -> Void in
            if buttonIndex == 1{
                KMCacheTool.clearCache()
                self.slideIndexTableView?.reloadData()
            }
        }
    }
    
    // 评论
    func comment(){
        let alert = UIAlertView(title: "评论", message: "您确定要对软件进行评论?", delegate: nil, cancelButtonTitle: "取消", otherButtonTitles: "确定")
        alert.showAlertViewWithCompleteBlock({ (buttonIndex) -> Void in
            if buttonIndex == 1{
                UIApplication.sharedApplication().openURL(NSURL(string: KM_API_APP_COMMENT)!)
            }
        })
    }
    
    // 检查更新
    func checkUpdate(){
        if KM_VERSION_NEED_UPDATE{
            let alert = UIAlertView(title: "版本更新", message: "您可以更新到最新的版本!", delegate: nil, cancelButtonTitle: "取消", otherButtonTitles: "确定")
            alert.showAlertViewWithCompleteBlock({ (buttonIndex) -> Void in
                if buttonIndex == 1{
                    UIApplication.sharedApplication().openURL(NSURL(string: KM_API_APP_STORE_UPDATE)!)
                }
            })
        }else{
            //            let alert = UIAlertView(title: "版本更新", message: "您目前使用的是最新版本!", delegate: nil, cancelButtonTitle: "确定")
            //            alert.show()
        }
    }
    
    
    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        KMLog("prepareForSegue")
        self.slideBack()
        
        let fromVC = segue.sourceViewController
        let toVC = segue.destinationViewController
        
        if segue.identifier == FeatureTitle_Habits || segue.identifier == FeatureTitle_Today || segue.identifier == FeatureTitle_History || segue.identifier == FeatureTitle_Health{
            toVC.modalPresentationStyle = .FullScreen
            toVC.modalTransitionStyle = .CrossDissolve
            fromVC.presentViewController(toVC, animated: true, completion: {[weak self]() -> Void in
                self?.collectionMenu.userInteractionEnabled = true
                })
        }
    }
    
    
}
