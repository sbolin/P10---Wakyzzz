//
//  NotifcationController.swift
//  WakyZzz
//
//  Created by Scott Bolin on 2/18/21.
//  Copyright © 2020 Scott Bolin. All rights reserved.
//

import UIKit
import UserNotifications

enum NotificationType {
    case turnOff
    case alarmSnoozed
    case alarmSnoozedThreeTimes
}

enum ActOfKindness: String, CaseIterable {
    case messageFriend = "Send a message to a friend asking how they are doing"
    case contactFamily = "Send a kind thought to a family member"
    case donateToCharity = "Send some money to your favorite charity"
    case volunteer = "Volunteer at local homeless shelter"
    case giveGifts = "Give gifts to local orphanage"
    case payItForward = "Pay for next person in line"
}

class NotificationController: NSObject, UNUserNotificationCenterDelegate {
    
    //MARK: - Properties
    private let identifier = "WakyZzz"
    
    // closure for handling response to alarm
    var handleAlarmTapped: ((Bool) -> Void)?
    
    //MARK: - Notification when Alarm changed (off/snooze)
    func manageLocalNotification() {
        

// TODO: Below Needs to be worked on....
        var title = String()
        var subtitle = String()
        var body = String()
        var actOfKindness: String {
            ActOfKindness.allCases.randomElement()!.rawValue
        }
        let snoozedTimes = Int()
        let type: NotificationType
        
        if snoozedTimes == 0 {
            type = NotificationType.turnOff
            title = "Turn Alarm Off 🔕 or Snooze? 😴"
            subtitle = "Shut off or snooze for 1 minute"
            body = "Body of notification"
        } else {
            if snoozedTimes < 3 {
                type = NotificationType.alarmSnoozed
                title = "Turn Alarm Off 🔕 or Snooze? 😴"
                subtitle = "Shut off or snooze for 1 minute"
                body = "You have snoozed \(snoozedTimes) out of 3"
            } else {
                type = NotificationType.alarmSnoozedThreeTimes
                title = "Act of Kindness Alert! ⚠️"
                subtitle = "You must perform an act of kindness to turn alarm off"
                body = "Random act of kindness: \(actOfKindness)"
            }
        }
        
        setupNotification(title: title, subtitle: subtitle, body: body, notificationType: type)
        
    }
        
    
    //MARK: - Schedule Notification
    private func setupNotification(title: String?, subtitle: String?, body: String?, notificationType: NotificationType) {
        registerCategory(notificationType: notificationType)
        let center = UNUserNotificationCenter.current()
        //remove previously scheduled notifications
        center.removeDeliveredNotifications(withIdentifiers: [identifier])
        
        // need to set so goes off at 8am each day
        var dateComponents = DateComponents()
        dateComponents.hour = 8
        dateComponents.minute = 00
        
        // create trigger
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        
        // set up notification content
        if let newTitle = title, let newBody = body, let subtitle = subtitle {
            //create content
            let content = UNMutableNotificationContent()
            content.title = newTitle
            content.subtitle = subtitle
            content.body = newBody
            content.badge = 1 as NSNumber // just show 1 if alarm sounded, but no response
            content.categoryIdentifier = identifier
            content.sound = UNNotificationSound(named: "sound.mp3")
            
            // create request
            let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
            
            // schedule notification
            center.add(request) { (error) in
                if let error = error {
                    print("Request 1 Error: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func removeNotification(at identifier: String) {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: [identifier])
    }

    
    func registerCategory(notificationType: NotificationType) {
        let center = UNUserNotificationCenter.current()
        center.delegate = self
        switch notificationType {
            case .turnOff:
                let alarmOff = UNNotificationAction(identifier: "ALARM_OFF",
                                                   title: "Alarm Turned Off",
                                                   options: .foreground)
                let category = UNNotificationCategory(identifier: identifier,
                                                      actions: [alarmOff],
                                                      intentIdentifiers: [],
                                                      options: .customDismissAction)
                center.setNotificationCategories([category])
            
            case .alarmSnoozed:
                let alarmSnoozed = UNNotificationAction(identifier: "ALARM_SNOOZED",
                                                        title: "Alarm Snoozed",
                                                        options: .foreground)
                let category = UNNotificationCategory(identifier: identifier,
                                                      actions: [alarmSnoozed],
                                                      intentIdentifiers: [],
                                                      options: .customDismissAction)
                center.setNotificationCategories([category])
            
            case .alarmSnoozedThreeTimes:
                let alarmSnoozedThreeTimes = UNNotificationAction(identifier: "ALARM_SNOOZED3TIMES",
                                                        title: "Alarm Snoozed for 3rd Time!",
                                                        options: .foreground)
                let category = UNNotificationCategory(identifier: identifier,
                                                      actions: [alarmSnoozedThreeTimes],
                                                      intentIdentifiers: [],
                                                      options: .customDismissAction)
                center.setNotificationCategories([category])
        }
    }
    // Show notification when Wakyzzz.app is active
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        // Show the banner in-app
        completionHandler([.alert, .sound])
    }
    
    // handle notifications
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        switch response.actionIdentifier {
            
            case UNNotificationDefaultActionIdentifier:
                // the user swiped to unlock
                handleAlarmTapped?(false)
                
            case "ALARM_OFF":
                //user tapped turn off alarm
                handleAlarmTapped?(true)
                break
                
            case "ALARM_SNOOZED":
                // user tapped "Snooze Alarm"
                handleAlarmTapped?(false)
                break
                
            case "ALARM_SNOOZED3TIMES":
                // user tapped "Snooze Alarm" for third time
                handleAlarmTapped?(false)
                break
                
            default:
                break
        }
        // call the completion handler, reset alarm, set badge to zero (no unanswered alarms)
        completionHandler()
        // reset alarm
        UIApplication.shared.applicationIconBadgeNumber = 0
    }
    
    func tempFunctionPrintNotifications() {
        
        UNUserNotificationCenter.current().getPendingNotificationRequests(completionHandler: { (requests) in
            var offCount = 0
            var snoozeCount = 0
            var snoozed3TimesCount = 0
            
            for request in requests {
                print("Notification: \(request.content)")
                
                if request.identifier == "ALARM_OFF" {
                    offCount += 1
                } else if request.identifier == "ALARM_SNOOZED" {
                    snoozeCount += 1
                } else if request.identifier == "ALARM_SNOOZED3TIMES" {
                snoozed3TimesCount += 1
                } else if request === requests.last {
                    print("No requests") 
                }
            }
        })
    }
}
