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

class MapViewController: UIViewController {
    
    var riverNumber: Int?
    let regionRadius: CLLocationDistance = 20000
    var riverIndex: Int?
    let riverData = RiverData()
    var locations = [String : JSON]()
    var initialLocation: CLLocation?
    
    @IBOutlet weak var riverNameLabel: UILabel!
    
    @IBOutlet weak var riverMapView: MKMapView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        

    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        //riverNumber = SelectedRiver.River.selectedRiver
        riverIndex = SelectedRiver.River.selectedRiver
        
        
        if let _ = riverIndex {
            //riverNameLabel.text = SelectedRiver.River.riverArray[river]
            zoomToRiver()
            addLaunchData()
            
        }  else {
            riverNameLabel.text = "No River Selected Yet"
            
        }
    }

    
    func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, regionRadius, regionRadius)
        riverMapView.setRegion(coordinateRegion, animated: true)
    }

    
    
    //MARK: - ZOOM TO AREA
    func zoomToRiver() {
        
        locations = riverData.riverData[riverIndex!]["launchinfo"][0]["location"].dictionaryValue
        let mylatitude = locations["latitude"]?.doubleValue
        let mylongitude = locations["longitude"]?.doubleValue
        initialLocation = CLLocation(latitude: mylatitude!, longitude: mylongitude!)
        centerMapOnLocation(location: initialLocation!)
        
        
        
    }
    //MAARK: - ADD PIN LOCATION FOR BOAT LAUNCH
    func addLaunchData() {
        for i in 0...riverData.riverData[riverIndex!]["launchinfo"].count {
            let title = riverData.riverData[riverIndex!]["launchinfo"][i - 1]["launch"].stringValue
            let locationName = riverData.riverData[riverIndex!]["river"].stringValue
            let mylatitude = riverData.riverData[riverIndex!]["launchinfo"][i - 1]["location"]["latitude"].doubleValue
            let mylongitude = riverData.riverData[riverIndex!]["launchinfo"][i - 1]["location"]["longitude"].doubleValue
            let coordinate = CLLocationCoordinate2D(latitude: mylatitude, longitude: mylongitude)
            let pin = BoatLaunchData(title: title, locationName: locationName, coordinate: coordinate)
            riverMapView.addAnnotation(pin)
            
        }
        
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        let placemark = MKPlacemark(coordinate: view.annotation!.coordinate, addressDictionary: nil)
        // The map item is the restaurant location
        let mapItem = MKMapItem(placemark: placemark)
        
        let launchOptions = [MKLaunchOptionsDirectionsModeKey:MKLaunchOptionsDirectionsModeTransit]
        mapItem.openInMaps(launchOptions: launchOptions)
    }
    
    @IBAction func mapSelector(_ sender: UISegmentedControl) {
        
        riverMapView.mapType = MKMapType.init(rawValue: UInt(sender.selectedSegmentIndex)) ?? .standard
        
        
        
    }
    
}
