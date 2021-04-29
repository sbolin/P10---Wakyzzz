//
//  WakyZzzCoreDataTests.swift
//  WakyZzzCoreDataTests
//
//  Created by Scott Bolin on 2/27/21.
//  Copyright © 2021 Olga Volkova OC. All rights reserved.
//

import XCTest
import CoreData
@testable import WakyZzz

final class WakyZzzCoreDataTests: XCTestCase {
    
    //MARK: - Properties
    var testStack: TestCoreDataController!
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
        let fetchAlarm = fetchedResultsController
        XCTAssertNotNil(fetchAlarm)
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
        
        // fetch same alarm
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
    
    func testAddNewAlarmWithID() {
        let alarmTime = Int32(8*60*60)
        //        let id = UUID()
        // create alarm
        testStack.createAlarmEntity()
        
        do {
            try testStack.fetchedAlarmResultsController.performFetch()
        } catch {
            print("could not perform fetch")
            XCTFail("\(#function) error happened \(error.localizedDescription)")
        }
        
        // fetch same alarm
        let allAlarms = fetchedResultsController.fetchedObjects
        guard let alarm = allAlarms?.last else { // last
            XCTFail()
            return
        }
        
        XCTAssertNotNil(alarm, "alarm should not be nil")
        XCTAssertEqual(alarm.enabled, true)
        // can't set the id on its own, it is set by the entity itself.
        //        XCTAssertEqual(alarm.alarmID, id)
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
            XCTFail("\(#function) error happened \(error.localizedDescription)")
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
            XCTFail("\(#function) error happened \(error.localizedDescription)")
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
            XCTFail("\(#function) error happened \(error.localizedDescription)")
        }
        
