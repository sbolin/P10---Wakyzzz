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
    
    //MARK: - Notification factory for creating notifications given a Core Data AlarmEntity object
    // Schedule notification alarms at given time/repeat.
    func notificationFactory(entity: AlarmEntity) {
        let localNotification = createLocalNotification(entity: entity)
        let content = createNotificationContent(notification: localNotification)
        let requests = createNotificationRequest(notification: localNotification, content: content)
        addRequests(requests: requests) { result in
            if result {
                print("Notification \(localNotification.id) added successfully")
            } else {
                print("Error, Notification not added")
            }
        }
    }
    
    //MARK: - Create LocalNotification object given Core Data AlarmEntity object
    // create local notification object from core data Entity
    func createLocalNotification(entity: AlarmEntity) -> LocalNotification {
        // create dateComponents (time/date/weekday) from alarmEntity, get snoozedTimes (number of times user snoozed alarm) and notification type (based on # times snoozed) and create Local notification
        print(#function)
        let dateComponents = getDateComponents(alarmEntity: entity)
        let snoozedTimes = entity.timesSnoozed
        let type = getNotificationType(alarmEntity: entity)
        let notificationText = makeNotificationText(type: type, snoozedTimes: snoozedTimes)
        
        return LocalNotification(
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
    }
    
    // MARK: - Create notification content form given LocalNotification object, return UNMutableNotificationContent
    // Create notification content from notification object
    func createNotificationContent(notification: LocalNotification) -> UNMutableNotificationContent {
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
        
        return content
    }
    
    //MARK: - Create notification requests given local notification and content, return [NotificationRequest]
    // loop thru repeated weekdays and create notifications for each day
    func createNotificationRequest(notification: LocalNotification, content: UNMutableNotificationContent) -> [NotificationRequest] {
        var request = [NotificationRequest]()
        if notification.repeats {                                                  // check if there are repeated alarms or not
            var _notification = notification                                       // notification is passed in, thus immutable, so create temp notification object
            guard let unwrappedRepeated = notification.repeated else { return [] } // could force unwrap, since notification.repeats is true (so repeated is non-nil)
            for index in 0..<unwrappedRepeated.count {                             // cycle thru each repeated weekday
                let repeatDay = unwrappedRepeated[index]                           // get the repeat day in array at [index + 1]
                var newDateComponents = notification.dateComponents                // make a copy the dateComponents from the notification...
                newDateComponents.weekday = repeatDay + 1                          // and modify the repeat day based on notification.repeated array values
                _notification.dateComponents = newDateComponents                   // apply new dateComponent to notificaiton
                request.append(NotificationRequest(notification: _notification, content: content))
//                addRequests(notification: _notification, content: content)
            }
        } else {                                                                   // no repeated alarms
            request.append(NotificationRequest(notification: notification, content: content))
//            addRequests(notification: notification, content: content) // if non-repeating, dateComponent in notification is correct already (and not needed).
        }
        return request
    }
    
    //MARK: - Add given NotificationRequests to notification center, return bool with outcome
    // create Notification Request and add notification given n
    func addRequests(requests: [NotificationRequest], completionHandler: @escaping (Bool) -> Void) {
        print(#function)
        for request in requests {
            
            let notification = request.notification
            let content = request.content
            
            print("notification type: \(notification.type.rawValue)")
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
                    dateComponent.minute! += Int(notification.timesSnoozed)
                    trigger = UNCalendarNotificationTrigger(dateMatching: dateComponent, repeats: repeats)
                case .delayedAction:
                    dateComponent.minute! += 30 // alarm will go off in 30 minutes
                    trigger = UNCalendarNotificationTrigger(dateMatching: dateComponent, repeats: repeats)
            }
            
            // add notification request. Note: if repeating all repeats share the same id (not sure this works?)
            let revisedRequest = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
            
            center.add(revisedRequest) { error in
                if let error = error {
                    print("Error adding request \(id): \(error.localizedDescription)")
                    completionHandler(false)
                } else {
                    print("Notification \(id) with request id \(revisedRequest.identifier) set")
                    completionHandler(true)
                }
            }
        }
        // below is for debug only, not needed...
        listScheduledNotifications()
        listDeliveredNotifications()
    }
    
    //MARK: - Notification helper methods
    // get the NotificationType based on AlarmEntity object timesSnoozed attribute
    // tested indirectly
    private func getNotificationType(alarmEntity: AlarmEntity) -> NotificationType {
        print(#function)
        var notificationType: NotificationType
        switch alarmEntity.timesSnoozed {
            case 0: notificationType = .snoozable
            case 1...2: notificationType = .snoozed //
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
                returnText.append("Turn Off Alarm 🔕 or Snooze? 😴")
                returnText.append("Shut off or snooze for 1 minute")
                returnText.append("You can snooze 3 times...")
            case .snoozed:
                let timeText = snoozedTimes > 1 ? "times" : "time"
                returnText.append("Turn Alarm Off 🔕 or Snooze? 😴")
                returnText.append("Shut off or snooze for 1 minute")
                returnText.append("You have snoozed \(snoozedTimes) \(timeText) out of 3")
            case .nonSnoozable:
                let actOfKindness = ActOfKindness.allCases.randomElement()?.rawValue
                returnText.append("⚠️ Act of Kindness Alert! ⚠️")
                returnText.append("You must perform a random act of kindness to turn alarm off")
                returnText.append("kindness: \(actOfKindness ?? "Smile today!")")
            case .delayedAction:
                returnText.append("⛔️ Reminder! ⛔️")
                returnText.append("Did you perform your Act of Kindness?")
                returnText.append("Perform Act of Kindness to turn off alarm")
        }
        return returnText
    }
}
