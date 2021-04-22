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
        
        // set authorization
        center.getNotificationSettings { settings in
            let status: UNAuthorizationStatus = .authorized
            settings.setValue(status.rawValue, forKey: "authorizationStatus")
        }
        
        // setup notification actions
        notifcationController.setupActions()
        
        //DANGER: DELETE ALL NOTIFICATIONS!
        removeAllDeliveredNotifications()
        removeAllPendingNotificationRequests()
        
        // set up core data stack
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
    func test_notificationFactory() {
        
        //given AlarmEntity
        let alarmEntity = makeAlarmEntity()
        
        // create notification with entity
        notifcationController.notificationFactory(entity: alarmEntity)
        
        //
        let expectation = XCTestExpectation(description: "Test passed")
        var requests: [UNNotificationRequest] = []
        
        center.getPendingNotificationRequests { notificationRequests in
            requests = notificationRequests
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 10.0)
        XCTAssertNotNil(requests)
    }
    
    func test_createLocalNotification() {
        
        // given alarmEntity
        let alarmEntity = makeAlarmEntity()
        alarmEntity.repeatDays = [false, false, false, true, false, false, false]
        
        // create local notification with alarm entity
        let localNotification = notifcationController.createLocalNotification(entity: alarmEntity)
        
        // test local notification
        XCTAssertNotNil(localNotification)
        XCTAssertTrue(localNotification.title == "Turn Off Alarm 🔕 or Snooze? 😴")
        XCTAssertTrue(localNotification.subtitle == "Shut off or snooze for 1 minute")
        XCTAssertTrue(localNotification.body == "You can snooze 3 times...")
        XCTAssertTrue(localNotification.type == .snoozable)
        XCTAssertTrue(localNotification.repeats == true)
        XCTAssertTrue(localNotification.repeated == [3])
        XCTAssertTrue(localNotification.snoozed == false)
        XCTAssertTrue(localNotification.timesSnoozed == 0)
        XCTAssertTrue(localNotification.dateComponents.isValidDate == true)
    }
    
    func test_createNotificationContent() {
        
        // given alarmEntity
        let alarmEntity = makeAlarmEntity()
        alarmEntity.repeatDays = [false, false, false, true, false, false, false]
        
        // create local notification with alarm entity
        let localNotification = notifcationController.createLocalNotification(entity: alarmEntity)
        // create content from localNotification
        let content = notifcationController.createNotificationContent(notification: localNotification)
        let defaultSound = UNNotificationSound.init(named: UNNotificationSoundName("sound.m4a"))
        
        // test contents
        XCTAssertNotNil(localNotification)
        XCTAssertNotNil(content)
        XCTAssertTrue(content.title == "Turn Off Alarm 🔕 or Snooze? 😴")
        XCTAssertTrue(content.subtitle == "Shut off or snooze for 1 minute")
        XCTAssertTrue(content.body == "You can snooze 3 times...")
        XCTAssertTrue(content.categoryIdentifier == "SNOOZABLE_ALARM")
        XCTAssertTrue(content.sound == defaultSound)
    }
    
    func test_createNotificationRequest() {
        
        // given alarmEntity
        let alarmEntity = makeAlarmEntity()
        alarmEntity.repeatDays = [false, false, false, true, false, false, false]
        
        // create local notification with alarm entity
        let localNotification = notifcationController.createLocalNotification(entity: alarmEntity)
        // create content from localNotification
        let content = notifcationController.createNotificationContent(notification: localNotification)
        // create request from localNotification and content
        let request = notifcationController.createNotificationRequest(notification: localNotification, content: content)
        
        // test contents
        XCTAssertNotNil(localNotification)
        XCTAssertNotNil(content)
        XCTAssertNotNil(request)
        
    }
    
    func test_addRequest() {
        
        // given alarmEntity
        let alarmEntity = makeAlarmEntity()
        alarmEntity.repeatDays = [false, false, false, true, false, false, false]
        var testResult: Bool = false
        
        // with expectation
        let expectation = XCTestExpectation(description: "Test passed")
        
        // create local notification with alarm entity
        let localNotification = notifcationController.createLocalNotification(entity: alarmEntity)
        // create content from localNotification
        let content = notifcationController.createNotificationContent(notification: localNotification)
        // create request from localNotification and content
        let request = notifcationController.createNotificationRequest(notification: localNotification, content: content)
        
        notifcationController.addRequests(requests: request) { result in
            if result {
                testResult = result
                expectation.fulfill()
            } else {
                testResult = result
                expectation.fulfill()
            }
        }
        // primary result
        wait(for: [expectation], timeout: 10.0)
        XCTAssertEqual(testResult, true)
    }
    
    func test_cancelNotification() {
        // given alarm entity
        let alarmEntity = makeAlarmEntity()
        // with expectation
        let expectation = XCTestExpectation(description: "Test passed")
        var count = 0
        // create notification
        notifcationController.notificationFactory(entity: alarmEntity)
        //cancel notification
        notifcationController.cancelNotificationForEntity(entity: alarmEntity)
        center.getPendingNotificationRequests { requests in
            count = requests.count
            XCTAssertTrue(count == 0)
            expectation.fulfill()
            // fulfill expectation
        }
        wait(for: [expectation], timeout: 10.0)
    }
    
    // helper methods
    
    func makeAlarmEntity() -> AlarmEntity {
        let derivedContext = testStack.derivedContext
        let alarmEntity = AlarmEntity(context: derivedContext)
        alarmEntity.alarmID = UUID()
        alarmEntity.enabled = true
        alarmEntity.time = Int32(8 * 60 * 60)
        alarmEntity.repeatDays = [false, false, false, false, false, false, false]
        alarmEntity.snoozed = false
        alarmEntity.timesSnoozed = 0
        
        return alarmEntity
    }
    
    // used in testing setup and teardown
    func removeAllDeliveredNotifications() {
        center.removeAllDeliveredNotifications()
    }
    
    // used in testing setup and teardown
    func removeAllPendingNotificationRequests() {
        center.removeAllPendingNotificationRequests()
    }
}

