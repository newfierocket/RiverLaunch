//
//  MapViewController.swift
//  RiverLaunch
//
//  Created by Christopher Hynes on 2018-03-11.
//  Copyright © 2018 Christopher Hynes. All rights reserved.
//

import UIKit
import MapKit
import SwiftyJSON
import Firebase
import SCLAlertView
import KVNProgress

class MapViewController: UIViewController, MKMapViewDelegate{
    
    
    
    //var riverNumber: Int?
    let regionRadius: CLLocationDistance = 20000
    var index: Int?
    let riverData = RiverData()
    //var locations = [String : JSON]()
    var initialLocation: CLLocation?
    var riverName: String?
    var riverArray : [LaunchData] = [LaunchData]()
    //let group = DispatchGroup()
    
    
    
    
    
    
    
    @IBOutlet weak var riverMapView: MKMapView!
    
    
    override func viewDidLoad() {
       
        super.viewDidLoad()
        
        
        
        
        riverMapView.delegate = self
        riverMapView.showsUserLocation = true
        //index = SelectedRiver.River.selectedRiver
        
       
        
        
        guard let title = SelectedRiver.River.selectedRiver else { fatalError() }
        
        
        riverName = title
        
        
            getRiverData {
                
                if self.riverArray.count > 0 {
                    self.addLaunchData()
                    self.zoomToRiver()
            
            } else {
                    //KVNProgress.showError(withStatus: "No Data Entered Yet!!")
                }
                
                
            }
       
    }
    
    
    
 

    //MARK: - MAP FUNCTIONS
    //MARK: - HELPER FUNCTION TO CENTER ON MAP
    
    func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, regionRadius, regionRadius)
        riverMapView.setRegion(coordinateRegion, animated: true)
    }
    
    //MARK: - ZOOM TO AREA
    func zoomToRiver() {
        if riverArray.count == 0 {
            print(riverArray.count)
            KVNProgress.showError(withStatus: "No Data Entered Yet!!")
            }
        
        let startingPoint = riverArray[0]
        if let myLatitude = Double(startingPoint.latitude) {
            let myLongitude = Double(startingPoint.longitude)
            initialLocation = CLLocation(latitude: myLatitude, longitude: myLongitude!)
            centerMapOnLocation(location: initialLocation!)
        
        }
        
    
    }
    
    
 
    //MARK: - TRANSFER DATA TO APPLE MAPS FOR DIRECTIONS.
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
       
        
        let apperance = SCLAlertView.SCLAppearance(showCircularIcon: false,  circleBackgroundColor: UIColor.white, contentViewColor: UIColor.flatWhite, titleColor: UIColor.flatBlack, subTitleColor: UIColor.white)
        let alert = SCLAlertView(appearance: apperance)
        
        alert.addButton("Get Directions") {
            let placemark = MKPlacemark(coordinate: view.annotation!.coordinate, addressDictionary: nil)
            let mapItem = MKMapItem(placemark: placemark)
            let launchOptions = [MKLaunchOptionsDirectionsModeKey:MKLaunchOptionsDirectionsModeDriving]
            mapItem.openInMaps(launchOptions: launchOptions)
        }
        alert.showInfo("Directions")
        
        
        
        
    
    }
 
    // MARK: - MAP SELECTOR
    @IBAction func mapSelector(_ sender: UISegmentedControl) {
        
        riverMapView.mapType = MKMapType.init(rawValue: UInt(sender.selectedSegmentIndex)) ?? .standard
      
    }
    
    //MARK: - RETRIEVE DATA FROM FIREBASE
    func getRiverData(completion: @escaping () -> Void) {
        
        let riverDB = Database.database().reference().child("launch").child(riverName!)
        
        riverDB.observe(.childAdded) { (snapShot) in
            let snapShotValue = snapShot.value as! Dictionary<String, String>
            let launchName = snapShotValue["launchname"]!
            
            let latitude = snapShotValue["latitude"]!
            let longitude = snapShotValue["longitude"]!
            let rating = snapShotValue["rating"]!
            
        
            
            let launchData = LaunchData()
            launchData.launchName = launchName
            launchData.latitude = latitude
            launchData.longitude = longitude
            launchData.rating = rating
            
            self.riverArray.append(launchData)
            
            completion()
            
        }
      
    }
    
    //MARK: - ADD PIN LOCATION FOR BOAT LAUNCH FROM FIREBASE DATA
    func addLaunchData() {
        
        for i in 0..<riverArray.count {
            let title = riverName
            let launchName = riverArray[i].launchName
            let mylatitude = Double(riverArray[i].latitude)
            let mylongitude = Double(riverArray[i].longitude)
            let coordinate = CLLocationCoordinate2D(latitude: mylatitude!, longitude: mylongitude!)
            let pin = BoatLaunchData(title: title!, locationName: launchName, coordinate: coordinate)
            
            riverMapView.addAnnotation(pin)
        
        }
        
    }
    
    //MARK: - CLEAR RIVERARRAY TO STOP DUPLICATE ENTRIES
    override func viewWillDisappear(_ animated: Bool) {
        riverArray = []
    }
    
}
