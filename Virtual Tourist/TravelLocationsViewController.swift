//
//  TravelLocationsViewController.swift
//  Virtual Tourist
//
//  Created by Mihir Thanekar on 7/23/17.
//  Copyright © 2017 Mihir Thanekar. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class TravelLocationsViewController: UIViewController {
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet var pressDetector: [UILongPressGestureRecognizer]!
    var coordinateTapped: CLLocationCoordinate2D? = nil
    var pinTapped: Pin? = nil
    var context: NSManagedObjectContext {
        get{
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            guard let place = appDelegate.stack?.context else {
                fatalError("Context not found.")
            }
            
            return place
        }
    }
    //let minPressTime: Double = 2.0
    
    
    @IBAction func longPress(_ sender: Any) {
        let state = pressDetector[0].state
        if state == .began {   // When our finger is there, not lifted
            print("Felt a long press.")
            let screenRelativeLoc = pressDetector[0].location(in: mapView)
            let coordinate = mapView.convert(screenRelativeLoc, toCoordinateFrom: mapView)
            
            // Round the doubles so DB matches up
            let roundLat = round(coordinate.latitude * 1000) / 1000
            let roundLon = round(coordinate.longitude * 1000) / 1000
            let roundedCoordinate = CLLocationCoordinate2D(latitude: roundLat, longitude: roundLon)
            
            // Make annotation
            let annotation = MKPointAnnotation()
            annotation.coordinate = roundedCoordinate
            let annotationView = MKPinAnnotationView()
            mapView.view(for: annotation)
            
            // Settings
            annotationView.annotation = annotation
            annotationView.animatesDrop = true
            
            _ = Pin(latitude: roundLat, longitude: roundLon, context: context)
            BackgroundOps.immediateSave(context: context)
            
            DispatchQueue.main.async {
                self.mapView.addAnnotation(annotation)
            }
            
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //pressDetector[0].minimumPressDuration = minPressTime
        BackgroundOps.getDBItems(context: context, entityName: "Pin"){ pinArray in
            guard let pins = pinArray as? [Pin] else {
                print("Pin array error")
                return
            }
            
            for pin in pins {
                let annotationForPin = MKPointAnnotation()
                annotationForPin.coordinate = CLLocationCoordinate2D(latitude: pin.latitude, longitude: pin.longitude)
                
                self.mapView.addAnnotation(annotationForPin)
            }
        }
        
    }


}

extension TravelLocationsViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "TravelAnnotationView")
        annotationView.animatesDrop = true
        
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        // Go to next vc
        guard let coordinateTapped = view.annotation?.coordinate else {
            print("Invalid coordinates")
            return
        }
        
        self.coordinateTapped = coordinateTapped
        
        // Check for latitude and longitude
        let latPredicate = NSPredicate(format: "latitude = \(coordinateTapped.latitude)")
        let lonPredicate = NSPredicate(format: "longitude = \(coordinateTapped.longitude)")
        let combPred = NSCompoundPredicate(andPredicateWithSubpredicates: [latPredicate, lonPredicate]) // We combine our predecates since we can only accept one
        
        BackgroundOps.getDBItems(context: context, predicate: combPred, entityName: "Pin") { Pins in
            guard let pin = Pins.first as? Pin else {
                print("No pin with specified characteristics.")
                return
            }
            
            self.pinTapped = pin
        }
        
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: "goToPhotoAlbum", sender: self)
        }
    
    }
    
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        mapView.deselectAnnotation(view.annotation, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToPhotoAlbum" {
            let destination = segue.destination as! PhotoAlbumViewController
            if let loc = coordinateTapped {
                destination.mapLocation = loc
            }
            
            destination.pin = pinTapped // Set pin
            
            
        }
    }

}

