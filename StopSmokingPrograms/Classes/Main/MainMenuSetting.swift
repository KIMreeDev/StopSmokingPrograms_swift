//
//  MainMenuSetting.swift
//  StopSmokingPrograms
//
//  Created by Fran on 15/10/20.
//  Copyright © 2015年 kimree. All rights reserved.
//

import UIKit

class MainMenuSetting: UIView {
    
    
    @IBOutlet weak var radiusLabel: UILabel!
    @IBOutlet weak var radiusSlider: UISlider!
    
    @IBOutlet weak var angularSpacingLabel: UILabel!
    @IBOutlet weak var angularSpacingSlider: UISlider!
    
    @IBOutlet weak var xOffsetLabel: UILabel!
    @IBOutlet weak var xOffsetSlider: UISlider!
    
    @IBOutlet weak var widthLabel: UILabel!
    @IBOutlet weak var widthSlider: UISlider!
    
    @IBOutlet weak var heightLabel: UILabel!
    @IBOutlet weak var heightSlider: UISlider!

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */
    
    class func instanceFromNib() -> MainMenuSetting{
        let view = UINib(nibName: "MainMenuSetting", bundle: nil).instantiateWithOwner(nil, options: nil).first as! MainMenuSetting
        return view
    }

}
