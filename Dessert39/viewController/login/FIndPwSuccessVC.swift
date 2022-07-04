//
//  FIndPwSuccessVC.swift
//  Dessert39
//
//  Created by YongSoo Choi on 2021/10/22.
//

import UIKit

class FIndPwSuccessVC: UIViewController {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet var btn: UIButton!{
        didSet{
            btn.layer.cornerRadius = btn.frame.height / 2
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NavigationThemeUtil.clearBackTheme(self.navigationController, selfView: self, title: "회원가입 완료")
        
    }
    
    @IBAction func goLoginHandler(_ sender: Any) {
        
        self.navigationController?.popToRootViewController(animated: true)
        
    }
    
}
