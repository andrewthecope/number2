//
//  SentPoop.swift
//  Number 2
//
//  Created by Andrew Cope on 8/29/16.
//  Copyright © 2016 Andrew Cope. All rights reserved.
//

import UIKit
import CloudKit

enum PicOrPoop {
    case poop //0
    case pic  //1
    
}

class SentPoop: NSObject {

    var picOrPoop = PicOrPoop.poop
    var image = UIImage()
    var timeStamp = Date()
    var location = PoopLocation(title: "", locationName: "", discipline: "", coordinate: CLLocationCoordinate2D(), location: CLLocation())

    
    init(record: CKRecord) {
        let typeInt = record.object(forKey: "picOrPoop") as? Int
        
        if let type = typeInt {
            if type == 0 {
                picOrPoop = .poop
            } else {
                picOrPoop = .pic
            }
        }
        
        let loc = record.object(forKey: "location") as! CLLocation
        
        location = PoopLocation(title: "", locationName: "\(loc)", discipline: "Poop Location", coordinate: loc.coordinate, location: loc)
        
        if let date = record.creationDate {
            timeStamp = date
        }
        
    }
    
}
