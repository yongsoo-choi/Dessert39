//
//  Card.swift
//  Dessert39
//
//  Created by YongSoo Choi on 2022/04/01.
//

import UIKit

class Card: UIViewController {

    @IBOutlet var grayView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        grayView.layer.cornerRadius = 10
        grayView.layer.borderColor = UIColorFromRGB.colorInit(1.0, rgbValue: 0xAEAEAE).cgColor
        grayView.layer.borderWidth = 1.0
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NavigationThemeUtil.defaultShadowTheme(self.navigationController, selfView: self, title: "결제카드 관리")
        navigationController?.isNavigationBarHidden = false
        
    }
    
    @IBAction func registAction(_ sender: Any) {
        
        //
        
    }
    
}
