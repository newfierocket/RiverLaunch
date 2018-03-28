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
    
    var activeField: UITextField?
    var lastOffset: CGPoint!
    var keyboardHeight: CGFloat!
   
    @IBOutlet weak var allStackView: UIStackView!
    
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
        self.hideKeyboard()
        
        enteredRatingTextField.delegate = self
        enterLongitudeTextField.delegate = self
        enteredLatitudeTextField.delegate = self
        enteredLaunchNameTextField.delegate = self
       
        index = SelectedRiver.River.selectedRiver
        
        
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
    
   
    
//    @objc func keyBoardWillShow(notification: Notification) {
//
//        let info: NSDictionary = notification.userInfo! as NSDictionary
//        let keyboardSize = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
//        let keyboardY = view.frame.size.height - keyboardSize.height
//        originalHeight = view.frame.height
//        let editingTextFieldY: CGFloat! = activeTextField?.frame.origin.y
//
//
//        if editingTextFieldY < keyboardY - 60 {
//            UIView.animate(withDuration: 0.25, animations: {
//                self.view.frame = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: (self.view.frame.height - (self.allStackView.frame.origin.y + self.allStackView.frame.height)) + keyboardSize.height)
//            })
//        }
//
//
//    }
//    @objc func keyBoardWillHide(notification: Notification) {
//        UIView.animate(withDuration: 0.1) {
//            self.view.frame = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.originalHeight!)
//
//        }
//
//    }
    
    override func viewDidDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardDidShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardDidHide, object: nil)
    }
 

}

extension EnterLaunchDataViewController {
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
}


    
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
            
            UIView.animate(withDuration: 0.3, animations: {
                self.scrollView.contentOffset = CGPoint(x: self.lastOffset.x, y: collapseSpace + 10)
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


