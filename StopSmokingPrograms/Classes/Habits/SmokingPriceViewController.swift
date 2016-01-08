//
//  SmokingPriceViewController.swift
//  StopSmokingPrograms
//
//  Created by Fran on 15/10/23.
//  Copyright © 2015年 kimree. All rights reserved.
//

import UIKit

class SmokingPriceViewController: HabitsBasicViewController, UITextFieldDelegate {

    @IBOutlet weak var textField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        textField.text = "\(userHabits!.priceForOnePackage ?? 20.0)"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        textField.becomeFirstResponder()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        textField.resignFirstResponder()
        
        let price = ((textField.text ?? "20.0") as NSString).floatValue
        delegate?.habitsSettingChanged!("priceForOnePackage", value: price)
    }
    
    // MARK: - UITextFieldDelegate
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        
        var canInput = true
        
        let text = textField.text ?? ""
        if text.containsString(".") && string == "."{
            canInput = false
        }
        
        if text.characters.count == 0 && string == "."{
            canInput = false
        }
        
        if !string.isEmpty && !ValidateTool.matchPattern("\\d|\\.", str: string){
            canInput = false
        }
        
        return canInput
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
