//
//  NonSmokeSinceViewController.swift
//  StopSmokingPrograms
//
//  Created by Fran on 15/10/23.
//  Copyright © 2015年 kimree. All rights reserved.
//

import UIKit

class NonSmokeSinceViewController: HabitsBasicViewController {

    @IBOutlet weak var pickerView: UIDatePicker!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        let dateStr = userHabits?.nonSmokeSince ?? KimreeDateTool.currentDateString()
        pickerView.setDate(KimreeDateTool.dateFromString(dateStr), animated: false)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        let dateStr = KimreeDateTool.dateStringWithDate(pickerView.date)
        delegate?.habitsSettingChanged!("nonSmokeSince", value: dateStr)
        
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
