//
//  Agreement ViewController.swift
//  StopSmokingPrograms
//
//  Created by Fran on 15/10/12.
//  Copyright © 2015年 kimree. All rights reserved.
//

import UIKit

class Agreement_ViewController: BasicViewController {

    @IBOutlet weak var webView: UIWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: UIBarMetrics.Default)
        
        let htmlPath = NSBundle.mainBundle().pathForResource("agreement_strings", ofType: "html")
        let htmlStr = try? NSString(contentsOfFile: htmlPath!, encoding: NSUTF8StringEncoding) as String
        webView.loadHTMLString(htmlStr ?? "", baseURL: nil)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        // 半透明导航栏
        self.navigationController?.navigationBar.setBackgroundImage(imageWithColor(KM_COLOR_BLACK_ALPHA, size: self.view.frame.size), forBarMetrics: UIBarMetrics.Default)
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
