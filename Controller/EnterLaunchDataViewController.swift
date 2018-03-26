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

class EnterLaunchDataViewController: UIViewController, MyProtocol, UITextFieldDelegate {
    
    var riverName: String?
    var index: String?
    var dataFromDropPinViewController: [String : String]?
    var activeTextField: UITextField!
    var originalHeight: CGFloat?
   
    @IBOutlet weak var allStackView: UIStackView!
    
    
    
    @IBOutlet weak var enteredLaunchNameTextField: UITextField!
    @IBOutlet weak var enteredLatitudeTextField: UITextField!
    @IBOutlet weak var enterLongitudeTextField: UITextField!
    @IBOutlet weak var enteredRatingTextField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboard()
        
        enteredRatingTextField.delegate = self
        enterLongitudeTextField.delegate = self
        enteredLatitudeTextField.delegate = self
        enteredLaunchNameTextField.delegate = self
       
        index = SelectedRiver.River.selectedRiver
        
        
        let center: NotificationCenter = NotificationCenter.default
        center.addObserver(self, selector: #selector(keyBoardDidShow(notification:)), name: NSNotification.Name.UIKeyboardDidShow, object: nil)
        center.addObserver(self, selector: #selector(keyBoardWillHide(notification:)), name: NSNotification.Name.UIKeyboardDidHide, object: nil)
        

    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        
        if let riverIndex = index {
            riverName = riverIndex
            
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
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        activeTextField = textField
       
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @objc func keyBoardDidShow(notification: Notification) {
        
        let info: NSDictionary = notification.userInfo! as NSDictionary
        let keyboardSize = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        let keyboardY = view.frame.size.height - keyboardSize.height
        originalHeight = view.frame.height
        let editingTextFieldY: CGFloat! = activeTextField?.frame.origin.y
    
        
        if editingTextFieldY < keyboardY - 60 {
            UIView.animate(withDuration: 0.25, animations: {
                self.view.frame = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: (self.view.frame.height - (self.allStackView.frame.origin.y + self.allStackView.frame.height)) + keyboardSize.height)
            })
        }
        
        
    }
    @objc func keyBoardWillHide(notification: Notification) {
        UIView.animate(withDuration: 0.1) {
            self.view.frame = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.originalHeight!)
            
        }
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardDidShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardDidHide, object: nil)
    }
 

}


