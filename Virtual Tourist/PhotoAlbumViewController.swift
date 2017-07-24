//
//  PhotoAlbumViewController.swift
//  Virtual Tourist
//
//  Created by Mihir Thanekar on 7/23/17.
//  Copyright © 2017 Mihir Thanekar. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class PhotoAlbumViewController: UIViewController {
    @IBOutlet weak var smallMapView: MKMapView!
    var mapLocation: CLLocationCoordinate2D? = nil
    var pin: Pin? = nil
    var context: NSManagedObjectContext {
        get{
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            guard let place = appDelegate.stack?.context else {
                fatalError("Context not found.")
            }
            return place
        }
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Settings
        smallMapView.isScrollEnabled = false
        smallMapView.isZoomEnabled = false
        
        guard let lat = mapLocation?.latitude, let lon = mapLocation?.longitude else {
            print("Point location is nil")
            return
        }
        
        //print(pin?.photos?.isEmpty)
        
        if let noPhotos = pin?.photos?.isEmpty {
            // What to do if there are no photos previously loaded
            // Make a flickr request
            print("Getting photos")
            BackgroundOps.getPhotos(latitude: lat, longitude: lon, completion: { urlArray,error in
                guard error == nil else {
                    print(error?.localizedDescription ?? "I don't know what happened.")
                    return
                }
                
                
            })
            print(noPhotos)
            // TODO: Load from Flickr
            
        }
        
        // Otherwise we just load from DB
        // TODO: Load from DB
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let pointLoc = mapLocation {
            //smallMapView.setCenter(mapLocation!, animated: false)
            var region = MKCoordinateRegion()
            region.center = pointLoc
            region.span = MKCoordinateSpan(latitudeDelta: 1, longitudeDelta: 1)
            smallMapView.setRegion(region, animated: false)
            
            let mapAnnotation = MKPointAnnotation()
            mapAnnotation.coordinate = pointLoc
            smallMapView.addAnnotation(mapAnnotation)   // Add our annotation
        }

    }

}
