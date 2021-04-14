//
//  NotifcationController+HelperMethods.swift
//  WakyZzz
//
//  Created by Scott Bolin on 08-A-21.
//  Copyright © 2021 TukgaeSoft. All rights reserved.
//

import UIKit
import UserNotifications

extension NotificationController {
    
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
    
    func cancelNotificationForEntity(entity: AlarmEntity) {
        let id = entity.alarmID.uuidString
        // cancel notification id
        center.removePendingNotificationRequests(withIdentifiers: [id])
        
    }
    
//    func removeNotification(at identifier: String) {
//       center.removePendingNotificationRequests(withIdentifiers: [identifier])
//    }
    
    // used in testing
    func removeAllDeliveredNotifications() {
        center.removeAllDeliveredNotifications()
    }
    
    // used in testing
    func removeAllPendingNotificationRequests() {
        center.removeAllPendingNotificationRequests()
    }
    
    //MARK: - NotificationController helper methods
    func listScheduledNotifications() {
        var count = 0
        print("====Scheduled Notifications====")
        center.getPendingNotificationRequests { notifications in
            for notification in notifications {
                count += 1
                print("s: ",count, notification)
            }
        }
        print("====Scheduled Notifications====")
    }
    
    func listDeliveredNotifications() {
        var count = 0
        print("====Delivered Notifications====")
        center.getDeliveredNotifications { notifications in
            for notification in notifications {
                count += 1
                print("d: ", count, notification)
            }
        }
        print("====Delivered Notifications====")
    }
}
