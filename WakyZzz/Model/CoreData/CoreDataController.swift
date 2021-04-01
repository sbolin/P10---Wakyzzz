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
    
    //MARK: - NSManagedObjectModel
//    lazy var model: NSManagedObjectModel = {
//        let modelURL = Bundle.main.url(forResource: modelName, withExtension: "momd")!
//        return NSManagedObjectModel(contentsOf: modelURL)!
//    }()
    
    //MARK: - NSPersistentContainer
    lazy var persistentContainer: NSPersistentContainer = {
//        let container = NSPersistentContainer(name: modelName, managedObjectModel: model)
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
            return count == 0
        } catch {
            return true
        }
    }()
    
    //MARK: - Fetch Properties
    lazy var fetchedAlarmResultsController: NSFetchedResultsController<AlarmEntity> = {
        let request = AlarmEntity.alarmFetchRequest()
        request.returnsObjectsAsFaults = false // since few alarms, return objects, not faults
        // annoying having table resort when alarm enabled/disabled...
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
    func saveContext(context: NSManagedObjectContext) {
        guard context.hasChanges else { return }
        do {
            try context.save()
        } catch let error as NSError {
            context.rollback() // if error, go back to previous state
            print("Unresolved error \(error), \(error.localizedDescription)")
        }
    }
    
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
    
    func changeAlarmStatus(at indexPath: IndexPath, status: Bool) {
        let alarmEntity = fetchedAlarmResultsController.object(at: indexPath)
        alarmEntity.enabled = status
        saveContext(context: managedContext)
    }
    
    func changeAlarmTime(at indexPath: IndexPath, date: Date) {
        let alarmEntity = fetchedAlarmResultsController.object(at: indexPath)
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute, .second, .day, .month, .year, .weekdayOrdinal], from: date as Date)
        let time = components.hour! * 3600 + components.minute! * 60
        alarmEntity.time = Int32(time)
        saveContext(context: managedContext)
    }
    
    func updateSnoozeStatus(for alarmID: UUID) {
        guard let alarmEntity = fetchAlarmByAlarmID(with: alarmID) else { return }
        alarmEntity.snoozed = true
        alarmEntity.timesSnoozed += 1
        saveContext(context: managedContext)
        if alarmEntity.timesSnoozed > 3 {
            print("Activate Random Act of Kindness™")
        }
    }
    
    func changeRepeateDays(at indexPath: IndexPath, repeatDays: [Bool]) {
        let alarmEntity = fetchedAlarmResultsController.object(at: indexPath)
        alarmEntity.repeatDays = repeatDays
        saveContext(context: managedContext)
    }
    
    func deleteAlarmEntity(at indexPath: IndexPath) {
        let alarmEntity = fetchedAlarmResultsController.object(at: indexPath)
        managedContext.delete(alarmEntity)
        saveContext(context: managedContext)
    }
    
    func createAlarmEntityFromAlarmObject(alarm: Alarm) {
        let newAlarmEntity = AlarmEntity(context: managedContext)
        newAlarmEntity.alarmID = alarm.alarmID
        newAlarmEntity.time = Int32(alarm.time)
        newAlarmEntity.repeatDays = alarm.repeatDays
        newAlarmEntity.snoozed = alarm.snoozed
        newAlarmEntity.timesSnoozed = Int16(alarm.timesSnoozed)
        newAlarmEntity.enabled = alarm.enabled
        
        saveContext(context: managedContext)
    }
}
