//
//  NicotineLevelViewController.swift
//  StopSmokingPrograms
//
//  Created by Fran on 15/10/23.
//  Copyright © 2015年 kimree. All rights reserved.
//

import UIKit

class NicotineLevelViewController: HabitsBasicViewController, UIPickerViewDataSource, UIPickerViewDelegate {

    @IBOutlet weak var pickerView: UIPickerView!
    
    private var pickerData = [NicotineLevel_Ultra_Light, NicotineLevel_Light, NicotineLevel_Regular, NicotineLevel_Strong]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        let userNicotineLevel = userHabits?.nicotineLevel ?? NicotineLevel_Ultra_Light
        let row = pickerData.indexOf(userNicotineLevel) ?? 0
        pickerView.selectRow(row, inComponent: 0, animated: false)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        let select = pickerData[pickerView.selectedRowInComponent(0)]
        delegate?.habitsSettingChanged!("nicotineLevel", value: select)
    }
    
    // MARK: - UIPickerViewDataSource
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }
    
    // MARK: - UIPickerViewDelegate
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerData[row]
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
