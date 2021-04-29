//
//  WakyZzzAlarmsViewControllerTests.swift
//  WakyZzzTests
//
//  Created by Scott Bolin on 26-Apr-21.
//  Copyright © 2021 TukgaeSoft. All rights reserved.
//

import XCTest
import CoreData
@testable import WakyZzz

final class WakyZzzAlarmsViewControllerTests: XCTestCase, NSFetchedResultsControllerDelegate {
    
    //MARK: - Properties
    var testStack: TestCoreDataController!
    var fetchedResultsController: NSFetchedResultsController<AlarmEntity>!
    var viewControllerUnderTest: AlarmsViewController!
    
    override func setUp() {
        super.setUp()
        
        testStack = TestCoreDataController()
        if fetchedResultsController == nil {
            fetchedResultsController = testStack.fetchedAlarmResultsController
        }
        fetchedResultsController.delegate = self
        do {
            try fetchedResultsController.performFetch()
        } catch {
            print("Fetch failed")
        }
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        self.viewControllerUnderTest = storyboard.instantiateViewController(withIdentifier: "AlarmsViewController") as? AlarmsViewController
        
        // in view controller, menuItems = ["one", "two", "three"]
        self.viewControllerUnderTest.loadView()
        self.viewControllerUnderTest.viewDidLoad()
        self.viewControllerUnderTest.viewWillAppear(false)
        self.viewControllerUnderTest.viewDidAppear(false)
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
        testStack = nil
    }
    
    func testHasATableView() {
        XCTAssertNotNil(viewControllerUnderTest.tableView)
    }
    
    func testTableViewHasDelegate() {
        XCTAssertNotNil(viewControllerUnderTest.tableView.delegate)
    }
    
    func testTableViewConfromsToTableViewDelegateProtocol() {
        XCTAssertTrue(viewControllerUnderTest.conforms(to: UITableViewDelegate.self))
        XCTAssertTrue(viewControllerUnderTest.responds(to: #selector(viewControllerUnderTest.tableView(_:didSelectRowAt:))))
    }
    
    func testTableViewHasDataSource() {
        XCTAssertNotNil(viewControllerUnderTest.tableView.dataSource)
    }
    
    func testTableViewConformsToTableViewDataSourceProtocol() {
        XCTAssertTrue(viewControllerUnderTest.conforms(to: UITableViewDataSource.self))
        XCTAssertTrue(viewControllerUnderTest.responds(to: #selector(viewControllerUnderTest.numberOfSections(in:))))
        XCTAssertTrue(viewControllerUnderTest.responds(to: #selector(viewControllerUnderTest.tableView(_:numberOfRowsInSection:))))
        XCTAssertTrue(viewControllerUnderTest.responds(to: #selector(viewControllerUnderTest.tableView(_:cellForRowAt:))))
    }
    
    func testTableViewCellHasReuseIdentifier() {
        // create alarm to populate table
        createAlarm()
        viewControllerUnderTest.tableView.reloadData()
        let cell = viewControllerUnderTest.tableView(viewControllerUnderTest.tableView, cellForRowAt: IndexPath(row: 0, section: 0)) as? AlarmTableViewCell
        let actualReuseIdentifer = cell?.reuseIdentifier
        let expectedReuseIdentifier = "AlarmCell"
        XCTAssertEqual(actualReuseIdentifer, expectedReuseIdentifier)
    }
    
    func testFirstRunCompleted() {
        XCTAssertEqual(UserDefaults.standard.bool(forKey: "Launched Before"), true)
    }
    
    func testTableCellHasCorrectLabelText() {
        // create alarm to populate table
        createAlarm()
        viewControllerUnderTest.tableView.reloadData()
        let cell0 = viewControllerUnderTest.tableView(viewControllerUnderTest.tableView, cellForRowAt: IndexPath(row: 0, section: 0)) as? AlarmTableViewCell
        XCTAssertEqual(cell0?.captionLabel.text, "8:00 AM")
        XCTAssertEqual(cell0?.subcaptionLabel.text, "One time alarm")
        XCTAssertEqual(cell0?.enabledSwitch.isOn, true)
    }
    
    func createAlarm() {
        let alarmTime = 8*60*60
        let alarm = Alarm()
        alarm.enabled = true
        alarm.time = alarmTime
        alarm.repeatDays = [false, false, false, false, false, false, false]
        alarm.snoozed = false
        alarm.timesSnoozed = 0
        
        // create alarm
        viewControllerUnderTest.setAlarmViewControllerDone(alarm: alarm)
        
        // fetch same alarm
        do {
            try testStack.fetchedAlarmResultsController.performFetch()
        } catch {
            print("could not perform fetch")
        }
        print("Alarm count: \(fetchedResultsController.fetchedObjects?.count)")
    }
}
