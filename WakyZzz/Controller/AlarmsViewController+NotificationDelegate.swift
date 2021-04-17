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
        guard let uuid = UUID(uuidString: id) else { return } // not sure what to do if can't get uuid
        guard let alarmEntity = CoreDataController.shared.fetchAlarmByAlarmID(with: uuid) else { return }
        
        print(#function)
        print("alarm id         : \(id)")
        print("alarm category   : \(categoryID)")
        print("alarm actionID   : \(actionID)")
        print("alarm uuid       : \(uuid)")
        print("alarmEntity ID   : \(alarmEntity.alarmID)")
        print("alarmEntity En   : \(alarmEntity.enabled)")
        print("alarmEntity Rpt  : \(alarmEntity.repeatDays)")
        print("alarmEntity Snz# : \(alarmEntity.timesSnoozed)")
        print("category ID      : \(categoryID)")
        print("action ID        : \(actionID)")


        if (categoryID == "SNOOZABLE_ALARM") || (categoryID == "SNOOZED_ALARM") {
            switch actionID {
                case "TURN_OFF_ALARM":
                    print("alarm turned off")
                    // check if alarm repeats other days, if so do nothing, otherwise turn off
                    if !alarmEntity.repeats {
                        alarmEntity.enabled = false
                    }
                    
                case "SNOOZE_ALARM":
                    print("alarm snoozed")
                    // increment snooze count in updateSnoozeStatus
                    CoreDataController.shared.updateSnoozeStatus(for: uuid)
                    if !alarmEntity.repeats {
                        alarmEntity.enabled = true
                    }
                    // update notification (will automatically adds timesSnoozed to alarm time - ie, if snoozed 1 time adds 1 minute, 2 times adds 2 minutes...)
                    notifcationController.assembleNotificationItemsFrom(entity: alarmEntity)
                                    
                case UNNotificationDefaultActionIdentifier:
                    // User clicked on notifcation
                    print("for this app, just open app and let user decide what to do")
                    
                case UNNotificationDismissActionIdentifier:
                    // User dismissed notification (clicked "x" button)
                    print("for this app, just open app and let user decide what to do")
                    // check if alarm repeats other days, if so do nothing, otherwise turn off
                    if !alarmEntity.repeats {
                        alarmEntity.enabled = false
                    }
                    
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
                    if !alarmEntity.repeats {
                        alarmEntity.enabled = false
                    }
                    
                    
                case "ACT_OF_KINDNESS_LATER":
                    print("snoozed 3 times")
                    print("notification shows the act of kindness")
                    print("must promise to perform an act of kindness later to turn off")
                    // check if alarm repeats other days, if so do nothing, otherwise turn off
                    if !alarmEntity.repeats {
                        alarmEntity.enabled = false
                    }
                    
                    
                case UNNotificationDefaultActionIdentifier:
                    // User clicked on notifcation
                    print("turns alarm off if ")
                    // check if alarm repeats other days, if so do nothing, otherwise turn off
                    if !alarmEntity.repeats {
                        alarmEntity.enabled = false
                    }
                    
                case UNNotificationDismissActionIdentifier:
                    // User dismissed notification (clicked "x" button)
                    print("for this app, just open app and let user decide what to do")
                    // check if alarm repeats other days, if so do nothing, otherwise turn off
                    if !alarmEntity.repeats {
                        alarmEntity.enabled = false
                    }
                    
                default:
                    print("Unknown identifier, should not happen")
            }
        }
        center.removeAllDeliveredNotifications()
        completionHandler()
        //       manager.removeDeliveredNotifications(identifiers: [notification])
    }
    
    // show notification while app is in the forground, just turn alarm off
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let id = notification.request.identifier
        guard let uuid = UUID(uuidString: id) else { return } // not sure what to do if can't get uuid
        guard let alarmEntity = CoreDataController.shared.fetchAlarmByAlarmID(with: uuid) else { return }
        print(#function)
        print("In app click, alarm id: \(id)")
        print("alarm category: \(notification.request.content.categoryIdentifier)")
        
        switch notification.request.content.categoryIdentifier {
            case "SNOOZABLE_ALARM":
                print("Snoozable alarm, turn off alarm \(id)")
                if !alarmEntity.repeats {
                    alarmEntity.enabled = false
                }
            case "NON_SNOOZABLE_ALARM":
                print("Non Snoozable alarm, also turn off \(id)")
                if !alarmEntity.repeats {
                    alarmEntity.enabled = false
                }
            default:
                print("Default action, which is also to turn off alarm")
                if !alarmEntity.repeats {
                    alarmEntity.enabled = false
                }
        }
        center.removeAllDeliveredNotifications()
        completionHandler([.banner, .sound, .list])
        //        manager.removeDeliveredNotifications(identifiers: [notification])
    }
}
