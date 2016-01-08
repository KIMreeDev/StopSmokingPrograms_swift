//
//  HabitsViewController.swift
//  StopSmokingPrograms
//
//  Created by Fran on 15/10/19.
//  Copyright © 2015年 kimree. All rights reserved.
//

import UIKit

@objc protocol HabitsSettingChangeDelegate: NSObjectProtocol{
    optional func habitsSettingChanged(settingField: String, value: AnyObject?)
}

class HabitsViewController: HabitsBasicViewController, UITableViewDataSource, UITableViewDelegate{

    @IBOutlet weak var tableView: UITableView!
    
    private var switchButton: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        setUpView()
        setUpData()
    }
    
    func setUpData(){

        self.userHabits = KM_APP_DELEGATE.userHabits
    }
    
    func setUpView(){
        let tView = UIView(frame: CGRectMake(0, 0, CGFloat.min, 0))
        tView.backgroundColor = self.view.backgroundColor
        self.tableView.tableFooterView = tView
        self.tableView.tableHeaderView = tView
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    // MARK: - goback action
    @IBAction func goback(sender: UIBarButtonItem) {
        SVProgressHUD.showInfoWithStatus("数据同步中,请稍等!")
        
        // 具体面销毁时， 才对用户吸烟习惯进行同步， 不要使用saveXXX方法， 使用 KMUserHabitsHelper.updateUserHabits(userHabits!)
        KMUserHabitsHelper.updateUserHabits(self.userHabits!)
        
        // habits变化之后, 同时要修改 record
        if KMUserHabitsHelper.canSmokingToday(self.userHabits!){
            KM_APP_DELEGATE.todayActionRecord.habitsNum = self.userHabits!.smokedPerDay
        }else{
            KM_APP_DELEGATE.todayActionRecord.habitsNum = 0
        }
        KM_APP_DELEGATE.todayActionRecord.priceForOnePackage = self.userHabits!.priceForOnePackage
        
        KMUserActionRecordHelper.updateUserActionRecord(KM_APP_DELEGATE.todayActionRecord)
        
        self.navigationController?.dismissViewControllerAnimated(true, completion: {
            SVProgressHUD.dismiss()
        })
    }
    
    // MARK: - UISwith
    func setupSwitch(){
        switchButton = UISwitch(frame: CGRectMake(KM_FRAME_WIDTH - 60 - 10, (60 - 30) / 2.0, 60, 30))
        switchButton.setOn(userHabits?.stillSmoking ?? true, animated: false)
        switchButton.addTarget(self, action: "switchButtonAction:", forControlEvents: UIControlEvents.ValueChanged)
        switchButton.onTintColor = KM_COLOR_NAVIGATION_BAR_BUTTON_ITEM
    }
    
    func switchButtonAction(sender: UISwitch){
        habitsSettingChanged("stillSmoking", value: sender.on)
    }
    
    // MARK: - UITableViewDataSource
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let stillSmoking = userHabits?.stillSmoking ?? true
        let rowNum = stillSmoking == true ? 6 : 7
        return rowNum
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        // 这里不需要复用
        let cell = UITableViewCell(style: UITableViewCellStyle.Value1, reuseIdentifier: "HabitsCell")
        cell.selectionStyle = .None
        cell.layer.contents = UIImage(named: "cellbackground")?.CGImage
        
        cell.textLabel?.textColor = RGB(44, 144, 160)
        cell.textLabel?.font = UIFont.systemFontOfSize(15)
        cell.detailTextLabel?.font = UIFont.systemFontOfSize(15)
        
        
        let row = indexPath.row
        if row == 0{
            cell.textLabel?.text = "仍在吸烟"
            if switchButton == nil{
                setupSwitch()
            }
            cell.contentView.addSubview(switchButton)
            
        }else if row == 1{
            cell.textLabel?.text = "每天吸烟支数"
            cell.detailTextLabel?.text = "\(userHabits!.smokedPerDay) 支"
        }else if row == 2{
            cell.textLabel?.text = "烟龄"
            cell.detailTextLabel?.text = "\(KM_DATE_CURRENT_YEAR - userHabits!.smokingYears) 年"
        }else if row == 3{
            cell.textLabel?.text = "平均每包烟价格"
            cell.detailTextLabel?.text = "\(userHabits!.priceForOnePackage) 元/包"
        }else if row == 4{
            cell.textLabel?.text = "尼古丁含量"
            cell.detailTextLabel?.text = "\(userHabits!.nicotineLevel!) mg/支"
        }else if row == 5{
            cell.textLabel?.text = "年龄"
            cell.detailTextLabel?.text = "\(KM_DATE_CURRENT_YEAR - userHabits!.birthYear)"
        }else if row == 6{
            cell.textLabel?.text = "戒烟开始时间"
            cell.detailTextLabel?.text = "\(userHabits!.nonSmokeSince!)"
        }
        
        return cell
    }
    
    // MARK: - UITableViewDelegate
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let row = indexPath.row
        
        var identifier = ""
        if row == 1{
            identifier = "smokedPerDay"
        }else if row == 2{
            identifier = "smokingYears"
        }else if row == 3{
            identifier = "smokingPrice"
        }else if row == 4{
            identifier = "nicotineLevel"
        }else if row == 5{
            identifier = "userAge"
        }else if row == 6{
            identifier = "nonSmokeSince"
        }
        
        if identifier != ""{
            self.performSegueWithIdentifier(identifier, sender: self)
        }
        
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 60
    }
    
    // MARK: - HabitsSettingChangeDelegate
    func habitsSettingChanged(settingField: String, value: AnyObject?){
        if settingField == "stillSmoking"{
            userHabits?.nonSmokeSince = KimreeDateTool.currentDateString()
        }
        
        userHabits?.setValue(value, forKey: settingField)
        
        // 因为修改的部分可能比较强多，当退出界面的时候， 一次性的保存
        //userHabits?.saveEventually()
        
        self.tableView.reloadData()
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        KMLog("prepareForSegue")
        
        let toVC = segue.destinationViewController
        
        if toVC is HabitsBasicViewController{
            (toVC as! HabitsBasicViewController).delegate = self
            (toVC as! HabitsBasicViewController).userHabits = self.userHabits
        }
    }

}
