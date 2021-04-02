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

    var delegate: SetAlarmViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        config()
    }
    
    func config() {
        // uses alarmEntity
        if alarm == nil {
            navigationItem.title = "New Alarm"
            // initially show 8am on datepicker
            var components = DateComponents()
            components.hour = 8
            components.minute = 0
            let date = Calendar.current.date(from: components) ?? Date()
            datePicker.date = date
            
            alarm = Alarm()
        }
        else {
            navigationItem.title = "Edit Alarm"
        }
        
        tableView.delegate = self
        tableView.dataSource = self
        
        datePicker.date = (alarm?.alarmTimeAndDate)!
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Alarm.daysOfWeek.count
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
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        alarm?.repeatDays[indexPath.row] = false
        tableView.cellForRow(at: indexPath)?.accessoryType = (alarm?.repeatDays[indexPath.row])! ? .checkmark : .none
    }
    
    @IBAction func cancelButtonPress(_ sender: Any) {
        delegate?.setAlarmViewControllerCancel() //
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func doneButtonPress(_ sender: Any) {
        delegate?.setAlarmViewControllerDone(alarm: alarm!)
        navigationController?.popViewController(animated: true)
    }
    @IBAction func datePickerValueChanged(_ sender: Any) {
        alarm?.setAlarmTime(date: datePicker.date)
    }
    
}
