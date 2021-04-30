//
//  WakyZzzSetAlarmViewControllerTests.swift
//  WakyZzzTests
//
//  Created by Scott Bolin on 29-Apr-21.
//  Copyright © 2021 TukgaeSoft. All rights reserved.
//

import XCTest
import CoreData
@testable import WakyZzz

class WakyZzzSetAlarmViewControllerTests: XCTestCase, NSFetchedResultsControllerDelegate {

    //MARK: - Properties
    var viewControllerUnderTest: SetAlarmViewController!
    var alarm: Alarm? // pass in alarm object for editing
    var delegate: SetAlarmViewControllerDelegate?
    
    override func setUp() {
        super.setUp()
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        self.viewControllerUnderTest = storyboard.instantiateViewController(withIdentifier: "SetAlarm") as? SetAlarmViewController
        
        self.viewControllerUnderTest.loadView()
        self.viewControllerUnderTest.viewDidLoad()
        self.viewControllerUnderTest.config()
        self.viewControllerUnderTest.viewWillAppear(false)
        self.viewControllerUnderTest.viewDidAppear(false)
    }
    
    override func tearDown() {
        super.tearDown()
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
        
        let cell = viewControllerUnderTest.tableView(viewControllerUnderTest.tableView, cellForRowAt: IndexPath(row: 0, section: 0))
        let actualReuseIdentifer = cell.reuseIdentifier
        let expectedReuseIdentifier = "DayOfWeekCell"
        XCTAssertEqual(actualReuseIdentifer, expectedReuseIdentifier)
    }
    
    func testTableViewSections() {
        XCTAssertEqual(viewControllerUnderTest.tableView.numberOfSections, 1)
    }
    
    func testTableViewRows() {
        XCTAssertEqual(viewControllerUnderTest.tableView.numberOfRows(inSection: 0), 7)
    }
    
    func testTableCellHasCorrectLabelText() {
        
        let cell0 = viewControllerUnderTest.tableView(viewControllerUnderTest.tableView, cellForRowAt: IndexPath(row: 0, section: 0))
        XCTAssertNotNil(cell0)
        XCTAssertEqual(cell0.textLabel?.text, "Sun")
        XCTAssertEqual(cell0.accessoryType, .none )
        
        let cell1 = viewControllerUnderTest.tableView(viewControllerUnderTest.tableView, cellForRowAt: IndexPath(row: 1, section: 0))
        XCTAssertNotNil(cell1)
        XCTAssertEqual(cell1.textLabel?.text, "Mon")
        XCTAssertEqual(cell1.accessoryType, .none )
        
        let cell2 = viewControllerUnderTest.tableView(viewControllerUnderTest.tableView, cellForRowAt: IndexPath(row: 2, section: 0))
        XCTAssertNotNil(cell2)
        XCTAssertEqual(cell2.textLabel?.text, "Tue")
        XCTAssertEqual(cell2.accessoryType, .none )
        
        let cell3 = viewControllerUnderTest.tableView(viewControllerUnderTest.tableView, cellForRowAt: IndexPath(row: 3, section: 0))
        XCTAssertNotNil(cell3)
        XCTAssertEqual(cell3.textLabel?.text, "Wed")
        XCTAssertEqual(cell3.accessoryType, .none )
        
        let cell4 = viewControllerUnderTest.tableView(viewControllerUnderTest.tableView, cellForRowAt: IndexPath(row: 4, section: 0))
        XCTAssertNotNil(cell4)
        XCTAssertEqual(cell4.textLabel?.text, "Thu")
        XCTAssertEqual(cell4.accessoryType, .none )
        
        let cell5 = viewControllerUnderTest.tableView(viewControllerUnderTest.tableView, cellForRowAt: IndexPath(row: 5, section: 0))
        XCTAssertNotNil(cell5)
        XCTAssertEqual(cell5.textLabel?.text, "Fri")
        XCTAssertEqual(cell5.accessoryType, .none )
        
        let cell6 = viewControllerUnderTest.tableView(viewControllerUnderTest.tableView, cellForRowAt: IndexPath(row: 6, section: 0))
        XCTAssertNotNil(cell6)
        XCTAssertEqual(cell6.textLabel?.text, "Sat")
        XCTAssertEqual(cell6.accessoryType, .none )
        
    }
}
