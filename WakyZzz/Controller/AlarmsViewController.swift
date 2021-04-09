//
//  AlarmsViewController.swift
//  WakyZzz
//
//  Created by Olga Volkova on 2018-05-30.
//  Copyright © 2018 Olga Volkova OC. All rights reserved.
//

import UIKit
import CoreData

class AlarmsViewController: UIViewController {
    
    //MARK:- Outlets
    @IBOutlet weak var tableView: UITableView!
    
    //MARK: Set up data store
    var fetchedResultsController: NSFetchedResultsController<AlarmEntity>!
    var notificationController: NotificationController!
    
    //MARK: - Notification Properties
    let notifcationController = NotificationController() // manager
    let center = UNUserNotificationCenter.current()
    var editingIndexPath: IndexPath?

//MARK: - View Lifecylcle
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        center.delegate = self
        checkFirstRun()
        notifcationController.requestNotificationAuthorization()
        notifcationController.setupActions()
        configureTableView()
    }
    
    func checkFirstRun() {
        let launchedBefore = UserDefaults.standard.bool(forKey: "Launched Before")
        if !launchedBefore  {
            // First launch, set user defaults to true (Launched Before = true)
            UserDefaults.standard.set(true, forKey: "Launched Before")
            
            // show alert for setting up alarms
            let alert = UIAlertController(title: "Lets get started!", message: "1. Add alarm (+ button).\n2. Set alarm time and days to repeat.\n3. Alarm goes off once if no repeated days.\n4. Switch turns alarm on/off", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Got it! 👍", style: .default, handler: nil))
            self.present(alert, animated: true)
            // temporary, will be removed in final
//            populateAlarms()
            //
        }
    }
    
    // Setup TableView delegate and datasource, populate alarms
    func configureTableView() {
        print(#function)
        // setup fetchrequest
        if fetchedResultsController == nil {
            fetchedResultsController = CoreDataController.shared.fetchedAlarmResultsController
        }
        fetchedResultsController.delegate = self
        do {
            try fetchedResultsController.performFetch()
        } catch (let error) {
            print("Fetch failed, error: \(error.localizedDescription)")
        }
    }
    
    //MARK: - Actions
    @IBAction func addButtonPress(_ sender: Any) {
        presentSetAlarmViewController(alarmEntity: nil) // (alarm: nil)
    }
}

//MARK: - AlarmCellDelegate method
extension AlarmsViewController: AlarmCellDelegate {
    func alarmCell(_ cell: AlarmTableViewCell, enabledChanged enabled: Bool) {
        if let indexPath = tableView.indexPath(for: cell) {
            CoreDataController.shared.changeAlarmStatus(at: indexPath, status: enabled)
            // update notification
            let alarmEntity = fetchedResultsController.object(at: indexPath)
            notifcationController.ScheduleNotificationForEntity(entity: alarmEntity)
        }
    }
}

//MARK: - SetAlarmViewControllerDelegate methods
extension AlarmsViewController: SetAlarmViewControllerDelegate {
    func setAlarmViewControllerDone(alarm: Alarm) {
        if let editingIndexPath = editingIndexPath {
            // alarm has been edited
            CoreDataController.shared.updateAlarmEntityFromAlarmObject(at: editingIndexPath, alarm: alarm)
            // update notification
            let alarmEntity = fetchedResultsController.object(at: editingIndexPath)

            // NOTE: need to check if notification must be cancelled first, then re-scheduled, or if can just reschedule using same ID
            // cancel for now...
            notifcationController.CancelNotificationForEntity(entity: alarmEntity)
            notifcationController.ScheduleNotificationForEntity(entity: alarmEntity)
        }
        else {
            // new core data alarmEntity
            CoreDataController.shared.createAlarmEntityFromAlarmObject(alarm: alarm)
            guard let alarmEntity = fetchedResultsController.fetchedObjects?.last else { return }
            // create notification
            notifcationController.ScheduleNotificationForEntity(entity: alarmEntity)        }
        editingIndexPath = nil
    }
    
    func setAlarmViewControllerCancel() {
        // cancel pressed, don't do anything
        editingIndexPath = nil
    }
}
