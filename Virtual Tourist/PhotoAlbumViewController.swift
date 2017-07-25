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
    var numberOfItems = Constants.imagesPer
    var imagesToAdd = [#imageLiteral(resourceName: "placeholder")]
    
    
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
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var toolbar: UIBarButtonItem!
    @IBAction func toolbarClicked(_ sender: Any) {
        if toolbar.title == "Remove Selected Pictures" {
            if let deletionIndices = collectionView.indexPathsForSelectedItems {
                numberOfItems -= deletionIndices.count
                print(deletionIndices.count)
                
                collectionView.performBatchUpdates({
                    self.collectionView.deleteItems(at: deletionIndices)
                    // Delete Core Data items
                }, completion: nil)
                
                
            }
        }else { // Add collection
            numberOfItems = Constants.imagesPer
            print("New collection added")
        }
    
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView.allowsMultipleSelection = true
        
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
        

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Map settings
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
        
        BackgroundOps.getPhotos(latitude: (pin?.latitude)!, longitude: (pin?.longitude)!) { urlArray,error in
                guard error == nil else {
                    print(error?.localizedDescription ?? "I don't know what happened.")
                    return
                }
                
                guard let urlArray = urlArray, !urlArray.isEmpty else {
                    print("No urls")
                    return
                }
                
                
                self.numberOfItems = urlArray.count
//                DispatchQueue.main.async {
//                    self.collectionView.reloadData()
//                }
        
        }
    
    }

}


extension PhotoAlbumViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //print("Hey someone selected \(indexPath)")
        
        collectionView.selectItem(at: indexPath, animated: true, scrollPosition: .right)
        
        toolbar.title = "Remove Selected Pictures"
    }
    
    
    
    
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return numberOfItems
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "photoAlbumCollectionViewCell", for: indexPath) as! PhotoAlbumCollectionViewCell
        
        if let empty = pin?.photos?.isEmpty, empty == true {    // Don't override things if they are already there
            cell.photo.image = #imageLiteral(resourceName: "placeholder")
            
            BackgroundOps.getPhotos(latitude: (pin?.latitude)!, longitude: (pin?.longitude
                )!, completion: { urlArray,error in
                guard error == nil else {
                    print(error?.localizedDescription ?? "I don't know what happened.")
                    return
                }

                guard let urlArray = urlArray, !urlArray.isEmpty else {
                    print("No urls")
                    return
                }
                    

                    self.numberOfItems = urlArray.count
                    DispatchQueue.main.async {
                        collectionView.reloadData()
                    }
                
                    
                // Instead of for, get element in pin.photos
                BackgroundOps.getPhoto(url: urlArray[indexPath.row]) { data in
                    guard data != nil else {
                        print("Data is nil")
                        return
                    }
                    print("yay!")
                    let newPhoto = Photo(image: data!, context: self.context)   // Add to DB
                    self.pin?.addToPhotos(newPhoto) // Connect photos to pin
                    
                    DispatchQueue.main.async {
                        cell.photo.image = UIImage(data: data!)
                    }
                    
                    
                }
                    
                
            })
        }else {
        // load from database
            print("TRY")
            guard self.numberOfItems > indexPath.row else { // Check something else
                print("Out of range")
                return cell
            }
            
            let startInd = (pin?.photos?.startIndex)!
            
            guard let ind = pin?.photos?.index(startInd, offsetBy: indexPath.row) else {
                return cell
            }
            
            print(ind)
            print(indexPath.row, numberOfItems) // numberOfItems isn't decreasing
            print(pin?.photos?[ind])
            guard let photo = pin?.photos?[ind], photo.photo != nil else {
                print("nil photo")
                return cell
            }
            cell.photo.image = UIImage(data: photo.photo!)
        }
        
        return cell
    }
}
