//
//  ViewController.swift
//  MapApp
//
//  Created by Eduardo on 9/01/16.
//  Copyright © 2016 EduardoAndrade. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {

    @IBOutlet weak var mapa: MKMapView!
    @IBOutlet var segmentControl : AVDSegmentedControl!
    @IBOutlet var imageBackground : UIImageView!
    
    private let manejador = CLLocationManager()
    
    var startLocation: CLLocation!
    var startDistance : CLLocationDistance!
    
    var pin : MKPointAnnotation!
    var distancia : Double!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        segmentControl.items = ["Normal", "Satélite", "Híbrido"]
        segmentControl.font = UIFont(name: "Avenir-Black", size: 14)
        segmentControl.borderColor = UIColor(white: 1.0, alpha: 0.3)
        segmentControl.selectedIndex = 1
        segmentControl.addTarget(self, action: "segmentValueChanged:", forControlEvents: .ValueChanged)
        
        
        manejador.delegate = self
        mapa.delegate = self
        manejador.desiredAccuracy = kCLLocationAccuracyBest
        manejador.requestWhenInUseAuthorization()
        manejador.distanceFilter = 50.0
        
        pin = nil
        distancia = 0.0
        mapa.mapType = .Satellite
        
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.Dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        
        //always fill the view
        blurEffectView.frame = self.imageBackground.bounds
        blurEffectView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        
        self.imageBackground.addSubview(blurEffectView)
    }
    
    
    func mapView(mapView: MKMapView, didUpdateUserLocation userLocation: MKUserLocation) {
        
//        let center = CLLocationCoordinate2D(latitude: userLocation.coordinate.latitude, longitude: userLocation.coordinate.longitude)
//        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
//        
//        self.mapa.setRegion(region, animated: true)
    }
    
    func segmentValueChanged(sender: AnyObject?){
        
        if segmentControl.selectedIndex == 0 {
            mapa.mapType = .Standard
        }
        else if segmentControl.selectedIndex == 1{
            mapa.mapType = .Satellite
        }
        else{
            mapa.mapType = .Hybrid
        }
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations.last! as CLLocation
        
        // ---
        let latestLocation: CLLocation = locations[locations.count - 1]
        
        if startLocation == nil {
            startLocation = latestLocation
        }
        
        let distanceBetween: CLLocationDistance = latestLocation.distanceFromLocation(startLocation)
        // ---
        
        if distanceBetween >= 50 {
            
            distancia = distancia + distanceBetween
            pin = MKPointAnnotation()
            pin.title = "Latitud: \(NSString(format:"%.3f", latestLocation.coordinate.latitude)), Longitud: \(NSString(format:"%.3f", latestLocation.coordinate.longitude))"
            pin.subtitle = "Distancia: \(NSString(format:"%.3f", distancia))"
            pin.coordinate = latestLocation.coordinate
            mapa.addAnnotation(pin)
            startLocation = nil
        }
        
        let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        
        self.mapa.setRegion(region, animated: true)

    }
    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == .AuthorizedWhenInUse {
            manejador.startUpdatingLocation()
            mapa.showsUserLocation = true
        } else {
            manejador.stopUpdatingLocation()
            mapa.showsUserLocation = false
        }
    }
    
    // MARK: Método que se lanza si hay un error
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        let alerta = UIAlertController(title: "ERROR", message: "error \(error.code)", preferredStyle: .Alert)
        let accionOK = UIAlertAction(title: "OK", style: .Default, handler: { accion in
            // ...
        })
        
        alerta.addAction(accionOK)
        self.presentViewController(alerta, animated: true, completion: nil)
    }

}

