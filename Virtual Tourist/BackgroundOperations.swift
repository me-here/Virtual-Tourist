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
    static func getPins(context: NSManagedObjectContext, entityName: String, completion: @escaping ([NSFetchRequestResult])->()) {
        DispatchQueue.global(qos: .background).async {
            let fetchEntity = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)

            do {
                let fetchedEntities: [NSFetchRequestResult] = try context.fetch(fetchEntity)
                completion(fetchedEntities)
            } catch {
                fatalError("Failed to fetch employees: \(error)")
            }
            
        }

    }
}
