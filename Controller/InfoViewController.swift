//
//  InfoViewController.swift
//  RiverLaunch
//
//  Created by Christopher Hynes on 2018-03-14.
//  Copyright © 2018 Christopher Hynes. All rights reserved.
//

import UIKit
import Firebase
import SwiftyJSON
import KVNProgress
import Reachability

class InfoViewController: UIViewController {
    
    
    var riverArray : [LaunchData] = [LaunchData]()
    var riverName: String?
    let networkStatus = Reachability()!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {

        if let riverIndex = SelectedRiver.River.selectedRiver {
            title = riverIndex
            riverName = riverIndex
        } else {
            title = "No River Selected"
        }
        
    }
    
    
    
    //MARK: - GET RIVER DATA COMPLETION
    
    func getRiverData(completion: @escaping () -> Void) {
        KVNProgress.update(0.25, animated: true)
        let riverDB = Database.database().reference().child("launch").child(riverName!)
        
        riverDB.observeSingleEvent(of: .value, with:  { (snapShot) in
            if let _ = snapShot.value as? NSNull {
                KVNProgress.update(0.75, animated: true)
                completion()
            } else {
                KVNProgress.update(0.5, animated: true)
                let snapShotValue = snapShot.value as! Dictionary<String, AnyObject>
                let keyArray = snapShotValue.keys
                
                for key in keyArray {
                    let launchData = LaunchData()
                    launchData.launchName = snapShotValue[key]!["launchname"] as! String
                    launchData.latitude = snapShotValue[key]!["latitude"] as! String
                    launchData.longitude = snapShotValue[key]!["longitude"] as! String
                    launchData.rating = snapShotValue[key]!["rating"] as! String
                    
                    self.riverArray.append(launchData)
                    
                }
                
                KVNProgress.update(0.75, animated: true)
                completion()
            }
            
     
        })
        
        
        
        
    }
    
    @IBAction func launchLoacationsButton(_ sender: UIButton) {
        if networkStatus.connection != . none {
            KVNProgress.show(0, status: "Loading")
            getRiverData {
                KVNProgress.update(1, animated: true)
                KVNProgress.dismiss()
                print("Completion")
                self.performSegue(withIdentifier: "GoToMapView", sender: self)
            }
        } else {
            performSegue(withIdentifier: "GoToMapView", sender: self)
        }
        
        
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "GoToMapView" {
            let destinationVC : MapViewController = segue.destination as! MapViewController
            destinationVC.riverArray = self.riverArray
            
        }
          
        
        
    }
    override func viewDidDisappear(_ animated: Bool) {
        riverArray = []
    }
        
    @IBAction func signOutButton(_ sender: UIButton) {
    
        do {
            try Auth.auth().signOut()
            navigationController?.popToRootViewController(animated: true)
        } catch {
            print(error)
        }
        
    }
    
        
}
