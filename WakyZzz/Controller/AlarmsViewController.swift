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
        notifcationController.requestNotificationAuthorization()
        notifcationController.setupActions()
        checkFirstRun()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureTableView()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        fetchedResultsController.delegate = nil
    }
    
    func checkFirstRun() {
        let launchedBefore = UserDefaults.standard.bool(forKey: "Launched Before")
        if !launchedBefore  {
            // First launch, set user defaults to true (Launched Before = true)
            UserDefaults.standard.set(true, forKey: "Launched Before")
            
            // set up alert text nicely aligned
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .left
            
            // show alert for setting up alarms
            let alert = UIAlertController(title: "Lets get started!", message: "message", preferredStyle: .alert)
            
            // reassign message using attributed text
            let messageText = NSAttributedString(
                string: "1. Add alarm (+ button).\n2. Set alarm time and days to repeat.\n3. No repeat = 1 time alarm.\n4. Switch turns alarm on/off.\n5. Click notification to turn off alarm",
                attributes: [
                    NSAttributedString.Key.paragraphStyle: paragraphStyle,
                    NSAttributedString.Key.foregroundColor : UIColor.black,
                    NSAttributedString.Key.font : UIFont.systemFont(ofSize: 13)
                ]
            )
            alert.setValue(messageText, forKey: "attributedMessage")
            
            // add alert
            alert.addAction(UIAlertAction(title: "Got it! 👍", style: .default, handler: nil))
            self.present(alert, animated: true)
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
