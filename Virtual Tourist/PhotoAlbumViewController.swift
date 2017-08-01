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
    
    var context: NSManagedObjectContext {
        get{
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            guard let place = appDelegate.stack?.context else {
                fatalError("Context not found.")
            }
            return place
        }
    }

    var numPhotos: Int {
        get {
            let urlsCount = pin?.numberOfPhotos
            return Int(urlsCount!)
        }
        set {
            context.perform {
                self.pin?.numberOfPhotos = Int16(newValue)
            }
        }
    }
    
    var flickrPage = 1

    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var toolbar: UIBarButtonItem!
    @IBAction func toolbarClicked(_ sender: Any) {
        if toolbar.title == "Remove Selected Pictures" {
            if let deletionIndices = collectionView.indexPathsForSelectedItems {
                numberOfItems -= deletionIndices.count
                numPhotos -= deletionIndices.count
                print(deletionIndices.count)
                
                collectionView.performBatchUpdates({
                    self.collectionView.deleteItems(at: deletionIndices)
                    // Delete Core Data items
                    
                }, completion: { _ in
                    BackgroundOps.immediateSave(context: self.context)
                    self.toolbar.title = "Add Collection"
                })
                
                
            }
        }else { // Add collection
            flickrPage += 1
            collectionView.performBatchUpdates({
                self.pin?.photos?.removeAll()
                self.numPhotos = 0
                self.getPhotosUrls(page: self.flickrPage)
            }, completion: {_ in
                self.collectionView.reloadData()
            })

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
        
        if numPhotos == 0 {
            getPhotosUrls(page: flickrPage)
        }


    }
    
    func getPhotosUrls(page: Int) {
        BackgroundOps.getPhotos(latitude: (pin?.latitude)!, longitude: (pin?.longitude)!, page: page) { urlArray,error in
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
            
            self.numPhotos = urlArray.count
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
    func displayError(title: String = "Network failure",subtitle: String, secondaryHandler: (()->())? = nil) {
        let alert = UIAlertController(title: title, message: subtitle, preferredStyle: .alert)
        alert.addAction(.init(title: "Ok.", style: .default) { _ in alert.dismiss(animated: true, completion: nil) })   // Add action to dismiss alert
        if let secAction = secondaryHandler {
            alert.addAction(UIAlertAction(title: "Retry", style: UIAlertActionStyle.destructive) {_ in
                secAction()
            })
        }
        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func singleShotSave(_ delayInSeconds: Int) {
        let deadline = DispatchTime.now() + Double(delayInSeconds)
        
        DispatchQueue.main.asyncAfter(deadline: deadline) {
            BackgroundOps.immediateSave(context: self.context)
            print("Single shot saved")
        }
    }

}


extension PhotoAlbumViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //collectionView.selectItem(at: indexPath, animated: true, scrollPosition: .right)
        grayCell(at: indexPath, amount: 0.5)
        toolbar.title = "Remove Selected Pictures"
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        grayCell(at: indexPath, amount: 1.0)
        if collectionView.indexPathsForSelectedItems?.count == 0 {
            toolbar.title = "New Collection"
        }
    }
    
    func grayCell(at indexPath: IndexPath, amount: Double) {
        let cell = collectionView.cellForItem(at: indexPath)
        cell?.alpha = CGFloat(amount)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print("\(numPhotos) URLs expected.")
        singleShotSave(5)   // 5 seconds should be plenty of time for the cells to load so we have one I/O save each time
        return numPhotos
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "photoAlbumCollectionViewCell", for: indexPath) as! PhotoAlbumCollectionViewCell
        //cell.photo.image = #imageLiteral(resourceName: "placeholder")
        
        if let empty = self.pin?.photos?.isEmpty, empty == true {
            cell.photo.image = #imageLiteral(resourceName: "placeholder")
            
        }
        
        if (self.pin?.photos?.count)! <= urlArray.count && urlArray.count > 0 {   // If photo isn't in DB
                BackgroundOps.getPhoto(url: self.urlArray[indexPath.row], completionHandler: { data in
                    if data != nil {
                        cell.photo.image = UIImage(data: data!) // Set cell's image
                        self.pin?.addToPhotos(Photo(image: data!, context: self.context)) // add photo in relationship
                        
                    }else {
                        self.displayError(subtitle: "Could not GET Photo.") {
                            DispatchQueue.main.async {
                                collectionView.reloadData()
                            }
                        }
                    }
                })
            
        }else { // Photo is in DB so load it
            if numberOfItems >= indexPath.row {
                let startInd = (pin?.photos?.startIndex)!   // Get start index in set
                
                guard let ind = pin?.photos?.index(startInd, offsetBy: indexPath.row) else {    // current photo's index
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
