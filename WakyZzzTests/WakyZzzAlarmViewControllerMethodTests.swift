//
//  WakyZzzAlarmViewControllerMethodTests.swift
//  WakyZzzTests
//
//  Created by Scott Bolin on 17-Apr-21.
//  Copyright © 2021 TukgaeSoft. All rights reserved.
//

import CoreData
import XCTest
@testable import WakyZzz

class WakyZzzAlarmViewControllerMethodTests: XCTestCase {

    // Set up notifications
    var notifications = [LocalNotification]()
    let center = UNUserNotificationCenter.current()
    let notifcationController = NotificationController() // manager
    var vc: AlarmsViewController?
    
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
    func testDeleteAlarm() {
        testStack.createAlarmEntity()
        do {
            try testStack.fetchedAlarmResultsController.performFetch()
        } catch {
            print("could not perform fetch")
            XCTFail("\(#function) error happened \(error.localizedDescription)")
        }
        
        let indexPath = IndexPath(row: 0, section: 0)
        vc?.deleteAlarm(at: indexPath)

        let alarm = testStack.fetchedAlarmResultsController.object(at: indexPath)
        // test function
        XCTAssertNotNil(alarm, "alarm not nil")
    }
    
    //note: functions editAlarm and presentSetAlarmViewController are not tested
    
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
