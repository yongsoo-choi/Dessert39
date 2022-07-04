//
//  AlertUtil.swift
//  Dessert39
//
//  Created by YongSoo Choi on 2021/10/18.
//

import Foundation
import UIKit

class AlertUtil {
    
    func oneItem(_ selfView: UIViewController, title: String, message: String) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default) { (action) in
                    //
            }
        
        alert.addAction(okAction)
        
        selfView.present(alert, animated: true, completion: nil)
    }
    
}
