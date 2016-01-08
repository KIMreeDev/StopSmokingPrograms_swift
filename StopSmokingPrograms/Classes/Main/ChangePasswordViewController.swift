//
//  ChangePasswordViewController.swift
//  StopSmokingPrograms
//
//  Created by Fran on 15/10/22.
//  Copyright © 2015年 kimree. All rights reserved.
//

import UIKit

class ChangePasswordViewController: BasicViewController {
    
    
    @IBOutlet weak var oldPassword: UITextField!
    @IBOutlet weak var newPassword: UITextField!
    @IBOutlet weak var reInputNewPassword: UITextField!
    @IBOutlet weak var submitButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.navigationController?.navigationBar.setBackgroundImage(imageWithColor(KM_COLOR_BLACK_ALPHA, size: self.view.frame.size), forBarMetrics: UIBarMetrics.Default)
        
        oldPassword.setValue(UIColor.whiteColor(), forKeyPath: "_placeholderLabel.textColor")
        newPassword.setValue(UIColor.whiteColor(), forKeyPath: "_placeholderLabel.textColor")
        reInputNewPassword.setValue(UIColor.whiteColor(), forKeyPath: "_placeholderLabel.textColor")
        
        let combineSignal = RACSignal.combineLatest([oldPassword.rac_textSignal(), newPassword.rac_textSignal(), reInputNewPassword.rac_textSignal()]).map { (tuple: AnyObject!) -> AnyObject! in
            let tuple = tuple as! RACTuple
            let oldPwd = tuple[0] as? String ?? ""
            let newPwd = tuple[1] as? String ?? ""
            let reInputNewPwd = tuple[2] as? String ?? ""
            
            var enabled = false
            if oldPwd.characters.count > 5 && newPwd.characters.count > 5 && reInputNewPwd.characters.count > 5 && newPwd == reInputNewPwd{
                enabled = true
            }
            
            return enabled
        }
        combineSignal.setKeyPath("enabled", onObject: self.submitButton, nilValue: false)
        submitButton.setBackgroundImage(imageWithColor(UIColor.grayColor(), size: submitButton.bounds.size), forState: UIControlState.Disabled)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func goback(){
        self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
    }

    @IBAction func changePasswordAction(sender: UIButton) {
        let loginUser = KM_APP_DELEGATE.loginUser
        let oldPwd = oldPassword.text ?? ""
        let newPwd = newPassword.text ?? ""
        let reInputNewPwd = reInputNewPassword.text ?? ""
        
        if loginUser?.password == oldPwd && newPwd == reInputNewPwd{
            loginUser?.password = newPwd
            loginUser?.saveEventually({ [weak self](success: Bool, error: NSError!) -> Void in
                if success{
                    JDStatusBarNotification.showWithStatus("密码修改成功", dismissAfter: KM_JD_VIEW_SHOW_TIME)
                    SVProgressHUD.showSuccessWithStatus("密码修改成功")
                    self?.goback()
                }else{
                    let errorMsg = error!.localizedDescription ?? "密码修改失败"
                    JDStatusBarNotification.showWithStatus(errorMsg, dismissAfter: KM_JD_VIEW_SHOW_TIME)
                    SVProgressHUD.showSuccessWithStatus(errorMsg)
                }
            })
        }else{
            JDStatusBarNotification.showWithStatus("密码不匹配或新密码不一致", dismissAfter: KM_JD_VIEW_SHOW_TIME)
            SVProgressHUD.showSuccessWithStatus("密码不匹配或新密码不一致")
        }
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
