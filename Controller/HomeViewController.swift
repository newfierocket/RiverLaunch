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

class HomeViewController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
  
    @IBOutlet weak var emailTextField: UITextField!
    
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UITabBarItem.appearance().setTitleTextAttributes([NSAttributedStringKey.foregroundColor: UIColor.red], for: .normal)
        
        titleLabel.textColor = UIColor.flatWhite
        
        
    }
    
    
    @IBAction func loginButton(_ sender: UIButton) {
        
        Auth.auth().signIn(withEmail: emailTextField.text!, password: passwordTextField.text!) { (user, error) in
            if error != nil {
                print("error Signing in")
                print(error!)
                let error2: NSError = error! as NSError
                
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
                print("User Authenticated")
                self.performSegue(withIdentifier: "GoToMain", sender: self)
                //SVProgressHUD.dismiss()
            }
        }
    
    }
    
    @IBAction func registerButton(_ sender: UIButton) {
        
        Auth.auth().createUser(withEmail: emailTextField.text!, password: passwordTextField.text!) { (user, error) in
            
            if error != nil {
                print(error!)
                let error2: NSError = error! as NSError
                print("hi")
                
                if error2.code == AuthErrorCode.invalidEmail.rawValue {
                    
                    KVNProgress.showError(withStatus: "Invalid Email", completion: nil)
                    
                }else if error2.code == AuthErrorCode.networkError.rawValue {
                    
                    KVNProgress.showError(withStatus: "Network Error", completion: nil)
                    
                }else if error2.code == AuthErrorCode.weakPassword.rawValue {
                    
                    KVNProgress.showError(withStatus: "Weak Password", completion: nil)
                    
                }else if error2.code == AuthErrorCode.emailAlreadyInUse.rawValue {
                    
                    KVNProgress.showError(withStatus: "Email Already In Use", completion: nil)
                }
            } else {
                //sucess
                print("Success")
                self.performSegue(withIdentifier: "GoToMain", sender: self)
                //SVProgressHUD.dismiss()
            }
        }
        
    }
    
    

}

