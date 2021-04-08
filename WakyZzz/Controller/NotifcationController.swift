//
//  NotifcationController.swift
//  WakyZzz
//
//  Created by Scott Bolin on 2/18/21.
//  Copyright © 2020 Scott Bolin. All rights reserved.
//

import UIKit
import UserNotifications

enum NotificationType: String {
    case snoozable = "SNOOZABLE_ALARM"
    case snoozed = "SNOOZED_ALARM"
    case nonSnoozable = "NON_SNOOZABLE_ALARM"
}

// not specifically needed, just used to post notification details to viewcontroller...
struct LocalNotification {
    var id: String
    var title: String
    var subtitle: String
    var body: String
    var repeating: Bool
    var repeatDays: [Int]
    var dateComponents: DateComponents
}

class NotificationController: NSObject, UNUserNotificationCenterDelegate {
    
    //MARK: - Properties
    var notifications = [LocalNotification]()
    let center = UNUserNotificationCenter.current()
    // user notification types to check if authorized or not.
    var alertOn = false
    var soundOn = false
    var badgeOn = false
    //    let alerts = AlertsManager()

    //MARK: - Request Authorization
    func requestNotificationAuthorization() {
        let authOptions = UNAuthorizationOptions.init(arrayLiteral: .alert, .announcement, .badge, .carPlay, .sound) // asks for authorization to show notification via alert, Siri read aloud, badges, carplay, and play sound
        
        // unused authorization options, keep in case added functionality later
        let _: UNAuthorizationOptions = [
            .criticalAlert, // For having sound even device is muted / Do Not Disturb is enabled
            .providesAppNotificationSettings, // provide settings in app
            .provisional] // post non-interrupting notifications provisionally to the Notification Center
        
        // request user authorization to present notifications
        center.requestAuthorization(options: authOptions) { granted, error in
            
            if let error = error {
                print("Auth Error...", error.localizedDescription)
                // Handle Error
                return
            } else if granted {
                self.center.getNotificationSettings { settings in
                    guard (settings.authorizationStatus == .authorized) ||
                            (settings.authorizationStatus == .provisional) else { return }
                    
                    // check individual settings and toggle notification types accordingly
                    if settings.alertSetting == .enabled {
                        print("alert setting: \(settings.alertSetting)")
                        self.alertOn = true
                    }
                    
                    if settings.soundSetting == .enabled {
                        print("sound setting: \(settings.soundSetting)")
                        self.soundOn = true
                    }
                    
                    if settings.badgeSetting == .enabled {
                        print("badge setting: \(settings.badgeSetting)")
                        self.badgeOn = true
                    }
                    // ignore other settings for version 1
                }
            } else {
                print("Notification denied")
            }
        }
    }
    
    //MARK: - Setup Notification Actions and Categories
    func setupActions() {
        /// Define Notification actions.
        /// snoozed < 3 times
        // turn off alarm
        let turnOffAlarm = UNNotificationAction(identifier: "TURN_OFF_ALARM",
                                                title: "Turn off Alarm",
                                                options: .foreground) //UNNotificationActionOptions(rawValue: 0))
        // snooze alarm
        let snoozeAlarm = UNNotificationAction(identifier: "SNOOZE_ALARM",
                                               title: "Snooze alarm for 1 minute",
                                               options: .foreground) //UNNotificationActionOptions(rawValue: 1))
        /// snoozed >= 3 times
        // act of kindness performed now
        let actOfKindnessNow = UNNotificationAction(identifier: "ACT_OF_KINDNESS",
                                                    title: "Perform Act of Kindness Now",
                                                    options: .foreground) //UNNotificationActionOptions(rawValue: 2))
        // act of kindess performed later
        let actOfKindnessLater = UNNotificationAction(identifier: "ACT_OF_KINDNESS_LATER",
                                                      title: "Defer Act of Kindness (Trust system™)",
                                                      options: .foreground) //UNNotificationActionOptions(rawValue: 3))
        
        /// Define the notification categories
        /// snoozed < 3 times
        let snoozableCategory = UNNotificationCategory(identifier: NotificationType.snoozable.rawValue,
                                                       actions: [turnOffAlarm, snoozeAlarm],
                                                       intentIdentifiers: [],
                                                       hiddenPreviewsBodyPlaceholder: "",
                                                       options: .customDismissAction)
        /// alarm has been snoozed
        let snoozedCategory = UNNotificationCategory(identifier: NotificationType.snoozed.rawValue,
                                                       actions: [turnOffAlarm, snoozeAlarm],
                                                       intentIdentifiers: [],
                                                       hiddenPreviewsBodyPlaceholder: "",
                                                       options: .customDismissAction)
        /// snoozed 3 times
        let nonSnoozableCategory = UNNotificationCategory(identifier: NotificationType.nonSnoozable.rawValue,
                                                          actions: [actOfKindnessNow, actOfKindnessLater],
                                                          intentIdentifiers: [],
                                                          hiddenPreviewsBodyPlaceholder: "",
                                                          options: .customDismissAction)
        
        // Register the notification type.
        center.setNotificationCategories([snoozableCategory, snoozedCategory, nonSnoozableCategory])
        
        print("Actions and Categories set")
    }

    //MARK: - Schedule Notification
    func createNotification(notification: LocalNotification, type: NotificationType) {
        
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
            addNotification(notification: notification, weekDay: repeatDay, content: content)
        }
    }
    
    private func addNotification(notification: LocalNotification, weekDay: Int, content: UNNotificationContent) {
        
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
    
    //MARK: - Cleanup methods
    func removeDeliveredNotificationsWithIdentifiers(identifiers: [UNNotification]) {
        var id = [""]
        center.getDeliveredNotifications { deliveredNotificationList in
            deliveredNotificationList.forEach { notification in
                if identifiers.contains(notification) {
                    id.append(notification.request.identifier)
                }
            }
        }
        center.removeDeliveredNotifications(withIdentifiers: id)
        // below not needed if notifications is used for creation only

        notifications.removeAll { item in
            return item.id == id[0]
        }
    }
    
    func removePendingNotificationRequestsWithIdentifiers(identifiers: [UNNotificationRequest]) {
        var id = [""]
        center.getPendingNotificationRequests { pendingNotificationRequests in
            pendingNotificationRequests.forEach { request in
                if identifiers.contains(request) {
                    id.append(request.identifier)
                }
            }
        }
        center.removePendingNotificationRequests(withIdentifiers: id)
        // below not needed if notifications is used for creation only
        notifications.removeAll { item in
            return item.id == id[0]
        }
    }
    
    func removeNotification(at identifier: String) {
        center.removePendingNotificationRequests(withIdentifiers: [identifier])
    }
    
    func removeAllDeliveredNotifications() {
        center.removeAllDeliveredNotifications()
    }
    
    func removeAllPendingNotificationRequests() {
        center.removeAllPendingNotificationRequests()
    }
    
    //MARK: - NotificationController helper methods
    private func listScheduledNotifications() {
        print("====Scheduled Notifications====")
        center.getPendingNotificationRequests { notifications in
            for notification in notifications {
                print(notification)
            }
        }
    }
    
    private func listDeliveredNotifications() {
        print("====Delivered Notifications====")
        center.getDeliveredNotifications { notifications in
            for notification in notifications {
                print(notification)
            }
        }
    }
}
