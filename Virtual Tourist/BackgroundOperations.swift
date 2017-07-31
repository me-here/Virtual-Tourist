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
        //DispatchQueue.global(qos: .background).async {
            let fetchEntity = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
            if predicate != nil {
                fetchEntity.predicate = predicate
            }
            completeRequest(fetchEntity: fetchEntity, context: context, completion: completion)
        //}

    }
    
    // completeRequest is synchronouse because we don't want the rest of the app to move forward accidentally without the pin.
    private static func completeRequest(fetchEntity: NSFetchRequest<NSFetchRequestResult>, context: NSManagedObjectContext, completion: @escaping (([NSFetchRequestResult])->())) {
        //DispatchQueue.global(qos: .background).async {
            do {
                let fetchedEntities: [NSFetchRequestResult] = try context.fetch(fetchEntity)
                completion(fetchedEntities)
            } catch {
                fatalError("Failed to fetch employees: \(error)")
            }
        //}
    }
    
    
    static func requestWith(requestType: String, requestURL: String, completionHandler: @escaping ([String: AnyObject]?, Error?)-> Void) {
        
        let baseURL = URL(string: requestURL)!
        var request = URLRequest(url: baseURL)
        request.httpMethod = requestType
        request.timeoutInterval = 5
        
        let task = URLSession.shared.dataTask(with: request, completionHandler: {(data, response, error) in
            guard error == nil, let bytesData = data else {
                completionHandler(nil, error)
                print("problem")
                print(error ?? "Something went wrong")
                return
            }
            
            do{
                guard let deserializedJSONData = try JSONSerialization.jsonObject(with: bytesData, options: .allowFragments) as? [String: AnyObject] else {
                    print("Deserialization failure")
                    completionHandler(nil, error)
                    return
                }
                
                
                
                completionHandler(deserializedJSONData, nil)
            }catch{
                completionHandler(nil, error)
            }
        })
        
        task.resume()
    }
    


    static func getPhotos(latitude: Double, longitude: Double, page: Int, completion: @escaping ([String]?, Error?) -> ()) {
        let getPhotosURL = "\(Constants.FlickrBaseURL)method=\(Constants.flickrGetPhotos)&api_key=\(Constants.apiKEY)&page=\(page)&lat=\(latitude)&lon=\(longitude)&extras=\(Constants.urlFormat)&per_page=\(Constants.imagesPer)&format=\(Constants.format)&nojsoncallback=\(Constants.noJSONCallback)"
        print(getPhotosURL)
        print(latitude, longitude)
        
        
        requestWith(requestType: "GET", requestURL: getPhotosURL, completionHandler: {
            photosJSON,error in
            //print(photosJSON)
            guard error == nil, let photosJSON = photosJSON, let photos = photosJSON["photos"] as? [String: AnyObject] else {
                print("Err with request")
                completion(nil, error)
                return
            }
            
            let photo = photos["photo"] as! [[String: AnyObject]]   // Must succeed because there isn't an error
            var photosURLS = [String]()
            for pic in photo {
                guard let url = pic["url_m"] as? String else {  // Get url
                    continue
                }
                photosURLS.append(url)  // Add url to array
            }
            //print(photosURLS)
            completion(photosURLS, nil)
        })
    }
    
    static func getPhoto(url: String, completionHandler: @escaping (Data?)->()) {
        let baseURL = URL(string: url)!
        let task = URLSession.shared.dataTask(with: baseURL) {
            (data, response, error) in
            if error == nil {
                DispatchQueue.main.async {
                    completionHandler(data)
                }
                
            }
        }
        task.resume()
    }
    
}
