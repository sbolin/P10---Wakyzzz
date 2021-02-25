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
            sectionNameKeyPath: #keyPath(AlarmEntity.enabled), // use if works, otherwise use nil,
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
    
    func createAlarmEntity() {
        let newAlarmEntity = AlarmEntity(context: managedContext)
        newAlarmEntity.alarmTime = 8 * 60 * 60
        newAlarmEntity.repeating = false
        newAlarmEntity.repeatDays = [false, false, false, false, false, false, false]
        newAlarmEntity.snoozed = false
        newAlarmEntity.snoozedTimes = 0
        newAlarmEntity.enabled = true // alarm turned on when created
        
        saveContext(managedContext: managedContext)
    }
    
    func changeAlarmStatus(at indexPath: IndexPath, status: Bool) {
        let alarmEntity = fetchedAlarmResultsController.object(at: indexPath)
        alarmEntity.enabled = status
        saveContext(managedContext: managedContext)
    }
    
    func changeAlarmTime(at indexPath: IndexPath, time: Int) {
        let alarmEntity = fetchedAlarmResultsController.object(at: indexPath)
        alarmEntity.alarmTime = Int32(time)
        saveContext(managedContext: managedContext)
    
    }
    
    func changeRepeateDays(at indexPath: IndexPath, repeatDays: [Bool]) {
        let alarmEntity = fetchedAlarmResultsController.object(at: indexPath)
        alarmEntity.repeatDays = repeatDays
        saveContext(managedContext: managedContext)
    }
    
    func deleteAlarmEntity(at indexPath: IndexPath) {
        let alarmEntity = fetchedAlarmResultsController.object(at: indexPath)
        managedContext.delete(alarmEntity)
        saveContext(managedContext: managedContext)
    }
    
    func createAlarmEntityFromAlarmObject(alarm: Alarm) {
        let newAlarmEntity = AlarmEntity(context: managedContext)
        
        newAlarmEntity.alarmTime = Int32(alarm.time)
        newAlarmEntity.repeatDays = alarm.repeatDays
        newAlarmEntity.repeating = alarm.repeatDays.contains(true) ? true : false
        newAlarmEntity.snoozed = alarm.snoozed
        newAlarmEntity.snoozedTimes = Int16(alarm.timeSnoozed)
        newAlarmEntity.enabled = alarm.enabled
        
        saveContext(managedContext: managedContext)
    }
}
