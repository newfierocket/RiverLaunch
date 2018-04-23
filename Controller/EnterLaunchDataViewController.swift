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
import KVNProgress
import ChameleonFramework

class EnterLaunchDataViewController: UIViewController, MyProtocol {
    
    var riverName: String?
    var index: String?
    var dataFromDropPinViewController: [String : String]?
    var activeTextField: UITextField!
    var originalHeight: CGFloat?
    var activeField: UITextField?
    var lastOffset: CGPoint!
    var keyboardHeight: CGFloat!
    var ratingPicker: UIPickerView!
    
    let ratingArray = ["1 Star", "2 Star", "3 Star", "4 Star", "5 Star"]
    
    
    @IBOutlet weak var constraintContentHeight: NSLayoutConstraint!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var mainStackView: UIStackView!
    @IBOutlet weak var enteredLaunchNameTextField: UITextField!
    @IBOutlet weak var enteredLatitudeTextField: UITextField!
    @IBOutlet weak var enterLongitudeTextField: UITextField!
    @IBOutlet weak var enteredRatingTextField: UITextField!
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //self.hideKeyboard()
        ratingPicker = UIPickerView()
        ratingPicker.backgroundColor = UIColor(hexString: "#17518D")

        enteredRatingTextField.delegate = self
        enterLongitudeTextField.delegate = self
        enteredLatitudeTextField.delegate = self
        enteredLaunchNameTextField.delegate = self
       
        index = SelectedRiver.River.selectedRiver
        ratingPicker.isHidden = true
        ratingPicker.delegate = self
        ratingPicker.dataSource = self
        
        
        let center: NotificationCenter = NotificationCenter.default
        center.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        center.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: NSNotification.Name.UIKeyboardDidHide, object: nil)
        self.contentView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(returnTextView(gesture:))))
        

    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        
        if let riverIndex = index {
            riverName = riverIndex
            
        } else {
            riverName = "No Selected River Yet"
        }
        
        navigationItem.title = riverName

    }
    
    @objc func returnTextView(gesture: UIGestureRecognizer) {
        guard activeField != nil else {
            return
        }
        
        activeField?.resignFirstResponder()
        activeField = nil
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
        KVNProgress.showError(withStatus: "Incorrect Data!")
        
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
        
        let rating = enteredRatingTextField?.text, !rating.isEmpty,
        
        let user = Auth.auth().currentUser?.email
        
        
        else { showError()
            return
        }
        
        guard let _ = Double(latitude) else { let alert = SCLAlertView(); alert.showError("Latitude Incorrect"); return}
        guard let _ = Double(longitude) else { let alert = SCLAlertView(); alert.showError("Longitude Incorrect"); return}
        
        
        let riverDataToStore = ["launchname" : launchName, "latitude" : latitude, "longitude" : longitude, "rating" : rating, "user" : user]
        let myDataBase = Database.database().reference().child("launch").child(riverName!)
        myDataBase.childByAutoId().updateChildValues(riverDataToStore)
        let alert = SCLAlertView(); alert.showSuccess("Data Uploaded Successfully")
        
        clearTextFields()
        
        }
   
    override func viewDidDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardDidShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardDidHide, object: nil)
    }
}

//MARK: - TEXTFIELD DELEGATES

extension EnterLaunchDataViewController: UITextFieldDelegate {
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        activeField = textField
        
        lastOffset = self.scrollView.contentOffset
        
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        activeField?.resignFirstResponder()
        activeField = nil
        return true
        
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        activeTextField = textField
        if activeTextField == enteredRatingTextField {
            ratingPicker.isHidden = false
            activeTextField.inputView = ratingPicker
        }
        
    }
}


//MARK: - KEYBOARD WILL SHOW/HIDE

extension EnterLaunchDataViewController {
    
    @objc func keyboardWillShow(notification: NSNotification) {
        
        if keyboardHeight != nil {
            return
        }
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            keyboardHeight = keyboardSize.height
            
            UIView.animate(withDuration: 0.3, animations: {
                self.constraintContentHeight.constant += self.keyboardHeight
                
            })
            let distanceToBottom = self.scrollView.frame.size.height - (mainStackView?.frame.origin.y)! - (mainStackView?.frame.size.height)!
            //let distanceToBottom = self.scrollView.frame.size.height - (activeField?.frame.origin.y)! - (activeField?.frame.size.height)!
            let collapseSpace = keyboardHeight - distanceToBottom
            
            if collapseSpace < 0 {
                return
            }
            
            UIView.animate(withDuration: 0.3, animations: {  // x: self.lastOffset.x
                self.scrollView.contentOffset = CGPoint(x: 0, y: collapseSpace + 10)
            })
        }
        
        
        
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        
        UIView.animate(withDuration: 0.3) {
            self.constraintContentHeight.constant -= self.keyboardHeight
            
            self.scrollView.contentOffset = self.lastOffset
            
        }
        keyboardHeight = nil
    }
}


//MARK: - PICKER VEW DELEGATES
extension EnterLaunchDataViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return ratingArray.count
    }
    
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        enteredRatingTextField.text = ratingArray[row]
        activeField?.resignFirstResponder()
        activeField = nil
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let pickerLabel = UILabel()
        let title = ratingArray[row]
        pickerLabel.text = title
        pickerLabel.textAlignment = .center
        pickerLabel.textColor = UIColor.flatWhite
        pickerLabel.font = UIFont.boldSystemFont(ofSize: 20)
        return pickerLabel
    }
  
    
}

    



