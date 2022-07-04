//
//  Switcher.swift
//  Dessert39
//
//  Created by YongSoo Choi on 2021/10/05.
//

import Foundation
import UIKit

class Switcher {
    
    static func updateRootVC(){
        
//        let defaults = UserDefaults.standard
//        let dictionary = defaults.dictionaryRepresentation()
//        dictionary.keys.forEach { key in
//            defaults.removeObject(forKey: key)
//        }
        
//        UserDefaults.standard.removeObject(forKey: "loginToken")
//        UserDefaults.standard.removeObject(forKey: "isFirst")
        var rootVC : UIViewController?
        if UserDefaults.standard.string(forKey: "loginToken") != nil {
            
            rootVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "TabBarVC") as! TabBarViewController
            
        } else {
            
            let vc = UIStoryboard(name: "Login", bundle: nil).instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
            let navigationController = UINavigationController(rootViewController: vc)
            
            rootVC = navigationController
            
        }
        
        if #available(iOS 13.0, *) {
            let sceneDelegate = UIApplication.shared.connectedScenes.first!.delegate as! SceneDelegate
            sceneDelegate.window!.rootViewController = rootVC
            sceneDelegate.window?.makeKeyAndVisible()

        } else {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.window!.rootViewController = rootVC
            appDelegate.window?.makeKeyAndVisible()
        }
        
    }
    
}
