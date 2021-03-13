//
//  SetAlarmViewController.swift
//  WakyZzz
//
//  Created by Olga Volkova on 2018-05-30.
//  Copyright © 2018 Olga Volkova OC. All rights reserved.
//

import Foundation
import UIKit

protocol SetAlarmViewControllerDelegate {
    func setAlarmViewControllerDone(alarm: Alarm)
    func setAlarmViewControllerCancel()
}

class SetAlarmViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var tableView: UITableView!
    var alarm: Alarm?
    var alarmEntity: AlarmEntity?
    lazy var coreDataController = CoreDataController()

    var delegate: SetAlarmViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        config()
    }
    
    func config() {
        if alarmEntity == nil {
            navigationItem.title = "New Alarm"
            coreDataController.createAlarmEntity()
        }
        else {
            navigationItem.title = "Edit Alarm"
        }
//        if alarm == nil {
//            navigationItem.title = "New Alarm"
//            alarm = Alarm()
//        }
//        else {
//            navigationItem.title = "Edit Alarm"
//        }
        
        tableView.delegate = self
        tableView.dataSource = self
        
        // initially show 8am on datepicker
        var components = DateComponents()
        components.hour = 8
        components.minute = 0
        let date = Calendar.current.date(from: components) ?? Date()
        datePicker.date = date
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Alarm.daysOfWeek.count // Alarm.daysOfWeek.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DayOfWeekCell", for: indexPath)
        cell.textLabel?.text = Alarm.daysOfWeek[indexPath.row]
        cell.accessoryType = (alarm?.repeatDays[indexPath.row])! ? .checkmark : .none
        if (alarm?.repeatDays[indexPath.row])! {
            tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Repeat on following weekdays"
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        alarm?.repeatDays[indexPath.row] = true
        tableView.cellForRow(at: indexPath)?.accessoryType = (alarm?.repeatDays[indexPath.row])! ? .checkmark : .none
        print("didSelectRowAt: \(String(describing: alarm?.repeatDays))")
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        alarm?.repeatDays[indexPath.row] = false
        tableView.cellForRow(at: indexPath)?.accessoryType = (alarm?.repeatDays[indexPath.row])! ? .checkmark : .none
        print("didDeselectRowAt: \(String(describing: alarm?.repeatDays))")
    }
    
    @IBAction func cancelButtonPress(_ sender: Any) {
        delegate?.setAlarmViewControllerCancel() //
        presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func doneButtonPress(_ sender: Any) {
        delegate?.setAlarmViewControllerDone(alarm: alarm!)
        presentingViewController?.dismiss(animated: true, completion: nil)
    }
    @IBAction func datePickerValueChanged(_ sender: Any) {
        alarm?.setAlarmTime(date: datePicker.date)
    }
    
}
