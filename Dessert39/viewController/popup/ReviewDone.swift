//
//  ReviewDone.swift
//  Dessert39
//
//  Created by YongSoo Choi on 2021/11/30.
//

import UIKit

class ReviewDone: UIViewController {

    @IBOutlet weak var warpView: UIView!
    @IBOutlet weak var titleView: UIView!
    @IBOutlet weak var btn_ok: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setting()
    }
    
    func setting() {
        
        warpView.layer.cornerRadius = 20
        titleView.clipsToBounds = true
        titleView.layer.cornerRadius = 20
        titleView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        
        btn_ok.layer.cornerRadius = btn_ok.frame.height / 2
        
    }
    
    @IBAction func okHandler(_ sender: UIButton) {
        
        if self.presentingViewController != nil {
            
            if let tvc = self.presentingViewController as? UITabBarController {
                if let nvc = tvc.selectedViewController as? UINavigationController {
                    if let pvc = nvc.topViewController {
                        self.dismiss(animated: false) {
                            pvc.navigationController?.popToRootViewController(animated: true)
                        }
                    }
                }
            }
            
        }
        
    }

}
