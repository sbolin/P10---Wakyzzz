//
//  AlarmEntity+CoreDataProperties.swift
//  WakyZzz
//
//  Created by Scott Bolin on 2/25/21.
//  Copyright © 2021 Olga Volkova OC. All rights reserved.
//
//

import Foundation
import CoreData


extension AlarmEntity {

    @nonobjc public class func alarmFetchRequest() -> NSFetchRequest<AlarmEntity> {
        return NSFetchRequest<AlarmEntity>(entityName: "AlarmEntity")
    }

    @NSManaged public var status: Bool
    @NSManaged public var repeating: Bool
    @NSManaged public var alarmTime: Int32
    @NSManaged public var repeatDays: String?
    @NSManaged public var snoozed: Bool
    @NSManaged public var snoozedTimes: Int16

}

extension AlarmEntity : Identifiable {

}
