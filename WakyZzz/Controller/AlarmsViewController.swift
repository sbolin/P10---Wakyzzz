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
    @IBOutlet weak var addButton: UIBarButtonItem!
    
    //MARK: Set up data store
    var fetchedResultsController: NSFetchedResultsController<AlarmEntity>!
    //    var notificationController: NotificationController!
    
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
        // Request authorization to display notifications, and setup notifications
 //       notifcationController.requestNotificationAuthorization()
        notifcationController.setupActions()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureTableView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // check if authorized to use notifications if app was launched previously. If not, throw up an alert notifying user that app is useless without notifications.
        let launchedBefore = UserDefaults.standard.bool(forKey: "Launched Before")
        if launchedBefore {
            checkAuthenticationStatus()
        }
        // check first run status
        checkFirstRun()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        fetchedResultsController.delegate = nil
    }
    
    //MARK: - Status checks
    func checkFirstRun() {
        let launchedBefore = UserDefaults.standard.bool(forKey: "Launched Before")
        if !launchedBefore {
            // First launch, set user defaults to true (Launched Before = true)
            UserDefaults.standard.set(true, forKey: "Launched Before")
            DispatchQueue.main.async {
                AlertsController.showSetupAlert(controller: self)
            }
            // wait 20 seconds before throwing up the request authorization, so user has time to orient to the Focus list
            DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
                self.notifcationController.requestNotificationAuthorization()
            }
        }
    }
    
    func checkAuthenticationStatus() {
        notifcationController.center.getNotificationSettings { setting in
            switch setting.authorizationStatus {
                case .denied, .notDetermined, .ephemeral:
                    self.addButton.isEnabled = false
                    DispatchQueue.main.async {
                        AlertsController.showNotificationAlert(controller: self)
                    }
                case .authorized, .provisional:
                    self.addButton.isEnabled = true
                    print("OK")
                @unknown default:
                    print("OK")
            }
        }
    }
    
    // Setup TableView delegate and datasource, populate alarms
    func configureTableView() {
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
        tableView.reloadData()
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
            // update core data model
            CoreDataController.shared.changeAlarmStatus(at: indexPath, status: enabled)
            // update notification based on enabled
            let alarmEntity = fetchedResultsController.object(at: indexPath)
            switch enabled {
                case true:
                    notifcationController.notificationFactory(entity: alarmEntity)
                case false:
                    notifcationController.cancelNotificationForEntity(entity: alarmEntity)
            }
        }
    }
}

//MARK: - SetAlarmViewControllerDelegate methods
extension AlarmsViewController: SetAlarmViewControllerDelegate {
    func setAlarmViewControllerDone(alarm: Alarm) {
        if let editingIndexPath = editingIndexPath {
            // alarm has been edited, update core data model 
            CoreDataController.shared.updateAlarmEntityFromAlarmObject(at: editingIndexPath, alarm: alarm)
            // get entity object
            let alarmEntity = fetchedResultsController.object(at: editingIndexPath)
            notifcationController.notificationFactory(entity: alarmEntity)
        }
        else {
            // new core data alarmEntity
            guard let alarmEntity = CoreDataController.shared.createAlarmEntityFromAlarmObject(alarm: alarm) else { return }
            // create notification
            notifcationController.notificationFactory(entity: alarmEntity)
        }
        editingIndexPath = nil
    }
    
    func setAlarmViewControllerCancel() {
        // cancel pressed, don't do anything
        editingIndexPath = nil
    }
}
