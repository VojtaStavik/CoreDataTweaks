//
//  CoreDataTweaks.swift
//
//  Created by Vojta Stavik on 10/10/15.
//  Copyright © 2015 STRV. All rights reserved.
//

// *****
// You have to define NSManagedObjectContext.mainContext in order to use this
// *****

import CoreData

public class FetchedResultsController<T : NSManagedObject> : NSFetchedResultsController {
    
    init(predicate: NSPredicate?, sortDescriptors: [NSSortDescriptor]?, managedObjectContext context: NSManagedObjectContext, sectionNameKeyPath: String?, cacheName name: String?) {
        let request = NSFetchRequest(entityName: T.entityName)
        
        request.predicate = predicate
        request.sortDescriptors = sortDescriptors ?? []
        
        super.init(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: sectionNameKeyPath, cacheName: name)
    }
    
    var fetchedObjectsWithType : [T] {
        return super.fetchedObjects as? [T] ?? []
    }
}


public extension NSManagedObject {
    
    public class var entityName : String {
        return NSStringFromClass(self).componentsSeparatedByString(".").last!
    }
    
    public class func findOrCreateElement<T: NSManagedObject>(id: String?, context: NSManagedObjectContext = NSManagedObjectContext.mainContext) -> T? {
        guard let id = id else { return nil }
        
        let request = NSFetchRequest(entityName: entityName)
        request.predicate = NSPredicate(format: "id == '\(id)'", argumentArray: nil)
        
        do {
            if let object = try context.executeFetchRequest(request).first as? T {
                return object
            }
        } catch let error as NSError {
            log.error("Fetch error", error: error)
        }
        
        return NSEntityDescription.insertNewObjectForEntityForName(entityName, inManagedObjectContext: context) as? T
    }

    
    public class func fetchObject<T: NSManagedObject>(id: String, context: NSManagedObjectContext = NSManagedObjectContext.mainContext) -> T? {
        
        let entityName = NSStringFromClass(self).componentsSeparatedByString(".").last!
        
        let request = NSFetchRequest(entityName: entityName)
        request.predicate = NSPredicate(format: "id == '\(id)'", argumentArray: nil)
        
        
        do {
            return try context.executeFetchRequest(request).first as? T
            
        } catch { }
        
        return T()
    }
    
    
    
    public class func fetchObjects<T: NSManagedObject>(predicate: NSPredicate? = nil, sortDescriptors: [NSSortDescriptor]? = nil, context: NSManagedObjectContext = NSManagedObjectContext.mainContext) -> [T]? {
        
        let entityName = NSStringFromClass(self).componentsSeparatedByString(".").last!
        
        let request = NSFetchRequest(entityName: entityName)
        request.predicate = predicate
        request.sortDescriptors = sortDescriptors
        
        do {
            
            return try context.executeFetchRequest(request) as? [T]
            
        } catch {
            
            print("Error : \((error as NSError).description)")
        }
        
        return [T]()
        
    }
    
    /**
    - Fetch one object from database
    */
    public class func fetchObject<T: NSManagedObject>(predicate: NSPredicate? = nil, context: NSManagedObjectContext = NSManagedObjectContext.mainContext) -> T? {
        
        return fetchObjects(predicate, sortDescriptors: nil, context: context)?.first
    }
    
    
    public class func removeObjects(context: NSManagedObjectContext = NSManagedObjectContext.mainContext, predicate: NSPredicate? = nil) {
        
        let entityName = NSStringFromClass(self).componentsSeparatedByString(".").last!
        let request = NSFetchRequest(entityName: entityName)
        request.predicate = predicate
        
        
        do {
            for entity in try context.executeFetchRequest(request) {
                
                context.deleteObject(entity as! NSManagedObject)
            }
            
            
        } catch { }
        
        
    }
    
    
}


extension NSManagedObjectContext {
    
    public class func createTempContext(parrentContext: NSManagedObjectContext? = nil) -> NSManagedObjectContext {
        
        let tempContext = NSManagedObjectContext(concurrencyType: NSManagedObjectContextConcurrencyType.PrivateQueueConcurrencyType)
        tempContext.parentContext = parrentContext ?? NSManagedObjectContext.mainContext
        
        return tempContext
    }
    
    public func saveContextWithDefaultErrorHandling() {
        
        do {
            
            if hasChanges {
                
                try save()
            }
            
        } catch {
            
            log.error("Error while saving context.", error: error as NSError)
        }
        
    }
}