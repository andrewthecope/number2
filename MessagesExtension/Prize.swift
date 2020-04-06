//
//  Prize.swift
//  Number 2
//
//  Created by Andrew Cope on 8/29/16.
//  Copyright © 2016 Andrew Cope. All rights reserved.
//

import UIKit

class Prize: NSObject {

    var accessory: UIImage? = nil
    var poop: Poop? = nil
    var background: UIImage? = nil
    
    var prizeLabel: String {
        if let p = poop {
            return p.title
        } else if let _ = accessory {
            return "Accessory"
        } else if let _ = background {
            return "Background"
        } else {
            return ""
        }
    }
    
    var prizeType: Int {
        if let _ = poop {
            return 0
        } else if let _ = accessory {
            return 1
        } else if let _ = background {
            return 2
        } else {
            return 1
        }
    }
    
    var image: UIImage {
        if let p = poop {
            return p.image
        } else if let _ = accessory {
            return accessory!
        } else if let _ = background {
            return background!
        } else {
            return UIImage()
        }
    }
    

    
    init(accessory: UIImage) {
        self.accessory = accessory
    }
    
    init(poop: Poop) {
        self.poop = poop
    }
    
    init(background: UIImage) {
        self.background = background
    }
    
    override init() {
        
    }
    
}
