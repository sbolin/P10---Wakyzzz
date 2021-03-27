//
//  SetAlarmViewController.swift
//  WakyZzz
//
//  Created by Olga Volkova on 2018-05-30.
//  Copyright © 2018 Olga Volkova OC. All rights reserved.
//

//TODO: !!! currently mess of alarm and alarmEntity useage. Must fix this!!!
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
//    lazy var coreDataController = CoreDataController()

    var delegate: SetAlarmViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        config()
    }
    
    func config() {
        // uses alarmEntity
        if alarmEntity == nil {
            navigationItem.title = "New Alarm"
            // initially show 8am on datepicker
            var components = DateComponents()
            components.hour = 8
            components.minute = 0
            let date = Calendar.current.date(from: components) ?? Date()
            datePicker.date = date
        }
        else {
            navigationItem.title = "Edit Alarm"
            // get time from alarmEntity
            var components = DateComponents()
            let time = Int(alarmEntity!.time) // force unwrap alarmEntity is ok, just checked above if nil or not.
            
            let hour = time / 3600
            let minute = time / 60 - hour * 60
            components.hour = hour
            components.minute = minute
            let date = Calendar.current.date(from: components) ?? Date()
           
            // assign datePicker date to match alarmEntity date
            datePicker.date = date
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
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return Alarm.daysOfWeek.count
        return AlarmEntity.daysOfWeek.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DayOfWeekCell", for: indexPath)
//        cell.textLabel?.text = alarm?.daysOfWeek[indexPath.row]
        cell.textLabel?.text = AlarmEntity.daysOfWeek[indexPath.row]
//        cell.accessoryType = (alarm?.repeatDays[indexPath.row])! ? .checkmark : .none
        cell.accessoryType = (alarmEntity?.repeatDays[indexPath.row])! ? .checkmark : .none
        
//        if (alarm?.repeatDays[indexPath.row])! {
        if (alarmEntity?.repeatDays[indexPath.row])! {
            tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Repeat on following weekdays"
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        alarmEntity?.repeatDays[indexPath.row] = true
        tableView.cellForRow(at: indexPath)?.accessoryType = (alarmEntity?.repeatDays[indexPath.row])! ? .checkmark : .none
        print("didSelectRowAt: \(String(describing: alarmEntity?.repeatDays))")
        
        //        alarm?.repeatDays[indexPath.row] = true
//        tableView.cellForRow(at: indexPath)?.accessoryType = (alarm?.repeatDays[indexPath.row])! ? .checkmark : .none
//        print("didSelectRowAt: \(String(describing: alarm?.repeatDays))")
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        alarmEntity?.repeatDays[indexPath.row] = false
        tableView.cellForRow(at: indexPath)?.accessoryType = (alarmEntity?.repeatDays[indexPath.row])! ? .checkmark : .none
        print("didDeselectRowAt: \(String(describing: alarmEntity?.repeatDays))")
//        alarm?.repeatDays[indexPath.row] = false
//        tableView.cellForRow(at: indexPath)?.accessoryType = (alarm?.repeatDays[indexPath.row])! ? .checkmark : .none
//        print("didDeselectRowAt: \(String(describing: alarm?.repeatDays))")
    }
    
    @IBAction func cancelButtonPress(_ sender: Any) {
        delegate?.setAlarmViewControllerCancel() //
        presentingViewController?.dismiss(animated: true, completion: nil)
        // all changes made need to be disgarded
    }
    
    @IBAction func doneButtonPress(_ sender: Any) {
        delegate?.setAlarmViewControllerDone(alarm: alarm!)
        // need to save changes to core data
        presentingViewController?.dismiss(animated: true, completion: nil)
    }
    @IBAction func datePickerValueChanged(_ sender: Any) {
        alarm?.setAlarmTime(date: datePicker.date)
        // need to update below method, since IndexPath is not correct. Should update based on alarmEntity.id instead.
        CoreDataController.shared.changeAlarmTime(at: IndexPath(row: 0, section: 0), date: datePicker.date)
    }
    
}
