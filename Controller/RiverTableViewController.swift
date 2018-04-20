//
//  RiverTableViewController.swift
//  RiverLaunch
//
//  Created by Christopher Hynes on 2018-04-17.
//  Copyright © 2018 Christopher Hynes. All rights reserved.
//

import UIKit
import Firebase
import KVNProgress
import Reachability


class RiverTableViewController: UITableViewController {
    
    let table = [
            ["Launch Locations", "A map view of selectable locations with active directions."],
            ["Gallery", "View user uploaded photos or upload your own in the Gallery!"],
            ["Add New Location","Manually enter Lat/Long or use the Map View to drop a pin."],
            ["Sign Out", "You know what to do!"]
            ]
    var riverArray : [LaunchData] = [LaunchData]()
    var riverName: String?
    let networkStatus = Reachability()!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.estimatedRowHeight = 100.0
        tableView.rowHeight = UITableViewAutomaticDimension
        view.backgroundColor = UIColor(patternImage: UIImage(named: "Nighthawk")!)
        tableView.alwaysBounceVertical = false
        
       
        
        
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
        //KVNProgress.update(0.25, animated: true)
        
        let riverDB = Database.database().reference().child("launch").child(riverName!)
        
        riverDB.observeSingleEvent(of: .value, with:  { (snapShot) in
            if let _ = snapShot.value as? NSNull {
                //KVNProgress.update(0.75, animated: true)
                completion()
            } else {
                //KVNProgress.update(0.5, animated: true)
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
                
                //KVNProgress.update(0.75, animated: true)
                completion()
            }
            
            
        })
       
    }
    override func viewDidDisappear(_ animated: Bool) {
        riverArray = []
    }

   

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return table.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ButtonCell", for: indexPath) as! RiverTableViewCell
        cell.buttonLabel.text = table[indexPath.row][0]
        cell.buttonLabel.sizeToFit()
        cell.infoLabel.text = table[indexPath.row][1]
        cell.infoLabel.sizeToFit()
        
        cell.textLabel?.textColor = .white
        
        cell.backgroundColor = UIColor(patternImage: UIImage(named: "Nighthawk")!)
        cell.layer.backgroundColor = UIColor(patternImage: UIImage(named: "Nighthawk")!).cgColor
        

        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 65
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let index = indexPath.row
        if index == 0 {
            launchLocations()
        } else if index == 1 {
            gallery()
        } else if index == 2 {
            setPin()
        } else if index == 3 {
            signout()
        } else {
            tableView.deselectRow(at: indexPath, animated: true)
            return
        }
        
      
        
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
    
    
    func launchLocations() {
        if networkStatus.connection != . none {
            KVNProgress.showSuccess(withStatus: "Getting Data")
            //KVNProgress.show(0, status: "Loading")
            getRiverData {
                //KVNProgress.update(1, animated: true)
                //KVNProgress.dismiss()
                
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
        
        func gallery() {
            performSegue(withIdentifier: "GoToGallery", sender: self)
        }
        func setPin() {
            performSegue(withIdentifier: "GoToPinDrop", sender: self)
        }
        
        func signout() {
            do {
                try Auth.auth().signOut()
                navigationController?.popToRootViewController(animated: true)
            } catch {
                print(error)
            }
            
        }
   

}

class RiverTableViewCell: UITableViewCell {
    
    @IBOutlet weak var buttonLabel: UILabel!
    
    @IBOutlet weak var infoLabel: UILabel!
    
    
    
}
