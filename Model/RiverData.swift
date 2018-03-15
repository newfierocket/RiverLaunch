//
//  RiverData.swift
//  RiverLaunch
//
//  Created by Christopher Hynes on 2018-03-13.
//  Copyright © 2018 Christopher Hynes. All rights reserved.
//
import Foundation
import SwiftyJSON

class RiverData {
    
    var riverData: JSON = [
    [
        "river" : "Wapiti River",
        "launchinfo" : [
            
            ["launch" : "Magoo's",
            "location" : ["latitude" : 55.0697, "longitude" : -118.7104]],
            
            ["launch" : "Pipestone",
             "location" : ["latitude" : 55.0447, "longitude" : -119.0958]]
            ],
        "gallary" : [],
        "reviews" : [],
        
        ],
    [
        "river" : "Smokey River",
        "launchinfo" : [
            
            ["launch" : "Bezanson Launch",
             "location" : ["latitude" : 55.2342, "longitude" : -118.2610]]
        ],
        "gallary" : [],
        "reviews" : [],
        ]
        
]
        
    
    


}
