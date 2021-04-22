//
//  AlertsController.swift
//  WakyZzz
//
//  Created by Scott Bolin on 22-Apr-21.
//  Copyright © 2021 TukgaeSoft. All rights reserved.
//
/*
Thanks to Sean Allen for the great idea (part of Statics explaination)
https://www.youtube.com/watch?v=s2E5hVxQAZQ
*/

import UIKit

class AlertsController {
    
    static func showNotificationAlert(controller: UIViewController) {
        let alert = UIAlertController(title: "Notifications are off", message: "Please turn on notifications to use alarms", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
            print("OK tapped, \(action)")
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { action in
            print("Cancel tapped \(action)")
        }))
        
        controller.present(alert, animated: true)
    }
}
