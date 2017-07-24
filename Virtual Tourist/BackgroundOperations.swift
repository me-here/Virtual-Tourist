//
//  BackgroundOperations.swift
//  Virtual Tourist
//
//  Created by Mihir Thanekar on 7/23/17.
//  Copyright © 2017 Mihir Thanekar. All rights reserved.
//

import Foundation
import CoreData

class BackgroundOps {
    static func getDBItems(context: NSManagedObjectContext, entityName: String, completion: @escaping ([NSFetchRequestResult])->()) {
        DispatchQueue.global(qos: .background).async {
            let fetchEntity = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
            completeRequest(fetchEntity: fetchEntity, context: context, completion: completion)
        }

    }
    
    static func getPins(context: NSManagedObjectContext, entityName: String, completion: @escaping ([NSFetchRequestResult])->()) {
            let fetchEntity = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
            fetchEntity.predicate = NSPredicate(format: "Pin = %@", "")
            completeRequest(fetchEntity: fetchEntity, context: context, completion: completion)
    }
    
    static func completeRequest(fetchEntity: NSFetchRequest<NSFetchRequestResult>, context: NSManagedObjectContext, completion: @escaping (([NSFetchRequestResult])->())) {
        DispatchQueue.global(qos: .background).async {
            do {
                let fetchedEntities: [NSFetchRequestResult] = try context.fetch(fetchEntity)
                completion(fetchedEntities)
            } catch {
                fatalError("Failed to fetch employees: \(error)")
            }
        }
    }
    
    // Get photos for specified pin
    static func downloadPhotos(context: NSManagedObjectContext, latitude: Double, longitude: Double) {
        //getDBItems(context: <#T##NSManagedObjectContext#>, entityName: "Photos", completion: <#T##([NSFetchRequestResult]) -> ()#>)
    }
}
