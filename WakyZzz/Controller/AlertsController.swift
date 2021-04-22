//
//  AlertsController.swift
//  WakyZzz
//
//  Created by Scott Bolin on 22-Apr-21.
//  Copyright © 2021 TukgaeSoft. All rights reserved.
//

import UIKit

class AlertsController {
    
    static func showSetupAlert(controller: UIViewController) {
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
        DispatchQueue.main.async {
            controller.present(alert, animated: true)
        }
    }
    
    static func showNotificationAlert(controller: UIViewController) {
        let alert = UIAlertController(title: "Notifications are off", message: "Please turn on notifications in System Settings to use alarms", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
            print("OK tapped, \(action)")
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { action in
            print("Cancel tapped \(action)")
        }))
        
        DispatchQueue.main.async {
            controller.present(alert, animated: true)
        }
    }
}
