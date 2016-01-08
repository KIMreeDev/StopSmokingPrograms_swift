//
//  MainMenuCell.swift
//  StopSmokingPrograms
//
//  Created by Fran on 15/10/8.
//  Copyright © 2015年 kimree. All rights reserved.
//

import UIKit

class MainMenuCell: /*SCHCircleViewCell*/ UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    
    class func instanceFromNib() -> MainMenuCell{
        let cell = UINib(nibName: "MainMenuCell", bundle: nil).instantiateWithOwner(nil, options: nil).first as! MainMenuCell
        return cell
    }

}
