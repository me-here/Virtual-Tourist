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

    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let space: CGFloat = 5.0
        flowLayout.minimumInteritemSpacing = space
        flowLayout.minimumLineSpacing = space
        
        let numberOfColumns: CGFloat = 3.0
        let width = (self.view.frame.size.width - (2 * space))/numberOfColumns
        let height = (self.view.frame.size.height - (2 * space))/space
        flowLayout.itemSize = CGSize(width: width, height: height)
        
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


extension PhotoAlbumViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("Hey someone selected \(indexPath)")
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return Constants.imagesPer
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "photoAlbumCollectionViewCell", for: indexPath) as! PhotoAlbumCollectionViewCell
        
        cell.photo.image = #imageLiteral(resourceName: "placeholder")
        
        return cell
    }
}
