//
//  OrderFinish.swift
//  Dessert39
//
//  Created by YongSoo Choi on 2022/01/12.
//

import UIKit

class OrderFinish: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NavigationThemeUtil.clearBackTheme(self.navigationController, selfView: self, title: "주문하기")
        
        let settingItem = UIBarButtonItem(image: UIImage(named: "close"), style: .done, target: self, action: #selector(setClose(sender:)))
        settingItem.tintColor = UIColorFromRGB.colorInit(1.0, rgbValue: 0x202020)
        self.navigationItem.rightBarButtonItem = settingItem
        
    }
    
    @objc func setClose(sender: UIBarButtonItem) {
        self.navigationController?.popToRootViewController(animated: true)
    }

}
