//
//  FindPasswordViewController.swift
//  StopSmokingPrograms
//
//  Created by Fran on 15/10/12.
//  Copyright © 2015年 kimree. All rights reserved.
//

import UIKit

class FindPasswordViewController: BasicViewController, SKPSMTPMessageDelegate {

    @IBOutlet weak var userName: UITextField!
    @IBOutlet weak var emailAddress: UITextField!
    @IBOutlet weak var findPasswordButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
         userName.setValue(UIColor.whiteColor(), forKeyPath: "_placeholderLabel.textColor")
         emailAddress.setValue(UIColor.whiteColor(), forKeyPath: "_placeholderLabel.textColor")
        
        let combineSignal = RACSignal.combineLatest([userName.rac_textSignal(), emailAddress.rac_textSignal()]).map { (tuple: AnyObject!) -> AnyObject! in
            var enabled = true
            
            let tuple = tuple as! RACTuple
            let userName = tuple[0] as? String ?? ""
            let email = tuple[1] as? String ?? ""
            
            if userName.characters.count > 5 && email.characters.count > 5{
                
                if !ValidateTool.isUserName(userName){
                    JDStatusBarNotification.showWithStatus("用户名格式错误!", dismissAfter: KM_JD_VIEW_SHOW_TIME)
                    enabled = false
                }
                
                if !ValidateTool.isEmail(email){
                    JDStatusBarNotification.showWithStatus("邮箱格式错误!", dismissAfter: KM_JD_VIEW_SHOW_TIME)
                    enabled = false
                }
                
            }else{
                enabled = false
            }
            
            return enabled
        }
        combineSignal.setKeyPath("enabled", onObject: self.findPasswordButton, nilValue: false)
        findPasswordButton.setBackgroundImage(imageWithColor(UIColor.grayColor(), size: findPasswordButton.bounds.size), forState: UIControlState.Disabled)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - 找回密码
    // 根据用户名和邮箱找回密码， 对应用户名的密码会发送到指定的邮箱当中
    @IBAction func sendEmailToFindPassword(sender: AnyObject) {
        let userName = self.userName.text ?? ""
        let email = self.emailAddress.text ?? ""
        
        let user = KMUserHelper.findUserWithUserName(userName, email: email)
        if user != nil{
            let emailServer = SKPSMTPMessage()
            emailServer.delegate = self
            
            emailServer.fromEmail = KM_EMAIL_ADDRESS
            emailServer.toEmail = email
            emailServer.login = KM_EMAIL_ADDRESS
            emailServer.pass = KM_EMAIL_PASSWORD
            
            emailServer.relayHost = KM_EMAIL_SMTP
            emailServer.requiresAuth = true
            
            emailServer.wantsSecure = true
            
            // TODO: 使用中文主题时候，SKPSMTPMessage.m文件中的sendParts方法中，需要修改 NSData *messageData = [message dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES]; 为 NSData *messageData = [message dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
            emailServer.subject = "找回密码"
            
            let messageContent = "用户名为 \(userName) 的账号密码为: \(user!.password!)"
            let messagePart = [kSKPSMTPPartContentTypeKey: "text/plain", kSKPSMTPPartMessageKey: messageContent, kSKPSMTPPartContentTransferEncodingKey: "8bit"]
            emailServer.parts = [messagePart]
            
            emailServer.send()
        }
    }
    
    // MARK: - SKPSMTPMessageDelegate
    func messageFailed(message: SKPSMTPMessage!, error: NSError!) {
        SVProgressHUD.showSuccessWithStatus("\(error.localizedDescription)")
    }
    
    func messageSent(message: SKPSMTPMessage!) {
        SVProgressHUD.showSuccessWithStatus("密码已发送到您的邮箱,请查收!")
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
