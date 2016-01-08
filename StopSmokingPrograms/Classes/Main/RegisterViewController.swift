//
//  RegisterViewController.swift
//  StopSmokingPrograms
//
//  Created by Fran on 15/10/10.
//  Copyright © 2015年 kimree. All rights reserved.
//

import UIKit

class RegisterViewController: BasicViewController {

    @IBOutlet weak var userName: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var reInputPassword: UITextField!
    @IBOutlet weak var emailAddress: UITextField!
    @IBOutlet weak var registerButton: UIButton!
    
    // 同意协议选择框， 高度宽度相同，等于 同意协议选择框 和 label 的整体高度
    @IBOutlet weak var agreeCheckboxImageView: UIImageView!
    private var checkedImage = UIImage(named: "select")
    private var unCheckedImage = UIImage(named: "unselect")
    
    // 已阅读并同意label
    @IBOutlet weak var agreeLabel: UILabel!
    @IBOutlet weak var agreeLabelWidth: NSLayoutConstraint!
    
    // 同意协议选择框 和 label 总宽度
    @IBOutlet weak var agreeTotalWidth: NSLayoutConstraint!
    // 同意协议选择框的高度
    @IBOutlet weak var agreeTotalHeight: NSLayoutConstraint!
    
    // 使用协议label
    @IBOutlet weak var userAgreeLabel: UILabel!
    @IBOutlet weak var userAgreeLabelWidth: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        setUpConstraint()
        
        userName.setValue(UIColor.whiteColor(), forKeyPath: "_placeholderLabel.textColor")
        password.setValue(UIColor.whiteColor(), forKeyPath: "_placeholderLabel.textColor")
        reInputPassword.setValue(UIColor.whiteColor(), forKeyPath: "_placeholderLabel.textColor")
        emailAddress.setValue(UIColor.whiteColor(), forKeyPath: "_placeholderLabel.textColor")
        
        let combineSignal = RACSignal.combineLatest([userName.rac_textSignal(), password.rac_textSignal(), reInputPassword.rac_textSignal(), emailAddress.rac_textSignal(), agreeCheckboxImageView.rac_valuesForKeyPath("image", observer: self.agreeCheckboxImageView)]).map { (tuple: AnyObject!) -> AnyObject! in
            var enabled = true
            
            let tuple = tuple as! RACTuple
            let userName = tuple[0] as? String ?? ""
            let password = tuple[1] as? String ?? ""
            let rePassword = tuple[2] as? String ?? ""
            let email = tuple[3] as? String ?? ""
            let agreeProtocol = self.agreeCheckboxImageView.image == self.checkedImage
            
            if !agreeProtocol || userName.characters.count <= 5 || password.characters.count <= 5 || rePassword.characters.count <= 5 || email.characters.count == 0{
                enabled = false
                JDStatusBarNotification.showWithStatus("输入信息长度小于6个字符", dismissAfter: KM_JD_VIEW_SHOW_TIME)
            }
            
            if userName.characters.count > 5 && !ValidateTool.isUserName(userName){
                JDStatusBarNotification.showWithStatus("用户名格式错误!", dismissAfter: KM_JD_VIEW_SHOW_TIME)
                enabled = false
            }
            
            if password.characters.count > 5 && !ValidateTool.isPassword(password){
                JDStatusBarNotification.showWithStatus("密码格式错误!", dismissAfter: KM_JD_VIEW_SHOW_TIME)
                enabled = false
            }
            
            if rePassword.characters.count > 5 && rePassword != password{
                JDStatusBarNotification.showWithStatus("两次输入的密码不一致!", dismissAfter: KM_JD_VIEW_SHOW_TIME)
                enabled = false
            }
            
            if !ValidateTool.isEmail(email){
                JDStatusBarNotification.showWithStatus("邮箱格式错误!", dismissAfter: KM_JD_VIEW_SHOW_TIME)
                enabled = false
            }
            
            return enabled
        }
        combineSignal.setKeyPath("enabled", onObject: self.registerButton, nilValue: false)
        registerButton.setBackgroundImage(imageWithColor(UIColor.grayColor(), size: registerButton.bounds.size), forState: UIControlState.Disabled)
    }
    
    func setUpConstraint(){
        // 添加下划线
        let content = NSMutableAttributedString(string: userAgreeLabel.text ?? "")
        content.addAttribute(NSUnderlineStyleAttributeName, value: NSUnderlineStyle.StyleSingle.rawValue, range: NSMakeRange(0, content.length))
        userAgreeLabel.attributedText = content
        
        // 修改约束
        let agreeLabelSize = agreeLabel.sizeThatFits(CGSizeZero)
        let userAgreeSize = userAgreeLabel.sizeThatFits(CGSizeZero)
        
        agreeLabelWidth.constant = agreeLabelSize.width
        agreeTotalWidth.constant = agreeLabelWidth.constant + agreeTotalHeight.constant
        userAgreeLabelWidth.constant = userAgreeSize.width
    }
    
    // 在 viewDidAppear 中，storyboard里面view的frame才是正确的
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - 使用协议
    @IBAction func showUserAgree(sender: AnyObject) {
        KMLog("showUserAgree")
        
        self.performSegueWithIdentifier("showAgreeProtocol", sender: self)
    }
    
    // MARK: - 同意协议
    @IBAction func agree(sender: AnyObject) {
        if agreeCheckboxImageView.image == self.checkedImage{
            agreeCheckboxImageView.image = self.unCheckedImage
        }else{
            agreeCheckboxImageView.image = self.checkedImage
        }
    }
    
    // MARK: - 注册新用户
    @IBAction func register(sender: AnyObject) {
        let userName = self.userName.text ?? ""
        let password = self.password.text ?? ""
        let email = self.emailAddress.text ?? ""
        
        if KMUserHelper.validateUserName(userName){
            let result = KMUserHelper.registerWithUserName(userName, password: password, email: email)
            if result{
                KM_APP_DELEGATE.loginWithUserName(userName, password: password)
            }
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
