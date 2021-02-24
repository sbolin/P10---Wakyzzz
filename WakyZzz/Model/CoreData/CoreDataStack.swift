//
//  CoreDataStack.swift
//  WakyZzz
//
//  Created by Scott Bolin on 2/20/21.
//  Copyright © 2021 Olga Volkova OC. All rights reserved.
//

import Foundation
import CoreData

class CoreDataStack {
    
    //MARK: - Create Core Data Stack
    private lazy var persistentContainer: NSPersistentContainer = {
        
        let container = NSPersistentContainer(name: "WakyZzz")
        container.loadPersistentStores { storeDescription, error in
            if let error = error as NSError? {
                print("Unresolved error \(error), \(error.userInfo)")
            }
        }
        return container
    }()
    
    // main managed Context
    lazy var managedContext: NSManagedObjectContext = {
        let context = self.persistentContainer.viewContext
        context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        return context
    }()
    
    // background context used for testing
    lazy var backgroundContext: NSManagedObjectContext = {
        let context = self.persistentContainer.newBackgroundContext()
        return context
    }()
    
    
    //MARK: - Fetch Properties
    lazy var fetchedAlarmResultsController: NSFetchedResultsController<AlarmEntity> = {
        let request = AlarmEntity.alarmFetchRequest()
        request.returnsObjectsAsFaults = false // since few alarms, return objects, not faults
        let alarmTimeSort = NSSortDescriptor(keyPath: \AlarmEntity.alarmTime, ascending: true)
        request.sortDescriptors = [alarmTimeSort]
        
        let fetchedResultsController = NSFetchedResultsController(
            fetchRequest: request,
            managedObjectContext: managedContext,
            sectionNameKeyPath: #keyPath(AlarmEntity.status), // use if works, otherwise use nil,
            cacheName: nil)
            
        return fetchedResultsController
    }()
    
    
    //MARK: - CoreData Utility Methods
    //MARK: SaveContext
    func saveContext(managedContext: NSManagedObjectContext) {
        guard managedContext.hasChanges else { return }
        do {
            try managedContext.save()
        } catch let error as NSError {
            managedContext.rollback()
            print("Unresolved error \(error), \(error.localizedDescription)")
        }
    }
    
    func createAlarm() {
        let newAlarm = AlarmEntity(context: managedContext)
        newAlarm.alarmTime = 8 * 60 * 60
        newAlarm.repeating = false
        newAlarm.repeatDays = "0000000"
        newAlarm.snoozed = false
        newAlarm.snoozedTimes = 0
        newAlarm.status = true // alarm turned on when created
        
        saveContext(managedContext: managedContext)
    }
    
    func modifyAlarm(at indexPath: IndexPath) {
        let alarm = fetchedAlarmResultsController.object(at: indexPath)
        // ? need to find out what changed and set it
        
        saveContext(managedContext: managedContext)
    }
    
    func deleteAlarm(at indexPath: IndexPath) {
        let alarm = fetchedAlarmResultsController.object(at: indexPath)
        managedContext.delete(alarm)
        saveContext(managedContext: managedContext)
    }
}
