//
//  MapViewController.swift
//  RiverLaunch
//
//  Created by Christopher Hynes on 2018-03-11.
//  Copyright © 2018 Christopher Hynes. All rights reserved.
//

import UIKit

class MapViewController: UIViewController {
    
    var riverNumber: Int?
    @IBOutlet weak var riverNameLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        riverNumber = SelectedRiver.River.selectedRiver
        if let river = riverNumber {
            riverNameLabel.text = SelectedRiver.River.riverArray[river]
        }  else {
            riverNameLabel.text = "No River Selected Yet"
            
        }
    }

    
}
