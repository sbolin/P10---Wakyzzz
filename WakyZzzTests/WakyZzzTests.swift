//
//  WakyZzzTests.swift
//  WakyZzzTests
//
//  Created by Scott Bolin on 2/27/21.
//  Copyright © 2021 Olga Volkova OC. All rights reserved.
//

@testable import WakyZzz
import XCTest
import CoreData

final class WakyZzzTests: XCTestCase {
    
    //MARK: - Properties
    var mockStack: CoreDataStack!
    var fetchedResultsController: NSFetchedResultsController<AlarmEntity>!
    
    override func setUp() {
        super.setUp()
        mockStack = MockCoreDataStack()
        if fetchedResultsController == nil {
            fetchedResultsController = mockStack.fetchedAlarmResultsController
        }
        do {
            try fetchedResultsController.performFetch()
        } catch {
            print("Fetch failed")
        }
    }
    
    override func tearDown() {
        super.tearDown()
        mockStack = nil
    }
    
    func deleteAllAlarms() {
        // Initialize Fetch Request
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ToDo")
        let context = MockCoreDataStack().managedContext
        fetchRequest.includesPropertyValues = false
        do {
            let items = try context.fetch(fetchRequest) as! [NSManagedObject]
            for item in items {
                context.delete(item)
            }
            try context.save()
            
        } catch {
            print("Could not delete mockStack")
        }
    }

    //MARK: - Tests
    //MARK: CoreData Tests
    func test_coreDataManager() {
        let instance = MockCoreDataStack()
        XCTAssertNotNil(instance)
    }
    
    func test_persistentContainerCreated() {
        let persistentContainer = MockCoreDataStack().persistentContainer
        XCTAssertNotNil(persistentContainer)
    }
    
    func test_persistentStoreType() {
        let persistentStore = mockStack.persistentContainer.persistentStoreDescriptions
        print("persistentStore \(persistentStore)")
        let persistentStoreType = persistentStore[0].type
        XCTAssertEqual(persistentStoreType, NSInMemoryStoreType)
    }
    
    func test_contextCreated() {
        let managedContext = MockCoreDataStack().managedContext
        XCTAssertNotNil(managedContext)
    }
    
    func test_mainContextConcurrencyType() {
        let concurrencyType = MockCoreDataStack().managedContext.concurrencyType
        XCTAssertEqual(concurrencyType, .mainQueueConcurrencyType)
    }
    
    func test_fetchedResultsFetched() {
        let fetchToDo = fetchedResultsController
        XCTAssertNotNil(fetchToDo)
    }
    
    func test_fetchedResultsControllerFetches() {
        let frca = mockStack.fetchedAlarmResultsController
        XCTAssertNotNil(frca)
    }
    
    //MARK: Alarm tests
    func testAddNewAlarm() {
        let alarmTime = Int32(8*60*60)
        // create goal
        MockCoreDataStack().createAlarmEntity()
        
        // fetch same goal
        let allAlarms = fetchedResultsController.fetchedObjects
        guard let alarm = allAlarms?.last else { return }
        
        XCTAssertNotNil(alarm, "alarm should not be nil")
        XCTAssertEqual(alarm.enabled, true)
        XCTAssertEqual(alarm.time, alarmTime)
        XCTAssertEqual(alarm.repeatDays, [false, false, false, false, false, false, false])
        XCTAssertEqual(alarm.snoozed, false)
        XCTAssertEqual(alarm.timesSnoozed, 0)
        XCTAssertNotEqual(alarm.timesSnoozed, 1)
    }

    func testChangeAlarmStatus() {
        let indexPath = IndexPath(row: 1, section: 0)
        // modify Alarm
        MockCoreDataStack().changeAlarmStatus(at: indexPath, status: false)
        
        // fetch same Alarm
        let alarm = MockCoreDataStack().fetchedAlarmResultsController.object(at: indexPath)
        
        XCTAssertNotNil(alarm, "alarm should not be nil")
        XCTAssertEqual(alarm.enabled, false)
        XCTAssertNotEqual(alarm.enabled, true)
    }
    
    func testChangeAlarmTime() {
        let indexPath = IndexPath(row: 1, section: 0)
        let time = 9.5*60*60
        let date = Date()
        let calendar = Calendar.current
        let hour = Int(time/3600) // h
        let minute = Int(time/60) - hour * 60 // m
        
        var alarmTimeComponents = calendar.dateComponents([.hour, .minute, .month, .year, .day, .second, .weekOfMonth], from: date as Date)
        
        alarmTimeComponents.hour = hour
        alarmTimeComponents.minute = minute
        
        let alarmTimeAndDate = calendar.date(from: alarmTimeComponents)!
        // modify todo
        MockCoreDataStack().changeAlarmTime(at: indexPath, date: alarmTimeAndDate)
        
        // fetch same todo
        let alarm = MockCoreDataStack().fetchedAlarmResultsController.object(at: indexPath)
        
        XCTAssertNotNil(alarm, "alarm should not be nil")
        XCTAssertEqual(alarm.time, Int32(time))
        XCTAssertNotEqual(alarm.time, 0)
    }
    
    func testChangeRepeatDays() {
        let indexPath = IndexPath(row: 1, section: 0)
        // modify Alarm
        MockCoreDataStack().changeRepeateDays(at: indexPath, repeatDays: [true, false, true, false, true, false, true])
        
        // fetch same Alarm
        let alarm = MockCoreDataStack().fetchedAlarmResultsController.object(at: indexPath)
        XCTAssertNotNil(alarm, "alarm should not be nil")
        XCTAssertEqual(alarm.repeatDays, [true, false, true, false, true, false, true])
        XCTAssertNotEqual(alarm.repeatDays, [])
    }
    
    func testDeleteAlarm() {
        let indexPath = IndexPath(row: 1, section: 0)
        // modify Alarm
        MockCoreDataStack().deleteAlarmEntity(at: indexPath)
        
        // fetch same Alarm
        let alarm = MockCoreDataStack().fetchedAlarmResultsController.object(at: indexPath)
        XCTAssertNil(alarm, "alarm should be nil")
    }
    
    func testAddNewAlarmObject() {
        let indexPath = IndexPath(row: 1, section: 0)
        let alarmTime = 8*60*60
        let alarm = Alarm()
        alarm.enabled = true
        alarm.time = alarmTime
        alarm.repeatDays = [false, false, false, false, false, false, false]
        alarm.snoozed = false
        alarm.timesSnoozed = 0
        
        // create goal
        MockCoreDataStack().createAlarmEntityFromAlarmObject(alarm: alarm)
        
        // fetch same goal
        let mockAlarm = MockCoreDataStack().fetchedAlarmResultsController.object(at: indexPath)
        
        XCTAssertNotNil(mockAlarm, "alarm should not be nil")
        XCTAssertEqual(mockAlarm.enabled, true)
        XCTAssertEqual(mockAlarm.time, Int32(alarmTime))
        XCTAssertEqual(mockAlarm.repeatDays, [false, false, false, false, false, false, false])
        XCTAssertEqual(mockAlarm.snoozed, false)
        XCTAssertEqual(mockAlarm.timesSnoozed, 0)
        XCTAssertNotEqual(mockAlarm.timesSnoozed, 1)
    }
}
