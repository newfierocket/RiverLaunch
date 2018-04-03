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

class MapViewController: UIViewController, MKMapViewDelegate {
   
    //MARK - VARIABLES
    let regionRadius: CLLocationDistance = 20000
    var index: Int?
    var initialLocation: CLLocation?
    var riverName: String?
    var riverArray : [LaunchData] = [LaunchData]()
    var renderCount: Int = 0
   
    
    //MARK - OUTLETS
    @IBOutlet weak var riverMapView: MKMapView!
    @IBOutlet weak var launchPickerView: UIPickerView!
    @IBOutlet weak var pickerViewContainer: UIView!
    @IBOutlet weak var pickerToolBar: UIToolbar!
    
    
    //MARK - VIEWDIDLOAD
    override func viewDidLoad() {
       
        super.viewDidLoad()
        launchPickerView.delegate = self
        launchPickerView.dataSource = self
        pickerViewContainer.isHidden = true
        //pickerToolBar.setBackgroundImage(UIImage(named:"Nighthawk"), forToolbarPosition: .any, barMetrics: .default)
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissPickerView))
        view.addGestureRecognizer(tap)
        
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
       
        
        self.getRiverData {
            self.addLaunchData()
            if self.riverArray.count == 1 {
             self.zoomToRiver(with: self.riverArray[0])
            }
            
        }
       
        
        let addButtonItem = UIBarButtonItem(barButtonSystemItem: .organize, target: self, action: #selector(loadPickerWheel))
        navigationItem.rightBarButtonItem = addButtonItem
    }
   
    
    //MARK: - DISMISS PICKER VIEW
    
    @objc func dismissPickerView() {
        pickerViewContainer.isHidden = true
     
    }
    //MARK: - PICKER DONE BUTTON
    @IBAction func pickerDoneButton(_ sender: UIBarButtonItem) {
        let index = launchPickerView.selectedRow(inComponent: 0)
        zoomToRiver(with: riverArray[index])
        self.pickerViewContainer.isHidden = true
        
        
    }
    
   
    
    //MARK: - CLEAR RIVERARRAY TO STOP DUPLICATE ENTRIES
    override func viewWillDisappear(_ animated: Bool) {
        
        riverArray = []
        renderCount = 0
    }
    //MARK: - LOAD PICKER WHEEL BUTTON
    @objc func loadPickerWheel() {
       
        if riverArray.count > 0 {
            pickerViewContainer.isHidden = false
       
        launchPickerView.reloadAllComponents()
        
        } else {
        KVNProgress.showError(withStatus: "No Data to Load")
        }
    }
  
}


//MARK: - GET DATA
extension MapViewController {
    
    func mapViewDidFinishRenderingMap(_ mapView: MKMapView, fullyRendered: Bool) {
        
        if riverMapView.annotations.count <= 1 && renderCount == 0 {
            KVNProgress.showError(withStatus: "No Data Added!")
            
        } else if riverMapView.annotations.count > 1 && (renderCount > 0 && renderCount < 2) {
            KVNProgress.showSuccess(withStatus: "Data Loaded")
           
        }
         renderCount += 1
       
    }
 
    //MARK: - GET RIVER DATA COMPLETION
    func getRiverData(completion: @escaping () -> Void) {
        
        
        let riverDB = Database.database().reference().child("launch").child(riverName!)
        
        riverDB.observe(.childAdded) { (snapShot) in
            
            let snapShotValue = snapShot.value as! Dictionary<String, String>
            
            let launchData = LaunchData()
            launchData.launchName = snapShotValue["launchname"]!
            launchData.latitude = snapShotValue["latitude"]!
            launchData.longitude = snapShotValue["longitude"]!
            launchData.rating = snapShotValue["rating"]!
           
            self.riverArray.append(launchData)
            
            completion()
            
            
        }
        
    }
    
}
//MARK - MAPKIT FUNCTIONS/DELEGATES
extension MapViewController {
    
    
    
    //MARK: - ADD PIN LOCATION FOR BOAT LAUNCH FROM FIREBASE DATA
    func addLaunchData() {
        
        for i in 0..<riverArray.count {
            let title = riverName
            let launchName = riverArray[i].launchName
            let mylatitude = Double(riverArray[i].latitude)
            let mylongitude = Double(riverArray[i].longitude)
            let coordinate = CLLocationCoordinate2D(latitude: mylatitude!, longitude: mylongitude!)
            let pin = BoatLaunchData(title: launchName, locationName: title!, coordinate: coordinate)
            
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
    func zoomToRiver(with location: LaunchData) {
        
        
            let myLatitude = Double(location.latitude)
            let myLongitude = Double(location.longitude)
            initialLocation = CLLocation(latitude: myLatitude!, longitude: myLongitude!)
            centerMapOnLocation(location: initialLocation!)
            
        }
        
    
}

extension MapViewController: UIPickerViewDelegate, UIPickerViewDataSource {
        
    func numberOfComponents(in launchPickerView: UIPickerView) -> Int {
        return 1
        
    }
    
    func pickerView(_ launchPickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
       
        return riverArray.count
        
    }
    
    
    
    func pickerView(_ launchPickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let pickerLabel = UILabel()
        let title = riverArray[row].launchName
        pickerLabel.text = title
        pickerLabel.textAlignment = .center
        pickerLabel.textColor = UIColor.flatWhite
        pickerLabel.font = UIFont.boldSystemFont(ofSize: 20)
        return pickerLabel
    }
    
//    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
//        return riverArray[row].launchName
//    }
//
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
    
    }

    
}










