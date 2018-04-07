//
//  ViewController.swift
//  RiverLaunch
//
//  Created by Christopher Hynes on 2018-02-28.
//  Copyright © 2018 Christopher Hynes. All rights reserved.
//

import UIKit
import ChameleonFramework
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
        self.hideKeyboard()
       
    
        UITabBarItem.appearance().setTitleTextAttributes([NSAttributedStringKey.foregroundColor: UIColor.flatWhite], for: .normal)
        titleLabel.textColor = UIColor.flatWhite
        
    }
    
    
    @IBAction func loginButton(_ sender: UIButton) {
        if networkStatus.connection != .none {
            Auth.auth().signIn(withEmail: emailTextField.text!, password: passwordTextField.text!) { (user, error) in
                if error != nil {
                    print(error!)
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
    
   
    
    @IBAction func registerButton(_ sender: UIButton) {
        
        Auth.auth().createUser(withEmail: emailTextField.text!, password: passwordTextField.text!) { (user, error) in
            
            if error != nil {
                print(error!)
                let error2: NSError = error! as NSError
            
                //check for common login errors
                if error2.code == AuthErrorCode.invalidEmail.rawValue {
                    KVNProgress.showError(withStatus: "Invalid Email", completion: nil)
                } else if error2.code == AuthErrorCode.networkError.rawValue {
                    KVNProgress.showError(withStatus: "Network Error", completion: nil)
                } else if error2.code == AuthErrorCode.weakPassword.rawValue {
                    KVNProgress.showError(withStatus: "Weak Password", completion: nil)
                } else if error2.code == AuthErrorCode.emailAlreadyInUse.rawValue {
                    KVNProgress.showError(withStatus: "Email Already In Use", completion: nil)
                }
            
            } else {
            
                self.performSegue(withIdentifier: "GoToMain", sender: self)
                KVNProgress.showSuccess(withStatus: "Registered")
            }
        }
        
    }
    
    

}

extension UIViewController {
    
    func hideKeyboard() {
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    
}
