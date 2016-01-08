//
//  HealthRecoveryAttributeTableViewCell.swift
//  StopSmokingPrograms
//
//  Created by Fran on 15/11/13.
//  Copyright © 2015年 kimree. All rights reserved.
//

import UIKit

class HealthRecoveryAttributeTableViewCell: UITableViewCell {

    @IBOutlet weak var attributeLabel: UILabel!
    @IBOutlet weak var ratioLabel: UILabel!
    
    @IBOutlet weak var backgroundBarView: UIView!
    @IBOutlet weak var frontBarView: UIView!
    @IBOutlet weak var frontBarWidth: NSLayoutConstraint!
    
    var ratio: Double{
        get{
            let total = backgroundBarView.frame.size.width
            let barWith = frontBarWidth.constant
            return Double(barWith / total)
        }
        set{
            let total = backgroundBarView.frame.size.width
            let ratioWidth = total * CGFloat(newValue)
            frontBarWidth.constant = ratioWidth
            ratioLabel.text = String(format: "%.2f%%", newValue * 100.0)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
    }
    
}
