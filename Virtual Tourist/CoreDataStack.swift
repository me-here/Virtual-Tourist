//
//  CoreDataStack.swift
//  Virtual Tourist
//
//  Created by Mihir Thanekar on 7/23/17.
//  Copyright © 2017 Mihir Thanekar. All rights reserved.
//

import Foundation
import CoreData

struct CoreDataStack {
    private let model: NSManagedObjectModel
    internal let coordinator: NSPersistentStoreCoordinator
    private let modelURL: URL
    internal let dbURL: URL
    let context: NSManagedObjectContext
    
    init?(modelName: String) {
        guard let modelURL = Bundle.main.url(forResource: modelName, withExtension: "momd") else {
            print("I couldn't find the \(modelName) in the bundle")
            return nil
        }
        self.modelURL = modelURL
        
        guard let model = NSManagedObjectModel(contentsOf: modelURL) else {
            print("Couldn't create a model from the url: \(modelURL)")
            return nil
        }
        
        self.model = model
        
        coordinator = NSPersistentStoreCoordinator(managedObjectModel: model)
        
        context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        context.persistentStoreCoordinator = coordinator
        
        let fm = FileManager.default
        
        guard let documentsURL = fm.urls(for: .documentDirectory, in: .userDomainMask).first else {
            print("Documents directory unreachable.")
            return nil
        }
        
        dbURL = documentsURL.appendingPathComponent("LocationsModel.sqlite")    // Add our model
        
        let options = [NSInferMappingModelAutomaticallyOption: true, NSMigratePersistentStoresAutomaticallyOption: true]
        
        do {
            try addStoreCoordinator(NSSQLiteStoreType, configuration: nil, storeURL: dbURL, options: options as [NSObject : AnyObject])
        }catch {
            print("Can't add a store att \(dbURL)")
        }
    }
    
    func addStoreCoordinator(_ storeType: String, configuration: String?, storeURL: URL, options: [NSObject: AnyObject]?) throws {
        try coordinator.addPersistentStore(ofType: storeType, configurationName: configuration, at: storeURL, options: options)
    }

}

internal extension CoreDataStack {
    func dropAllData() throws {
        try coordinator.destroyPersistentStore(at: dbURL, ofType: NSSQLiteStoreType, options: nil)
        try addStoreCoordinator(NSSQLiteStoreType, configuration: nil, storeURL: dbURL, options: nil)
    }
}

extension CoreDataStack {
    func saveContext() throws {
        if context.hasChanges {
            try context.save()
        }
    }
    
    func autosave(_ delayInSeconds: Int) {
        if delayInSeconds > 0 {
            do {
                try saveContext()
                //print("Autosaving")
            }
            catch {
                print("Error with save")
            }
        }

        let deadline = DispatchTime.now() + Double(delayInSeconds)
        
        DispatchQueue.main.asyncAfter(deadline: deadline) {
            self.autosave(delayInSeconds)
        }
    }

}
