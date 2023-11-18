//
//  CacheManager.swift
//  BetterKia-iOS
//
//  Created by Joschua Haß on 15.11.23.
//

import Foundation
import CoreData
import os

public class CacheManager {
    public static var shared = CacheManager()
    
    let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "CacheManager")
    
    lazy var persistentContainer: NSPersistentContainer = {
            let container = NSPersistentContainer(name: "Main")
            container.loadPersistentStores { description, error in
                if let error = error {
                    fatalError("Unable to load persistent stores: \(error)")
                }
            }
            return container
        }()
    
    public func saveVehicleStatusToCache(status: VehicleStatus) {
        // Delete old record
        let fetchRequest: NSFetchRequest<CacheEntry> = CacheEntry.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", "vehicle_status")
        
        let context = persistentContainer.viewContext

        do {
            let fetchedObjects = try context.fetch(fetchRequest)
            
            // Perform the deletion
            for object in fetchedObjects {
                context.delete(object)
            }
            
            // Create new record
            let record = NSEntityDescription.insertNewObject(forEntityName: "CacheEntry", into: context) as! CacheEntry

            // Set the attribute values
            record.id = "vehicle_status"
            record.data = String(data: try JSONEncoder().encode(status), encoding: .utf8)
            
            // Save the context to persist the changes
            try context.save()
        } catch {
            // Handle the error
        }
    }
    
    public func loadCachedVehicleStatus() {
        let fetchRequest: NSFetchRequest<CacheEntry>
        fetchRequest = CacheEntry.fetchRequest()

        fetchRequest.predicate = NSPredicate(
            format: "id == %@", "vehicle_status"
        )

        // Get a reference to a NSManagedObjectContext
        let context = persistentContainer.viewContext

        do {
            let data = try context.fetch(fetchRequest).first
            
            if (data == nil || data!.data == nil) {
                return
            }
        
            let decoder = JSONDecoder()
            
            let cachedStatus = try decoder.decode(VehicleStatus.self, from: data!.data!.data(using: .utf8)!)
            
            // Actual data loading was faster than getting the cache data
            if (VehicleManager.shared.vehicleData != nil) {
                return
            }
            
            DispatchQueue.main.async {
                VehicleManager.shared.vehicleData = cachedStatus
                VehicleManager.shared.isHvacActive = cachedStatus.airCtrlOn
                VehicleManager.shared.isVehicleLocked = cachedStatus.doorLock
            }
        } catch let error {
            logger.error("An error occured while loading the cached vehicle status: \(error.localizedDescription)")
        }
    }
}
