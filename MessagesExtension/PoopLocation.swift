//
//  PoopLocation.swift
//  Number 2
//
//  Created by Andrew Cope on 9/13/16.
//  Copyright © 2016 Andrew Cope. All rights reserved.
//

import UIKit
import MapKit

class PoopLocation: NSObject, MKAnnotation {
    let title: String?
    let locationName: String
    let discipline: String
    let coordinate: CLLocationCoordinate2D
    let location: CLLocation
    
    var subtitle: String? {
        return locationName
    }
    
    init(title: String, locationName: String, discipline: String, coordinate: CLLocationCoordinate2D, location: CLLocation) {
        self.title = title
        self.locationName = locationName
        self.discipline = discipline
        self.coordinate = coordinate
        self.location = location
        
        super.init()
    }
}
