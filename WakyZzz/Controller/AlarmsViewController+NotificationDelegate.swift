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
        
        if (categoryID == "SNOOZABLE_ALARM") || (categoryID == "SNOOZED_ALARM") {
            switch actionID {
                case "TURN_OFF_ALARM":
                    // check if alarm repeats other days, if so do nothing, otherwise turn off
                    if !alarmEntity.repeats {
                        alarmEntity.enabled = false
                    }
                    
                case "SNOOZE_ALARM":
                    // increment snooze count in updateSnoozeStatus
                    CoreDataController.shared.updateSnoozeStatus(for: uuid)
                    if !alarmEntity.repeats {
                        alarmEntity.enabled = true
                    }
                    // update notification (will automatically adds timesSnoozed to alarm time - ie, if snoozed 1 time adds 1 minute, 2 times adds 2 minutes...)
                    notifcationController.notificationFactory(entity: alarmEntity)
                    
                case UNNotificationDefaultActionIdentifier:
                    // User clicked on notifcation
                    print("open app and let user decide what to do")
                    
                case UNNotificationDismissActionIdentifier:
                    // User dismissed notification (clicked "x" button)
                    print("open app and let user decide what to do")
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
                    // check if alarm repeats other days, if so do nothing, otherwise turn off
                    if !alarmEntity.repeats {
                        alarmEntity.enabled = false
                    }
                    
                case "ACT_OF_KINDNESS_LATER":
                    // check if alarm repeats other days, if so do nothing, otherwise turn off
                    if !alarmEntity.repeats {
                        alarmEntity.enabled = false
                    }
                    
                    
                case UNNotificationDefaultActionIdentifier:
                    // User clicked on notifcation
                    // check if alarm repeats other days, if so do nothing, otherwise turn off
                    if !alarmEntity.repeats {
                        alarmEntity.enabled = false
                    }
                    
                case UNNotificationDismissActionIdentifier:
                    // User dismissed notification (clicked "x" button)
                    // check if alarm repeats other days, if so do nothing, otherwise turn off
                    if !alarmEntity.repeats {
                        alarmEntity.enabled = false
                    }
                    
                default:
                    print("Unknown identifier, should not happen")
            }
        }
        
        if categoryID == "DELAYED_ACTION" {
            switch actionID {
                case "REMINDER_PERFORM_ACT_OF_KINDNESS":
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
    }
    
    // show notification while app is in the forground, just turn alarm off
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let id = notification.request.identifier
        guard let uuid = UUID(uuidString: id) else { return } // not sure what to do if can't get uuid
        guard let alarmEntity = CoreDataController.shared.fetchAlarmByAlarmID(with: uuid) else { return }
        
        switch notification.request.content.categoryIdentifier {
            case "SNOOZABLE_ALARM":
                if !alarmEntity.repeats {
                    alarmEntity.enabled = false
                }
            case "NON_SNOOZABLE_ALARM":
                if !alarmEntity.repeats {
                    alarmEntity.enabled = false
                }
            case "ACT_OF_KINDNESS_LATER":
                if !alarmEntity.repeats {
                    alarmEntity.enabled = false
                }
                
            case "REMINDER_PERFORM_ACT_OF_KINDNESS":
                if !alarmEntity.repeats {
                    alarmEntity.enabled = false
                }
                
            default:
                if !alarmEntity.repeats {
                    alarmEntity.enabled = false
                }
        }
        center.removeAllDeliveredNotifications()
        completionHandler([.banner, .sound, .list])
    }
}
