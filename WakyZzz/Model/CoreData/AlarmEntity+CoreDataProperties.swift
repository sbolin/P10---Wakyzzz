//
//  AlarmEntity+CoreDataProperties.swift
//  WakyZzz
//
//  Created by Scott Bolin on 3/27/21.
//  Copyright © 2021 TukgaeSoft. All rights reserved.
//
//

import Foundation
import CoreData


extension AlarmEntity {

    @nonobjc public class func alarmFetchRequest() -> NSFetchRequest<AlarmEntity> {
        return NSFetchRequest<AlarmEntity>(entityName: "AlarmEntity")
    }

    @NSManaged public var alarmID: UUID
    @NSManaged public var enabled: Bool
    @NSManaged public var repeatDays: [Bool]
    @NSManaged public var snoozed: Bool
    @NSManaged public var time: Int32
    @NSManaged public var timesSnoozed: Int16
    
    static let daysOfWeek = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
    
    //MARK: -  Computed Properties
    // String showing alarm time
    @objc public var localAlarmTimeString: String { // switched name to localAlarmTimeString from repeatingDayString
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        
        let date = Date()
        let calendar = Calendar.current
        let hour = Int(time/3600) // h
        let minute = Int(time/60) - hour * 60 // m
        
        var alarmTimeComponents = calendar.dateComponents([.hour, .minute, .second, .day, .month, .year, .weekdayOrdinal], from: date as Date)
        
        alarmTimeComponents.hour = hour
        alarmTimeComponents.minute = minute
        
        let alarmTimeAndDate = calendar.date(from: alarmTimeComponents)
        
        return formatter.string(from: alarmTimeAndDate!)
    }
    
    @objc public var repeatingDayString: String { // switched name to repeatingDayString from repeating
        var captions = [String]() // temp var holding string of repeated days
        for i in 0 ..< repeatDays.count {
            if repeatDays[i] {
                captions.append(AlarmEntity.daysOfWeek[i])
            }
        }
        return captions.count > 0 ? captions.joined(separator: ", ") : "One time alarm"
    }
    
    func toAlarm() -> Alarm {
        let alarm = Alarm()
        alarm.alarmID = self.alarmID
        alarm.enabled = self.enabled
        alarm.repeatDays = self.repeatDays
        alarm.snoozed = self.snoozed
        alarm.time = Int(self.time)
        alarm.timesSnoozed = Int(self.timesSnoozed)
        return alarm
    }

}

extension AlarmEntity : Identifiable {

}

/*
 enabled - Alarm on or off
 time - Time of alarm, represented as an integer (eg, 8am = 8 * 60 minutes/hour * 60 seconds/minute, or seconds in the day from midnight. 12:00AM = 0 or 86400
 repeatDays - Days alarm repeates, in the form [false, false, false, false, false, false, false]
 snoozed - Alarm has been snoozed
 timesSnoozed - Number of times snooze has been pressed
 */
