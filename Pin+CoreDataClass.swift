//
//  Pin+CoreDataClass.swift
//  Virtual Tourist
//
//  Created by Mihir Thanekar on 7/23/17.
//  Copyright © 2017 Mihir Thanekar. All rights reserved.
//

import Foundation
import CoreData

@objc(Pin)
public class Pin: NSManagedObject {
    convenience init(latitude: Double, longitude: Double, numberOfPhotos: Int16 = 0, context: NSManagedObjectContext) {
        if let entity = NSEntityDescription.entity(forEntityName: "Pin", in: context) {
            self.init(entity: entity, insertInto: context)
            self.latitude = latitude
            self.longitude = longitude
            self.numberOfPhotos = numberOfPhotos
        }else {
            print("Invalid entity for given context.")
            fatalError()    // Entity not accessible
        }
    }
}
