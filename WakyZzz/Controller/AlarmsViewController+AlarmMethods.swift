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
    
    //MARK: - Tableview helper function
    func deleteAlarm(at indexPath: IndexPath) {
        let alarmEntity = fetchedResultsController.object(at: indexPath)
        let alarmID = alarmEntity.alarmID.uuidString
        // remove notification
        self.notifcationController.center.removePendingNotificationRequests(withIdentifiers: [alarmID])
        
        CoreDataController.shared.deleteAlarmEntity(at: indexPath)
    }
    
    // present SetAlarmViewController to edit alarm
    func editAlarm(at indexPath: IndexPath) {
        editingIndexPath = indexPath
        let alarmEntity = fetchedResultsController.object(at: indexPath)
        
        presentSetAlarmViewController(alarmEntity: alarmEntity)
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
