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

            @unknown default:
                print("Unexpected NSFetchedResultsChangeType")
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
}
