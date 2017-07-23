//
//  TravelLocationsViewController.swift
//  Virtual Tourist
//
//  Created by Mihir Thanekar on 7/23/17.
//  Copyright © 2017 Mihir Thanekar. All rights reserved.
//

import UIKit
import MapKit

class TravelLocationsViewController: UIViewController {
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet var pressDetector: [UILongPressGestureRecognizer]!
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
            
            DispatchQueue.main.async {
                self.mapView.addAnnotation(annotation)
            }
            
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //pressDetector[0].minimumPressDuration = minPressTime
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
        
        performSegue(withIdentifier: "goToPhotoAlbum", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToPhotoAlbum" {
            // Tell the vc stuff
            // TODO: Make other vc's class
            //var destination = storyboard?.instantiateViewController(withIdentifier: "")
        }
    }

}

