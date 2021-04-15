//
//  WakyZzzNotificationTests.swift
//  WakyZzzTests
//
//  Created by Scott Bolin on 09-A-21.
//  Copyright © 2021 TukgaeSoft. All rights reserved.
//

import CoreData
import XCTest
@testable import WakyZzz

final class WakyZzzNotificationTests: XCTestCase {
    
    // Set up notifications
    var notifications = [LocalNotification]()
    let center = UNUserNotificationCenter.current()
    let notifcationController = NotificationController() // manager
    
    // Set up core data (needed for notification creation - pass entity to Notification controller to create.
    var testStack: CoreDataController!
    var fetchedResultsController: NSFetchedResultsController<AlarmEntity>!

    override func setUp() {
        super.setUp()
// get authorization (may already have it is app has been run
        notifcationController.requestNotificationAuthorization()
        notifcationController.setupActions()
//DANGER: DELETE ALL NOTIFICATIONS!
        removeAllDeliveredNotifications()
        removeAllPendingNotificationRequests()
        
        // core data
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
        //DANGER: DELETE ALL NOTIFICATIONS!
        removeAllDeliveredNotifications()
        removeAllPendingNotificationRequests()
        
        // core data teardown
        testStack = nil
    }
    
    //MARK: - Tests
    //MARK: Notification Tests
    func test_createNotification() {
        let expectation = XCTestExpectation(description: "Test passed")
        var count = 0
        let derivedContext = testStack.derivedContext
        let alarmEntity = AlarmEntity(context: derivedContext)
        alarmEntity.alarmID = UUID()
        alarmEntity.enabled = true
        alarmEntity.time = Int32(8 * 60 * 60)
        alarmEntity.repeatDays = [false, false, false, false, false, false, false]
        alarmEntity.snoozed = false
        alarmEntity.timesSnoozed = 0
        // create notification
        notifcationController.assembleNotificationItemsFrom(entity: alarmEntity)
        center.getPendingNotificationRequests { requests in
            requests.forEach { request in
                count += 1
                XCTAssertTrue(count > 0)
                expectation.fulfill()
                // fulfill expectation
            }
        }
        wait(for: [expectation], timeout: 0.5)
    }
    
    func test_cancelNotification() {
        let expectation = XCTestExpectation(description: "Test passed")
        var count = 0
        let derivedContext = testStack.derivedContext
        let alarmEntity = AlarmEntity(context: derivedContext)
        alarmEntity.alarmID = UUID()
        alarmEntity.enabled = true
        alarmEntity.time = Int32(8 * 60 * 60)
        alarmEntity.repeatDays = [false, false, false, false, false, false, false]
        alarmEntity.snoozed = false
        alarmEntity.timesSnoozed = 0
        // create notification
        notifcationController.assembleNotificationItemsFrom(entity: alarmEntity)
        // check if notification created
        //cancel notification
        notifcationController.cancelNotificationForEntity(entity: alarmEntity)
        center.getPendingNotificationRequests { requests in
            requests.forEach { request in
                count += 1
                XCTAssertTrue(count > 0)
                expectation.fulfill()
                // fulfill expectation
            }
        }
        wait(for: [expectation], timeout: 0.5)
    }
    
    func test_getNotificationType() {
        let expectation = XCTestExpectation(description: "Test passed")
        // indirectly test private method by examining created notification title, and compare to expected title (which is unique for each type)
        let expectedTitle = "Turn Alarm Off 🔕 or Snooze? 😴"
        var createdTitle = ""
        let derivedContext = testStack.derivedContext
        let alarmEntity = AlarmEntity(context: derivedContext)
        alarmEntity.alarmID = UUID()
        alarmEntity.enabled = true
        alarmEntity.time = Int32(8 * 60 * 60)
        alarmEntity.repeatDays = [false, false, false, false, false, false, false]
        alarmEntity.snoozed = false
        alarmEntity.timesSnoozed = 0 // so notification type should be .snoozable
        // create notification
        notifcationController.assembleNotificationItemsFrom(entity: alarmEntity)

        center.getPendingNotificationRequests { requests in
            createdTitle = requests[0].content.title
            XCTAssertEqual(expectedTitle, createdTitle)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 0.5)
    }
    
    // helper methods
    
    // used in testing setup and teardown
    func removeAllDeliveredNotifications() {
        center.removeAllDeliveredNotifications()
    }
    
    // used in testing setup and teardown
    func removeAllPendingNotificationRequests() {
        center.removeAllPendingNotificationRequests()
    }
}

