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
    case delayedAction = "DELAYED_ACTION"
}

// not specifically needed, just used to post notification details to viewcontroller...
struct LocalNotification {
    let id: String
    let title: String
    let subtitle: String
    let body: String
    let repeats: Bool
    let repeated: [Int]?
    let snoozed: Bool
    let timesSnoozed: Int16
    var dateComponents: DateComponents
    let type: NotificationType
}

struct NotificationRequest {
    let notification: LocalNotification
    let content: UNNotificationContent
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
        // asks for authorization to show notification via alert, Siri read aloud, badges, carplay, and play sound
        let authOptions = UNAuthorizationOptions.init(arrayLiteral: .alert, .announcement, .badge, .carPlay, .sound)
        
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
                // should put alert up in AlarmsViewController
            }
        }
    }
    
    //MARK: - Setup Notification Actions and Categories
    func setupActions() {
        print(#function)
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
        
        // reminder to perform act of kindness
        let remindPerformKindness = UNNotificationAction(identifier: "REMINDER_PERFORM_ACT_OF_KINDNESS",
                                                      title: "Perform Act of Kindness",
                                                      options: .foreground) //UNNotificationActionOptions(rawValue: 4))
        
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
        
        /// remind user to perform act of kindness if user deferred action
        let reminderCategory = UNNotificationCategory(identifier: NotificationType.delayedAction.rawValue,
                                                          actions: [remindPerformKindness],
                                                          intentIdentifiers: [],
                                                          hiddenPreviewsBodyPlaceholder: "",
                                                          options: .customDismissAction)
        
        // Register the notification type.
        center.setNotificationCategories([snoozableCategory, snoozedCategory, nonSnoozableCategory, reminderCategory])
    }
}
