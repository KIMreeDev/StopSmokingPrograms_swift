//
//  HistorySettingViewController.swift
//  StopSmokingPrograms
//
//  Created by Fran on 15/11/6.
//  Copyright © 2015年 kimree. All rights reserved.
//

import UIKit

enum HistorySettingDays: Int{
    case LastThreeDays = 3
    case LastWeek = 7
    case LastMonth = 30
}

class HistorySettingViewController: UITableViewController {

    var settingTableViewDelegate: UITableViewDelegate{
        get{
            return self.tableView.delegate!
        }
        set(newValue){
            self.tableView.delegate = newValue
        }
    }
    
    var settingTableViewSelect:Int{
        get{
            return self.tableView.indexPathForSelectedRow?.row ?? 0
        }
        set(newValue){
            self.tableView.selectRowAtIndexPath(NSIndexPath(forRow: newValue, inSection: 0), animated: false, scrollPosition: UITableViewScrollPosition.Middle)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.tableView.tableHeaderView = UIView(frame: CGRectMake(0, 0, 0, CGFloat.min))
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
