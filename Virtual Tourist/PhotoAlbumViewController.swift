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

class PhotoAlbumViewController: UIViewController, NSFetchedResultsControllerDelegate {
    @IBOutlet weak var smallMapView: MKMapView!
    var mapLocation: CLLocationCoordinate2D? = nil
    var pin: Pin? = nil
    var numberOfItems = Constants.imagesPer
    var urlArray = [String]()
    

    

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
            collectionView.performBatchUpdates({
                self.pin?.photos?.removeAll()
                self.numberOfItems = Constants.imagesPer
                
            }, completion: nil)
            
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
        
        
        BackgroundOps.getPhotos(latitude: (pin?.latitude)!, longitude: (pin?.longitude)!) { urlArray,error in
            guard error == nil else {
                self.displayError(subtitle: "Pin GET failure")
                print("errr")
                print(error?.localizedDescription ?? "I don't know what happened.")
                return
            }
            
            guard let urlArray = urlArray, !urlArray.isEmpty else {
                print("No urls")
                return
            }
            
            self.numberOfItems = urlArray.count
            self.urlArray = urlArray    // URL array added
            
            
            DispatchQueue.main.async{
                self.collectionView.reloadData()
            }
        }


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
        
    }

}

extension PhotoAlbumViewController {
    func displayError(title: String = "Network failure",subtitle: String, secondaryAction: UIAlertAction? = nil) {
        let alert = UIAlertController(title: title, message: subtitle, preferredStyle: .alert)
        alert.addAction(.init(title: "Ok.", style: .default) { _ in alert.dismiss(animated: true, completion: nil) })   // Add action to dismiss alert
        if let secAction = secondaryAction {
            alert.addAction(secAction)
        }
        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
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
        print(numberOfItems)
        return numberOfItems
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "photoAlbumCollectionViewCell", for: indexPath) as! PhotoAlbumCollectionViewCell
        cell.photo.image = #imageLiteral(resourceName: "placeholder")
        
        if let empty = self.pin?.photos?.isEmpty, empty == true {   // Is empty gets overrided after first cell
            // No photos for given pin
            if self.urlArray.count > 0 {
                // We can load some photos
                BackgroundOps.getPhoto(url: self.urlArray[indexPath.row], completionHandler: { data in
                    if data != nil {
                        cell.photo.image = UIImage(data: data!)
                        //self.pin?.addToPhotos(Photo(image: data!, context: self.context)) // we autosave so we don't have to do this anyways
                        
                    }
                })
            }
        }else {
            // load from DB
            if numberOfItems >= indexPath.row {
                // In DB
                print(numberOfItems, urlArray.count, indexPath.row)
                let startInd = (pin?.photos?.startIndex)!
                
                guard let ind = pin?.photos?.index(startInd, offsetBy: indexPath.row) else {
                    return cell
                }
                
                guard let photo = pin?.photos?[ind], photo.photo != nil else {
                    print("nil photo")
                    return cell
                }
                cell.photo.image = UIImage(data: photo.photo!)

            }else {
                // Not DB
                print(urlArray.count, indexPath.row)
                print("Not in DB")
            }
        }
        
        return cell
    }
}
