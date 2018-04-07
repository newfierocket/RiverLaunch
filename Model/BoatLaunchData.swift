//
//  BoatLaunchData.swift
//  RiverLaunch
//
//  Created by Christopher Hynes on 2018-03-13.
//  Copyright © 2018 Christopher Hynes. All rights reserved.
//

import MapKit

class BoatLaunchData: NSObject, MKAnnotation {
    let title: String?
    let locationName: String
    let coordinate: CLLocationCoordinate2D
    

    
    init(title: String, locationName: String, coordinate: CLLocationCoordinate2D) {
        self.title = title
        self.locationName = locationName
        self.coordinate = coordinate
        
        
        super.init()
    }
    
    var subtitle: String? {
        return locationName
    }
    
    
}
