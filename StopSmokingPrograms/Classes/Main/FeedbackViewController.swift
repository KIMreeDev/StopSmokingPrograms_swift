//
//  FeedbackViewController.swift
//  StopSmokingPrograms
//
//  Created by Fran on 15/10/14.
//  Copyright © 2015年 kimree. All rights reserved.
//

import UIKit

class FeedbackViewController: BasicViewController {

    @IBOutlet weak var feedbackContent: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.navigationController?.navigationBar.setBackgroundImage(imageWithColor(KM_COLOR_BLACK_ALPHA, size: self.view.frame.size), forBarMetrics: UIBarMetrics.Default)
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "提交", style: .Done, target: self, action: "submit")
        
        feedbackContent.rac_textSignal().map { (content: AnyObject!) -> AnyObject! in
            var enabled = false
            
            let content = content as? String ?? ""
            let trimContent = content.stringByReplacingOccurrencesOfString(" ", withString: "")
            if trimContent.characters.count >= 10{
                enabled = true
            }
            return enabled
        }.setKeyPath("enabled", onObject: self.navigationItem.rightBarButtonItem, nilValue: false)
    }
    
    @IBAction func goback(){
        self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        feedbackContent.becomeFirstResponder()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        feedbackContent.resignFirstResponder()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func submit(){
        let content = feedbackContent.text
        
        let userfd = KMUserFeedback()
        userfd.content = content
        userfd.user = KM_APP_DELEGATE.loginUser
        userfd.saveEventually { [weak self](success: Bool, error: NSError!) -> Void in
            var showTitle = ""
            if success{
                showTitle = "提交成功"
                JDStatusBarNotification.showWithStatus(showTitle, dismissAfter: KM_JD_VIEW_SHOW_TIME)
                SVProgressHUD.showSuccessWithStatus(showTitle)
                self?.goback()
            }else{
                showTitle = error!.localizedDescription
                JDStatusBarNotification.showWithStatus(showTitle, dismissAfter: KM_JD_VIEW_SHOW_TIME)
                SVProgressHUD.showErrorWithStatus(showTitle)
            }
        }
    }
    
    @IBAction func textViewResignFirstResponder(sender: UITapGestureRecognizer) {
        feedbackContent.resignFirstResponder()
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
