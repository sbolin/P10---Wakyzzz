//
//  WakyZzzAlarmTests.swift
//  WakyZzzTests
//
//  Created by Scott Bolin on 22-Apr-21.
//  Copyright © 2021 TukgaeSoft. All rights reserved.
//

import XCTest
@testable import WakyZzz


class WakyZzzAlarmTests: XCTestCase {
    
    var alarm: Alarm!

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        alarm = Alarm()

    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    // test default Alarm object is created as expected, including computed props.
    func testAlarm() {
        
        // check Alarm created properly
        XCTAssertNotNil(alarm)
        XCTAssertTrue(alarm.time == 28_800)
        XCTAssertTrue(alarm.repeatDays == [false, false, false, false, false, false, false])
        XCTAssertTrue(alarm.enabled == true)
        XCTAssertTrue(alarm.snoozed == false)
        XCTAssertTrue(alarm.timesSnoozed == 0)
        XCTAssertTrue(alarm.localAlarmTimeString == "08:00")
        XCTAssertTrue(alarm.repeatingDayString == "One time alarm")

        
        // to test alarmTimeAndDate must create an alarm at set time, then check time components of alarm are correct 
        let date = Date().addingTimeInterval(60) // create known date object
        let calendar = Calendar.current
        //
        let day = calendar.component(.day, from: date)
        //
        let hour = calendar.component(.hour, from: date)
        let minute = calendar.component(.minute, from: date)
        let weekday = calendar.component(.weekday, from: date)
        let alarmTimeInSeconds = (hour * 60 + minute) * 60 // hours to minutes, add minutes, convert overall to seconds
        alarm.setAlarmTime(date: date)

        // must test below with a known time
        // unwrap optional alarm.alarmTimeAndDate
        guard let alarmTimeAndDate = alarm.alarmTimeAndDate else {
            XCTFail()
            return
        }
        
        let testDay = calendar.component(.day, from: alarmTimeAndDate)
        let testHour = calendar.component(.hour, from: alarmTimeAndDate)
        let testMinute = calendar.component(.minute, from: alarmTimeAndDate)
        let testWeekDay = calendar.component(.weekday, from: alarmTimeAndDate)

        // test newly created alarm time and alarmTimeAndDate function
        XCTAssertTrue(alarm.time == alarmTimeInSeconds)
        XCTAssertTrue(testDay == day)
        XCTAssertTrue(testHour == hour)
        XCTAssertTrue(testMinute == minute)
        XCTAssertTrue(testWeekDay == weekday)
        
        // test note: below fails, though day, hour, minute, weekday (above) all pass
//        XCTAssertTrue(alarmTimeAndDate == date) 
    }
}
