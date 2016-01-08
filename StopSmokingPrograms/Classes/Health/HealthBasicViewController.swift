//
//  HealthBasicViewController.swift
//  StopSmokingPrograms
//
//  Created by Fran on 15/11/13.
//  Copyright © 2015年 kimree. All rights reserved.
//

import UIKit

class HealthBasicViewController: BasicViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.navigationController?.navigationBar.shadowImage = imageWithColor(KM_COLOR_BLACK_ALPHA, size: CGSizeMake(KM_FRAME_WIDTH, 1))
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
