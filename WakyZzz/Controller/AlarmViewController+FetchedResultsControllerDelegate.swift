//
//  AlarmViewController+FetchedResultsControllerDelegate.swift
//  WakyZzz
//
//  Created by Scott Bolin on 3/27/21.
//  Copyright © 2021 TukgaeSoft. All rights reserved.
//

import UIKit
import CoreData

extension AlarmsViewController: NSFetchedResultsControllerDelegate {
    //MARK: - NSFetchedResultsControllerDelegate
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
            case .insert:
                tableView.insertRows(at: [newIndexPath!], with: .automatic)
            case .delete:
                tableView.deleteRows(at: [indexPath!], with: .automatic) //newIndexPath
            case .move:
                tableView.moveRow(at: indexPath!, to: newIndexPath!)
 //               tableView.deleteRows(at: [indexPath!], with: .automatic)
 //               tableView.insertRows(at: [newIndexPath!], with: .automatic)
            case .update:
                tableView.reloadRows(at: [indexPath!], with: .automatic)
//                let cell = tableView.cellForRow(at: indexPath!) as! AlarmTableViewCell
//                let fetchedAlarm = fetchedResultsController.object(at: indexPath!)
//                cell.populate(caption: fetchedAlarm.localAlarmTimeString, subcaption: fetchedAlarm.repeatingDayString, enabled: fetchedAlarm.enabled)
            @unknown default:
                print("Unexpected NSFetchedResultsChangeType")
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
    
//    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
//        let indexSet = IndexSet(integer: sectionIndex)
//        switch type {
//            case .insert:
//                tableView.insertSections(indexSet, with: .automatic)
//            case .delete:
//                tableView.deleteSections(indexSet, with: .automatic)
//            default:
//                break
//        }
//    }
}
