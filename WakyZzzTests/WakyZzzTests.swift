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
    


}
