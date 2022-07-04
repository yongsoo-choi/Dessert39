//
//  AutoChargingCancelAlert.swift
//  Dessert39
//
//  Created by YongSoo Choi on 2021/11/03.
//

import UIKit

class AutoChargingCancelAlert: UIViewController {

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
        
        btn_ok.layer.cornerRadius = 5
        
    }
    
    @IBAction func okHandler(_ sender: UIButton) {
        self.dismiss(animated: false, completion: nil)
    }

}
