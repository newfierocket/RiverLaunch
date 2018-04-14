//
//  RegisterViewController.swift
//  RiverLaunch
//
//  Created by Christopher Hynes on 2018-04-11.
//  Copyright © 2018 Christopher Hynes. All rights reserved.
//

import UIKit
import Firebase
import KVNProgress
import Reachability

class RegisterViewController: UIViewController {
    
    var activeField: UITextField?
    var lastOffset: CGPoint!
    let network = Reachability()!
    
    
    @IBOutlet weak var emailTextfield: UITextField!
    @IBOutlet weak var passwordTextfield: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    @IBOutlet weak var usernameTextfield: UITextField!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        emailTextfield.delegate = self
        passwordTextfield.delegate = self
        confirmPasswordTextField.delegate = self
        usernameTextfield.delegate = self
        
        
        let center: NotificationCenter = NotificationCenter.default
        center.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        center.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: NSNotification.Name.UIKeyboardDidHide, object: nil)
        contentView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(returnTextView(gesture:))))
       
    }
    override func viewDidDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardDidHide, object: nil)
    }

    
    @IBAction func registerButton(_ sender: UIButton) {
        guard let email = emailTextfield.text, email.count > 0 else { KVNProgress.showError(withStatus: "Enter a email"); return }
        guard let password = passwordTextfield.text, password.count > 0 else { KVNProgress.showError(withStatus: "Enter a Password"); return }
        guard let passwordCheck = confirmPasswordTextField.text, passwordCheck.count > 0 else { KVNProgress.showError(withStatus: "Confirm Password"); return }
        guard let userName = usernameTextfield.text, userName.count > 0 else { KVNProgress.showError(withStatus: "Enter a username"); return }
        
        
        if (password  == passwordCheck) && (password != "") {
            if network.connection != .none {
            Auth.auth().createUser(withEmail: emailTextfield.text!, password: passwordTextfield.text!) { (user, error) in
               
                    if error != nil {
                        KVNProgress.showError(withStatus: error.debugDescription)
            
                    } else {
                        guard let userID = user?.uid
                        
                            else {
                                KVNProgress.showError(withStatus: "Could not get userID")
                                return
                                
                        }
                        let database = Database.database().reference().child("users")
                        let dataToUpload = ["username" : userName, "email" : email]
                        database.child(userID).updateChildValues(dataToUpload)
                        self.dismiss(animated: true, completion: nil)
                    }
            }
            
            } else {
                KVNProgress.showError(withStatus: "No Network")
            }
            
        } else {
            KVNProgress.showError(withStatus: "Passwords Do Not Match")
        
        }
    }
    
}

extension RegisterViewController: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        activeField = textField
        lastOffset = scrollView.contentOffset
       
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
      
        activeField?.resignFirstResponder()
        activeField = nil
        return true
    }
    
    
}

extension RegisterViewController {
    
    @objc func keyboardWillShow(notification: NSNotification) {
       
        scrollView.contentSize = CGSize(width: view.frame.width, height: view.frame.height )
        
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        
        scrollView.contentSize = CGSize(width: view.frame.width, height: view.frame.height)
        
    }
    
    @objc func returnTextView(gesture: UIGestureRecognizer) {
        guard activeField != nil  else { return }
        activeField?.resignFirstResponder()
        activeField = nil
        scrollView.contentOffset = lastOffset
    }
    
    
    
}
