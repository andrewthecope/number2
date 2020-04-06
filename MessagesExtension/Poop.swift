//
//  Poop.swift
//  Number 2
//
//  Created by Andrew Cope on 8/14/16.
//  Copyright © 2016 Andrew Cope. All rights reserved.
//

import UIKit

class Poop: NSObject {

    var title = "Happy"
    var image = #imageLiteral(resourceName: "test")
    
    init(title:String,image:UIImage)
    {
        self.title = title
        self.image = image
    }
    
    override init() {}
    
}
