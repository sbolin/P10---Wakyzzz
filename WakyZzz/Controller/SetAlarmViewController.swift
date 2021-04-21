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
    
    //MARK: - IBOutlets
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var tableView: UITableView!
    
    //MARK: - Properties and delegates
    var alarm: Alarm? // pass in alarm object for editing
    var delegate: SetAlarmViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        config()
    }
    
    func config() {
        if alarm == nil {
            navigationItem.title = "New Alarm"
            // show 8am on datePicker if new...
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
        
        // otherwise set datePicker time to alarm time
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
        return "Repeat on following days:"
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        alarm?.repeatDays[indexPath.row] = true
        tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        alarm?.repeatDays[indexPath.row] = false
        tableView.cellForRow(at: indexPath)?.accessoryType = .none
    }
    
    @IBAction func cancelButtonPress(_ sender: Any) {
        delegate?.setAlarmViewControllerCancel() //
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func doneButtonPress(_ sender: Any) {
        // send back alarm object to process/display in AlarmsViewController
        // note: new/edited alarm is handled in AlarmsViewController
        navigationController?.popViewController(animated: true)
        delegate?.setAlarmViewControllerDone(alarm: alarm!)
    }
    
    @IBAction func datePickerValueChanged(_ sender: Any) {
        alarm?.setAlarmTime(date: datePicker.date)
    }
    
}