        let indexPath = IndexPath(row: 0, section: 0)
        // delete Alarm
        testStack.deleteAlarmEntity(at: indexPath)
        let alarm = testStack.fetchedAlarmResultsController.object(at: indexPath)
        // test same Alarm
        XCTAssertNotNil(alarm, "alarm not nil")
    }
    
    func testUpdateSnoozeStatue() {
        let alarmTime = Int32(8*60*60)
        // create alarm
        testStack.createAlarmEntity()
        
        do {
            try testStack.fetchedAlarmResultsController.performFetch()
        } catch {
            print("could not perform fetch")
            XCTFail("\(#function) error happened \(error.localizedDescription)")
        }
        
        // fetch same alarm
        let allAlarms = fetchedResultsController.fetchedObjects
        guard let alarm = allAlarms?.last else {
            XCTFail()
            return
        }
        ///
        // update snooze status of alarm
        testStack.updateSnoozeStatus(for: alarm.alarmID)
        
        // fetch same alarm again
        let updatedAllAlarms = fetchedResultsController.fetchedObjects
        guard let updatedAlarm = updatedAllAlarms?.last else {
            XCTFail()
            return
        }
        
        ///
        
//        XCTAssertNotNil(alarm, "alarm should not be nil")
//        XCTAssertEqual(alarm.enabled, true)
//        XCTAssertEqual(alarm.time, alarmTime)
//        XCTAssertEqual(alarm.repeatDays, [false, false, false, false, false, false, false])
//        XCTAssertEqual(alarm.snoozed, true)
//        XCTAssertEqual(alarm.timesSnoozed, 1)
//        XCTAssertNotEqual(alarm.timesSnoozed, 0)
        
        
        XCTAssertNotNil(updatedAlarm, "alarm should not be nil")
        XCTAssertEqual(updatedAlarm.enabled, true)
        XCTAssertEqual(updatedAlarm.time, alarmTime)
        XCTAssertEqual(updatedAlarm.repeatDays, [false, false, false, false, false, false, false])
        XCTAssertEqual(updatedAlarm.snoozed, true)
        XCTAssertEqual(updatedAlarm.timesSnoozed, 1)
        XCTAssertNotEqual(updatedAlarm.timesSnoozed, 0)
    }
    
    func testAddNewAlarmObject() {
        let alarmTime = 8*60*60
        let alarm = Alarm()
        alarm.enabled = true
        alarm.time = alarmTime
        alarm.repeatDays = [false, false, false, false, false, false, false]
        alarm.snoozed = false
        alarm.timesSnoozed = 0
        
        // create alarm
        let _ = testStack.createAlarmEntityFromAlarmObject(alarm: alarm)
        
        // fetch same alarm
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
    
    func testUpdateAlarmObject() {
        let alarmTime = 10*60*60
        let alarm = Alarm()
        alarm.enabled = true
        alarm.time = alarmTime
        alarm.repeatDays = [false, false, false, true, false, false, false]
        alarm.snoozed = false
        alarm.timesSnoozed = 1
        
        let indexPath = IndexPath(row: 0, section: 0)
        
        // create alarm
        let _ = testStack.createAlarmEntityFromAlarmObject(alarm: alarm)
        
        // fetch same alarm
        do {
            try testStack.fetchedAlarmResultsController.performFetch()
        } catch {
            print("could not perform fetch")
        }
        
        // modify alarm...
        testStack.updateAlarmEntityFromAlarmObject(at: indexPath, alarm: alarm)
        
        // fetch same alarm
        let mockAlarm = testStack.fetchedAlarmResultsController.object(at: indexPath)
        
        XCTAssertNotNil(mockAlarm, "alarm should not be nil")
        XCTAssertEqual(mockAlarm.enabled, true)
        XCTAssertEqual(mockAlarm.time, Int32(alarmTime))
        XCTAssertEqual(mockAlarm.repeatDays, [false, false, false, true, false, false, false])
        XCTAssertEqual(mockAlarm.snoozed, false)
        XCTAssertEqual(mockAlarm.timesSnoozed, 1)
        XCTAssertNotEqual(mockAlarm.timesSnoozed, 0)
    }
    
    func testFetchAlarmByAlarmID() {
        let alarmTime = 8*60*60
        let alarm = Alarm()
        alarm.alarmID = UUID()
        alarm.enabled = true
        alarm.time = alarmTime
        alarm.repeatDays = [false, false, false, false, false, false, false]
        alarm.snoozed = false
        alarm.timesSnoozed = 0
        let alarmID = alarm.alarmID
        // create alarm
        let _ = testStack.createAlarmEntityFromAlarmObject(alarm: alarm)
        
        // fetch same alarm
        do {
            try testStack.fetchedAlarmResultsController.performFetch()
        } catch {
            print("could not perform fetch")
        }
        
        guard let mockAlarm = testStack.fetchAlarmByAlarmID(with: alarmID) else {
            XCTFail()
            return
        }
        
        XCTAssertNotNil(mockAlarm, "alarm should not be nil")
        XCTAssertEqual(mockAlarm.enabled, true)
        XCTAssertEqual(mockAlarm.time, Int32(alarmTime))
        XCTAssertEqual(mockAlarm.repeatDays, [false, false, false, false, false, false, false])
        XCTAssertEqual(mockAlarm.snoozed, false)
        XCTAssertEqual(mockAlarm.timesSnoozed, 0)
        XCTAssertNotEqual(mockAlarm.timesSnoozed, 1)
    }
    
    func testToAlarm() {
        // create alarm
        testStack.createAlarmEntity()
        let alarmTime = Int(8*60*60)
        
        do {
            try testStack.fetchedAlarmResultsController.performFetch()
        } catch {
            print("could not perform fetch")
            XCTFail("\(#function) error happened \(error.localizedDescription)")
        }
        
        // fetch same alarm
        let allAlarms = fetchedResultsController.fetchedObjects
        guard let alarm = allAlarms?.last else {
            XCTFail()
            return
        }
        
        // create Alarm object to test setup
        let alarmToTest = alarm.toAlarm()
        
        XCTAssertNotNil(alarm)
        XCTAssertNotNil(alarmToTest)
        
        XCTAssertEqual(alarmToTest.enabled, true)
        XCTAssertEqual(alarmToTest.time, alarmTime)
        XCTAssertEqual(alarmToTest.repeatDays, [false, false, false, false, false, false, false])
        XCTAssertEqual(alarmToTest.snoozed, false)
        XCTAssertEqual(alarmToTest.timesSnoozed, 0)
        
        XCTAssertEqual(alarm.enabled, alarmToTest.enabled)
        XCTAssertEqual(Int(alarm.time), alarmToTest.time)
        XCTAssertEqual(alarm.repeatDays, alarmToTest.repeatDays)
        XCTAssertEqual(alarm.snoozed, alarmToTest.snoozed)
        XCTAssertEqual(Int(alarm.timesSnoozed), alarmToTest.timesSnoozed)
    }
}
