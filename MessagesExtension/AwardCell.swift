//
//  AwardCell.swift
//  Number 2
//
//  Created by Andrew Cope on 9/13/16.
//  Copyright © 2016 Andrew Cope. All rights reserved.
//

import UIKit

class AwardCell: UICollectionViewCell {
    
    var award: Award? = nil {
        didSet {
            if let safeAward = award {
                imageView.image = safeAward.image
            }
        }
    }
    
    
    @IBOutlet weak var imageView: UIImageView!
    
    
}
