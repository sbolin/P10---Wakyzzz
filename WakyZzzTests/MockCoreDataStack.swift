//
//  MockCoreDataStack.swift
//  WakyZzzTests
//
//  Created by Scott Bolin on 2/27/21.
//  Copyright © 2021 Olga Volkova OC. All rights reserved.
//

@testable import WakyZzz
import Foundation
import CoreData

class MockCoreDataStack: CoreDataStack {
    
    override init() {
        super.init()
        
        let persistentStoreDescription = NSPersistentStoreDescription()
        persistentStoreDescription.type = NSInMemoryStoreType
        persistentStoreDescription.url = URL(fileURLWithPath: "/dev/null")
        
        let container = NSPersistentContainer(
            name: "WakyZzz",
            managedObjectModel: CoreDataStack().model)
        
        container.persistentStoreDescriptions = [persistentStoreDescription]
        
        container.loadPersistentStores { (_, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        persistentContainer = container
    }
}

