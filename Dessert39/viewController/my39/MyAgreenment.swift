//
//  MyAgreenment.swift
//  Dessert39
//
//  Created by YongSoo Choi on 2021/11/23.
//

import UIKit

class MyAgreenment: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NavigationThemeUtil.defaultShadowTheme(self.navigationController, selfView: self, title: "약관 및 정책")
        navigationController?.isNavigationBarHidden = false
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let segueVC = segue.destination as? AgreementCon {
            
            switch segue.identifier {
            case "agreenment1":
                segueVC.agreeMentTag = 0
            case "agreenment2":
                segueVC.agreeMentTag = 1
            case "agreenment3":
                segueVC.agreeMentTag = 2
            case "agreenment4":
                segueVC.agreeMentTag = 3
            case "agreenment5":
                segueVC.agreeMentTag = 4
            default:
                break
            }
            
        }
        
    }

}
