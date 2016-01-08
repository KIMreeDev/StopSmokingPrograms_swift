//
//  HealthRecoveryTableViewCell.swift
//  StopSmokingPrograms
//
//  Created by Fran on 15/11/13.
//  Copyright © 2015年 kimree. All rights reserved.
//

import UIKit

class HealthRecoveryTableViewCell: UITableViewCell {

    @IBOutlet weak var frontImageConstraintWidth: NSLayoutConstraint!
    
    @IBOutlet weak var heartBackgroundImageView: UIImageView!
    
    @IBOutlet weak var nonSmokingInfoLabel: UILabel!
    @IBOutlet weak var nonSmokingHabitsInfoLabel: UILabel!
    
    @IBOutlet weak var ratioLabel: UILabel!
    @IBOutlet weak var recoveryDaysLabel: UILabel!
    
    
    var ratio: Double{
        set{
            let total = heartBackgroundImageView.frame.size.width
            let frontWidth = total * CGFloat(newValue)
            frontImageConstraintWidth.constant = frontWidth
            ratioLabel.text = String(format: "%.2f%%", newValue * 100.0)
        }
        get{
            let total = heartBackgroundImageView.frame.size.width
            let frontWidth = frontImageConstraintWidth.constant
            return Double(frontWidth) / Double(total)
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
