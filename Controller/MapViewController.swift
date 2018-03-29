//
//  MapViewController.swift
//  RiverLaunch
//
//  Created by Christopher Hynes on 2018-03-11.
//  Copyright © 2018 Christopher Hynes. All rights reserved.
//

import UIKit
import MapKit
import Firebase
import SCLAlertView
import KVNProgress

class MapViewController: UIViewController, MKMapViewDelegate{
   
    //MARK - VARIABLES
    let regionRadius: CLLocationDistance = 20000
    var index: Int?
    let riverData = RiverData()
    var initialLocation: CLLocation?
    var riverName: String?
    var riverArray : [LaunchData] = [LaunchData]()
    var renderCount: Int = 0
  
    //MARK - OUTLETS
    @IBOutlet weak var riverMapView: MKMapView!
    
    
    
    //MARK - VIEWDIDLOAD
    override func viewDidLoad() {
       
        super.viewDidLoad()
        
        riverMapView.delegate = self
        riverMapView.showsUserLocation = true
        
        
        if let title = SelectedRiver.River.selectedRiver  {
        riverName = title
    
        } else {
            riverName = "No River Selected Yet"
        }
    }
    //MARK - VIEW WILL APPEAR
    override func viewWillAppear(_ animated: Bool) {
       
        getRiverData {
            self.addLaunchData()
            self.zoomToRiver()
        }
        
//        let addButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(actionAdd))
//        navigationItem.rightBarButtonItem = addButtonItem
    }
    
    //MARK: - CLEAR RIVERARRAY TO STOP DUPLICATE ENTRIES
    override func viewWillDisappear(_ animated: Bool) {
        print(riverArray.count)
        riverArray = []
        renderCount = 0
    }
    
    
    
}


//MARK: - GET DATA
extension MapViewController {
    
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
    
}
//MARK - MAPKIT FUNCTIONS/DELEGATES
extension MapViewController {
    
    func mapViewDidFinishRenderingMap(_ mapView: MKMapView, fullyRendered: Bool) {
        
        if riverArray.count == 0 && renderCount == 0 {
            KVNProgress.showError(withStatus: "No Data Entered Yet!!")
            renderCount += 1
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
    
    
    // MARK: - MAP SELECTOR
    @IBAction func mapSelector(_ sender: UISegmentedControl) {
        
        riverMapView.mapType = MKMapType.init(rawValue: UInt(sender.selectedSegmentIndex)) ?? .hybrid
        
    }
    
    //MARK: - HELPER FUNCTION TO CENTER ON MAP
    
    func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, regionRadius, regionRadius)
        riverMapView.setRegion(coordinateRegion, animated: true)
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
    
    //MARK: - ZOOM TO AREA
    func zoomToRiver() {
        
        let startingPoint = riverArray[0]
        if let myLatitude = Double(startingPoint.latitude) {
            let myLongitude = Double(startingPoint.longitude)
            initialLocation = CLLocation(latitude: myLatitude, longitude: myLongitude!)
            centerMapOnLocation(location: initialLocation!)
            
        }
        
    }
    
    
}








