//
//  ActivityView.swift
//  Dessert39
//
//  Created by YongSoo Choi on 2022/01/11.
//

import Foundation
import UIKit

class ActivityView {
    
    func copy(_ selfView: UIViewController) {
        
        let activityViewController = UIActivityViewController(activityItems: [store.storeAddress], applicationActivities: nil)
        selfView.present(activityViewController, animated: true, completion: nil)
        
    }
    
}
