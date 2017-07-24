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
        if pressDetector[0].state == UIGestureRecognizerState.began {   // When our finger is there, not lifted
            print("Felt a long press.")
            let screenRelativeLoc = pressDetector[0].location(in: mapView)
            let coordinate = mapView.convert(screenRelativeLoc, toCoordinateFrom: mapView)
            
            // Make annotation
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            let annotationView = MKPinAnnotationView()
            mapView.view(for: annotation)
            
            // Settings
            annotationView.annotation = annotation
            annotationView.animatesDrop = true
            
            let p = Pin(latitude: coordinate.latitude, longitude: coordinate.longitude, context: context)
            //print(p.latitude, p.longitude, "-------")
            
            
            do {
                try context.save()
                print("NEW PIN ADDED!!!")
            }catch {
                print("database err")
            }
            
            
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
                
                print(pin.latitude, pin.longitude)
                
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
        coordinateTapped = (view.annotation?.coordinate)!
        print(coordinateTapped)
        //let fr = NSFetchRequest<Pin>(entityName: "Pin")
        let pin: NSFetchRequest<Pin> = Pin.fetchRequest()
        pin.predicate = NSPredicate(format: "latitude = \((coordinateTapped?.latitude)!)")
        let fetchedEntities: [Pin] = try! context.fetch(pin)
        //print(fetchedEntities.index(of: Pin(latitude: (coordinateTapped?.latitude)!, longitude: (coordinateTapped?.longitude)!, context: context)))
        for ent in fetchedEntities {
            print(ent.latitude, ent.longitude)
        }
        print(fetchedEntities.isEmpty)
        
        
        
        performSegue(withIdentifier: "goToPhotoAlbum", sender: self)
        
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToPhotoAlbum" {
            // Tell the vc stuff
            // TODO: Make other vc's class
            let destination = segue.destination as! PhotoAlbumViewController
            if let loc = coordinateTapped {
                destination.mapLocation = loc
            }
        }
    }

}

