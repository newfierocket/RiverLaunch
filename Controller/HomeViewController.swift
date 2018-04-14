//
//  ViewController.swift
//  RiverLaunch
//
//  Created by Christopher Hynes on 2018-02-28.
//  Copyright © 2018 Christopher Hynes. All rights reserved.
//

import UIKit
import Firebase
import KVNProgress
import Reachability

class HomeViewController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    
    let networkStatus = Reachability()!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
       
    
        UITabBarItem.appearance().setTitleTextAttributes([NSAttributedStringKey.foregroundColor: UIColor.white], for: .normal)
        titleLabel.textColor = UIColor.white
        
    }
   
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    
   
    
    @IBAction func loginButton(_ sender: UIButton) {
        
        if networkStatus.connection != .none {
            Auth.auth().signIn(withEmail: emailTextField.text!, password: passwordTextField.text!) { (user, error) in
                if error != nil {
                    
                    let error2: NSError = error! as NSError
                    
                    //common log in errors
                    if error2.code == AuthErrorCode.accountExistsWithDifferentCredential.rawValue {
                        KVNProgress.showError(withStatus: "Accont Credentials Wrong", completion: nil)
                    } else if error2.code == AuthErrorCode.userNotFound.rawValue {
                        KVNProgress.showError(withStatus: "User Not Found", completion: nil)
                    } else if error2.code == AuthErrorCode.wrongPassword.rawValue {
                        KVNProgress.showError(withStatus: "Wrong Password", completion: nil)
                    } else if error2.code == AuthErrorCode.invalidEmail.rawValue {
                        KVNProgress.showError(withStatus: "Invalid Email", completion: nil)
                    }
             
                    
                } else {
                    KVNProgress.showSuccess(withStatus: "Logged In")
                    self.performSegue(withIdentifier: "GoToMain", sender: self)
                    
                }
            }
        } else {
            KVNProgress.showError(withStatus: "No Internet Try Again Later")
        }
    
    }
    
   
    
    
    @IBAction func forgotPasswordButton(_ sender: UIButton) {
        var textfield = UITextField()
        
        let alert = UIAlertController(title: "Password Reset", message: "Enter Email", preferredStyle: .alert)
        alert.addTextField { (enteredTextfield) in
            enteredTextfield.placeholder = "Email"
            textfield = enteredTextfield
            
        }
        let action = UIAlertAction(title: "Password Reset", style: .default) { (alert) in
            if let emailToSend = textfield.text {
                if self.networkStatus.connection != .none {
                    Auth.auth().sendPasswordReset(withEmail: emailToSend) { (error) in
                        if let error = error {
                            KVNProgress.showError(withStatus: error.localizedDescription)
                            
                        } else {
                            KVNProgress.showSuccess(withStatus: "Password Reset Email Sent")
                            
                        }
                    }
                } else {
                    KVNProgress.showError(withStatus: "Network Error")
                }
            }
            
        }
        
        alert.addAction(action)
        
        present(alert, animated: true, completion: nil)
    
    }
    
    

}





