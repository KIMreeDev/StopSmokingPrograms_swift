//
//  BasicViewController.swift
//  StopSmokingPrograms
//
//  Created by Fran on 15/10/10.
//  Copyright © 2015年 kimree. All rights reserved.
//

import UIKit

class BasicViewController: UIViewController, ACParallaxViewDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        // 避免使用scrollView后界面自动下移， 不过关闭之后需要自己处理scrollView的显示位置
        self.automaticallyAdjustsScrollViewInsets = false
    }

    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.view.endEditing(true)
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
