//
//  FindPasswordVC.swift
//  Dessert39
//
//  Created by YongSoo Choi on 2021/10/19.
//

import UIKit

class FindPasswordVC: UIViewController {

    @IBOutlet weak var btn_auth: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NavigationThemeUtil.defaultTheme(self.navigationController, selfView: self, title: "비밀번호 찾기")
        
        setButton()
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let segueVC = segue.destination as? PersonalAuthVC {
            if segue.identifier == "authFromFindPw"{
                segueVC.parentView = "fromFindPw"
            }
        }
        
    }
    
    func setButton() {
        
        btn_auth.layer.cornerRadius = btn_auth.frame.height / 2
        
    }

}
