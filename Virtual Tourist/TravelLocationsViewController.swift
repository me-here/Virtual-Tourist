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
    let minPressTime: Double = 10.0
    
    
    @IBAction func longPress(_ sender: Any) {
        if pressDetector[0].state == UIGestureRecognizerState.began {   // When our finger is there, not lifted
            print("Felt a long press.")
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        pressDetector[0].minimumPressDuration = minPressTime
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

