//
//  LoginViewController.swift
//  StopSmokingPrograms
//
//  Created by Fran on 15/10/7.
//  Copyright © 2015年 kimree. All rights reserved.
//

import UIKit

class LoginViewController: BasicViewController {

    @IBOutlet weak var userName: UITextField!
    @IBOutlet weak var password: UITextField!
    
    @IBOutlet weak var loginButton: UIButton!
    
    @IBOutlet weak var forgetButton: UIButton!
    @IBOutlet weak var forgetButtonWidth: NSLayoutConstraint!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        setUpConstraint()
        defaultSetting()
        
        // Navigation
        self.navigationController?.navigationBar.setBackgroundImage(imageWithColor(KM_COLOR_BLACK_ALPHA, size: self.view.frame.size), forBarMetrics: UIBarMetrics.Default)
        
        // textfield placeHolder 字体颜色设置
        userName.setValue(UIColor.whiteColor(), forKeyPath: "_placeholderLabel.textColor")
        password.setValue(UIColor.whiteColor(), forKeyPath: "_placeholderLabel.textColor")
        
        // 根据账号密码输入情况控制登录按钮是否可以点击
        let combileSignal = RACSignal.combineLatest([userName.rac_textSignal(), password.rac_textSignal()]).map { (tuple: AnyObject!) -> AnyObject! in
            var enabled = true
            let tuple = tuple as! RACTuple
            let userName = tuple[0] as! String
            let password = tuple[1] as! String
            
            if userName.characters.count > 5 && password.characters.count > 5{
                if !ValidateTool.isUserName(userName){
                    JDStatusBarNotification.showWithStatus("用户名格式错误!", dismissAfter: KM_JD_VIEW_SHOW_TIME)
                    enabled = false
                }
                
                if !ValidateTool.isPassword(password){
                    JDStatusBarNotification.showWithStatus("密码格式错误!", dismissAfter: KM_JD_VIEW_SHOW_TIME)
                    enabled = false
                }
                
                
            }else{
                JDStatusBarNotification.showWithStatus("用户名或密码长度小于6个字符", dismissAfter: KM_JD_VIEW_SHOW_TIME)
                enabled = false
            }
            
            return enabled
        }
        combileSignal.setKeyPath("enabled", onObject: self.loginButton, nilValue: false)
        loginButton.setBackgroundImage(imageWithColor(UIColor.grayColor(), size: loginButton.bounds.size), forState: UIControlState.Disabled)
        
        KMLog("LoginViewController")
    }
    
    func setUpConstraint(){
        // 添加下划线
        let content = NSMutableAttributedString(string: forgetButton.titleLabel?.text ?? "")
        content.addAttribute(NSUnderlineStyleAttributeName, value: NSUnderlineStyle.StyleSingle.rawValue, range: NSMakeRange(0, content.length))
        forgetButton.setAttributedTitle(content, forState: UIControlState.Normal)
        
        // 修改宽度
        let tempLabel = UILabel(frame: CGRectZero)
        tempLabel.text = forgetButton.titleLabel?.text
        let size = tempLabel.sizeThatFits(CGSizeZero)
        forgetButtonWidth.constant = size.width        
    }
    
    func defaultSetting(){
        let loginProof = LocalStorage.shareLocalStorage().getObject(KM_STORAGE_USER_LOGIN_PROOF, searchPathDirectory: NSSearchPathDirectory.DocumentDirectory) as? NSDictionary
        if loginProof != nil{
            let userName = loginProof!["userName"] as! String
            let password = loginProof!["password"] as! String
            
            self.userName.text = userName
            self.password.text = password
            
        }
    }

    @IBAction func login(sender: AnyObject) {
        let userName = self.userName.text ?? ""
        let password = self.password.text ?? ""
        // 登陆登出操作使用appdelegate里面的方法统一处理
        KM_APP_DELEGATE.loginWithUserName(userName, password: password, changeRootVCWhenLoginFail: false)
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
