//
//  EnterLaunchDataViewController.swift
//  RiverLaunch
//
//  Created by Christopher Hynes on 2018-03-16.
//  Copyright © 2018 Christopher Hynes. All rights reserved.
//

import UIKit
import Firebase

class EnterLaunchDataViewController: UIViewController {
    
    var riverName: String?
    var index: Int?
    
    @IBOutlet weak var enteredLaunchNameTextField: UITextField!
    @IBOutlet weak var enteredLatitudeTextField: UITextField!
    @IBOutlet weak var enterLongitudeTextField: UITextField!
    @IBOutlet weak var enteredRatingTextField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        index = SelectedRiver.River.selectedRiver

    }
    
    override func viewWillAppear(_ animated: Bool) {
        if let riverIndex = index {
            riverName = SelectedRiver.River.riverNames[riverIndex]
            
        } else {
            riverName = "No Selected River Yet"
        }
        
        navigationItem.title = riverName

       
    }
    
    
    
    
    @IBAction func submitDataButton(_ sender: UIButton) {
        
        guard
        
        let launchName = enteredLaunchNameTextField?.text, !launchName.isEmpty,
        
        let latitude = enteredLatitudeTextField?.text, !latitude.isEmpty,
        
        let longitude = enterLongitudeTextField?.text, !longitude.isEmpty,
        
        let rating = enteredRatingTextField?.text, !rating.isEmpty
        
        else { print("invalid data")
            return
        }
        
        guard let _ = Double(latitude) else { print("Invalid Data Latitude"); return}
        guard let _ = Double(longitude) else { print("Invalid Data Longitude"); return}
        
        
        let riverDataToStore = ["launchname" : launchName, "latitude" : latitude, "longitude" : longitude, "rating" : rating]
        let myDataBase = Database.database().reference().child(riverName!)
        myDataBase.childByAutoId().updateChildValues(riverDataToStore)
        
        enteredLaunchNameTextField.text = ""
        enteredLatitudeTextField.text = ""
        enterLongitudeTextField.text = ""
        enteredRatingTextField.text = ""
        
        }
    
    
    


}
