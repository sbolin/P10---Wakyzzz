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
    private let notifcationController = NotificationController() // manager
    private let center = UNUserNotificationCenter.current()
    private var alarmName = ""
    private var subtitle = ""
    private var body = ""

//    private var alarm = Alarm()
//    private var alarms = [Alarm]()
    
    private var editingIndexPath: IndexPath?
    
    //MARK: Set up data store
    lazy var coreDataController = CoreDataController()
    var fetchedResultsController: NSFetchedResultsController<AlarmEntity>!
    

//MARK: - View Lifecylcle
    override func viewDidLoad() {
        super.viewDidLoad()
//        self.navigationItem.leftBarButtonItem = self.editButtonItem
        configureTableView()
        self.center.delegate = self
        notifcationController.requestNotificationAuthorization()
        notifcationController.setupActions()
// for now, populate Alarms
//        if alarms.count == 0 {
//            populateAlarms()
//        }
        // for now, populate core data with alarms
        if fetchedResultsController.fetchedObjects == nil { // no alarms set
            populateAlarms()
        }
        scheduleAlarm(hour: 20, minute: 0, repeats: false, type: .snoozable)
        scheduleAlarm(hour: 20, minute: 0, repeats: false, type: .snoozable)
        scheduleAlarm(hour: 20, minute: 1, repeats: true, type: .nonSnoozable)
    }
    
    // Setup TableView delegate and datasource, populate alarms
    func configureTableView() {
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    // Temporary function to populate alarms with dummy data, will be removed after app works properly and user will set their own alarms
    func populateAlarms() {
// using core data
        let context = coreDataController.managedContext
        let weekDayAlarmID = UUID()
        coreDataController.createAlarmEntityWithID(id: weekDayAlarmID)
        guard let weekDayAlarmEntity = coreDataController.fetchAlarmByAlarmID(with: weekDayAlarmID) else { return }
        // Weekdays 5am
        weekDayAlarmEntity.time = 5 * 3600
        weekDayAlarmEntity.enabled = true
        for i in 1 ... 5 {
            weekDayAlarmEntity.repeatDays[i] = true
        }
        
        let weekEndAlarmID = UUID()
        coreDataController.createAlarmEntityWithID(id: weekEndAlarmID)
        guard let weekendAlarmEntity = coreDataController.fetchAlarmByAlarmID(with: weekEndAlarmID) else { return }
        weekendAlarmEntity.time = 9 * 3600
        weekendAlarmEntity.enabled = false
        weekendAlarmEntity.repeatDays[0] = true
        weekendAlarmEntity.repeatDays[6] = true

        coreDataController.saveContext(context: context)
    }
    
    func scheduleAlarm(hour: Int, minute: Int, repeats: Bool, type: NotificationType) {
        let date = Date() // use today's date for now...
        let calendar = Calendar.current
        let year = calendar.component(.year, from: date)
        let month = calendar.component(.month, from: date)
        let day = calendar.component(.day, from: date)
        let weekday = calendar.component(.weekday, from: date)
        var repeated: [Int] = [weekday]
        let dateComponents = DateComponents(calendar: .current, timeZone: .current, year: year, month: month, day: day, hour: hour, minute: minute, weekday: weekday)
        let snoozedTimes = 2 // TODO: get from CoreData
        let actOfKindness = ActOfKindness.allCases.randomElement()?.rawValue
        
        if repeats {
            repeated = [3, 5, 7] // Tues/Thur/Sat for example, final will use Core Data to populate
        }
        
        switch type {
            case .snoozable:
                alarmName = "Turn Alarm Off 🔕 or Snooze? 😴"
                subtitle = "Shut off or snooze for 1 minute"
                body = "Body of notification"
            case .snoozed:
                alarmName = "Turn Alarm Off 🔕 or Snooze? 😴"
                subtitle = "Shut off or snooze for 1 minute"
                body = "You have snoozed \(snoozedTimes) out of 3" // timesSn
            case .nonSnoozable:
                alarmName = "Act of Kindness Alert! ⚠️"
                subtitle = "You must perform an act of kindness to turn alarm off"
                body = "Random act of kindness: \(actOfKindness ?? "Smile today!")"
        }
        
        let notification = LocalNotification(
            id: UUID().uuidString,
            title: alarmName,
            subtitle: subtitle,
            body: body,
            repeating: repeats,
            repeatDays: repeated,
            dateComponents: dateComponents)

        notifcationController.createNotification(notification: notification, type: type)
    }
    
//    func alarm(at indexPath: IndexPath) -> Alarm? {
//        return indexPath.row < alarms.count ? alarms[indexPath.row] : nil
//    }
    
    func deleteAlarm(at indexPath: IndexPath) {
        tableView.beginUpdates()
        print("Deleting alarm at indexPath\(indexPath.row)")
//        alarms.remove(at: indexPath.row) // alarms.count
        coreDataController.deleteAlarmEntity(at: indexPath)
        tableView.deleteRows(at: [indexPath], with: .automatic)
        tableView.endUpdates()
    }
    
    func editAlarm(at indexPath: IndexPath) {
        editingIndexPath = indexPath // What does this do?
        let alarmEntity = fetchedResultsController.object(at: indexPath)
        presentSetAlarmViewController(alarmEntity: alarmEntity) // (alarm: alarm(at: indexPath))
    }
    
    func addAlarm(_ alarm: Alarm, at indexPath: IndexPath) {
        tableView.beginUpdates()
//        alarms.insert(alarm, at: indexPath.row)
        coreDataController.createAlarmEntity()
        tableView.insertRows(at: [indexPath], with: .automatic)
        tableView.endUpdates()
    }
    
    func presentSetAlarmViewController(alarmEntity: AlarmEntity?) { // change call site from (alarm: Alarm?)
        if let vc = storyboard?.instantiateViewController(withIdentifier: "SetAlarm") as? SetAlarmViewController {
            vc.alarmEntity = alarmEntity
            vc.delegate = self
            navigationController?.pushViewController(vc, animated: true)
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



// use for making pre-defined Notifications
/*
 
 
 if snoozedTimes == 0 {
 type = NotificationType.turnOff
 title = "Turn Alarm Off 🔕 or Snooze? 😴"
 subtitle = "Shut off or snooze for 1 minute"
 body = "Body of notification"
 } else {
 if snoozedTimes < 3 {
 type = NotificationType.alarmSnoozed
 title = "Turn Alarm Off 🔕 or Snooze? 😴"
 subtitle = "Shut off or snooze for 1 minute"
 body = "You have snoozed \(snoozedTimes) out of 3"
 } else {
 type = NotificationType.alarmSnoozedThreeTimes
 title = "Act of Kindness Alert! ⚠️"
 subtitle = "You must perform an act of kindness to turn alarm off"
 body = "Random act of kindness: \(actOfKindness)"
 }
 }
 
 */
