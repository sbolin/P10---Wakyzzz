//
//  CoreDataController.swift
//  WakyZzz
//
//  Created by Scott Bolin on 2/20/21.
//  Copyright © 2021 Olga Volkova OC. All rights reserved.
//

import Foundation
import CoreData

class CoreDataController {
    
    //MARK: - Singleton
    static let shared = CoreDataController()
    init() {}
    
    lazy var modelName = "WakyZzz"
    
    //MARK: - NSPersistentContainer
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: modelName)
        container.loadPersistentStores { _, error in
            if let error = error as NSError? {
                print("Unresolved error \(error), \(error.userInfo)")
            }
        }
        return container
    }()
    
    //MARK: - NSManagedObjectContext Main
    lazy var managedContext: NSManagedObjectContext = {
        let context = self.persistentContainer.viewContext
        context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        return context
    }()
    
    //MARK: - Background Context
    lazy var derivedContext: NSManagedObjectContext = {
        let context = self.persistentContainer.newBackgroundContext()
        return context
    }()
    
    //MARK: - Check if Model is empty (for first run check)
    lazy var modelIsEmpty: Bool = {
        do {
            let request = AlarmEntity.alarmFetchRequest()
            let count = try managedContext.count(for: request)
            print("count: \(count)")
            return count == 0
        } catch {
            print("could not count objects")
            return false
        }
    }()
    
    //MARK: - Fetch Properties
    lazy var fetchedAlarmResultsController: NSFetchedResultsController<AlarmEntity> = {
        let request = AlarmEntity.alarmFetchRequest()
        request.returnsObjectsAsFaults = false // return objects not faults (small model)
//        let alarmEnabledSort = NSSortDescriptor(keyPath: \AlarmEntity.enabled, ascending: true)
        let alarmTimeSort = NSSortDescriptor(keyPath: \AlarmEntity.time, ascending: true)
//        request.sortDescriptors = [alarmEnabledSort, alarmTimeSort]
        request.sortDescriptors = [alarmTimeSort]

        let fetchedResultsController = NSFetchedResultsController(
            fetchRequest: request,
            managedObjectContext: managedContext,
            sectionNameKeyPath: nil, // #keyPath(AlarmEntity.enabled)
            cacheName: nil)
            
        return fetchedResultsController
    }()
    
    func fetchAlarmByAlarmID(with alarmID: UUID) -> AlarmEntity? {
        var alarm: AlarmEntity?
        managedContext.performAndWait {
            let request = AlarmEntity.alarmFetchRequest()
            request.predicate = NSPredicate(format: "alarmID == %@", alarmID as CVarArg)
            request.fetchLimit = 1
            alarm = (try? request.execute())?.first
        }
        return alarm
    }
    
    //MARK: - CoreData Utility Methods
    //MARK: SaveContext
    @discardableResult
    func saveContext(context: NSManagedObjectContext) -> Bool {
        guard context.hasChanges else { return true }
        do {
            try context.save()
            print("Saved context")
            return true
        } catch let error as NSError {
            context.rollback() // if error, go back to previous state
            print("Unresolved error \(error), \(error.localizedDescription)")
            return false
        }
    }
    
    // tested, not used otherwise
    func createAlarmEntity() {
        let newAlarmEntity = AlarmEntity(context: managedContext)
        newAlarmEntity.alarmID = UUID()
        newAlarmEntity.time = Int32(8 * 60 * 60)
        newAlarmEntity.repeatDays = [false, false, false, false, false, false, false]
        newAlarmEntity.snoozed = false
        newAlarmEntity.timesSnoozed = Int16(0)
        newAlarmEntity.enabled = true // alarm turned on when created
        saveContext(context: managedContext)
    }
    
    // tested, in populate alarms only, can delete in final
    func createAlarmEntityWithID(id: UUID) {
        let newAlarmEntity = AlarmEntity(context: managedContext)
        newAlarmEntity.alarmID = id
        newAlarmEntity.time = Int32(8 * 60 * 60)
        newAlarmEntity.repeatDays = [false, false, false, false, false, false, false]
        newAlarmEntity.snoozed = false
        newAlarmEntity.timesSnoozed = Int16(0)
        newAlarmEntity.enabled = true // alarm turned on when created
        saveContext(context: managedContext)
    }
    
    // tested
    func changeAlarmStatus(at indexPath: IndexPath, status: Bool) {
        let alarmEntity = fetchedAlarmResultsController.object(at: indexPath)
        alarmEntity.enabled = status
        saveContext(context: managedContext)
    }
    
    // tested, not used otherwise
    func changeAlarmTime(at indexPath: IndexPath, date: Date) {
        let alarmEntity = fetchedAlarmResultsController.object(at: indexPath)
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute, .second, .day, .month, .year, .weekdayOrdinal], from: date as Date)
        let time = components.hour! * 3600 + components.minute! * 60
        alarmEntity.time = Int32(time)
        saveContext(context: managedContext)
    }
    
    // tested, not used otherwise
    func changeRepeateDays(at indexPath: IndexPath, repeatDays: [Bool]) {
        let alarmEntity = fetchedAlarmResultsController.object(at: indexPath)
        alarmEntity.repeatDays = repeatDays
        saveContext(context: managedContext)
    }
    
    // tested
    func deleteAlarmEntity(at indexPath: IndexPath) {
        let alarmEntity = fetchedAlarmResultsController.object(at: indexPath)
        managedContext.delete(alarmEntity)
        saveContext(context: managedContext)
    }
    
    // tested, not used yet
    func updateSnoozeStatus(for alarmID: UUID) {
        guard let alarmEntity = fetchAlarmByAlarmID(with: alarmID) else { return }
        alarmEntity.snoozed = true
        alarmEntity.timesSnoozed += 1
        saveContext(context: managedContext)
        if alarmEntity.timesSnoozed > 3 {
            print("Activate Random Act of Kindness™")
        }
    }
    
    // tested
    func createAlarmEntityFromAlarmObject(alarm: Alarm) -> AlarmEntity? {
        let newAlarmEntity = AlarmEntity(context: managedContext)
        newAlarmEntity.alarmID = alarm.alarmID
        newAlarmEntity.time = Int32(alarm.time)
        newAlarmEntity.repeatDays = alarm.repeatDays
        newAlarmEntity.snoozed = alarm.snoozed
        newAlarmEntity.timesSnoozed = Int16(alarm.timesSnoozed)
        newAlarmEntity.enabled = alarm.enabled
        
        let result = saveContext(context: managedContext)
        
        if result {
        return newAlarmEntity
        } else {
            return nil
        }
    }
    
    // tested
    func updateAlarmEntityFromAlarmObject(at indexPath: IndexPath, alarm: Alarm) {
        // just update all properties, rather than track/update individual properties
        let alarmEntity = fetchedAlarmResultsController.object(at: indexPath)
        alarmEntity.alarmID = alarm.alarmID
        alarmEntity.time = Int32(alarm.time)
        alarmEntity.repeatDays = alarm.repeatDays
        alarmEntity.snoozed = alarm.snoozed
        alarmEntity.timesSnoozed = Int16(alarm.timesSnoozed)
        alarmEntity.enabled = alarm.enabled
        
        saveContext(context: managedContext)
    }
}
