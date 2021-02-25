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

    @NSManaged public var enabled: Bool
    @NSManaged public var repeating: Bool
    @NSManaged public var alarmTime: Int32
    @NSManaged public var repeatDays: [Bool]
    @NSManaged public var snoozed: Bool
    @NSManaged public var snoozedTimes: Int16

}

extension AlarmEntity : Identifiable {

}

/*
 status - Alarm on or off
 repeatingDayString - Alarm repeats or not
 alarmTime - Time of alarm, represented as an integer (eg, 8am = 8 * 60 minutes/hour * 60 seconds/minute, or seconds in the day from midnight. 12:00AM = 0 or 86400
 repeatDays - Days alarm repeates, in the form [false, false, false, false, false, false, false]
 snoozed - Alarm has been snoozed
 snoozedTimes - Number of times snooze has been pressed
 */
