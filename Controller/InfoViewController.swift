//
//  InfoViewController.swift
//  RiverLaunch
//
//  Created by Christopher Hynes on 2018-03-14.
//  Copyright © 2018 Christopher Hynes. All rights reserved.
//

import UIKit
import SwiftyJSON
import Firebase

class InfoViewController: UIViewController {
    
    let riverData = RiverData()
    var riverIndex: Int?
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
    }
    
    override func viewWillAppear(_ animated: Bool) {
       

        if let riverIndex = SelectedRiver.River.selectedRiver {
            title = riverIndex
    }
        
    }
        
    @IBAction func signOutButton(_ sender: UIButton) {
    
//        do {
//            try Auth.auth().signOut()
//            print("Signed Out!!!")
//            navigationController?.popToRootViewController(animated: true)
//        } catch {
//            print(error)
//        }
        
    }
    
        
        
        
    }
    

