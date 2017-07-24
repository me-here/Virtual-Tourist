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
    // getDBItems can be synchronous because it just makes the fetch request (a quick operation)
    static func getDBItems(context: NSManagedObjectContext, predicate: NSPredicate? = nil, entityName: String, completion: @escaping ([NSFetchRequestResult])->()) {
        DispatchQueue.global(qos: .background).async {
            let fetchEntity = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
            if predicate != nil {
                fetchEntity.predicate = predicate
            }
            completeRequest(fetchEntity: fetchEntity, context: context, completion: completion)
        }

    }
    
    // completeRequest is asynchronous because it queries the data, which could take a user- percievable amount of time
    private static func completeRequest(fetchEntity: NSFetchRequest<NSFetchRequestResult>, context: NSManagedObjectContext, completion: @escaping (([NSFetchRequestResult])->())) {
        DispatchQueue.global(qos: .background).async {
            do {
                let fetchedEntities: [NSFetchRequestResult] = try context.fetch(fetchEntity)
                completion(fetchedEntities)
            } catch {
                fatalError("Failed to fetch employees: \(error)")
            }
        }
    }
    
}
