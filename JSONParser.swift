//
//  JSONParser.swift
//
//  Created by Vojta Stavik on 15/06/15.
//  Copyright (c) 2015 STRV. All rights reserved.
//

import Foundation
import CoreData
import SwiftyJSON
import SwiftTweaks

public protocol JSONParser {
    
    var id : String { get set }
    func loadData(json: JSON)
}


public extension JSONParser where Self: NSManagedObject {

    public static func new(json: JSON, customId: String?, context: NSManagedObjectContext?) -> Self?  {
        
        if NSOperationQueue.currentQueue() !== NSOperationQueue.Shared.parsingQueue {
            print("#JSONParser-Warning: You run new() outside NSOperationQueue.Shared.parsingQueue. This can cause duplicities.")
        }
        
        
        let tempContext = context ?? NSManagedObjectContext.createTempContext()

        guard var
            returnObject = Self.findOrCreateElement(customId, context: tempContext) as? Self
        else { return nil }

        
        if let customId = customId {
            
            returnObject.id = customId
        }

        
        returnObject.loadData(json)
        
        if context == nil {
            // we save context only if we created it
            tempContext.saveContextWithDefaultErrorHandling()
        }
        
        return returnObject
    }
    
    
    public static func new(json: [JSON], customIdKey: String?, context: NSManagedObjectContext?) -> [Self]  {
        
        let tempContext = context ?? NSManagedObjectContext.createTempContext()
        
        var finalArray = [Self]()
        
        for objectJSON in json {

            var customId : String?
            
            if let customIdKey = customIdKey {
                
                if let aCustomId = objectJSON[customIdKey].string {
                    
                    customId = aCustomId
                } else {
                    
                    log.message("mrdka")
                }
            }
            
            if let newObject = new(objectJSON, customId: customId, context: tempContext) {
                
                finalArray.append(newObject)
            }
        }
        
        if context == nil {
            // we save context only if we created it
            tempContext.saveContextWithDefaultErrorHandling()
        }
        
        return finalArray
    }
    
    
    
    public static func id(id: String, context: NSManagedObjectContext) -> Self? {
        
        return Self.fetchObject(NSPredicate(format: "id==%@", argumentArray: [id]), context: context)
    }
}



public extension NSManagedObjectContext {
    
    public static func performAsync(parentContext parentContext: NSManagedObjectContext? = nil, tasks: (context: NSManagedObjectContext) -> (), completion: (()->())? = nil ) {
        
        backgroundQueue {
            
            self.performAndWait(parentContext: parentContext, tasks: tasks)
            
            mainQueue {
                
                completion?()
            }
        }        
    }
    
    
    public static func performAndWait(parentContext parentContext: NSManagedObjectContext? = nil, tasks: (context: NSManagedObjectContext) -> ()) {
        
        let parseOperation = NSBlockOperation() {
            
            let tempContext = NSManagedObjectContext.createTempContext(parentContext)
            
            tasks(context: tempContext)
            
            tempContext.saveContextWithDefaultErrorHandling()
        }
        
        NSOperationQueue.Shared.parsingQueue.addOperations([parseOperation], waitUntilFinished: true)

        
        mainQueue {

            if NSManagedObjectContext.mainContext.hasChanges {
                
                NSManagedObjectContext.mainContext.saveContextWithDefaultErrorHandling()
            }
        }
        
    }
}



extension NSOperationQueue {
    
    struct Shared {
        
        static var parsingQueue : NSOperationQueue = {
            
            let queue = NSOperationQueue()
            queue.maxConcurrentOperationCount = 1
            return queue
            
            }()
    }
}
