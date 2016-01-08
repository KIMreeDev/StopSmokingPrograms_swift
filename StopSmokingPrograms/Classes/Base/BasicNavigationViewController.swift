//
//  BasicNavigationViewController.swift
//  StopSmokingPrograms
//
//  Created by Fran on 15/10/21.
//  Copyright © 2015年 kimree. All rights reserved.
//

import UIKit

class BasicNavigationViewController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        // 导航栏， 默认是全透明的
        self.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: UIBarMetrics.Default)
        self.navigationBar.shadowImage = UIImage()
        self.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: KM_COLOR_NAVIGATION_TITLE]
        self.navigationBar.tintColor = KM_COLOR_NAVIGATION_BAR_BUTTON_ITEM
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func pushViewController(viewController: UIViewController, animated: Bool) {
        pushAnimate()
        super.pushViewController(viewController, animated: false)
    }
    
    override func popViewControllerAnimated(animated: Bool) -> UIViewController? {
        popAnimate()
        return super.popViewControllerAnimated(false)
    }
    
    override func popToRootViewControllerAnimated(animated: Bool) -> [UIViewController]? {
        popAnimate()
        return super.popToRootViewControllerAnimated(false)
    }
    
    override func popToViewController(viewController: UIViewController, animated: Bool) -> [UIViewController]? {
        popAnimate()
        return super.popToViewController(viewController, animated: false)
    }
    
    // push 动画效果
    func pushAnimate(){
        KMLog("pushAnimate")
        let pushAnimate = CATransition()
        pushAnimate.delegate = self
        pushAnimate.duration = 0.3
        pushAnimate.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        pushAnimate.type = kCATransitionFade
        pushAnimate.subtype = kCATransitionFromRight
        self.view.layer.addAnimation(pushAnimate, forKey: nil)
    }
    
    // pop 动画效果
    func popAnimate(){
        KMLog("popAnimate")
        let popAnimate = CATransition()
        popAnimate.delegate = self
        popAnimate.duration = 0.3
        popAnimate.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        popAnimate.type = kCATransitionFade
        popAnimate.subtype = kCATransitionFromLeft
        self.view.layer.addAnimation(popAnimate, forKey: nil)
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
