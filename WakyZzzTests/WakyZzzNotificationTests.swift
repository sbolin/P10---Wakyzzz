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
        notifcationController.removeAllDeliveredNotifications()
        notifcationController.removeAllPendingNotificationRequests()
        
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
        notifcationController.removeAllDeliveredNotifications()
        notifcationController.removeAllPendingNotificationRequests()
        
        // core data teardown
        testStack = nil
    }
    
    //MARK: - Tests
    //MARK: Notification Tests
    func test_createNotification() {
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
        notifcationController.ScheduleNotificationForEntity(entity: alarmEntity)
        center.getPendingNotificationRequests { requests in
            count = requests.count
        }
        XCTAssertNotNil(count)
        XCTAssertEqual(count, 1)
    }
    
    func test_cancelNotification() {
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
        notifcationController.ScheduleNotificationForEntity(entity: alarmEntity)
        center.getPendingNotificationRequests { requests in
            count = requests.count
        }
        XCTAssertNotNil(count)
        XCTAssertEqual(count, 1)
        
        notifcationController.CancelNotificationForEntity(entity: alarmEntity)
        center.getPendingNotificationRequests { requests in
            count = requests.count
        }
        XCTAssertEqual(count, 0)
    }
    
    func test_getNotificationType() {
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
        notifcationController.ScheduleNotificationForEntity(entity: alarmEntity)

        center.getPendingNotificationRequests { requests in
            createdTitle = requests[0].content.title
        }
        XCTAssertEqual(expectedTitle, createdTitle)
    }
}

