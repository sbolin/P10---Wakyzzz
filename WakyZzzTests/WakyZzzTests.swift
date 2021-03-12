//
//  WakyZzzTests.swift
//  WakyZzzTests
//
//  Created by Scott Bolin on 2/27/21.
//  Copyright © 2021 Olga Volkova OC. All rights reserved.
//

import XCTest
import CoreData
@testable import WakyZzz

final class WakyZzzTests: XCTestCase {
    
    //MARK: - Properties
    var testStack: CoreDataController!
    var fetchedResultsController: NSFetchedResultsController<AlarmEntity>!
    
    override func setUp() {
        super.setUp()
        testStack = TestCoreDataController()
        if fetchedResultsController == nil {
            fetchedResultsController = testStack.fetchedAlarmResultsController
        }
        do {
            try fetchedResultsController.performFetch()
        } catch {
            print("Fetch failed")
        }
    }
    
    override func tearDown() {
        super.tearDown()
        testStack = nil
    }

    //MARK: - Tests
    //MARK: CoreData Tests
    func test_coreDataManager() {
        let instance = TestCoreDataController.shared
        XCTAssertNotNil(instance)
    }
    
    func test_persistentContainerCreated() {
        let persistentContainer = testStack.persistentContainer
        XCTAssertNotNil(persistentContainer)
    }
    
    func test_persistentStoreType() {
        let persistentStore = testStack.persistentContainer.persistentStoreDescriptions
        print("persistentStore \(persistentStore)")
        let persistentStoreType = persistentStore[0].type
        XCTAssertEqual(persistentStoreType, NSInMemoryStoreType)
    }
    
    func test_contextCreated() {
        let managedContext = testStack.managedContext
        XCTAssertNotNil(managedContext)
    }
    
    func test_mainContextConcurrencyType() {
        let concurrencyType = testStack.managedContext.concurrencyType
        XCTAssertEqual(concurrencyType, .mainQueueConcurrencyType)
    }
    
    func test_fetchedResultsFetched() {
        let fetchToDo = fetchedResultsController
        XCTAssertNotNil(fetchToDo)
    }
    
    func test_fetchedResultsControllerFetches() {
        let frca = testStack.fetchedAlarmResultsController
        XCTAssertNotNil(frca)
    }
    
    func test_saveAsAfterAddingModdingAlarm() {
        let derivedContext = testStack.derivedContext
        let newAlarm = AlarmEntity(context: derivedContext)
        newAlarm.enabled = true
        newAlarm.time = Int32(8 * 60 * 60)
        newAlarm.repeatDays = [false, false, false, false, false, false, false]
        newAlarm.snoozed = false
        newAlarm.timesSnoozed = 0
        
        expectation(forNotification: .NSManagedObjectContextDidSave, object: testStack.managedContext) { _ in
            return true
        }
        derivedContext.perform {
            // create alarm
            self.testStack.createAlarmEntity()
            XCTAssertNotNil(newAlarm)
        }
        waitForExpectations(timeout: 1.0) { error in
            XCTAssertNil(error, "Save did not occur")
        }
    }
    
    //MARK: Alarm tests
    func testAddNewAlarm() {
        let alarmTime = Int32(8*60*60)
        // create alarm
        testStack.createAlarmEntity()

        do {
            try testStack.fetchedAlarmResultsController.performFetch()
        } catch {
            print("could not perform fetch")
            XCTFail("\(#function) error happened \(error.localizedDescription)")
        }
        
        // fetch same goal
        let allAlarms = fetchedResultsController.fetchedObjects
        guard let alarm = allAlarms?.last else {
            XCTFail()
            return
        }
        
        XCTAssertNotNil(alarm, "alarm should not be nil")
        XCTAssertEqual(alarm.enabled, true)
        XCTAssertEqual(alarm.time, alarmTime)
        XCTAssertEqual(alarm.repeatDays, [false, false, false, false, false, false, false])
        XCTAssertEqual(alarm.snoozed, false)
        XCTAssertEqual(alarm.timesSnoozed, 0)
        XCTAssertNotEqual(alarm.timesSnoozed, 1)
    }

