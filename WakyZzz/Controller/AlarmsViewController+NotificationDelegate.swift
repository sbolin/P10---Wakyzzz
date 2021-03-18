//
//  AlarmsViewController+NotificationDelegate.swift
//  WakyZzz
//
//  Created by Scott Bolin on 3/19/21.
//  Copyright © 2021 TukgaeSoft. All rights reserved.
//

import UIKit

extension AlarmsViewController: UNUserNotificationCenterDelegate {
    //MARK: UNUserNotificationCenter Delegate Methods
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let id = response.notification.request.identifier
        let categoryID = response.notification.request.content.categoryIdentifier
        let actionID = response.actionIdentifier
        
        print(#function)
        print("alarm id: \(id)")
        print("alarm category: \(categoryID)")
        print("alarm actionID: \(actionID)")
        
        if (categoryID == "SNOOZABLE_ALARM") || (categoryID == "SNOOZED_ALARM") {
            switch actionID {
                case "TURN_OFF_ALARM":
                    print("alarm turned off")
                // check if alarm repeats other days, if so do nothing, otherwise turn off
                
                case "SNOOZE_ALARM":
                    print("alarm snoozed")
                // increment snooze count
                // create new alarm with UNTimeIntervalNotificationTrigger
                
                case UNNotificationDefaultActionIdentifier:
                    // User clicked on notifcation
                    print("for this app, just open app and let user decide what to do")
                    
                case UNNotificationDismissActionIdentifier:
                    // User dismissed notification (clicked "x" button)
                    print("for this app, just open app and let user decide what to do")
                    
                default:
                    print("Unknown identifier, should not happen")
            }
        }
        
        if categoryID == "NON_SNOOZABLE_ALARM" {
            switch actionID {
                case "ACT_OF_KINDNESS":
                    print("snoozed 3 times")
                    print("notification shows the act of kindness")
                    print("must perform an act of kindness to turn off")
                    // check if alarm repeats other days, if so do nothing, otherwise turn off
                    break
                    
                case "ACT_OF_KINDNESS_LATER":
                    print("snoozed 3 times")
                    print("notification shows the act of kindness")
                    print("must promise to perform an act of kindness later to turn off")
                    // increment snooze count
                    break
                    
                case UNNotificationDefaultActionIdentifier:
                    // User clicked on notifcation
                    print("for this app, just open app and let user decide what to do")
                    
                case UNNotificationDismissActionIdentifier:
                    // User dismissed notification (clicked "x" button)
                    print("for this app, just open app and let user decide what to do")
                    
                default:
                    print("Unknown identifier, should not happen")
            }
        }
        center.removeAllDeliveredNotifications()
        completionHandler()
        //       manager.removeDeliveredNotifications(identifiers: [notification])
    }
    
    // show notification while app is at the forground
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let id = notification.request.identifier
        print(#function)
        print("In app click, alarm id: \(id)")
        print("alarm category: \(notification.request.content.categoryIdentifier)")
        
        switch notification.request.content.categoryIdentifier {
            case "SNOOZABLE_ALARM":
                print("Snoozable alarm, turn off alarm \(id)")
            case "NON_SNOOZABLE_ALARM":
                print("Non Snoozable alarm, also turn off \(id)")
            default:
                print("Default action, which is also to turn off alarm")
        }
        center.removeAllDeliveredNotifications()
        completionHandler([.banner, .sound, .list])
        //        manager.removeDeliveredNotifications(identifiers: [notification])
    }
}
