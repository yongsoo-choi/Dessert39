//
//  AutoChargingSetAlert.swift
//  Dessert39
//
//  Created by YongSoo Choi on 2021/11/02.
//

import UIKit

class AutoChargingSetAlert: UIViewController {
    
    @IBOutlet weak var warpView: UIView!
    @IBOutlet weak var titleView: UIView!
    @IBOutlet weak var label_standard: UILabel!
    @IBOutlet weak var label_money: UILabel!
    @IBOutlet weak var label_means: UILabel!
    
    @IBOutlet weak var btn_ok: UIButton!
    @IBOutlet weak var btn_cancel: UIButton!
    
    var strStandard: String?
    var strMoney: String?
    var strMeans: String?
    
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
        btn_cancel.layer.cornerRadius = 5
        btn_cancel.layer.borderWidth = 1
        btn_cancel.layer.borderColor = UIColorFromRGB.colorInit(1.0, rgbValue: 0x000000).cgColor
        
        label_standard.text = strStandard!
        label_money.text = strMoney!
        label_means.text = strMeans!
        
    }

    @IBAction func cancelHandler(_ sender: UIButton) {
        self.dismiss(animated: false, completion: nil)
    }
    
    @IBAction func okHandler(_ sender: UIButton) {
        
//        guard let pvc = self.presentingViewController else { return }

        self.dismiss(animated: false) {
//          pvc.present(SecondViewController(), animated: true, completion: nil)
        }
        
    }
}
