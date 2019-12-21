//
//  Helpers.swift
//  Virtual boy
//
//  Created by Fish on 08/12/2019.
//  Copyright © 2019 Fish. All rights reserved.
//

import Foundation
import UIKit

func performOnMain(_ updates: @escaping () -> Void) {
       DispatchQueue.main.async {
           updates()
       }
   }

func displayALert(title: String, alert: String, sender: UIViewController ) {
   
    let alert = UIAlertController(title: title, message: alert, preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))

    sender.present(alert, animated: true)
}
