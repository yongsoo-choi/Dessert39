//
//  FindIdResultVC.swift
//  Dessert39
//
//  Created by YongSoo Choi on 2021/10/18.
//

import UIKit

class FindIdResultVC: UIViewController {

    @IBOutlet weak var failView: UIView!
    @IBOutlet weak var successView: UIView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var idLabel: UILabel!
    @IBOutlet weak var btn_up: UIButton!
    @IBOutlet weak var btn_down: UIButton!
    
    var nameString: String = ""
    var idString: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NavigationThemeUtil.clearBackTheme(self.navigationController, selfView: self, title: "아이디 찾기")
        
        idString = store.id ?? ""
        nameString = store.name ?? ""
        
        setPage()
        setButton()
        
    }
    
    func setNavigation() {
        
        self.title = "아이디 찾기"
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont(name: "Pretendard-SemiBold", size: 24)!]
        
        let backImage = UIImage()
        navigationController?.navigationBar.backIndicatorImage = backImage
        navigationController?.navigationBar.backIndicatorTransitionMaskImage = backImage
        navigationItem.backButtonTitle = ""
        
    }
    
    func setPage() {
        
        failView.isHidden = true
        successView.isHidden = true
        
        if idString == "" {
            failView.isHidden = false
        } else {
            successView.isHidden = false
            
            nameLabel.text = "\(nameString)님의 아이디는"
            
            let attributedString = NSMutableAttributedString.init(string: "\(idString) 입니다.")
            attributedString.addAttribute(NSAttributedString.Key.underlineStyle, value: 1, range: NSRange.init(location: 0, length: idString.count))
            idLabel.attributedText = attributedString
    
        }
        
    }
    
    func setButton() {
        
        btn_up.layer.cornerRadius = btn_up.frame.height / 2
        btn_down.layer.cornerRadius = btn_down.frame.height / 2
        
        if idString == "" {
            
            UIView.setAnimationsEnabled(false)
            btn_up.setTitle("회원가입하기", for: .normal)
            btn_up.layoutIfNeeded()
            UIView.setAnimationsEnabled(true)
            
            UIView.setAnimationsEnabled(false)
            btn_down.setTitle("다시 입력하기", for: .normal)
            btn_down.layoutIfNeeded()
            UIView.setAnimationsEnabled(true)
            
        } else {
            
            UIView.setAnimationsEnabled(false)
            btn_up.setTitle("로그인 하기", for: .normal)
            btn_up.layoutIfNeeded()
            UIView.setAnimationsEnabled(true)
            
            UIView.setAnimationsEnabled(false)
            btn_down.setTitle("비밀번호 찾기", for: .normal)
            btn_down.layoutIfNeeded()
            UIView.setAnimationsEnabled(true)
            
        }
        
        btn_up.addTarget(self, action: #selector(upBtnHandler(sender:)), for: .touchUpInside)
        btn_down.addTarget(self, action: #selector(downBtnHandler(sender:)), for: .touchUpInside)
        
    }
    
    @objc func upBtnHandler(sender: UIButton) {
        
        if idString == "" {
            //회원가입하기
            store.isJoin = true
            self.navigationController?.popToRootViewController(animated: false)
        } else {
            //로그인하기
            self.navigationController?.popToRootViewController(animated: true)
        }
        
    }
    
    @objc func downBtnHandler(sender: UIButton) {
        
        if idString == "" {
            //다시입력하기
            self.navigationController?.popViewController(animated: true)
        } else {
            //비밀번호찾기
            store.isFindPw = true
            self.navigationController?.popToRootViewController(animated: false)
        }
        
    }

}
