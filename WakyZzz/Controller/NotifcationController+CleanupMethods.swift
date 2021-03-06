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
    
//    func removeDeliveredNotificationsWithIdentifiers(identifiers: [UNNotification]) {
//        var id = [""]
//        center.getDeliveredNotifications { deliveredNotificationList in
//            deliveredNotificationList.forEach { notification in
//                if identifiers.contains(notification) {
//                    id.append(notification.request.identifier)
//                }
//            }
//        }
//        center.removeDeliveredNotifications(withIdentifiers: id)
//        // below not needed if notifications is used for creation only
//        notifications.removeAll { item in
//            return item.id == id[0]
//        }
//    }
    
//    func removePendingNotificationRequestsWithIdentifiers(identifiers: [UNNotificationRequest]) {
//        var id = [""]
//        center.getPendingNotificationRequests { pendingNotificationRequests in
//            pendingNotificationRequests.forEach { request in
//                if identifiers.contains(request) {
//                    id.append(request.identifier)
//                }
//            }
//        }
//        center.removePendingNotificationRequests(withIdentifiers: id)
//        // below not needed if notifications is used for creation only
//        notifications.removeAll { item in
//            return item.id == id[0]
//        }
//    }
    
    // tested
    func cancelNotificationForEntity(entity: AlarmEntity) {
        let id = entity.alarmID.uuidString
        // cancel notification id
        center.removePendingNotificationRequests(withIdentifiers: [id])
        // add this, since above doesn't seem to work?
        center.removeAllDeliveredNotifications()
    }
    
    //MARK: - NotificationController helper methods, for debugging
    func listScheduledNotifications() {
        center.getPendingNotificationRequests { notifications in
            for notification in notifications {
                print("s: ",notification)
            }
        }
    }
    
    func listDeliveredNotifications() {
        center.getDeliveredNotifications { notifications in
            for notification in notifications {
                print("d: ",notification)
            }
        }
    }
}
