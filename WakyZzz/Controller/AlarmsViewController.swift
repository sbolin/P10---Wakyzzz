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
    
    //MARK: - Notification Properties
    let notifcationController = NotificationController() // manager
    let center = UNUserNotificationCenter.current()
    var alarmName = ""
    var subtitle = ""
    var body = ""

//    private var alarm = Alarm()
//    private var alarms = [Alarm]()
    
    private var editingIndexPath: IndexPath? // what is this???
    
    //MARK: Set up data store
    lazy var coreDataController = CoreDataController()
    var fetchedResultsController: NSFetchedResultsController<AlarmEntity>!
    

//MARK: - View Lifecylcle
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        fetchedResultsController.delegate = self
        center.delegate = self
//      tableView.dataSource = self
        notifcationController.requestNotificationAuthorization()
        notifcationController.setupActions()
        
//      self.navigationItem.leftBarButtonItem = self.editButtonItem
// for now, populate Alarms
//        if alarms.count == 0 {
//            populateAlarms()
//        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        checkFirstRun()
        configureTableView()
        populateAlarms()
    }
    
    func checkFirstRun() {
        let launchedBefore = UserDefaults.standard.bool(forKey: "Launched Before")
        if !launchedBefore  {
            // First launch, set user defaults to true (Launched Before = true)
            UserDefaults.standard.set(true, forKey: "Launched Before")
        }
        // add in first run for app overview?
    }
    
    // Setup TableView delegate and datasource, populate alarms
    func configureTableView() {
        print(#function)
        // setup fetchrequest
        if fetchedResultsController == nil {
            print("fetchResultsController is nil, set to fetchedAlarmResultsController")
            fetchedResultsController = CoreDataController.shared.fetchedAlarmResultsController
        }
        do {
            print("tryng to performFetch()")
            try fetchedResultsController.performFetch()
 //           tableView.reloadData()
        } catch (let error) {
            print("Fetch failed, error: \(error.localizedDescription)")
        }
    }
    
    
    //MARK: - Actions
    @IBAction func addButtonPress(_ sender: Any) {
        presentSetAlarmViewController(alarmEntity: nil) // (alarm: nil)
    }
}

extension AlarmsViewController: AlarmCellDelegate {
    // AlarmCellDelegate method
    func alarmCell(_ cell: AlarmTableViewCell, enabledChanged enabled: Bool) {
        if let indexPath = tableView.indexPath(for: cell) {
            coreDataController.changeAlarmStatus(at: indexPath, status: enabled)
//            if let alarm = self.alarm(at: indexPath) {
//               alarm.enabled = enabled
//            }
        }
    }
}

extension AlarmsViewController: SetAlarmViewControllerDelegate {
    // SetAlarmViewControllerDelegate methods
    func setAlarmViewControllerDone(alarm: Alarm) {
        if let editingIndexPath = editingIndexPath {
            print("Edited Alarm")
            tableView.reloadRows(at: [editingIndexPath], with: .automatic)
        }
        else {
            print("new Alarm added")
//            addAlarm(alarm, at: IndexPath(row: alarms.count, section: 0))
            let objectCount = fetchedResultsController.fetchedObjects?.count ?? 0
            addAlarm(alarm, at: IndexPath(row: objectCount, section: 0))
        }
        editingIndexPath = nil
    }
    
    func setAlarmViewControllerCancel() {
        editingIndexPath = nil
    }
}