    func testChangeAlarmStatus() {
        // create alarms
        testStack.createAlarmEntity()
        
        do {
            try testStack.fetchedAlarmResultsController.performFetch()
        } catch {
            print("could not perform fetch")
        }
        
        // modify alarm
        let indexPath = IndexPath(row: 0, section: 0)
        testStack.changeAlarmStatus(at: indexPath, status: false)

        // fetch same alarm
        let alarm = testStack.fetchedAlarmResultsController.object(at: indexPath)
        
        XCTAssertNotNil(alarm, "alarm should not be nil")
        XCTAssertEqual(alarm.enabled, false)
        XCTAssertNotEqual(alarm.enabled, true)
    }
    
    func testChangeAlarmTime() {
        // create alarms
        testStack.createAlarmEntity()
        testStack.createAlarmEntity()

        do {
            try testStack.fetchedAlarmResultsController.performFetch()
        } catch {
            print("could not perform fetch")
        }
        
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
        testStack.changeAlarmTime(at: indexPath, date: alarmTimeAndDate)
        
        // fetch same todo
        let alarm = testStack.fetchedAlarmResultsController.object(at: indexPath)
        
        XCTAssertNotNil(alarm, "alarm should not be nil")
        XCTAssertEqual(alarm.time, Int32(time))
        XCTAssertNotEqual(alarm.time, 0)
    }
    
    func testChangeRepeatDays() {
        testStack.createAlarmEntity()
        testStack.createAlarmEntity()
        testStack.createAlarmEntity()
        
        do {
            try testStack.fetchedAlarmResultsController.performFetch()
        } catch {
            print("could not perform fetch")
        }
        
        let indexPath = IndexPath(row: 2, section: 0)
        // modify Alarm
        testStack.changeRepeateDays(at: indexPath, repeatDays: [true, false, true, false, true, false, true])
        
        // fetch same Alarm

        let alarm = testStack.fetchedAlarmResultsController.object(at: indexPath)
        XCTAssertNotNil(alarm, "alarm should not be nil")
        XCTAssertEqual(alarm.repeatDays, [true, false, true, false, true, false, true])
        XCTAssertNotEqual(alarm.repeatDays, [])
    }
    
    func testDeleteAlarm() {
        testStack.createAlarmEntity()
        do {
            try testStack.fetchedAlarmResultsController.performFetch()
        } catch {
            print("could not perform fetch")
        }
        
        let indexPath = IndexPath(row: 0, section: 0)
        // delete Alarm
        testStack.deleteAlarmEntity(at: indexPath)
        let alarm = testStack.fetchedAlarmResultsController.object(at: indexPath)
        // test same Alarm
        XCTAssertNotNil(alarm, "alarm not nil")
    }
    
    func testAddNewAlarmObject() {
        let alarmTime = 8*60*60
        let alarm = Alarm()
        alarm.enabled = true
        alarm.time = alarmTime
        alarm.repeatDays = [false, false, false, false, false, false, false]
        alarm.snoozed = false
        alarm.timesSnoozed = 0
        
        // create goal
        testStack.createAlarmEntityFromAlarmObject(alarm: alarm)

        // fetch same goal
        do {
            try testStack.fetchedAlarmResultsController.performFetch()
        } catch {
            print("could not perform fetch")
        }
        
        let mockAlarm = testStack.fetchedAlarmResultsController.fetchedObjects!.last!
        
        XCTAssertNotNil(mockAlarm, "alarm should not be nil")
        XCTAssertEqual(mockAlarm.enabled, true)
        XCTAssertEqual(mockAlarm.time, Int32(alarmTime))
        XCTAssertEqual(mockAlarm.repeatDays, [false, false, false, false, false, false, false])
        XCTAssertEqual(mockAlarm.snoozed, false)
        XCTAssertEqual(mockAlarm.timesSnoozed, 0)
        XCTAssertNotEqual(mockAlarm.timesSnoozed, 1)
    }
}
