//
//  AlarmViewController+TableViewDataSource+TableViewDelegate.swift
//  WakyZzz
//
//  Created by Scott Bolin on 3/19/21.
//  Copyright © 2021 TukgaeSoft. All rights reserved.
//

import UIKit
import CoreData

extension AlarmsViewController: UITableViewDelegate, UITableViewDataSource {
    //MARK: - Tableview delegate methods
    func numberOfSections(in tableView: UITableView) -> Int {
        fetchedResultsController.sections?.count ?? 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sectionInfo = fetchedResultsController.sections?[section] else {
            return 0
        }
        return sectionInfo.numberOfObjects
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AlarmCell", for: indexPath) as! AlarmTableViewCell
        cell.delegate = self
        let fetchedAlarm = fetchedResultsController.object(at: indexPath)
        cell.populate(caption: fetchedAlarm.localAlarmTimeString, subcaption: fetchedAlarm.repeatingDayString, enabled: fetchedAlarm.enabled)
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Alarms"
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        editAlarm(at: indexPath)
    }
    
    //MARK: Set up table view editing
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let delete = UIContextualAction(style: .destructive, title: "Delete") { (action, view, completion) in
            self.deleteAlarm(at: indexPath)
            completion(true)
        }
        
        let edit = UIContextualAction(style: .normal, title: "Edit") { (action, view, completion) in
            self.editAlarm(at: indexPath)
            completion(true)
        }
        
        delete.image = UIImage(systemName: "trash.circle")
        delete.backgroundColor =  UIColor(red: 1, green: 0, blue: 0, alpha: 1)

        edit.image = UIImage(systemName: "pencil.circle")
        edit.backgroundColor =  UIColor(red: 0, green: 1, blue: 0, alpha: 1)
        
        let config = UISwipeActionsConfiguration(actions: [delete, edit])
        config.performsFirstActionWithFullSwipe = false
        return config
    }
}
