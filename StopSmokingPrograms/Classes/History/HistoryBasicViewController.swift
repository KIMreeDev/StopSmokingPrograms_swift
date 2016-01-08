//
//  HistoryBasicViewController.swift
//  StopSmokingPrograms
//
//  Created by Fran on 15/10/31.
//  Copyright © 2015年 kimree. All rights reserved.
//

import UIKit

class HistoryBasicViewController: BasicViewController {
    
    // 设置的tableView
    private var historySettingViewController: HistorySettingViewController?
    
    // 设置的弹出界面
    var popoverViewController: WYPopoverController?
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.navigationController?.navigationBar.shadowImage = imageWithColor(KM_COLOR_BLACK_ALPHA, size: CGSizeMake(KM_FRAME_WIDTH, 1))
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - barButtonItem 点击显示弹出框
    func setUpSettingViewController(settingDelegate: UITableViewDelegate? = nil){
        let settingNav = self.storyboard?.instantiateViewControllerWithIdentifier("history_setting") as! BasicNavigationViewController
        historySettingViewController = settingNav.viewControllers.first as? HistorySettingViewController
        
        if settingDelegate != nil{
            historySettingViewController?.settingTableViewDelegate = settingDelegate!
        }
        
        historySettingViewController?.preferredContentSize = CGSizeMake(200, 200)
        
        popoverViewController = WYPopoverController(contentViewController: settingNav)
        popoverViewController?.wantsDefaultContentAppearance = true
    }
    
    func showSettingViewController(barButton: UIBarButtonItem){
        
        popoverViewController?.presentPopoverFromBarButtonItem(barButton, permittedArrowDirections: WYPopoverArrowDirection.Down, animated: true)
    }
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
