//
//  NotificationController+CreationMethods.swift
//  WakyZzz
//
//  Created by Scott Bolin on 09-A-21.
//  Copyright © 2021 TukgaeSoft. All rights reserved.
//

import UIKit
import UserNotifications

extension NotificationController {
   
   //MARK: - Create Notification
   // Schedule notification alarms at given time/repeat.
    func ScheduleNotificationForEntity(entity: AlarmEntity) {
        let id = entity.alarmID.uuidString
        // if id == notification id then delete existing notification...
        // add new notification with id, and use entity to create date/repeat, etc
        let date = entity.dateFromTime // use today's date for now...
        let calendar = Calendar.current
        let year = calendar.component(.year, from: date)
        let month = calendar.component(.month, from: date)
        let day = calendar.component(.day, from: date)
        let hour = calendar.component(.hour, from: date)
        let minute = calendar.component(.minute, from: date)
        let weekday = entity.repeated[0]
        
        let repeats = entity.repeats
        let repeated = entity.repeated
        let dateComponents = DateComponents(calendar: .current, timeZone: .current, year: year, month: month, day: day, hour: hour, minute: minute, weekday: weekday)
        let snoozedTimes = entity.timesSnoozed
        let actOfKindness = ActOfKindness.allCases.randomElement()?.rawValue
        let type = getNotificationType(alarmEntity: entity)

        var alarmName = ""
        var subtitle = ""
        var body = ""
        
        switch type {
            case .snoozable:
                alarmName = "Turn Alarm Off 🔕 or Snooze? 😴"
                subtitle = "Shut off or snooze for 1 minute"
                body = "Body of notification"
            case .snoozed:
                alarmName = "Turn Alarm Off 🔕 or Snooze? 😴"
                subtitle = "Shut off or snooze for 1 minute"
                body = "You have snoozed \(snoozedTimes) out of 3" // timesSn
            case .nonSnoozable:
                alarmName = "Act of Kindness Alert! ⚠️"
                subtitle = "You must perform an act of kindness to turn alarm off"
                body = "Random act of kindness: \(actOfKindness ?? "Smile today!")"
        }
        
        let notification = LocalNotification(
            id: id, // from core data
            title: alarmName,
            subtitle: subtitle,
            body: body,
            repeating: repeats,
            repeatDays: repeated,
            dateComponents: dateComponents)
        
        createNotificationContent(notification: notification, type: type)
    }
   
   // Create notification content from notification object
   private func createNotificationContent(notification: LocalNotification, type: NotificationType) {
      
      // content is the snoozable alarm, contentNoSnooze is the non-snoozable alarm, + trial
      let content = UNMutableNotificationContent()
      
      // Set content
      let defaultSound = UNNotificationSound.init(named: (UNNotificationSoundName("sound.mp3")) as String)
      let annoyingSound = UNNotificationSound.init(named: (UNNotificationSoundName("evil.m4a")) as String)
      
      content.title = notification.title
      content.subtitle = notification.subtitle
      content.body = notification.body
      content.categoryIdentifier = type.rawValue
      content.sound = type.rawValue == "NON_SNOOZABLE_ALARM" ? annoyingSound : defaultSound
      content.threadIdentifier = type.rawValue // placeholder only
      content.summaryArgument = "WakyZzz" // placeholder, in case there are more than one notification showing
      content.summaryArgumentCount = 0 // placeholder, count of unread notifications
      content.targetContentIdentifier = "WakyZzz" // placeholder...
      
      
      for index in 0..<(notification.repeatDays.count - 1) {
         let repeatDay = notification.repeatDays[index] // assumes Sunday = 0...
         createNotificationRequest(notification: notification, weekDay: repeatDay, content: content)
      }
   }
   
   // create Notification Request and add notification given n
   private func createNotificationRequest(notification: LocalNotification, weekDay: Int, content: UNNotificationContent) {
    print(#function)
      // notification parameters
      let dateComponent = notification.dateComponents
      let repeats = notification.repeating
      let id = notification.id // must use core data id so id can be tracked
      
      // notification trigger
      let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponent, repeats: repeats)
      
      // add notification request. Note: if repeating all repeats share the same id (not sure this works?)
      let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
      
      center.add(request) { error in
         if let error = error {
            print("Error adding request \(id): \(error.localizedDescription)")
         } else {
            print("Notification \(id) added to center")
            self.notifications.append(notification) // not needed...only use notification for creation
         }
      }
      
      // below is for debug only, not needed...
//      #if DEBUG
      print(#function)
      print("Notification \(id) with request id \(request.identifier) set")
      print("List of notifications follows:")
      listScheduledNotifications()
    print("=======================")
      listDeliveredNotifications()
//      #endif
   }
    
    private func getNotificationType(alarmEntity: AlarmEntity) -> NotificationType {
        print(#function)
        var notificationType: NotificationType
        if alarmEntity.timesSnoozed == 3 {
            notificationType = .nonSnoozable
        } else if alarmEntity.timesSnoozed > 0 {
            notificationType = .snoozed
        } else {
            notificationType = .snoozable
        }
        return notificationType
    }
}
