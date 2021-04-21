//
//  AlarmsViewController+AlarmMethods.swift
//  WakyZzz
//
//  Created by Scott Bolin on 3/27/21.
//  Copyright © 2021 TukgaeSoft. All rights reserved.
//

import UIKit

extension AlarmsViewController {
    
    //MARK: - Tableview helper function
//    func deleteAlarm(at indexPath: IndexPath) {
//        print(#function)
//        print("deleting alarm...")
//        let alarmEntity = fetchedResultsController.object(at: indexPath)
//        print("id: \(alarmEntity.alarmID)")
//        self.notifcationController.cancelNotificationForEntity(entity: alarmEntity)
//        CoreDataController.shared.deleteAlarmEntity(at: indexPath)
//    }
    
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
