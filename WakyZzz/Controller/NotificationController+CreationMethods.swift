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
    // tested
    func assembleNotificationItemsFrom(entity: AlarmEntity) {
        // create dateComponents (time/date/weekday) from alarmEntity, get snoozedTimes (number of times user snoozed alarm) and notification type (based on # times snoozed) and create Local notification
        print(#function)
        let dateComponents = getDateComponents(alarmEntity: entity)
        let snoozedTimes = entity.timesSnoozed
        let type = getNotificationType(alarmEntity: entity)
        let notificationText = makeNotificationText(type: type, snoozedTimes: snoozedTimes)
        
        let notification = LocalNotification(
            id: entity.alarmID.uuidString,
            title: notificationText[0],
            subtitle: notificationText[1],
            body: notificationText[2],
            repeats: entity.repeats,
            repeated: entity.repeated,
            snoozed: entity.snoozed,
            timesSnoozed: entity.timesSnoozed,
            dateComponents: dateComponents,
            type: type)
        // send to create content...
        createNotificationContent(notification: notification)
    }
    
    // Create notification content from notification object
    private func createNotificationContent(notification: LocalNotification) {
        print(#function)
        // content is the snoozable alarm, contentNoSnooze is the non-snoozable alarm, + trial
        let content = UNMutableNotificationContent()
        
        // Set alarm sounds. Sound played depends on type/number times snoozed
        let defaultSound = UNNotificationSound.init(named: UNNotificationSoundName("sound.m4a"))
        let annoyingSound = UNNotificationSound.init(named: UNNotificationSoundName("evil.m4a"))
        
        // Set notification content
        content.title = notification.title
        content.subtitle = notification.subtitle
        content.body = notification.body
        content.categoryIdentifier = notification.type.rawValue
        content.sound = notification.type.rawValue == "NON_SNOOZABLE_ALARM" ? annoyingSound : defaultSound
        content.threadIdentifier = notification.type.rawValue // placeholder only
        content.summaryArgument = "WakyZzz" // placeholder, in case there are more than one notification showing
        content.summaryArgumentCount = 0 // placeholder, count of unread notifications
        content.targetContentIdentifier = "WakyZzz" // placeholder...
        
        // loop thru repeated weekdays and create notifications for each day
        if notification.repeats {                                               // check if there are repeated alarms or not
            var _notification = notification                                    // notification is passed in, thus immutable, so create temp notification object
            guard let unwrappedRepeated = notification.repeated else { return } // could force unwrap, since notification.repeats is true (so repeated is non-nil)
            for index in 0..<unwrappedRepeated.count {                          // cycle thru each repeated weekday
                let repeatDay = unwrappedRepeated[index]                        // get the repeat day in array at [index + 1]
                var newDateComponents = notification.dateComponents             // make a copy the dateComponents from the notification...
                newDateComponents.weekday = repeatDay + 1                       // and modify the repeat day based on notification.repeated array values
                _notification.dateComponents = newDateComponents                // apply new dateComponent to notificaiton
                createNotificationRequest(notification: _notification, content: content)
            }
        } else {                                                                // no repeated alarms
            createNotificationRequest(notification: notification, content: content) // if non-repeating, dateComponent in notification is correct already (and not needed).
        }
    }
    
    // create Notification Request and add notification given n
    private func createNotificationRequest(notification: LocalNotification, content: UNNotificationContent) {
        print(#function)
        // notification parameters
        var dateComponent = notification.dateComponents
        let repeats = notification.repeats
        let id = notification.id // notification id matches core data id.
        var trigger: UNCalendarNotificationTrigger?
        // notification trigger
        switch notification.type {
            case .snoozable:
                trigger = UNCalendarNotificationTrigger(dateMatching: dateComponent, repeats: repeats)
            case .snoozed:
                dateComponent.minute! += Int(notification.timesSnoozed)
                trigger = UNCalendarNotificationTrigger(dateMatching: dateComponent, repeats: repeats)
            case .nonSnoozable:
                trigger = UNCalendarNotificationTrigger(dateMatching: dateComponent, repeats: repeats)
        }
        
        // add notification request. Note: if repeating all repeats share the same id (not sure this works?)
        let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
        
        center.add(request) { error in
            if let error = error {
                print("Error adding request \(id): \(error.localizedDescription)")
            } else {
                print("Notification \(id) added to center")
//                self.notifications.append(notification) // not needed...only use notification for creation
            }
        }
        
        // below is for debug only, not needed...
        print(#function)
        print("Notification \(id) with request id \(request.identifier) set")
        listScheduledNotifications()
        listDeliveredNotifications()
    }
    
    // get the NotificationType based on AlarmEntity object timesSnoozed attribute
    // tested indirectly
    private func getNotificationType(alarmEntity: AlarmEntity) -> NotificationType {
        print(#function)
        var notificationType: NotificationType
        switch alarmEntity.timesSnoozed {
            case 0: notificationType = .snoozable
            case 1...3: notificationType = .snoozed
            default: notificationType = .nonSnoozable
        }
        
        print("notification type: \(notificationType.rawValue)")
        return notificationType
    }
    
    // get the date components from an AlarmEntity object
    private func getDateComponents(alarmEntity: AlarmEntity) -> DateComponents {
        let date = alarmEntity.dateFromTime
        let calendar = Calendar.current
        let year = calendar.component(.year, from: date)
        let month = calendar.component(.month, from: date)
        let day = calendar.component(.day, from: date)
        let hour = calendar.component(.hour, from: date)
        let minute = calendar.component(.minute, from: date)
        let weekday = calendar.component(.weekday, from: date)
        
        return DateComponents(calendar: .current, timeZone: .current, year: year, month: month, day: day, hour: hour, minute: minute, weekday: weekday)
    }
    
    // get the notification text based on type, injecting the snoozedTimes and actOfKindness
    private func makeNotificationText(type: NotificationType, snoozedTimes: Int16) -> [String] {
        var returnText = [String]()
        
        switch type {
            case .snoozable:
                returnText.append("Turn Alarm Off 🔕 or Snooze? 😴")
                returnText.append("Shut off or snooze for 1 minute")
                returnText.append("You can snooze 3 times...")
            case .snoozed:
                returnText.append("Turn Alarm Off 🔕 or Snooze? 😴")
                returnText.append("Shut off or snooze for 1 minute")
                returnText.append("You have snoozed \(snoozedTimes) out of 3")
            case .nonSnoozable:
                let actOfKindness = ActOfKindness.allCases.randomElement()?.rawValue
                returnText.append("Act of Kindness Alert! ⚠️")
                returnText.append("You must perform an act of kindness to turn alarm off")
                returnText.append("Random act of kindness: \(actOfKindness ?? "Smile today!")")
        }
        return returnText
    }
}
