//
//  AlarmsViewController+AlarmMethods.swift
//  WakyZzz
//
//  Created by Scott Bolin on 3/27/21.
//  Copyright © 2021 TukgaeSoft. All rights reserved.
//

import UIKit

extension AlarmsViewController {
    // Temporary function to populate alarms with dummy data, will be removed after app works properly and user will set their own alarms
    func populateAlarms() {
        let context = CoreDataController.shared.managedContext
        // weekday alarm
        let weekDayAlarmID = UUID()
        CoreDataController.shared.createAlarmEntityWithID(id: weekDayAlarmID)
        guard let weekDayAlarmEntity = CoreDataController.shared.fetchAlarmByAlarmID(with: weekDayAlarmID) else { return }
        // Weekdays 5am
        weekDayAlarmEntity.time = 5 * 3600
        weekDayAlarmEntity.enabled = true
        for i in 1 ... 5 {
            weekDayAlarmEntity.repeatDays[i] = true
        }
        
        let weekEndAlarmID = UUID()
        CoreDataController.shared.createAlarmEntityWithID(id: weekEndAlarmID)
        guard let weekendAlarmEntity = CoreDataController.shared.fetchAlarmByAlarmID(with: weekEndAlarmID) else { return }
        weekendAlarmEntity.time = 9 * 3600
        weekendAlarmEntity.enabled = false
        weekendAlarmEntity.repeatDays[0] = true
        weekendAlarmEntity.repeatDays[6] = true
        
        CoreDataController.shared.saveContext(context: context)
    }
    
    // Schedule notification alarms at given time/repeat. Better to call using AlarmEntity
    func scheduleAlarm(hour: Int, minute: Int, repeats: Bool, type: NotificationType) {
        let date = Date() // use today's date for now...
        let calendar = Calendar.current
        let year = calendar.component(.year, from: date)
        let month = calendar.component(.month, from: date)
        let day = calendar.component(.day, from: date)
        let weekday = calendar.component(.weekday, from: date)
        var repeated: [Int] = [weekday]
        let dateComponents = DateComponents(calendar: .current, timeZone: .current, year: year, month: month, day: day, hour: hour, minute: minute, weekday: weekday)
        let snoozedTimes = 0 // TODO: get from CoreData
        let actOfKindness = ActOfKindness.allCases.randomElement()?.rawValue
        
        if repeats {
            repeated = [3, 5, 7] // use Core Data to populate...
        }
        
        switch type {
            case .snoozable:
                alarmName = "Turn Alarm Off 🔕 or Snooze? 😴"
                subtitle = "Shut off or snooze for 1 minute"
                body = "Body of notification"
            case .snoozed:
                alarmName = "Turn Alarm Off 🔕 or Snooze? 😴"
                subtitle = "Shut off or snooze for 1 minute"
                body = "You have snoozed \(snoozedTimes) out of 3" // timesSn
            case .nonSnoozable:
                alarmName = "Act of Kindness Alert! ⚠️"
                subtitle = "You must perform an act of kindness to turn alarm off"
                body = "Random act of kindness: \(actOfKindness ?? "Smile today!")"
        }
        
        let notification = LocalNotification(
            id: UUID().uuidString,
            title: alarmName,
            subtitle: subtitle,
            body: body,
            repeating: repeats,
            repeatDays: repeated,
            dateComponents: dateComponents)
        
        notifcationController.createNotificationContent(notification: notification, type: type)
    }
    
    //MARK: - Tableview helper function
    func deleteAlarm(at indexPath: IndexPath) {
        tableView.beginUpdates()
        CoreDataController.shared.deleteAlarmEntity(at: indexPath)
        tableView.deleteRows(at: [indexPath], with: .automatic)
        tableView.endUpdates()
    }
    
    func editAlarm(at indexPath: IndexPath) {
        editingIndexPath = indexPath
        let alarmEntity = fetchedResultsController.object(at: indexPath)
        presentSetAlarmViewController(alarmEntity: alarmEntity)
    }
    
    func addAlarm(_ alarm: Alarm, at indexPath: IndexPath) {
//        tableView.beginUpdates()
        CoreDataController.shared.createAlarmEntityFromAlarmObject(alarm: alarm)
//        tableView.insertRows(at: [indexPath], with: .automatic)
//        tableView.endUpdates()
    }
    
    // convert/pass Alarm object to SetAlarmViewController in lieu of AlarmEntity
    func presentSetAlarmViewController(alarmEntity: AlarmEntity?) {
        if let vc = storyboard?.instantiateViewController(withIdentifier: "SetAlarm") as? SetAlarmViewController {
            let alarm = alarmEntity?.toAlarm()
            vc.alarm = alarm
            vc.delegate = self
            navigationController?.pushViewController(vc, animated: true)
        }
    }
}

//MARK: - SetAlarmViewControllerDelegate methods
extension AlarmsViewController: SetAlarmViewControllerDelegate {
    // SetAlarmViewControllerDelegate methods
    func setAlarmViewControllerDone(alarm: Alarm) {
        if let editingIndexPath = editingIndexPath {
            // edited alarm
            CoreDataController.shared.updateAlarmEntityFromAlarmObject(at: editingIndexPath, alarm: alarm)
        }
        else {
            // new alarm
            CoreDataController.shared.createAlarmEntityFromAlarmObject(alarm: alarm)
        }
        editingIndexPath = nil
    }
    
    func setAlarmViewControllerCancel() {
        editingIndexPath = nil
    }
}
