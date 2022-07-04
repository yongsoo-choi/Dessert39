//
//  JoinAlreadyVC.swift
//  Dessert39
//
//  Created by YongSoo Choi on 2021/10/22.
//

import UIKit

class JoinAlreadyVC: UIViewController {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var idLabel: UILabel!
    @IBOutlet var regLabel: UILabel!
    @IBOutlet weak var btn_login: UIButton!
    @IBOutlet weak var btn_findPw: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NavigationThemeUtil.clearBackTheme(self.navigationController, selfView: self, title: "회원가입")
        
        btn_login.layer.cornerRadius = btn_login.frame.height / 2
        btn_findPw.layer.cornerRadius = btn_findPw.frame.height / 2
        
        nameLabel.text = store.name
        idLabel.text = store.id
        
        if store.regPart == "K" {
            regLabel.text = "kakao"
        } else if store.regPart == "N" {
            regLabel.text = "naver"
        } else if store.regPart == "A" {
            regLabel.text = "apple"
        } else {
            regLabel.text = "dessert39 회원가입"
        }
        
    }

    @IBAction func loginHandler(_ sender: Any) {
        
        self.navigationController?.popToRootViewController(animated: true)
        
    }
    
    @IBAction func findPwHandler(_ sender: Any) {
        
        store.isFindPw = true
        self.navigationController?.popToRootViewController(animated: true)
        
    }
}
