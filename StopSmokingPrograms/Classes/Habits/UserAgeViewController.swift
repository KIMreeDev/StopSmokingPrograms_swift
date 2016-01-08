//
//  UserAgeViewController.swift
//  StopSmokingPrograms
//
//  Created by Fran on 15/10/23.
//  Copyright © 2015年 kimree. All rights reserved.
//

import UIKit

class UserAgeViewController: HabitsBasicViewController, UIPickerViewDataSource, UIPickerViewDelegate {

    @IBOutlet weak var pickerView: UIPickerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        pickerView.selectRow(KM_DATE_CURRENT_YEAR - (userHabits?.birthYear ?? 18) - 18, inComponent: 0, animated: false)
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        let select = KM_DATE_CURRENT_YEAR - 18 - pickerView.selectedRowInComponent(0)
        delegate?.habitsSettingChanged!("birthYear", value: select)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - UIPickerViewDataSource
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 80 - 18 + 1
    }
    
    // MARK: - UIPickerViewDelegate
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return "\(KM_DATE_CURRENT_YEAR - 18 - row)"
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
