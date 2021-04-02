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
    
    //MARK: - Notification Properties
    let notifcationController = NotificationController() // manager
    let center = UNUserNotificationCenter.current()
    var alarmName = ""
    var subtitle = ""
    var body = ""

//    private var alarm = Alarm()
//    private var alarms = [Alarm]()
    
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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if CoreDataController.shared.modelIsEmpty {
            print(#function)
            print("Model empty? \(CoreDataController.shared.modelIsEmpty)")
            populateAlarms()
        }
    }
    
    func checkFirstRun() {
        let launchedBefore = UserDefaults.standard.bool(forKey: "Launched Before")
        if !launchedBefore  {
            // First launch, set user defaults to true (Launched Before = true)
            UserDefaults.standard.set(true, forKey: "Launched Before")
            
            // show alert for setting up alarms
            let alert = UIAlertController(title: "Lets get started!", message: "1. Add alarm (+ button).\n2. Set alarm time and days to repeat.\n3. Alarm goes off once if no repeated days.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Got it! 👍", style: .default, handler: nil))
            self.present(alert, animated: true)
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
 //           tableView.reloadData()
        } catch (let error) {
            print("Fetch failed, error: \(error.localizedDescription)")
        }
 //       tableView.reloadData()
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
            CoreDataController.shared.changeAlarmStatus(at: indexPath, status: enabled)
//            if let alarm = self.alarm(at: indexPath) {
//               alarm.enabled = enabled
//            }
        }
    }
}
