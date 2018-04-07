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
import Reachability
class MapViewController: UIViewController, MKMapViewDelegate {
   
    //MARK - VARIABLES
    
    var regionRadius: CLLocationDistance = 20000
    var initialLocation: CLLocation?
    var riverName: String?
    var riverArray : [LaunchData] = [LaunchData]()
    var renderCount: Int = 0
    let networkStatus = Reachability()!
   
    
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
       
        let addButtonItem = UIBarButtonItem(barButtonSystemItem: .organize, target: self, action: #selector(loadPickerWheel))
        navigationItem.rightBarButtonItem = addButtonItem
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        addLaunchData()
        if riverArray.count == 1 {
            regionRadius = 20000
        } else {
            regionRadius = 1250000
            
        }
        if networkStatus.connection != .none {
            if riverArray.count > 0 {
                KVNProgress.showSuccess(withStatus: "\(riverArray.count) Locations Added")
                zoomToRiver(with: riverArray[0])
            } else {
                KVNProgress.showError(withStatus: "No Data Yet")
            }
        } else {
            KVNProgress.showError(withStatus: "No Network Connection")
        }
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



//MARK - MAPKIT FUNCTIONS/DELEGATES

extension MapViewController {
    
    //MARK: - ADD PIN LOCATION FOR BOAT LAUNCH FROM FIREBASE DATA
    
    func addLaunchData() {
        
        for i in 0..<riverArray.count {
            print(i)
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
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        guard let annotation = annotation as? BoatLaunchData else { return nil }
        
        let identifier = "marker"
        var view: MKMarkerAnnotationView
        
        if let dequeuedView = riverMapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKMarkerAnnotationView {
            
            dequeuedView.annotation = annotation
            view = dequeuedView
        } else {
            view = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            view.canShowCallout = true
            view.calloutOffset = CGPoint(x: -5, y: 5)
            view.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }
        
        return view
        
        }

    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        
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
 


    
}












