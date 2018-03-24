//
//  EnterLaunchDataViewController.swift
//  RiverLaunch
//
//  Created by Christopher Hynes on 2018-03-16.
//  Copyright © 2018 Christopher Hynes. All rights reserved.
//

import UIKit
import Firebase
import SCLAlertView

class EnterLaunchDataViewController: UIViewController, MyProtocol {
    
    var riverName: String?
    var index: Int?
    var dataFromDropPinViewController: [String : String]?
   
    
    
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
    
  
    func setResultOfDroppedPin(valueSent: [String : String]) {
        dataFromDropPinViewController = valueSent
        
        if let data = dataFromDropPinViewController {
            enteredLatitudeTextField.text = data["latitude"]
            enterLongitudeTextField.text = data["longitude"]
        }
        
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "GoToDropPin" {
            let vc : DropPinViewController = segue.destination as! DropPinViewController
            vc.delegate = self
        }
    }
    
    func showError() {
        
        let alert = SCLAlertView()
        alert.showError("Incorrect or Incomplete Data")
        clearTextFields()
    }
    
    func clearTextFields() {
        enteredLaunchNameTextField.text = ""
        enteredLatitudeTextField.text = ""
        enterLongitudeTextField.text = ""
        enteredRatingTextField.text = ""
        
    }
 
    
    
    
    @IBAction func submitDataButton(_ sender: UIButton) {
        
        guard
        
        let launchName = enteredLaunchNameTextField?.text, !launchName.isEmpty,
        
        let latitude = enteredLatitudeTextField?.text, !latitude.isEmpty,
        
        let longitude = enterLongitudeTextField?.text, !longitude.isEmpty,
        
        let rating = enteredRatingTextField?.text, !rating.isEmpty
        
        else { showError()
            return
        }
        
        guard let _ = Double(latitude) else { let alert = SCLAlertView(); alert.showError("Latitude Incorrect"); return}
        guard let _ = Double(longitude) else { let alert = SCLAlertView(); alert.showError("Longitude Incorrect"); return}
        
        
        let riverDataToStore = ["launchname" : launchName, "latitude" : latitude, "longitude" : longitude, "rating" : rating]
        let myDataBase = Database.database().reference().child("launch").child(riverName!)
        myDataBase.childByAutoId().updateChildValues(riverDataToStore)
        let alert = SCLAlertView(); alert.showSuccess("Data Uploaded Successfully")
        
        clearTextFields()
        
        }
    
    
    


}
