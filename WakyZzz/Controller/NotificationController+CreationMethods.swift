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
   // Schedule notification alarms at given time/repeat. Better to call using AlarmEntity
    func ScheduleNotificationForEntity(entity: AlarmEntity, type: NotificationType) {
        let id = entity.alarmID.uuidString
        // if id == notification id then delete existing notification...
        // add new notification with id, and use entity to create date/repeat, etc
    }
    
    func CancelNotificationForEntity(entity: AlarmEntity) {
        let id = entity.alarmID.uuidString
        // cancel notification id
    }
    
   func ScheduleNotification(hour: Int, minute: Int, repeats: Bool, type: NotificationType) {
      let date = Date() // use today's date for now...
      let calendar = Calendar.current
      let year = calendar.component(.year, from: date)
      let month = calendar.component(.month, from: date)
      let day = calendar.component(.day, from: date)
      let weekday = calendar.component(.weekday, from: date)
      var repeated: [Int] = [weekday]
      let dateComponents = DateComponents(calendar: .current, timeZone: .current, year: year, month: month, day: day, hour: hour, minute: minute, weekday: weekday)
      let snoozedTimes = 0 // TODO: get from CoreData
      let actOfKindness = ActOfKindness.allCases.randomElement()?.rawValue
      
      if repeats {
         repeated = [3, 5, 7] // use Core Data to populate...
      }
      
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
         id: UUID().uuidString, // from core data
         title: alarmName,
         subtitle: subtitle,
         body: body,
         repeating: repeats,
         repeatDays: repeated,
         dateComponents: dateComponents)
      
      createNotificationContent(notification: notification, type: type)
   }
   
   // Create notification content from notification object
   func createNotificationContent(notification: LocalNotification, type: NotificationType) {
      
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
      
      
      for index in 0..<notification.repeatDays.count {
         let repeatDay = notification.repeatDays[index]
         createNotificationRequest(notification: notification, weekDay: repeatDay, content: content)
      }
   }
   
   // create Notification Request and add notification given n
   private func createNotificationRequest(notification: LocalNotification, weekDay: Int, content: UNNotificationContent) {
      
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
            print("Request \(id) creation error: ", error.localizedDescription)
         } else {
            print("Notification \(id) Scheduled")
            self.notifications.append(notification) // not needed...only use notification for creation
         }
      }
      
      // below is for debug only, not needed...
      #if DEBUG
      print(#function)
      print("Notification \(id) with request id \(request.identifier) set")
      print("List of notifications follows:")
      listScheduledNotifications()
      listDeliveredNotifications()
      #endif
   }
}
