//
//  xxx.swift
//  WakyZzz
//
//  Created by Scott Bolin on 3/6/21.
//  Copyright © 2021 Olga Volkova OC. All rights reserved.
//

import UIKit
import UserNotifications

class ViewController: UIViewController, UNUserNotificationCenterDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // Ask user permission
        let center = UNUserNotificationCenter.current()
        center.delegate = self
        center.requestAuthorization(options: [.alert, .badge, .sound]) { (granted, error) in
            if granted {
                print("Permission granted. Scheduling notification")
                self.scheduleNotification()
            }
        }
    }
    
    func scheduleNotification() {
        let notificationCenter = UNUserNotificationCenter.current()
        
        let notification = UNMutableNotificationContent()
        notification.title = "Important Message"
        notification.body = "It's a snow day tomorrow. No school busses."
        notification.userInfo = ["numberTimesSnoozed": 3] // increment userInfo each time snooze is pressed
        notification.sound = UNNotificationSound.default()
        notification.categoryIdentifier = "alarm"

        
        var dateComponents = DateComponents()
        dateComponents.calendar = Calendar.current

        dateComponents.weekday = 3  // Tuesday
        dateComponents.hour = 8
        dateComponents.minute = 0
        
//        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 10, repeats: false)
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        
        let identifier = UUID().uuidString
        
        let notificationRequest = UNNotificationRequest(identifier: identifier, content: notification, trigger: trigger)
        
        
        // Add Action button to notification
        let offAction = UNNotificationAction(identifier: "TurnOffAlarm", title: "Turn off Alarm", options: .foreground)
        let snoozeAction = UNNotificationAction(identifier: "SnoozeAlarm", title: "Snooze Alarm", options: .foreground)
        let snoozed3TimesAction = UNNotificationAction(identifier: "Snoozed3Times", title: "Act", options: .foreground)
        let notificationCategory = UNNotificationCategory(
            identifier: "alarm",
            actions: [offAction, snoozeAction, snoozed3TimesAction],
            intentIdentifiers: [])
        notificationCenter.setNotificationCategories([notificationCategory])
        
        notificationCenter.add(notificationRequest) { error in
            if error != nil {
                print("Error creating notification: \(error?.localizedDescription)")
            }
        }
    }
    
    func getNotifications() {
        let notificationCenter = UNUserNotificationCenter.current()

        notificationCenter.getPendingNotificationRequests { (notificationRequests) in
            for notificationRequest:UNNotificationRequest in notificationRequests {
                print(notificationRequest.identifier)
                print(notificationRequest.content)
                print(notificationRequest.trigger)
            }
        }
    }
    
    
    func getInfoOnDeleveredNotifications() {
        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.getDeliveredNotifications { (notifications) in
            print(notifications.count)
            for notification:UNNotification in notifications {
                print(notification.request.identifier)
                print(notification.date)
            }
        }
    }

    
    // out of app
    public func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        let userInfo = response.notification.request.content.userInfo
        if let additionalData = userInfo["additionalData"] as? String {
            print("Additional data: \(additionalData)")
        }
        
        switch response.actionIdentifier {
            case UNNotificationDefaultActionIdentifier:
                print("User tapped on message itself rather than on an Action button")
                
            case "TapToReadAction":
                print("User tapped on Tap to read button")
                break
                
            case "TapToShareAction":
                print("User tapped on Share button")
                break
                
            default:
                break
        }
        
        completionHandler()
    }
    
}
