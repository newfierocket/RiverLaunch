//
//  DropPinViewController.swift
//  RiverLaunch
//
//  Created by Christopher Hynes on 2018-03-20.
//  Copyright © 2018 Christopher Hynes. All rights reserved.
//

import UIKit
import MapKit
import SCLAlertView

protocol MyProtocol {
    func setResultOfDroppedPin(valueSent: [String : String])
}

protocol HandleMapSearch {
    func dropPinZoomIn(placemark:MKPlacemark)
}


class DropPinViewController: UIViewController, MKMapViewDelegate {

    
    @IBOutlet weak var riverDropPinMapView: MKMapView!
    
    var searchResultsController: UISearchController? = nil
    var delegate: MyProtocol?
    var selectedPin: MKPlacemark? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let alert1 = SCLAlertView()
        let alert2 = SCLAlertView()
        alert1.showInfo("Search or pinch to zoom")
        alert2.showInfo("Hold for 2 seconds to set location")
        
       
        let locationSearchTable = storyboard!.instantiateViewController(withIdentifier: "LocationSearchTable") as! MapSearchResultsViewController
        searchResultsController = UISearchController(searchResultsController: locationSearchTable)
        searchResultsController?.searchResultsUpdater = locationSearchTable
        
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(self.dropPinLocation))
        longPress.minimumPressDuration = 2.0
        riverDropPinMapView.addGestureRecognizer(longPress)
        
        
        let searchBar = searchResultsController!.searchBar
        searchBar.sizeToFit()
        searchBar.placeholder = "Search for places"
        navigationItem.titleView = searchResultsController?.searchBar
        searchResultsController?.hidesNavigationBarDuringPresentation = false
        searchResultsController?.dimsBackgroundDuringPresentation = true
        definesPresentationContext = true
        locationSearchTable.mapView = riverDropPinMapView
        locationSearchTable.handleMapSearchDelegate = self 
        
    }
    

    
    //MARK: - ADD DROPPED PIN TO MAP ----> MOVE TO OTHER MAP VIEW FOR ADDING LAUNCH DATA
    @objc func dropPinLocation(gestureRecognizer: UIGestureRecognizer) {
        
        for oldPin in riverDropPinMapView.annotations {
            if let title = oldPin.title, title == "Dropped Pin" {
                riverDropPinMapView.removeAnnotation(oldPin)
            }
        }
        
        let annotation = MKPointAnnotation()
        let touchedPoint = gestureRecognizer.location(in: riverDropPinMapView)
        let corrdinates = riverDropPinMapView.convert(touchedPoint, toCoordinateFrom: riverDropPinMapView)
        
        annotation.coordinate = corrdinates
        annotation.title = "Dropped Pin"
        riverDropPinMapView.addAnnotation(annotation)
    
        let corrdinatesToSend = ["latitude" : String(corrdinates.latitude), "longitude" : String(corrdinates.longitude)]
        delegate?.setResultOfDroppedPin(valueSent: corrdinatesToSend)
        navigationController?.popViewController(animated: true)
    }
    
    
    @IBAction func changeMapControl(_ sender: UISegmentedControl) {
        
        riverDropPinMapView.mapType = MKMapType.init(rawValue: UInt(sender.selectedSegmentIndex)) ?? .standard
    }
    

 
}

extension DropPinViewController: HandleMapSearch {
    func dropPinZoomIn(placemark:MKPlacemark){
        // cache the pin
        selectedPin = placemark
        // clear existing pins
        for oldPin in riverDropPinMapView.annotations {
            riverDropPinMapView.removeAnnotation(oldPin)
        }
        //riverDropPinMapView.removeAnnotation(self.riverDropPinMapView.annotations as! MKAnnotation)
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = placemark.coordinate
        annotation.title = placemark.name
        if let city = placemark.locality,
            let state = placemark.administrativeArea {
            annotation.subtitle = "\(city), \(state)"
        }
        riverDropPinMapView.addAnnotation(annotation)
        let span = MKCoordinateSpanMake(0.05, 0.05)
        let region = MKCoordinateRegionMake(placemark.coordinate, span)
        riverDropPinMapView.setRegion(region, animated: true)
    }
}
